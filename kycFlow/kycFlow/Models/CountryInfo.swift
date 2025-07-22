import Foundation

// A country entry in the manifest file.
struct CountryInfo: Decodable, Identifiable {

    let id: String
    let name: String
    let configFile: String

    // For mapping country code to id correctly
    enum CodingKeys: String, CodingKey {
        case id = "code"
        case name, configFile
    }
}
