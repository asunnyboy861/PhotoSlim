import SwiftUI

struct SettingsView: View {
    let storeManager: StoreManager
    @State private var showPaywall = false
    @State private var showPrivacyPolicy = false
    @State private var showSupport = false

    var body: some View {
        NavigationStack {
            List {
                proSection
                scanSettingsSection
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView(storeManager: storeManager)
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                WebView(url: URL(string: "https://asunnyboy861.github.io/PhotoSlim/privacy.html")!)
            }
            .sheet(isPresented: $showSupport) {
                WebView(url: URL(string: "https://asunnyboy861.github.io/PhotoSlim/support.html")!)
            }
        }
    }

    private var proSection: some View {
        Section {
            if storeManager.isPro {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    Text("PhotoSlim Pro")
                        .bold()
                    Spacer()
                    Text("Active")
                        .foregroundStyle(.green)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundStyle(.yellow)
                        Text("Upgrade to Pro")
                            .bold()
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !storeManager.isPro {
                HStack {
                    Text("Daily Delete Limit")
                    Spacer()
                    Text("\(storeManager.remainingDeletesToday) remaining")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Subscription")
        }
    }

    private var scanSettingsSection: some View {
        Section {
            HStack {
                Text("Auto-select best photo")
                Spacer()
                Text("On")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Protect favorites")
                Spacer()
                Text("On")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Scan scope")
                Spacer()
                Text("All photos")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Scan Settings")
        }
    }

    private var aboutSection: some View {
        Section {
            Button { showPrivacyPolicy = true } label: {
                HStack {
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            Button { showSupport = true } label: {
                HStack {
                    Text("Support")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}
