import SwiftUI

struct HomeView: View {
    let scanViewModel: ScanViewModel
    let storeManager: StoreManager
    @State private var showScan = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroSection
                    quickActionsSection
                    if scanViewModel.scanPhase == .completed {
                        resultsSummarySection
                    }
                    featuresSection
                }
                .padding()
            }
            .navigationTitle("PhotoSlim")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !storeManager.isPro {
                        Button {
                            showScan = true
                        } label: {
                            Text("PRO")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue, in: Capsule())
                        }
                    }
                }
            }
            .sheet(isPresented: $showScan) {
                PaywallView(storeManager: storeManager)
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.metering.matrix")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .padding(.top, 20)

            Text("Smart Photo Cleaner")
                .font(.title.bold())

            Text("Find duplicates, blurry shots, and screenshots taking up space")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Button {
                Task { await scanViewModel.startScan() }
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text(scanViewModel.isScanning ? "Scanning..." : "Start Smart Scan")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(scanViewModel.isScanning ? Color.gray : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(scanViewModel.isScanning)

            if scanViewModel.isScanning {
                ProgressView(value: scanViewModel.scanProgress) {
                    Text(phaseDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .tint(.blue)
            }
        }
    }

    private var phaseDescription: String {
        switch scanViewModel.scanPhase {
        case .idle: return "Ready"
        case .loadingLibrary: return "Loading photo library..."
        case .detectingDuplicates: return "Detecting duplicates..."
        case .detectingBlur: return "Detecting blurry photos..."
        case .classifyingScreenshots: return "Classifying screenshots..."
        case .completed: return "Scan complete!"
        case .error: return scanViewModel.errorMessage ?? "Error occurred"
        }
    }

    private var resultsSummarySection: some View {
        VStack(spacing: 12) {
            Text("Last Scan Results")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                ResultCard(
                    icon: "doc.on.doc.fill",
                    title: "Duplicates",
                    count: scanViewModel.duplicateCount,
                    size: scanViewModel.duplicateSize,
                    color: .orange
                )
                ResultCard(
                    icon: "eye.slash.fill",
                    title: "Blurry",
                    count: scanViewModel.blurryCount,
                    size: scanViewModel.blurrySize,
                    color: .purple
                )
                ResultCard(
                    icon: "photo.fill",
                    title: "Screenshots",
                    count: scanViewModel.screenshotCount,
                    size: scanViewModel.screenshotSize,
                    color: .green
                )
            }
        }
    }

    private var featuresSection: some View {
        VStack(spacing: 12) {
            Text("Features")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            FeatureRow(icon: "brain.head.profile.fill", title: "Offline AI", subtitle: "100% on-device processing")
            FeatureRow(icon: "lock.shield.fill", title: "Privacy First", subtitle: "No data leaves your phone")
            FeatureRow(icon: "bolt.fill", title: "Lightning Fast", subtitle: "Vision framework powered")
            FeatureRow(icon: "trash.fill", title: "Smart Clean", subtitle: "Auto-select best photos to keep")
        }
    }
}

private struct ResultCard: View {
    let icon: String
    let title: String
    let count: Int
    let size: Int64
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.caption.bold())
            Text("\(count)")
                .font(.title2.bold())
            Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}
