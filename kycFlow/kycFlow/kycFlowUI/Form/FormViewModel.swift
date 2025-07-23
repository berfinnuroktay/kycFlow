import SwiftUI
import Combine

@MainActor
final class FormViewModel: ObservableObject {

    let countryConfig: KycCountryInfo

    @Published var fieldViewModels: [FormFieldItemViewModel] = []
    @Published var submissionResult: String? = nil
    @Published var isSubmissionResultPresented: Bool = false
    @Published var isSubmitEnabled: Bool = false
    @Published var isLoading: Bool = true

    private let fetcherFactory: UserProfileFetcherFactory
    private var cancellables = Set<AnyCancellable>()

    init(countryConfig: KycCountryInfo, fetcherFactory: UserProfileFetcherFactory) {
        self.countryConfig = countryConfig
        self.fetcherFactory = fetcherFactory
        self.fieldViewModels = countryConfig.fields.map { FormFieldItemViewModel(field: $0) }

        observeFieldChanges()
        handleSpecialCases()
    }

    func onTapSubmitButton() {
        self.validateAndSubmit()
    }

    func onTapAlertCancel() {
        self.submissionResult = nil
        self.isSubmissionResultPresented = false
    }

}

// MARK: - Form related helpers
private extension FormViewModel {

    /// Coordinates the validation of all fields and submits the data if valid.
    func validateAndSubmit() {

        // Use map to call validate on each itemVM's and check they satisfy
        let isFormValid = fieldViewModels.map { $0.validate() }.allSatisfy { $0 }

        if isFormValid {
            submitData()
        }
    }

    func submitData() {
        defer {
            isSubmissionResultPresented = true
        }

        let formData = fieldViewModels.reduce(into: [String: String]()) { result, fieldVM in
            result[fieldVM.id] = fieldVM.value
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(formData)
            self.submissionResult = String(data: jsonData, encoding: .utf8)
        } catch {
            self.submissionResult = "Error: Could not encode data."
        }
    }

    func observeFieldChanges() {

        // Publisher that fires whenever any of the field's value change
        let allValuesPublisher = Publishers.MergeMany(
            fieldViewModels.map { $0.$value }
        )

        // For each change, reevaluate form's validity
        allValuesPublisher
            .map { [weak self] _ -> Bool in
                guard let self = self else { return false }
                // Every field is not required or value is not empty
                return self.fieldViewModels
                    .map { self.checkFieldIsValidForSubmission(viewModel: $0)  }
                    .allSatisfy { $0 }
            }
            .assign(to: \.isSubmitEnabled, on: self)
            .store(in: &cancellables)
    }

    func checkFieldIsValidForSubmission(viewModel: FormFieldItemViewModel) -> Bool {

        let notRequired = !viewModel.isRequired
        let notEmpty = !viewModel.value.trimmingCharacters(in: .whitespaces).isEmpty
        return notRequired || notEmpty
    }
}

// MARK: - Network related helpers
private extension FormViewModel {

    func handleSpecialCases() {
        // Check if there is a fetcher
        if let fetcher = fetcherFactory.makeFetcher(for: countryConfig.country) {
            Task {
                await fetchPrefilledData(using: fetcher)
            }
        } else {
            self.isLoading = false
        }
    }

    func fetchPrefilledData(using fetcher: UserProfileFetcher) async {

        defer {
            self.isLoading = false
        }

        if let result = await fetcher.fetchUserProfile() {
            for fieldVM in fieldViewModels {
                // Check if the field exists in result
                if let fieldValue = result[fieldVM.id] {
                    fieldVM.value = fieldValue
                    fieldVM.isReadOnly = true
                } else {
                    fieldVM.isReadOnly = false
                }
            }
        }
    }
}
