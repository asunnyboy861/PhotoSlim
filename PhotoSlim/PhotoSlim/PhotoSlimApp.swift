import SwiftUI
import SwiftData

@main
struct PhotoSlimApp: App {
    @State private var storeManager = StoreManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    MainTabView()
                        .environment(storeManager)
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
            }
        }
        .modelContainer(for: [PhotoRecord.self, ScanSession.self, UserPreferences.self])
    }
}
