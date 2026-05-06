import CryptoKit
import Photos
import CoreImage

@Observable
final class DuplicateDetector {
    private var perceptualHashCache: [String: UInt64] = [:]
    private let maxCacheSize = 5000

    func computeHash(for asset: PHAsset, libraryService: PhotoLibraryService) async -> String? {
        guard let imageData = await libraryService.fetchOriginalImageData(for: asset) else { return nil }
        let hash = SHA256.hash(data: imageData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    func computePerceptualHash(for asset: PHAsset, libraryService: PhotoLibraryService) async -> UInt64? {
        if let cached = perceptualHashCache[asset.localIdentifier] { return cached }

        guard let cgImage = await libraryService.fetchCGImage(for: asset, targetSize: CGSize(width: 8, height: 8)) else { return nil }
        let ciImage = CIImage(cgImage: cgImage)

        let grayscale = ciImage.applyingFilter("CIPhotoEffectNoir")
        let context = CIContext()
        guard let outputImage = context.createCGImage(grayscale, from: grayscale.extent) else { return nil }

        let width = outputImage.width
        let height = outputImage.height
        guard width > 0, height > 0 else { return nil }

        let pixelData = outputImage.dataProvider?.data
        guard let data = pixelData else { return nil }
        let ptr = CFDataGetBytePtr(data)!

        var pixels: [Float] = []
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let gray = Float(ptr[offset])
                pixels.append(gray)
            }
        }

        let mean = pixels.reduce(0, +) / Float(pixels.count)
        var hash: UInt64 = 0
        for (index, pixel) in pixels.enumerated() {
            if pixel > mean {
                hash |= (1 << index)
            }
        }

        if perceptualHashCache.count >= maxCacheSize {
            perceptualHashCache.removeAll()
        }
        perceptualHashCache[asset.localIdentifier] = hash
        return hash
    }

    func findDuplicates(in assets: [PHAsset], libraryService: PhotoLibraryService, threshold: Float = 0.85) async -> [DuplicateGroup] {
        var hashGroups: [String: [PHAsset]] = [:]
        var pHashes: [String: UInt64] = [:]

        for asset in assets {
            if let hash = await computeHash(for: asset, libraryService: libraryService) {
                hashGroups[hash, default: []].append(asset)
            }
            if let pHash = await computePerceptualHash(for: asset, libraryService: libraryService) {
                pHashes[asset.localIdentifier] = pHash
            }
        }

        var groups: [DuplicateGroup] = []

        for (_, groupAssets) in hashGroups where groupAssets.count > 1 {
            let best = selectBestAsset(from: groupAssets)
            let totalSize = groupAssets.reduce(Int64(0)) { $0 + libraryService.estimateFileSize(for: $1) }
            groups.append(DuplicateGroup(type: .exact, assets: groupAssets, bestAsset: best, totalSize: totalSize))
        }

        let exactDuplicateIds = Set(hashGroups.values.flatMap { $0 }.map { $0.localIdentifier })
        let remainingAssets = assets.filter { !exactDuplicateIds.contains($0.localIdentifier) }

        let similarGroups = await findSimilarGroups(
            assets: remainingAssets,
            pHashes: pHashes,
            threshold: threshold,
            libraryService: libraryService
        )
        groups.append(contentsOf: similarGroups)

        return groups.sorted { $0.assets.count > $1.assets.count }
    }

    private func findSimilarGroups(
        assets: [PHAsset],
        pHashes: [String: UInt64],
        threshold: Float,
        libraryService: PhotoLibraryService
    ) async -> [DuplicateGroup] {
        var visited = Set<String>()
        var groups: [DuplicateGroup] = []

        let hammingThreshold = UInt64(Float(64) * (1.0 - threshold))

        for i in 0..<assets.count {
            let assetI = assets[i]
            guard !visited.contains(assetI.localIdentifier),
                  let hashI = pHashes[assetI.localIdentifier] else { continue }

            var similarAssets = [assetI]

            for j in (i + 1)..<assets.count {
                let assetJ = assets[j]
                guard !visited.contains(assetJ.localIdentifier),
                      let hashJ = pHashes[assetJ.localIdentifier] else { continue }

                let hammingDistance = computeHammingDistance(hashI, hashJ)

                if hammingDistance <= hammingThreshold {
                    similarAssets.append(assetJ)
                    visited.insert(assetJ.localIdentifier)
                }
            }

            if similarAssets.count > 1 {
                visited.insert(assetI.localIdentifier)
                let best = selectBestAsset(from: similarAssets)
                let totalSize = similarAssets.reduce(Int64(0)) { $0 + libraryService.estimateFileSize(for: $1) }
                groups.append(DuplicateGroup(
                    type: .similar(similarity: threshold),
                    assets: similarAssets,
                    bestAsset: best,
                    totalSize: totalSize
                ))
            }
        }

        return groups
    }

    private func computeHammingDistance(_ a: UInt64, _ b: UInt64) -> UInt64 {
        var xor = a ^ b
        var distance: UInt64 = 0
        while xor != 0 {
            distance += xor & 1
            xor >>= 1
        }
        return distance
    }

    private func selectBestAsset(from assets: [PHAsset]) -> PHAsset {
        assets.max { a, b in
            computeQualityScore(for: a) < computeQualityScore(for: b)
        } ?? assets[0]
    }

    private func computeQualityScore(for asset: PHAsset) -> Double {
        var score = 0.0
        if asset.pixelWidth > 3000 { score += 3.0 }
        else if asset.pixelWidth > 2000 { score += 2.0 }
        else { score += 1.0 }
        if asset.mediaSubtypes.contains(.photoLive) { score += 0.5 }
        if asset.isFavorite { score += 2.0 }
        return score
    }
}
