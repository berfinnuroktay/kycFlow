import SwiftUI
import Combine

@MainActor
final class FormViewModel: ObservableObject {

    let countryConfig: KycCountryInfo

    @Published var fieldViewModels: [FormFieldItemViewModel] = []
    @Published var submissionResult: String? = nil
    @Published var isSubmissionResultPresented: Bool = false
    @Published var isSubmitEnabled: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(countryConfig: KycCountryInfo) {
        self.countryConfig = countryConfig
        self.fieldViewModels = countryConfig.fields.map { FormFieldItemViewModel(field: $0) }

        observeFieldChanges()
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

    private func observeFieldChanges() {
        // Create a publisher that fires whenever ANY of the field's `$value` publishers change.
        let allValuesPublisher = Publishers.MergeMany(
            fieldViewModels.map { $0.$value }
        )

        allValuesPublisher
        // For each change, re-evaluate the entire form's validity.
            .map { [weak self] _ -> Bool in
                // The form is valid if every field satisfies the condition:
                // It's NOT required OR its value is NOT empty.
                self?.fieldViewModels.allSatisfy { vm in
                    !vm.isRequired || !vm.value.trimmingCharacters(in: .whitespaces).isEmpty
                } ?? false
            }
        // Assign the boolean result directly to our @Published property.
            .assign(to: \.isSubmitEnabled, on: self)
            .store(in: &cancellables)
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
