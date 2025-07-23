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

        allValuesPublisher
        // For each change, reevaluate form's validity
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

    private func handleSpecialCases() {
           // Ask the factory if there's a special fetcher for this country.
           if let fetcher = fetcherFactory.makeFetcher(for: countryConfig.country) {
               Task {
                   await fetchPrefilledData(using: fetcher)
               }
           } else {
               self.isLoading = false
           }
       }

    /// Fetches data and updates the relevant fields to be read-only.
        private func fetchPrefilledData(using fetcher: UserProfileFetcher) async {

            defer {
                self.isLoading = false
            }
            // Temporarily disable all fields to indicate a loading state.
            fieldViewModels.forEach { $0.isReadOnly = true }

            if let prefilledData = await fetcher.fetchUserProfile() {
                // Loop through all our form fields.
                for fieldVM in fieldViewModels {
                    // Check if the fetched data contains a value for this field's ID.
                    if let prefilledValue = prefilledData[fieldVM.id] {
                        // If it does, update the value and keep it read-only.
                        fieldVM.value = prefilledValue
                        fieldVM.isReadOnly = true
                    } else {
                        // If not, make sure the field is editable.
                        fieldVM.isReadOnly = false
                    }
                }
            } else {
                // If the fetch fails for any reason, make all fields editable again.
                fieldViewModels.forEach { $0.isReadOnly = false }
            }
        }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: @retroactive UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}
