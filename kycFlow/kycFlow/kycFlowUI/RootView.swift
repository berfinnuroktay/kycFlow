import SwiftUI

struct RootView: View {

    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                CountrySelectionView()
            }
            .navigationDestination(for: Destination.self, destination: makeNavigation(destination:))
        }
    }
}

private extension RootView {

    @ViewBuilder
    func makeNavigation(destination: Destination) -> some View {

        switch destination {
        case .countryForm(let countryConfig):

            let factory = UserProfileFetcherFactory()
            let viewModel = FormViewModel(countryConfig: countryConfig, fetcherFactory: factory)
            FormView(viewModel: viewModel)
        }
    }
}

#Preview {
    RootView()
}
