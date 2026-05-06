import Foundation
import Photos

struct BlurResult: Identifiable {
    let id = UUID()
    let asset: PHAsset
    let sharpnessScore: Float
    let isBlurry: Bool
    let fileSize: Int64

    var severityLabel: String {
        if sharpnessScore < 30 { return "Severely Blurry" }
        if sharpnessScore < 60 { return "Blurry" }
        return "Slightly Blurry"
    }
}
