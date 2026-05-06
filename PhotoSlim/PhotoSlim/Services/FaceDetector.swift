import Vision
import Photos

@Observable
final class FaceDetector {
    private var faceGroups: [String: [PHAsset]] = [:]

    func detectFaces(in assets: [PHAsset], libraryService: PhotoLibraryService) async -> [String: [PHAsset]] {
        var assetFaceCounts: [(PHAsset, Int)] = []

        for asset in assets {
            let faceCount = await detectFaceCount(for: asset, libraryService: libraryService)
            assetFaceCounts.append((asset, faceCount))
        }

        var groups: [String: [PHAsset]] = [:]
        for (asset, count) in assetFaceCounts where count > 0 {
            let key = "faces_\(count)"
            groups[key, default: []].append(asset)
        }

        faceGroups = groups
        return groups
    }

    private func detectFaceCount(for asset: PHAsset, libraryService: PhotoLibraryService) async -> Int {
        guard let cgImage = await libraryService.fetchCGImage(for: asset) else { return 0 }

        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            return request.results?.count ?? 0
        } catch {
            return 0
        }
    }
}
