import Photos
import ImageIO

@Observable
final class SmartClassifier {
    func classifyScreenshots(in assets: [PHAsset], libraryService: PhotoLibraryService) async -> [PHAsset] {
        var screenshots: [PHAsset] = []

        for asset in assets {
            if isScreenshot(asset) {
                screenshots.append(asset)
            }
        }

        return screenshots
    }

    private func isScreenshot(_ asset: PHAsset) -> Bool {
        let resources = PHAssetResource.assetResources(for: asset)
        if let resource = resources.first {
            if resource.type == .photo {
                let uniformTypeIdentifier = resource.uniformTypeIdentifier
                if uniformTypeIdentifier == "public.png" {
                    if asset.pixelWidth == asset.pixelHeight * 9 / 16 ||
                       asset.pixelHeight == asset.pixelWidth * 9 / 16 ||
                       asset.pixelWidth == asset.pixelHeight * 3 / 4 ||
                       asset.pixelHeight == asset.pixelWidth * 3 / 4 {
                        return true
                    }
                }
            }
        }

        if asset.mediaSubtypes.contains(.photoScreenshot) {
            return true
        }

        return false
    }

    func groupScreenshotsByApp(_ screenshots: [PHAsset]) -> [String: [PHAsset]] {
        var groups: [String: [PHAsset]] = [:]

        for screenshot in screenshots {
            let appName = extractAppName(from: screenshot)
            groups[appName, default: []].append(screenshot)
        }

        return groups
    }

    private func extractAppName(from asset: PHAsset) -> String {
        let resources = PHAssetResource.assetResources(for: asset)
        if let filename = resources.first?.originalFilename {
            let parts = filename.split(separator: " ")
            if parts.count > 1 {
                return String(parts[0])
            }
        }
        return "Other"
    }
}
