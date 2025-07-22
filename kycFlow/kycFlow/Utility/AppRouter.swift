import SwiftUI

@MainActor
final class AppRouter: ObservableObject {

    @Published var path: [Destination] = []
}

enum Destination: Hashable {
    case countryForm(countryConfig: KycCountryInfo)
}
