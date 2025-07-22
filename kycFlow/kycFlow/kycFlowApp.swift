import SwiftUI

@main
struct kycFlowApp: App {

    @StateObject private var configurationManager = ConfigurationManager()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(configurationManager)
                .environmentObject(router)
        }
    }
}
