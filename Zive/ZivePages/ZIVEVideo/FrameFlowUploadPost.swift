import SwiftUI
import AVFoundation
import UniformTypeIdentifiers
import UIKit

enum FrameFlowUploadPostFocusField {
    case content
}

struct FrameFlowUploadPost: View {
    @State private var frameFlowUploadPostContent = ""
    @State private var frameFlowUploadPostShowsVideoPicker = false
    @State private var frameFlowUploadPostVideoLocalUrlString = ""
    @State private var frameFlowUploadPostCoverLocalUrlString = ""
    @State private var frameFlowUploadPostIsUploading = false
    @FocusState private var frameFlowUploadPostFocusField: FrameFlowUploadPostFocusField?
    @EnvironmentObject private var frameFlowUploadPostNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var frameFlowUploadPostFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var frameFlowUploadPostVideoStore: ReelVideoStore
    @EnvironmentObject private var frameFlowUploadPostUserStore: OrbitUserStore

    var body: some View {
        ZStack {
            ZiveStyle.ColorPalette.background
                .ignoresSafeArea()
                .onTapGesture {
                    frameFlowUploadPostFocusField = nil
                }

            VStack(spacing: 0) {
                GrooveStreakTopNavigationBar(title: "Post")
                    .padding(.horizontal, 18)
                    .padding(.top, 12)

                VStack(alignment: .leading, spacing: 34) {
                    frameFlowUploadPostVideoSection
                    frameFlowUploadPostContentSection
                }
                .padding(.horizontal, 19)
                .padding(.top, 46)

                Spacer()

                if frameFlowUploadPostFocusField == nil && !frameFlowUploadPostIsUploading {
                    GrooveStreakButton(title: "Upload", width: 314, height: 44) {
                        frameFlowUploadPostFocusField = nil
                        Task {
                            await frameFlowUploadPostHandleUpload()
                        }
                    }
                    .padding(.bottom, 66)
                    .transition(.opacity)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            frameFlowUploadPostFocusField = nil
        }
        .sheet(isPresented: $frameFlowUploadPostShowsVideoPicker) {
            ZiveLegacyMediaPicker(
                ziveLegacyMediaPickerKind: .video,
                ziveLegacyMediaPickerOnImageData: nil,
                ziveLegacyMediaPickerOnVideoUrl: { frameFlowUploadPostVideoUrl in
                    Task {
                        await frameFlowUploadPostLoadSelectedVideo(from: frameFlowUploadPostVideoUrl)
                    }
                }
            )
        }
        .animation(.easeInOut(duration: 0.2), value: frameFlowUploadPostFocusField == nil)
        .navigationBarHidden(true)
    }

    private var frameFlowUploadPostVideoSection: some View {
        HStack(alignment: .top, spacing: 46) {
            Text("Video:")
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(ZiveStyle.ColorPalette.white)

            Button {
                frameFlowUploadPostShowsVideoPicker = true
            } label: {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        .white.opacity(0.23)
                    )
                    .frame(width: 123, height: 152)
                    .shadow(color: ZiveStyle.ColorPalette.brandPink.opacity(0.55), radius: 20, x: 0, y: 0)
                    
                    .overlay {
                        ZStack{
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            ZiveStyle.ColorPalette.brandPink,
                                            ZiveStyle.ColorPalette.brandOrange
                                        ],
                                        startPoint: .bottomLeading,
                                        endPoint: .topTrailing
                                    )
                                )
                                .frame(width: 123, height: 152)
                                .blur(radius: 10)

                            if frameFlowUploadPostCoverLocalUrlString.isEmpty {
                                Image(systemName: "plus")
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundStyle(ZiveStyle.ColorPalette.white)
                            } else {
                                ZiveSmartImage(ziveSmartImagePath: frameFlowUploadPostCoverLocalUrlString)
                                    .frame(width: 123, height: 152)
                                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                                    .overlay {
                                        Image("ZIVEPlay")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                    }
                            }
                        }
                        
                    }
            }
            .buttonStyle(.plain)
            .disabled(frameFlowUploadPostIsUploading)
        }
    }

    private var frameFlowUploadPostContentSection: some View {
        HStack(alignment: .top, spacing: 27) {
            Text("Content:")
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(ZiveStyle.ColorPalette.white)
                .padding(.top, 6)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(ZiveInputVariant.translucent.backgroundColor)
                    .frame(height: 222)

                if frameFlowUploadPostContent.isEmpty {
                    Text("Enter...")
                        .font(ZiveStyle.FontBook.regular(16))
                        .foregroundStyle(ZiveInputVariant.translucent.placeholderColor)
                        .padding(.leading, 18)
                        .padding(.top, 15)
                }

                TextEditor(text: $frameFlowUploadPostContent)
                    .ziveHideTextEditorBackground()
                    .font(ZiveStyle.FontBook.regular(16))
                    .foregroundStyle(ZiveInputVariant.translucent.textColor)
                    .tint(ZiveInputVariant.translucent.cursorColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(height: 222)
                    .background(Color.clear)
                    .focused($frameFlowUploadPostFocusField, equals: .content)
            }
        }
    }

    private var frameFlowUploadPostCurrentUser: OrbitUserModel? {
        let frameFlowUploadPostCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return frameFlowUploadPostUserStore.orbitUserFetch(by: frameFlowUploadPostCurrentUserId)
    }

    private func frameFlowUploadPostHandleUpload() async {
        guard !frameFlowUploadPostIsUploading else {
            return
        }

        let frameFlowUploadPostTrimmedContent = frameFlowUploadPostContent
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !frameFlowUploadPostVideoLocalUrlString.isEmpty else {
            await MainActor.run {
                frameFlowUploadPostFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: "Please upload a video first",
                    status: .error
                )
            }
            return
        }

        guard !frameFlowUploadPostTrimmedContent.isEmpty else {
            await MainActor.run {
                frameFlowUploadPostFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: "Please enter content",
                    status: .error
                )
            }
            return
        }

        guard let frameFlowUploadPostCurrentUser else {
            await MainActor.run {
                frameFlowUploadPostFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: "Current user not found",
                    status: .error
                )
            }
            return
        }

        await MainActor.run {
            frameFlowUploadPostIsUploading = true
            frameFlowUploadPostFeedbackCenter.ziveGlobalFeedbackShowLoading(
                text: "Uploading..."
            )
        }

        await delay(1)

        let frameFlowUploadPostNewVideo = ReelVideoModel(
            id: "video_\(UUID().uuidString)",
            reelVideoPublisherId: frameFlowUploadPostCurrentUser.id,
            reelVideoCoverUrl: frameFlowUploadPostCoverLocalUrlString,
            reelVideoUrl: frameFlowUploadPostVideoLocalUrlString,
            reelVideoContent: frameFlowUploadPostTrimmedContent,
            reelVideoLikeCount: 0,
            reelVideoGiftValue: 0
        )

        await MainActor.run {
            frameFlowUploadPostVideoStore.reelVideoCreate(frameFlowUploadPostNewVideo)
            frameFlowUploadPostIsUploading = false
            frameFlowUploadPostFeedbackCenter.ziveGlobalFeedbackHideLoading()
            frameFlowUploadPostFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Upload successful",
                status: .success
            )
            frameFlowUploadPostNavigator.weioZwivbeReplaceStack(
                with: .stagePulseVideoDetail(frameFlowUploadPostNewVideo.id)
            )
        }
    }

    private func frameFlowUploadPostLoadSelectedVideo(from frameFlowUploadPostSelectedVideoUrl: URL) async {
        do {
            await MainActor.run {
                frameFlowUploadPostFeedbackCenter.ziveGlobalFeedbackShowLoading(showsMask: true)
            }

            let frameFlowUploadPostVideoData = try Data(contentsOf: frameFlowUploadPostSelectedVideoUrl)
            let frameFlowUploadPostVideoUrl = try frameFlowUploadPostSaveVideoToLocal(
                frameFlowUploadPostVideoData,
                preferredExtension: frameFlowUploadPostSelectedVideoUrl.pathExtension.isEmpty
                ? "mp4"
                : frameFlowUploadPostSelectedVideoUrl.pathExtension
            )
            let frameFlowUploadPostCoverUrl = try frameFlowUploadPostGenerateCoverImage(
                for: frameFlowUploadPostVideoUrl
            )

            await MainActor.run {
                frameFlowUploadPostVideoLocalUrlString = frameFlowUploadPostVideoUrl.path
                frameFlowUploadPostCoverLocalUrlString = frameFlowUploadPostCoverUrl.path
            }
            await MainActor.run {
                frameFlowUploadPostFeedbackCenter.ziveGlobalFeedbackHideLoading()
            }
        } catch {
            await MainActor.run {
                frameFlowUploadPostIsUploading = false
                frameFlowUploadPostFeedbackCenter.ziveGlobalFeedbackHideLoading()
                frameFlowUploadPostFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: "Failed to process video",
                    status: .error
                )
            }
        }
    }

    private func frameFlowUploadPostSaveVideoToLocal(
        _ frameFlowUploadPostVideoData: Data,
        preferredExtension: String
    ) throws -> URL {
        let frameFlowUploadPostSafeExtension = preferredExtension.isEmpty ? "mp4" : preferredExtension
        let frameFlowUploadPostFileUrl = frameFlowUploadPostDocumentsDirectory()
            .appendingPathComponent("frameFlowVideo_\(UUID().uuidString).\(frameFlowUploadPostSafeExtension)")

        try frameFlowUploadPostVideoData.write(to: frameFlowUploadPostFileUrl, options: .atomic)
        return frameFlowUploadPostFileUrl
    }

    private func frameFlowUploadPostGenerateCoverImage(for frameFlowUploadPostVideoUrl: URL) throws -> URL {
        let frameFlowUploadPostAsset = AVAsset(url: frameFlowUploadPostVideoUrl)
        let frameFlowUploadPostImageGenerator = AVAssetImageGenerator(asset: frameFlowUploadPostAsset)
        frameFlowUploadPostImageGenerator.appliesPreferredTrackTransform = true

        let frameFlowUploadPostCgImage = try frameFlowUploadPostImageGenerator.copyCGImage(
            at: CMTime(seconds: 0, preferredTimescale: 600),
            actualTime: nil
        )
        let frameFlowUploadPostUiImage = UIImage(cgImage: frameFlowUploadPostCgImage)

        guard let frameFlowUploadPostImageData = frameFlowUploadPostUiImage.jpegData(compressionQuality: 0.9) else {
            throw NSError(domain: "FrameFlowUploadPost", code: -1)
        }

        let frameFlowUploadPostCoverUrl = frameFlowUploadPostDocumentsDirectory()
            .appendingPathComponent("frameFlowCover_\(UUID().uuidString).jpg")
        try frameFlowUploadPostImageData.write(to: frameFlowUploadPostCoverUrl, options: .atomic)
        return frameFlowUploadPostCoverUrl
    }

    private func frameFlowUploadPostDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
