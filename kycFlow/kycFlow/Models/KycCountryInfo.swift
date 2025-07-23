import Foundation
import SwiftUI

// Full kyc config for a country
struct KycCountryInfo: Decodable, Hashable {

    let country: String
    let fields: [ConfigField]
}

// Config field representation
struct ConfigField: Decodable, Identifiable, Hashable {

    let id: String
    let label: String
    let type: ConfigFieldType
    let required: Bool
    let validation: FieldValidation?
}

// Validation information for a given field
struct FieldValidation: Decodable, Hashable {

    let regex: String?
    let message: String?
}

// Enum for different field types
enum ConfigFieldType: String, Decodable {
    case text, date, number

    var keyboardType: UIKeyboardType {
        switch self {
        case .text:
                .default
        case .date:
                .default
        case .number:
                .decimalPad
        }
    }
}
