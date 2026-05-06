import Photos
import UIKit

@Observable
final class PhotoLibraryService {
    var authorizationStatus: PHAuthorizationStatus = .notDetermined

    init() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        authorizationStatus = status
        return status == .authorized || status == .limited
    }

    func fetchAllAssets() -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let result = PHAsset.fetchAssets(with: fetchOptions)
        var assets: [PHAsset] = []
        assets.reserveCapacity(result.count)
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }

    func fetchAssetByLocalIdentifier(_ identifier: String) -> PHAsset? {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        return result.firstObject
    }

    func fetchThumbnail(for asset: PHAsset, size: CGSize = CGSize(width: 200, height: 200)) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = false

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    func fetchCGImage(for asset: PHAsset, targetSize: CGSize = CGSize(width: 512, height: 512)) async -> CGImage? {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = false

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image?.cgImage)
            }
        }
    }

    func fetchOriginalImageData(for asset: PHAsset) async -> Data? {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = false

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                continuation.resume(returning: data)
            }
        }
    }

    func deleteAssets(_ assets: [PHAsset]) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }
    }

    func estimateFileSize(for asset: PHAsset) -> Int64 {
        let resources = PHAssetResource.assetResources(for: asset)
        if let resource = resources.first,
           let fileSize = resource.value(forKey: "fileSize") as? Int64, fileSize > 0 {
            return fileSize
        }
        return Int64(asset.pixelWidth) * Int64(asset.pixelHeight) * 4
    }
}
