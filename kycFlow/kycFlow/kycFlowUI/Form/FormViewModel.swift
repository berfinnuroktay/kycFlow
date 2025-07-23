import SwiftUI

@MainActor
final class FormViewModel: ObservableObject {

    let countryConfig: KycCountryInfo

    @Published var fieldViewModels: [FormFieldItemViewModel] = []
    @Published var submissionResult: String? = nil
    @Published var isSubmissionResultPresented: Bool = false

    init(countryConfig: KycCountryInfo) {
        self.countryConfig = countryConfig
        self.fieldViewModels = countryConfig.fields.map { FormFieldItemViewModel(field: $0) }
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
}
