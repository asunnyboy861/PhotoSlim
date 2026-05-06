import SwiftUI
import Photos

struct ScanView: View {
    let scanViewModel: ScanViewModel
    let storeManager: StoreManager
    @State private var cleanViewModel = CleanViewModel()
    @State private var selectedCategory: ScanCategory = .duplicates

    enum ScanCategory: String, CaseIterable {
        case duplicates = "Duplicates"
        case blurry = "Blurry"
        case screenshots = "Screenshots"

        var icon: String {
            switch self {
            case .duplicates: return "doc.on.doc.fill"
            case .blurry: return "eye.slash.fill"
            case .screenshots: return "photo.fill"
            }
        }

        var color: Color {
            switch self {
            case .duplicates: return .orange
            case .blurry: return .purple
            case .screenshots: return .green
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if scanViewModel.scanPhase == .idle {
                    scanPromptView
                } else if scanViewModel.isScanning {
                    scanningView
                } else if scanViewModel.scanPhase == .completed {
                    scanResultsView
                } else if scanViewModel.scanPhase == .error {
                    errorView
                } else {
                    scanPromptView
                }
            }
            .navigationTitle("Smart Scan")
        }
    }

    private var scanPromptView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(.blue)
            Text("Ready to Scan")
                .font(.title2.bold())
            Text("We'll analyze your photo library for duplicates, blurry photos, and screenshots")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                Task { await scanViewModel.startScan() }
            } label: {
                Label("Start Scan", systemImage: "play.fill")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            Spacer()
        }
    }

    private var scanningView: some View {
        VStack(spacing: 24) {
            Spacer()
            ProgressView(value: scanViewModel.scanProgress)
                .tint(.blue)
                .padding(.horizontal, 40)

            Text(phaseDescription)
                .font(.headline)

            Text("\(Int(scanViewModel.scanProgress * 100))%")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)

            Text("\(scanViewModel.totalPhotosScanned) photos found")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var phaseDescription: String {
        switch scanViewModel.scanPhase {
        case .loadingLibrary: return "Loading your photo library..."
        case .detectingDuplicates: return "Detecting duplicate photos..."
        case .detectingBlur: return "Analyzing photo sharpness..."
        case .classifyingScreenshots: return "Finding screenshots..."
        default: return ""
        }
    }

    private var scanResultsView: some View {
        VStack(spacing: 0) {
            categoryPicker

            TabView(selection: $selectedCategory) {
                duplicatesList.tag(ScanCategory.duplicates)
                blurryList.tag(ScanCategory.blurry)
                screenshotsList.tag(ScanCategory.screenshots)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            cleanActionBar
        }
    }

    private var categoryPicker: some View {
        HStack(spacing: 8) {
            ForEach(ScanCategory.allCases, id: \.self) { category in
                Button {
                    withAnimation { selectedCategory = category }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: category.icon)
                        Text(category.rawValue)
                            .font(.caption.bold())
                        countLabel(for: category)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(selectedCategory == category ? category.color.opacity(0.15) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .foregroundStyle(selectedCategory == category ? category.color : .secondary)
            }
        }
        .padding()
    }

    private func countLabel(for category: ScanCategory) -> some View {
        let count: Int
        switch category {
        case .duplicates: count = scanViewModel.duplicateCount
        case .blurry: count = scanViewModel.blurryCount
        case .screenshots: count = scanViewModel.screenshotCount
        }
        return Text("\(count)")
            .font(.caption2.bold())
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(category.color.opacity(0.2), in: Capsule())
    }

    private var duplicatesList: some View {
        List {
            ForEach(scanViewModel.duplicateGroups) { group in
                DuplicateGroupRow(group: group, cleanViewModel: cleanViewModel)
            }
        }
        .listStyle(.plain)
    }

    private var blurryList: some View {
        List {
            ForEach(scanViewModel.blurryPhotos) { result in
                BlurryPhotoRow(result: result, cleanViewModel: cleanViewModel)
            }
        }
        .listStyle(.plain)
    }

    private var screenshotsList: some View {
        List {
            ForEach(scanViewModel.screenshots, id: \.localIdentifier) { asset in
                ScreenshotRow(asset: asset, cleanViewModel: cleanViewModel)
            }
        }
        .listStyle(.plain)
    }

    private var cleanActionBar: some View {
        VStack(spacing: 8) {
            if !storeManager.isPro && cleanViewModel.totalSelectedCount > storeManager.remainingDeletesToday {
                Text("Free limit: \(storeManager.remainingDeletesToday) deletes remaining today")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            HStack {
                Text("\(cleanViewModel.totalSelectedCount) selected")
                    .font(.subheadline.bold())

                Spacer()

                Button {
                    cleanViewModel.autoSelectDuplicates(from: scanViewModel.duplicateGroups)
                    cleanViewModel.autoSelectBlurry(from: scanViewModel.blurryPhotos)
                    cleanViewModel.autoSelectScreenshots(from: scanViewModel.screenshots)
                } label: {
                    Text("Auto Select")
                        .font(.subheadline)
                }

                Button {
                    Task { await cleanViewModel.deleteSelected(storeManager: storeManager) }
                } label: {
                    Label("Clean", systemImage: "trash.fill")
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(cleanViewModel.totalSelectedCount > 0 ? Color.red : Color.gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(cleanViewModel.totalSelectedCount == 0 || cleanViewModel.isDeleting)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.red)
            Text("Scan Failed")
                .font(.title2.bold())
            Text(scanViewModel.errorMessage ?? "An unknown error occurred")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button {
                Task { await scanViewModel.startScan() }
            } label: {
                Text("Try Again")
                    .bold()
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

private struct DuplicateGroupRow: View {
    let group: DuplicateGroup
    let cleanViewModel: CleanViewModel
    @State private var thumbnails: [String: UIImage] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: group.type == .exact ? "doc.on.doc.fill" : "doc.on.doc")
                    .foregroundStyle(.orange)
                Text(group.type == .exact ? "Exact Duplicate" : "Similar Photo")
                    .font(.subheadline.bold())
                Spacer()
                Text("\(group.assets.count) photos")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(ByteCountFormatter.string(fromByteCount: group.reclaimableSize, countStyle: .file))
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(group.assets, id: \.localIdentifier) { asset in
                        let isSelected = cleanViewModel.selectedDuplicates.contains(asset.localIdentifier)
                        let isBest = asset.localIdentifier == group.bestAsset?.localIdentifier

                        Button {
                            if !isBest {
                                cleanViewModel.toggleDuplicate(asset.localIdentifier)
                            }
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                if let image = thumbnails[asset.localIdentifier] {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }

                                if isBest {
                                    Text("BEST")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(.green, in: Capsule())
                                } else if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.red)
                                        .font(.title3)
                                }
                            }
                        }
                        .disabled(isBest)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .task {
            for asset in group.assets {
                if thumbnails[asset.localIdentifier] == nil {
                    let service = PhotoLibraryService()
                    if let image = await service.fetchThumbnail(for: asset, size: CGSize(width: 160, height: 160)) {
                        thumbnails[asset.localIdentifier] = image
                    }
                }
            }
        }
    }
}

private struct BlurryPhotoRow: View {
    let result: BlurResult
    let cleanViewModel: CleanViewModel
    @State private var thumbnail: UIImage?

    var body: some View {
        HStack(spacing: 12) {
            if let image = thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(result.severityLabel)
                    .font(.subheadline.bold())
                Text("Sharpness: \(Int(result.sharpnessScore))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(ByteCountFormatter.string(fromByteCount: result.fileSize, countStyle: .file))
                    .font(.caption2)
                    .foregroundStyle(.purple)
            }

            Spacer()

            Button {
                cleanViewModel.toggleBlurry(result.asset.localIdentifier)
            } label: {
                Image(systemName: cleanViewModel.selectedBlurry.contains(result.asset.localIdentifier) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(cleanViewModel.selectedBlurry.contains(result.asset.localIdentifier) ? .red : .gray)
            }
        }
        .padding(.vertical, 4)
        .task {
            let service = PhotoLibraryService()
            thumbnail = await service.fetchThumbnail(for: result.asset)
        }
    }
}

private struct ScreenshotRow: View {
    let asset: PHAsset
    let cleanViewModel: CleanViewModel
    @State private var thumbnail: UIImage?

    var body: some View {
        HStack(spacing: 12) {
            if let image = thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Screenshot")
                    .font(.subheadline.bold())
                if let date = asset.creationDate {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                let size = PhotoLibraryService().estimateFileSize(for: asset)
                Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                    .font(.caption2)
                    .foregroundStyle(.green)
            }

            Spacer()

            Button {
                cleanViewModel.toggleScreenshot(asset.localIdentifier)
            } label: {
                Image(systemName: cleanViewModel.selectedScreenshots.contains(asset.localIdentifier) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(cleanViewModel.selectedScreenshots.contains(asset.localIdentifier) ? .red : .gray)
            }
        }
        .padding(.vertical, 4)
        .task {
            let service = PhotoLibraryService()
            thumbnail = await service.fetchThumbnail(for: asset)
        }
    }
}
