import Foundation
import SwiftUI

/// Handles config JSON files related to countries.
@MainActor
final class ConfigurationManager: ObservableObject {

    @Published var countryList: [CountryInfo] = []
    private let decoder: DataDecoder

    init(decoder: DataDecoder = JSONDataDecoder()) {
        self.decoder = decoder
        loadCountryList()
    }

    func loadCountryConfiguration(for countryCode: String) -> KycCountryInfo? {

        guard let countryInfo = countryList.first(where: { $0.id == countryCode }) else {
            return nil
        }

        guard let countryData = loadData(from: countryInfo.configFile) else {
            return nil
        }

        do {
            return try decoder.decode(from: countryData)
        } catch {
            print("=== Error: Failed to decode config file \(countryInfo.configFile): \(error)")
            return nil
        }
    }

    private func loadCountryList() {

        guard let countryListData = loadData(from: "Manifest.json") else { return }

        do {
            self.countryList = try decoder.decode(from: countryListData)
        } catch {
            print("=== Error: Failed to decode the initial country list \(error)")
            self.countryList = []
        }
    }
}
