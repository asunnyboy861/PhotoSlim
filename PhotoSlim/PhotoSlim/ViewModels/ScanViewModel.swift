import SwiftUI
import SwiftData
import Photos

@Observable
final class ScanViewModel {
    var isScanning = false
    var scanProgress: Float = 0
    var scanPhase: ScanPhase = .idle
    var duplicateGroups: [DuplicateGroup] = []
    var blurryPhotos: [BlurResult] = []
    var screenshots: [PHAsset] = []
    var totalPhotosScanned = 0
    var totalReclaimableSpace: Int64 = 0
    var errorMessage: String?

    enum ScanPhase {
        case idle
        case loadingLibrary
        case detectingDuplicates
        case detectingBlur
        case classifyingScreenshots
        case completed
        case error
    }

    private let libraryService = PhotoLibraryService()
    private let duplicateDetector = DuplicateDetector()
    private let blurDetector = BlurDetector()
    private let smartClassifier = SmartClassifier()

    var duplicateCount: Int { duplicateGroups.reduce(0) { $0 + $1.assets.count - 1 } }
    var duplicateSize: Int64 { duplicateGroups.reduce(0) { $0 + $1.reclaimableSize } }
    var blurryCount: Int { blurryPhotos.count }
    var blurrySize: Int64 { blurryPhotos.reduce(0) { $0 + $1.fileSize } }
    var screenshotCount: Int { screenshots.count }
    var screenshotSize: Int64 {
        screenshots.reduce(Int64(0)) { $0 + libraryService.estimateFileSize(for: $1) }
    }

    func startScan(similarityThreshold: Float = 0.85, blurThreshold: Float = 100) async {
        isScanning = true
        scanProgress = 0
        errorMessage = nil
        duplicateGroups = []
        blurryPhotos = []
        screenshots = []
        totalReclaimableSpace = 0

        scanPhase = .loadingLibrary
        scanProgress = 0.05

        let authorized: Bool
        if libraryService.authorizationStatus == .authorized || libraryService.authorizationStatus == .limited {
            authorized = true
        } else {
            authorized = await libraryService.requestAuthorization()
        }

        guard authorized else {
            scanPhase = .error
            errorMessage = "Photo library access denied. Please grant permission in Settings."
            isScanning = false
            return
        }

        let allAssets = libraryService.fetchAllAssets()
        totalPhotosScanned = allAssets.count
        scanProgress = 0.1

        scanPhase = .detectingDuplicates
        scanProgress = 0.15
        duplicateGroups = await duplicateDetector.findDuplicates(
            in: allAssets,
            libraryService: libraryService,
            threshold: similarityThreshold
        )
        scanProgress = 0.5

        scanPhase = .detectingBlur
        blurryPhotos = await blurDetector.detectBlur(
            in: allAssets,
            libraryService: libraryService,
            threshold: blurThreshold
        )
        scanProgress = 0.8

        scanPhase = .classifyingScreenshots
        screenshots = await smartClassifier.classifyScreenshots(
            in: allAssets,
            libraryService: libraryService
        )
        scanProgress = 1.0

        totalReclaimableSpace = duplicateSize + blurrySize + screenshotSize

        scanPhase = .completed
        isScanning = false
    }
}
