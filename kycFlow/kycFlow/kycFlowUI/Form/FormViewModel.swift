import SwiftUI

@MainActor
final class FormViewModel: ObservableObject {

    let countryConfig: KycCountryInfo

    init(countryConfig: KycCountryInfo) {
        self.countryConfig = countryConfig
    }

}
