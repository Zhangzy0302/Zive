import SwiftUI
import UIKit

enum ZiveSmartImageSource {
    case assetName(String)
    case fileUrl(URL)
    case remoteUrl(URL)
}

struct ZiveSmartImage<Placeholder: View>: View {
    let ziveSmartImagePath: String
    let ziveSmartImageContentMode: ContentMode
    let ziveSmartImagePlaceholder: Placeholder

    init(
        ziveSmartImagePath: String,
        ziveSmartImageContentMode: ContentMode = .fill,
        @ViewBuilder ziveSmartImagePlaceholder: () -> Placeholder = {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.12))
        }
    ) {
        self.ziveSmartImagePath = ziveSmartImagePath
        self.ziveSmartImageContentMode = ziveSmartImageContentMode
        self.ziveSmartImagePlaceholder = ziveSmartImagePlaceholder()
    }

    var body: some View {
        Group {
            if let ziveSmartImageSource = ziveSmartImageResolvedSource {
                switch ziveSmartImageSource {
                case let .assetName(ziveSmartImageAssetName):
                    Image(ziveSmartImageAssetName)
                        .resizable()
                        .aspectRatio(contentMode: ziveSmartImageContentMode)
                case let .fileUrl(ziveSmartImageFileUrl):
                    if let ziveSmartImageUiImage = UIImage(contentsOfFile: ziveSmartImageFileUrl.path) {
                        Image(uiImage: ziveSmartImageUiImage)
                            .resizable()
                            .aspectRatio(contentMode: ziveSmartImageContentMode)
                    } else {
                        ziveSmartImagePlaceholder
                    }
                case let .remoteUrl(ziveSmartImageRemoteUrl):
                    AsyncImage(url: ziveSmartImageRemoteUrl) { ziveSmartImagePhase in
                        switch ziveSmartImagePhase {
                        case let .success(ziveSmartImageImage):
                            ziveSmartImageImage
                                .resizable()
                                .aspectRatio(contentMode: ziveSmartImageContentMode)
                        case .failure:
                            ziveSmartImagePlaceholder
                        case .empty:
                            ziveSmartImagePlaceholder
                        @unknown default:
                            ziveSmartImagePlaceholder
                        }
                    }
                }
            } else {
                ziveSmartImagePlaceholder
            }
        }
    }

    private var ziveSmartImageResolvedSource: ZiveSmartImageSource? {
        let ziveSmartImageTrimmedPath = ziveSmartImagePath.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !ziveSmartImageTrimmedPath.isEmpty else {
            return nil
        }

        if let ziveSmartImageUrl = URL(string: ziveSmartImageTrimmedPath) {
            if let ziveSmartImageScheme = ziveSmartImageUrl.scheme?.lowercased() {
                if ziveSmartImageScheme == "http" || ziveSmartImageScheme == "https" {
                    return .remoteUrl(ziveSmartImageUrl)
                }

                if ziveSmartImageScheme == "file" {
                    return .fileUrl(ziveSmartImageUrl)
                }
            }
        }

        if ziveSmartImageTrimmedPath.hasPrefix("/") {
            return .fileUrl(URL(fileURLWithPath: ziveSmartImageTrimmedPath))
        }

        return .assetName(ziveSmartImageTrimmedPath)
    }
}
