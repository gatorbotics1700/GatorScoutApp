import SwiftUI

@main
struct GatorScoutApp: App {
    @StateObject private var networkMonitor = NetworkMonitor.shared

    var body: some Scene {
        WindowGroup {
            LoginView()
            .preferredColorScheme(.light)
            .environmentObject(networkMonitor)
        }
    }
}
