import Foundation

protocol UserProfileFetcher {
    func fetchUserProfile() async -> [String: String]?
}

struct MockNLProfileFetcher: UserProfileFetcher {
    func fetchUserProfile() async -> [String: String]? {
        // 1 second network deloy for simulation
        try? await Task.sleep(for: .seconds(1))

        return [
            "first_name": "Alex",
            "last_name": "Visser",
            "birth_date": "15/08/1990"
        ]
    }
}
