import Foundation

/// A factory responsible for creating the correct UserProfileFetcher for a country code
struct UserProfileFetcherFactory {

    /// Creates a fetcher if the country has a special data source
    func makeFetcher(for countryCode: String) -> UserProfileFetcher? {
        switch countryCode {
        case "NL":
            return MockNLProfileFetcher()
        default:
            return nil
        }
    }
}
