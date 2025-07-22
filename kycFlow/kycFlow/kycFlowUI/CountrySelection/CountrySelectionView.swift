import SwiftUI

/// Country selection screen which displays a custom picker for selecting the country
struct CountrySelectionView: View {

    @EnvironmentObject private var configManager: ConfigurationManager
    @EnvironmentObject private var router: AppRouter

    @State private var selectedCountryId: String?

    var body: some View {
        ZStack {
            linearGradientBackground

            VStack(alignment: .leading, spacing: 16) {

                HeaderView(
                    title: "Select Country",
                    subtitle: "Please select your country to begin verifying your information."
                )

                selectableCountryList

                Spacer()

                PrimaryButton(
                    title: "Continue",
                    action: onTapGoButton
                )
                .disabled(selectedCountryId == nil)
            }
            .padding()
        }
    }
}

// MARK: - Subviews and methods
private extension CountrySelectionView {

    @ViewBuilder
    var linearGradientBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blackHowl, .tuna]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    var selectableCountryList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(configManager.countryList) { country in
                    Button(
                        action: {
                            if selectedCountryId == country.id {
                                selectedCountryId = nil
                            } else {
                                selectedCountryId = country.id
                            }
                        }, label: {
                            CountryPickerCardView(country: country, isSelected: selectedCountryId == country.id)
                        }
                    )
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    func onTapGoButton() {
        if let id = selectedCountryId,
           let countryConfig = configManager.loadCountryConfiguration(for: id) {
            router.path.append(.countryForm(countryConfig: countryConfig))
        }
    }
}

#Preview {
    let configManager = ConfigurationManager()
    let appRouter = AppRouter()
    CountrySelectionView()
        .environmentObject(configManager)
        .environmentObject(appRouter)
}
