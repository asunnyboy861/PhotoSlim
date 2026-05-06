import SwiftUI
import SwiftData
import Photos

@Observable
final class CleanViewModel {
    var selectedDuplicates: Set<String> = []
    var selectedBlurry: Set<String> = []
    var selectedScreenshots: Set<String> = []
    var isDeleting = false
    var deletedCount = 0
    var freedSpace: Int64 = 0
    var showPaywall = false
    var showSuccessAlert = false

    private let libraryService = PhotoLibraryService()

    func toggleDuplicate(_ assetId: String) {
        if selectedDuplicates.contains(assetId) {
            selectedDuplicates.remove(assetId)
        } else {
            selectedDuplicates.insert(assetId)
        }
    }

    func toggleBlurry(_ assetId: String) {
        if selectedBlurry.contains(assetId) {
            selectedBlurry.remove(assetId)
        } else {
            selectedBlurry.insert(assetId)
        }
    }

    func toggleScreenshot(_ assetId: String) {
        if selectedScreenshots.contains(assetId) {
            selectedScreenshots.remove(assetId)
        } else {
            selectedScreenshots.insert(assetId)
        }
    }

    func autoSelectDuplicates(from groups: [DuplicateGroup]) {
        for group in groups {
            guard let best = group.bestAsset else { continue }
            for asset in group.assets where asset.localIdentifier != best.localIdentifier {
                selectedDuplicates.insert(asset.localIdentifier)
            }
        }
    }

    func autoSelectBlurry(from results: [BlurResult]) {
        for result in results {
            selectedBlurry.insert(result.asset.localIdentifier)
        }
    }

    func autoSelectScreenshots(from assets: [PHAsset]) {
        for asset in assets {
            selectedScreenshots.insert(asset.localIdentifier)
        }
    }

    var totalSelectedCount: Int {
        selectedDuplicates.count + selectedBlurry.count + selectedScreenshots.count
    }

    func deleteSelected(storeManager: StoreManager) async {
        guard totalSelectedCount > 0 else { return }

        if !storeManager.canDelete() {
            showPaywall = true
            return
        }

        isDeleting = true
        var assetsToDelete: [PHAsset] = []

        for id in selectedDuplicates {
            if let asset = libraryService.fetchAssetByLocalIdentifier(id) {
                assetsToDelete.append(asset)
            }
        }
        for id in selectedBlurry {
            if let asset = libraryService.fetchAssetByLocalIdentifier(id) {
                assetsToDelete.append(asset)
            }
        }
        for id in selectedScreenshots {
            if let asset = libraryService.fetchAssetByLocalIdentifier(id) {
                assetsToDelete.append(asset)
            }
        }

        let deleteCount = min(assetsToDelete.count, storeManager.isPro ? assetsToDelete.count : storeManager.remainingDeletesToday)
        let assetsToActuallyDelete = Array(assetsToDelete.prefix(deleteCount))

        do {
            let totalSize = assetsToActuallyDelete.reduce(Int64(0)) { $0 + libraryService.estimateFileSize(for: $1) }
            try await libraryService.deleteAssets(assetsToActuallyDelete)
            deletedCount = deleteCount
            freedSpace = totalSize
            storeManager.recordDeletion(count: deleteCount)
            showSuccessAlert = true

            selectedDuplicates.removeAll()
            selectedBlurry.removeAll()
            selectedScreenshots.removeAll()
        } catch {
        }

        isDeleting = false
    }
}
