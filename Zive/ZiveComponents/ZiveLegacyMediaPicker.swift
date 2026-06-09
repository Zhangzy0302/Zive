import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ZiveLegacyMediaPicker: UIViewControllerRepresentable {
    enum ZiveLegacyMediaPickerKind {
        case image
        case video
    }

    let ziveLegacyMediaPickerKind: ZiveLegacyMediaPickerKind
    let ziveLegacyMediaPickerOnImageData: ((Data) -> Void)?
    let ziveLegacyMediaPickerOnVideoUrl: ((URL) -> Void)?
    @Environment(\.dismiss) private var ziveLegacyMediaPickerDismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let ziveLegacyMediaPickerController = UIImagePickerController()
        ziveLegacyMediaPickerController.sourceType = .photoLibrary
        ziveLegacyMediaPickerController.delegate = context.coordinator
        ziveLegacyMediaPickerController.mediaTypes = [
            ziveLegacyMediaPickerKind == .image
                ? UTType.image.identifier
                : UTType.movie.identifier
        ]
        return ziveLegacyMediaPickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> ZiveLegacyMediaPickerCoordinator {
        ZiveLegacyMediaPickerCoordinator(self)
    }

    final class ZiveLegacyMediaPickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let ziveLegacyMediaPickerParent: ZiveLegacyMediaPicker

        init(_ ziveLegacyMediaPickerParent: ZiveLegacyMediaPicker) {
            self.ziveLegacyMediaPickerParent = ziveLegacyMediaPickerParent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let ziveLegacyMediaPickerImage = info[.originalImage] as? UIImage,
               let ziveLegacyMediaPickerData = ziveLegacyMediaPickerImage.jpegData(compressionQuality: 0.9) {
                ziveLegacyMediaPickerParent.ziveLegacyMediaPickerOnImageData?(ziveLegacyMediaPickerData)
            }

            if let ziveLegacyMediaPickerVideoUrl = info[.mediaURL] as? URL {
                ziveLegacyMediaPickerParent.ziveLegacyMediaPickerOnVideoUrl?(ziveLegacyMediaPickerVideoUrl)
            }

            ziveLegacyMediaPickerParent.ziveLegacyMediaPickerDismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            ziveLegacyMediaPickerParent.ziveLegacyMediaPickerDismiss()
        }
    }
}
