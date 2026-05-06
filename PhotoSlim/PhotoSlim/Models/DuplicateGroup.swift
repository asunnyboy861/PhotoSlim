import Foundation
import Photos

enum DuplicateType: Equatable {
    case exact
    case similar(similarity: Float)
}

struct DuplicateGroup: Identifiable {
    let id = UUID()
    let type: DuplicateType
    var assets: [PHAsset]
    var bestAsset: PHAsset?
    var totalSize: Int64 = 0

    var reclaimableSize: Int64 {
        guard let best = bestAsset else { return totalSize }
        let bestSize = Int64(best.pixelWidth) * Int64(best.pixelHeight) * 4
        return max(0, totalSize - bestSize)
    }
}
