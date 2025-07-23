import SwiftUI

@MainActor
final class FormFieldItemViewModel: ObservableObject, Identifiable {

    // Configuration
    let id: String
    let label: String
    let type: ConfigFieldType
    let isRequired: Bool
    private let validationRules: FieldValidation?

    // Live State
    @Published var value: String = "" // TODO: Could be date, may need fix later
    @Published var validationError: String? = nil
    @Published var isReadOnly: Bool = false
    let formatter = DateFormatter()

    init(field: ConfigField) {
        self.id = field.id
        self.label = field.label
        self.type = field.type
        self.validationRules = field.validation
        self.isRequired = field.required

        if type == .date {
            self.formatter.dateFormat = "dd/MM/yyyy"
            self.value = formatter.string(from: Date())
        }
    }

    /// Validates the field's current value against its rules.
    /// - Returns: `true` if the field is valid, `false` otherwise.
    func validate() -> Bool {
        // Clear previous error
        validationError = nil

        let trimmedValue = value.trimmingCharacters(in: .whitespaces)

        // 1. Check for required fields
        if isRequired && trimmedValue.isEmpty {
            validationError = "This field is required."
            return false
        }

        // An empty, non-required field is always valid.
        if !isRequired && trimmedValue.isEmpty {
            return true
        }

        // 2. Check regex validation
        if let regexPattern = validationRules?.regex {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regexPattern)
            if !predicate.evaluate(with: trimmedValue) {
                validationError = validationRules?.message ?? "Invalid format."
                return false
            }
        }

        // All checks passed.
        return true
    }
}
