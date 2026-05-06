import CoreImage
import Photos

@Observable
final class BlurDetector {
    private let context = CIContext()

    func detectBlur(in assets: [PHAsset], libraryService: PhotoLibraryService, threshold: Float = 100) async -> [BlurResult] {
        var results: [BlurResult] = []

        for asset in assets {
            let score = await computeLaplacianVariance(for: asset, libraryService: libraryService)
            let isBlurry = score < threshold
            let fileSize = libraryService.estimateFileSize(for: asset)

            if isBlurry {
                results.append(BlurResult(
                    asset: asset,
                    sharpnessScore: score,
                    isBlurry: isBlurry,
                    fileSize: fileSize
                ))
            }
        }

        return results.sorted { $0.sharpnessScore < $1.sharpnessScore }
    }

    func computeLaplacianVariance(for asset: PHAsset, libraryService: PhotoLibraryService) async -> Float {
        guard let cgImage = await libraryService.fetchCGImage(for: asset) else { return 1000 }
        let ciImage = CIImage(cgImage: cgImage)

        guard let filter = CIFilter(name: "CIConvolution3X3") else { return 1000 }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(values: [0, 1, 0, 1, -4, 1, 0, 1, 0], count: 9), forKey: "inputWeights")

        guard let outputImage = filter.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return 1000 }

        let pixelData = outputCGImage.dataProvider?.data
        guard let data = pixelData else { return 1000 }
        let ptr = CFDataGetBytePtr(data)!
        let length = CFDataGetLength(data)

        var sum: Float = 0
        var sumSq: Float = 0
        let count = length / 4

        for i in 0..<count {
            let offset = i * 4
            let value = Float(ptr[offset])
            sum += value
            sumSq += value * value
        }

        let mean = sum / Float(count)
        let variance = (sumSq / Float(count)) - (mean * mean)
        return variance
    }
}
