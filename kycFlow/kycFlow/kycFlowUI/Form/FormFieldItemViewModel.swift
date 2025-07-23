import SwiftUI

@MainActor
final class FormFieldItemViewModel: ObservableObject, Identifiable {

    // MARK: - Properties
    let id: String
    let label: String
    let type: ConfigFieldType
    let isRequired: Bool
    private let validationRules: FieldValidation?

    @Published var value: String = ""
    @Published var validationError: String? = nil
    @Published var isReadOnly: Bool = false

    var shouldShowError: Bool {
        validationError != nil
    }

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

    func validate() -> Bool {
        // Always start by clearing any previous validation error.
        validationError = nil
        let trimmedValue = value.trimmingCharacters(in: .whitespaces)

        // The main validation function now reads like a clear checklist.
        guard
            validateRequired(value: trimmedValue),
            validateLength(value: trimmedValue),
            validateValue(value: trimmedValue),
            validateRegex(value: trimmedValue)
        else {
            return false
        }

        return true
    }
}

private extension FormFieldItemViewModel {

    func validateRequired(value: String) -> Bool {
        if isRequired && value.isEmpty {
            validationError = "This field is required."
            return false
        }
        return true
    }

    func validateLength(value: String) -> Bool {
        // Skip if the value is empty, it is handled in validateRequired
        guard !value.isEmpty else { return true }

        if let minLength = validationRules?.minLength, value.count < minLength {
            validationError = validationRules?.message ?? "Must be at least \(minLength) characters."
            return false
        }
        if let maxLength = validationRules?.maxLength, value.count > maxLength {
            validationError = validationRules?.message ?? "Cannot exceed \(maxLength) characters."
            return false
        }
        return true
    }

    func validateValue(value: String) -> Bool {
        // Skip if the value is empty or not a number
        guard !value.isEmpty, let numberValue = Int(value) else { return true }

        if let minValue = validationRules?.minValue, numberValue < minValue {
            validationError = validationRules?.message ?? "Value must be at least \(minValue)."
            return false
        }
        if let maxValue = validationRules?.maxValue, numberValue > maxValue {
            validationError = validationRules?.message ?? "Value cannot exceed \(maxValue)."
            return false
        }
        return true
    }

    private func validateRegex(value: String) -> Bool {
        // Skip if the value is empty or there's no regex
        guard !value.isEmpty, let regexPattern = validationRules?.regex else { return true }

        let predicate = NSPredicate(format: "SELF MATCHES %@", regexPattern)
        if !predicate.evaluate(with: value) {
            validationError = validationRules?.message ?? "Invalid format."
            return false
        }
        return true
    }
}
