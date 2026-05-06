import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var scanViewModel = ScanViewModel()
    @State private var storeManager = StoreManager()

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(scanViewModel: scanViewModel, storeManager: storeManager)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ScanView(scanViewModel: scanViewModel, storeManager: storeManager)
                .tabItem {
                    Label("Scan", systemImage: "magnifyingglass")
                }
                .tag(1)

            ReportView(scanViewModel: scanViewModel)
                .tabItem {
                    Label("Report", systemImage: "chart.bar.fill")
                }
                .tag(2)

            SettingsView(storeManager: storeManager)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}
