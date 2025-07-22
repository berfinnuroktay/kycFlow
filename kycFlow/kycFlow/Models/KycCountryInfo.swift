import Foundation

// Full kyc config for a country
struct KycCountryInfo: Decodable {

    let country: String
    let fields: [ConfigField]
}

// Config field representation
struct ConfigField: Decodable, Identifiable {

    let id: String
    let label: String
    let type: ConfigFieldType
    let required: Bool
    let validation: FieldValidation?
}

// Validation information for a given field
struct FieldValidation: Decodable {

    let regex: String?
    let message: String?
}

// Enum for different field types
enum ConfigFieldType: String, Decodable {
    case text, date
}
