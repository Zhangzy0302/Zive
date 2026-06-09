import SwiftUI
import AVFoundation

enum WhisperBeatChatRoomInputMode {
    case text
    case voice
}

enum WhisperBeatChatRoomFocusField {
    case message
}

struct WhisperBeatChatRoom: View {
    let whisperBeatChatRoomId: String
    @State private var whisperBeatChatRoomInputMode: WhisperBeatChatRoomInputMode = .text
    @State private var whisperBeatChatRoomMessage = ""
    @State private var whisperBeatChatRoomShowsImagePicker = false
    @State private var whisperBeatChatRoomAudioRecorder: AVAudioRecorder?
    @State private var whisperBeatChatRoomAudioPlayer: AVAudioPlayer?
    @State private var whisperBeatChatRoomRecordingUrl: URL?
    @State private var whisperBeatChatRoomRecordingStartTime: Date?
    @State private var whisperBeatChatRoomRecordPressTask: Task<Void, Never>?
    @State private var whisperBeatChatRoomIsRecording = false
    @FocusState private var whisperBeatChatRoomFocusField: WhisperBeatChatRoomFocusField?
    @EnvironmentObject private var whisperBeatChatRoomNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var whisperBeatChatRoomActionSheetCenter: TraceGlowActionSheetCenter
    @EnvironmentObject private var whisperBeatChatRoomFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var whisperBeatChatRoomUserStore: OrbitUserStore
    @EnvironmentObject private var whisperBeatChatRoomRoomStore: RhythmRoomStore
    @EnvironmentObject private var whisperBeatChatRoomMessageStore: WhisperMessageStore
    @EnvironmentObject private var whisperBeatChatRoomGuestGate: CBnxweZGoLogCenter

    var body: some View {
        ZStack {
            ZiveStyle.ColorPalette.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                whisperBeatChatRoomTopBar
                    .padding(.horizontal, 17)
                    .padding(.top, 12)

                whisperBeatChatRoomMessages
                    .padding(.top, 30)

                Spacer()

                whisperBeatChatRoomInputPanel
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            whisperBeatChatRoomFocusField = nil
        }
        .onAppear {
            whisperBeatChatRoomMarkCurrentRoomAsRead()
        }
        .onChange(of: whisperBeatChatRoomMessagesList.count) { _ in
            whisperBeatChatRoomMarkCurrentRoomAsRead()
        }
        .sheet(isPresented: $whisperBeatChatRoomShowsImagePicker) {
            ZiveLegacyMediaPicker(
                ziveLegacyMediaPickerKind: .image,
                ziveLegacyMediaPickerOnImageData: { whisperBeatChatRoomImageData in
                    whisperBeatChatRoomLoadSelectedImage(whisperBeatChatRoomImageData)
                },
                ziveLegacyMediaPickerOnVideoUrl: nil
            )
        }
        .onChange(of: whisperBeatChatRoomFocusField) { whisperBeatChatRoomFocusedField in
            if whisperBeatChatRoomFocusedField == .message {
                whisperBeatChatRoomCollapseVoiceInput()
            }
        }
        .navigationBarHidden(true)
    }

    private var whisperBeatChatRoomTopBar: some View {
        HStack(spacing: 12) {
            GrooveStreakTopNavigationBar(title: nil)
                .frame(width: 44)

            ZiveSmartImage(ziveSmartImagePath: whisperBeatChatRoomOtherUser?.orbitUserAvatar ?? "") {
                Circle()
                    .fill(Color.white.opacity(0.14))
            }
                .frame(width: 32, height: 32)
                .clipShape(Circle())

            Text(whisperBeatChatRoomOtherUser?.orbitUserName ?? "Zive User")
                .font(ZiveStyle.FontBook.boldItalic(18))
                .foregroundStyle(ZiveStyle.ColorPalette.textPink)

            Spacer()

            Button {
                whisperBeatChatRoomShowReportSheet()
            } label: {
                Image("ZIVEBarReport")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
    }

    private var whisperBeatChatRoomMessages: some View {
        ScrollViewReader { whisperBeatChatRoomScrollProxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(whisperBeatChatRoomMessagesList) { whisperBeatChatRoomMessageItem in
                        whisperBeatChatRoomMessageRow(
                            whisperBeatChatRoomMessageItem: whisperBeatChatRoomMessageItem
                        )
                        .id(whisperBeatChatRoomMessageItem.id)
                    }
                }
                .padding(.bottom, 16)
            }
            .onAppear {
                whisperBeatChatRoomScrollToBottom(whisperBeatChatRoomScrollProxy)
            }
            .onChange(of: whisperBeatChatRoomMessagesList.count) { _ in
                whisperBeatChatRoomScrollToBottom(whisperBeatChatRoomScrollProxy)
            }
        }
        .padding(.horizontal, 20)
    }

    private var whisperBeatChatRoomInputPanel: some View {
        VStack(spacing: 0) {
            HStack(spacing: 13) {
                whisperBeatChatRoomToolButton(
                    imageName: whisperBeatChatRoomInputMode == .voice ? "ZIVEKeybord" : "ZIVEMicPhone"
                ) {
                    whisperBeatChatRoomGuestGate.CBnxweZGoLogRequireLogin {
                        whisperBeatChatRoomInputMode = whisperBeatChatRoomInputMode == .voice ? .text : .voice
                    }
                }

                Button {
                    whisperBeatChatRoomGuestGate.CBnxweZGoLogRequireLogin {
                        whisperBeatChatRoomShowsImagePicker = true
                    }
                } label: {
                    whisperBeatChatRoomToolButtonLabel(imageName: "ZIVESendIMage")
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, 17)
            .padding(.top, 12)

            HStack(spacing: 10) {
                ZiveTextField(
                    placeholder: "Enter",
                    text: $whisperBeatChatRoomMessage,
                    isFocused: whisperBeatChatRoomFocusField == .message,
                    variant: .translucent,
                    focusState: $whisperBeatChatRoomFocusField,
                    focusEquals: .message
                )
                .frame(height: 48)

                Button {
                    whisperBeatChatRoomGuestGate.CBnxweZGoLogRequireLogin {
                        whisperBeatChatRoomSendTextMessage()
                    }
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(colors: [
                                Color(red: 1, green: 244/255, blue: 235/255),
                                Color(red: 1, green: 199/255, blue: 220/255)
                            ], startPoint: .trailing, endPoint: .leading))
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(colors: [
                                ZiveStyle.ColorPalette.brandOrange,
                                ZiveStyle.ColorPalette.brandPink
                            ], startPoint: .trailing, endPoint: .leading))
                            .padding(.horizontal, 3)
                            .padding(.vertical, 2)
                            .blur(radius: 4)
                        Image("ZIVESend")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }.frame(width: 72, height: 53)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 17)
            .padding(.top, 9)

            if whisperBeatChatRoomInputMode == .voice {
                VStack(spacing: 22) {
                    
                    Image(systemName: whisperBeatChatRoomIsRecording ? "waveform.circle.fill" : "waveform")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(
                            whisperBeatChatRoomIsRecording
                            ? ZiveStyle.ColorPalette.brandPink
                            : Color.white.opacity(0.9)
                        )

                    ZStack{
                        Circle()
                            .fill(.white.opacity(whisperBeatChatRoomIsRecording ? 0.26 : 0.15))
                            .frame(width: 72, height: 72)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ZiveStyle.ColorPalette.brandPink,
                                        ZiveStyle.ColorPalette.brandOrange.opacity(0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: whisperBeatChatRoomIsRecording ? 82 : 72, height: whisperBeatChatRoomIsRecording ? 82 : 72)
                            .blur(radius: 8)
                            .overlay {
                                Image("ZIVEMicPhone")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                    }
                    .contentShape(Circle())
                    .simultaneousGesture(whisperBeatChatRoomRecordGesture)
                }
                .padding(.top, 25)
                .padding(.bottom, 28)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Spacer()
                    .frame(height: 35)
            }
        }
        .padding(.bottom, 10)
        .background(Color.white.opacity(0.12))
        .animation(.easeInOut(duration: 0.22), value: whisperBeatChatRoomInputMode)
    }

    private func whisperBeatChatRoomToolButton(
        imageName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.14))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
        }
        .buttonStyle(.plain)
        .transaction { whisperBeatChatRoomTransaction in
            whisperBeatChatRoomTransaction.animation = nil
        }
    }

    private func whisperBeatChatRoomToolButtonLabel(imageName: String) -> some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.white.opacity(0.14))
            .frame(width: 44, height: 44)
            .overlay {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
    }

    private var whisperBeatChatRoomCurrentUserId: String {
        QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var whisperBeatChatRoomRoom: RhythmRoomModel? {
        whisperBeatChatRoomRoomStore.rhythmRoomFetch(by: whisperBeatChatRoomId)
    }

    private var whisperBeatChatRoomOtherUser: OrbitUserModel? {
        guard let whisperBeatChatRoomRoom else {
            return nil
        }

        let whisperBeatChatRoomOtherUserId = whisperBeatChatRoomRoom.rhythmRoomUserIds.first {
            $0 != whisperBeatChatRoomCurrentUserId
        }

        guard let whisperBeatChatRoomOtherUserId else {
            return nil
        }

        return whisperBeatChatRoomUserStore.orbitUserFetch(by: whisperBeatChatRoomOtherUserId)
    }

    private var whisperBeatChatRoomMessagesList: [WhisperMessageModel] {
        whisperBeatChatRoomMessageStore.whisperMessageFetchByRoomId(whisperBeatChatRoomId)
    }

    private func whisperBeatChatRoomMessageRow(
        whisperBeatChatRoomMessageItem: WhisperMessageModel
    ) -> some View {
        let whisperBeatChatRoomIsMyMessage = whisperBeatChatRoomMessageItem.whisperMessageSenderId == whisperBeatChatRoomCurrentUserId

        return HStack {
            if whisperBeatChatRoomIsMyMessage {
                Spacer()
                whisperBeatChatRoomMessageBubble(
                    whisperBeatChatRoomMessageItem: whisperBeatChatRoomMessageItem,
                    whisperBeatChatRoomIsMyMessage: true
                )
            } else {
                whisperBeatChatRoomMessageBubble(
                    whisperBeatChatRoomMessageItem: whisperBeatChatRoomMessageItem,
                    whisperBeatChatRoomIsMyMessage: false
                )
                Spacer()
            }
        }
    }

    private func whisperBeatChatRoomMessageBubble(
        whisperBeatChatRoomMessageItem: WhisperMessageModel,
        whisperBeatChatRoomIsMyMessage: Bool
    ) -> some View {
        Group {
            if !whisperBeatChatRoomMessageItem.whisperMessageImagePath
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty {
                ZiveSmartImage(
                    ziveSmartImagePath: whisperBeatChatRoomMessageItem.whisperMessageImagePath
                ) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.15))
                }
                .frame(width: 180, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else if !whisperBeatChatRoomMessageItem.whisperMessageVoicePath
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty {
                Button {
                    whisperBeatChatRoomPlayVoiceMessage(whisperBeatChatRoomMessageItem)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "waveform")
                            .font(.system(size: 12, weight: .semibold))

                        Text("\(max(1, Int(ceil(whisperBeatChatRoomMessageItem.whisperMessageVoiceDuration))))s")
                            .font(ZiveStyle.FontBook.regular(14))
                    }
                    .foregroundStyle(whisperBeatChatRoomIsMyMessage ? Color.white : ZiveStyle.ColorPalette.textPrimary)
                    .padding(.horizontal, 25)
                    .frame(height: 43)
                    .background(whisperBeatChatRoomBubbleBackground(whisperBeatChatRoomIsMyMessage))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                Text(whisperBeatChatRoomMessageItem.whisperMessageText)
                    .font(ZiveStyle.FontBook.regular(14))
                    .foregroundStyle(whisperBeatChatRoomIsMyMessage ? Color.white : ZiveStyle.ColorPalette.textPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(whisperBeatChatRoomBubbleBackground(whisperBeatChatRoomIsMyMessage))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
        }
    }

    @ViewBuilder
    private func whisperBeatChatRoomBubbleBackground(_ whisperBeatChatRoomIsMyMessage: Bool) -> some View {
        if whisperBeatChatRoomIsMyMessage {
            LinearGradient(
                colors: [
                    ZiveStyle.ColorPalette.brandPink,
                    ZiveStyle.ColorPalette.brandOrange
                ],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
        } else {
            Color.white
        }
    }

    private func whisperBeatChatRoomSendTextMessage() {
        let whisperBeatChatRoomTrimmedMessage = whisperBeatChatRoomMessage
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !whisperBeatChatRoomTrimmedMessage.isEmpty else {
            whisperBeatChatRoomFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Message cannot be empty",
                status: .error
            )
            return
        }

        guard !whisperBeatChatRoomCurrentUserId.isEmpty,
              whisperBeatChatRoomRoom != nil else {
            whisperBeatChatRoomFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Chat room not found",
                status: .error
            )
            return
        }

        let whisperBeatChatRoomSendTime = Date()
        let whisperBeatChatRoomNewMessage = WhisperMessageModel(
            id: "message_\(UUID().uuidString)",
            whisperMessageRoomId: whisperBeatChatRoomId,
            whisperMessageSenderId: whisperBeatChatRoomCurrentUserId,
            whisperMessageText: whisperBeatChatRoomTrimmedMessage,
            whisperMessageImagePath: "",
            whisperMessageVoicePath: "",
            whisperMessageVoiceDuration: 0,
            whisperMessageSendTime: whisperBeatChatRoomSendTime
        )

        whisperBeatChatRoomMessageStore.whisperMessageCreate(whisperBeatChatRoomNewMessage)
        whisperBeatChatRoomRoomStore.rhythmRoomUpdateLastMessage(
            roomId: whisperBeatChatRoomId,
            senderId: whisperBeatChatRoomCurrentUserId,
            messageText: whisperBeatChatRoomTrimmedMessage,
            sendTime: whisperBeatChatRoomSendTime,
            unreadMessageCount: 1
        )
        whisperBeatChatRoomMessage = ""
        whisperBeatChatRoomFocusField = nil
    }

    private func whisperBeatChatRoomCreateMediaMessage(
        imagePath: String,
        voicePath: String,
        voiceDuration: TimeInterval,
        lastMessageText: String
    ) {
        guard !whisperBeatChatRoomCurrentUserId.isEmpty,
              whisperBeatChatRoomRoom != nil else {
            whisperBeatChatRoomFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Chat room not found",
                status: .error
            )
            return
        }

        let whisperBeatChatRoomSendTime = Date()
        let whisperBeatChatRoomNewMessage = WhisperMessageModel(
            id: "message_\(UUID().uuidString)",
            whisperMessageRoomId: whisperBeatChatRoomId,
            whisperMessageSenderId: whisperBeatChatRoomCurrentUserId,
            whisperMessageText: "",
            whisperMessageImagePath: imagePath,
            whisperMessageVoicePath: voicePath,
            whisperMessageVoiceDuration: voiceDuration,
            whisperMessageSendTime: whisperBeatChatRoomSendTime
        )

        whisperBeatChatRoomMessageStore.whisperMessageCreate(whisperBeatChatRoomNewMessage)
        whisperBeatChatRoomRoomStore.rhythmRoomUpdateLastMessage(
            roomId: whisperBeatChatRoomId,
            senderId: whisperBeatChatRoomCurrentUserId,
            messageText: lastMessageText,
            sendTime: whisperBeatChatRoomSendTime,
            unreadMessageCount: 1
        )
    }

    private func whisperBeatChatRoomLoadSelectedImage(_ whisperBeatChatRoomImageData: Data) {
        guard !QeixbgBriwyState.qeixbgBriwyIsGuestUser() else {
            whisperBeatChatRoomGuestGate.CBnxweZGoLogPresent()
            return
        }

        do {
            let whisperBeatChatRoomImageUrl = try whisperBeatChatRoomSaveMediaData(
                whisperBeatChatRoomImageData,
                prefix: "whisperBeatImage",
                preferredExtension: "jpg"
            )

            whisperBeatChatRoomCreateMediaMessage(
                imagePath: whisperBeatChatRoomImageUrl.path,
                voicePath: "",
                voiceDuration: 0,
                lastMessageText: "[Image]"
            )
        } catch {
            whisperBeatChatRoomFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Failed to send image",
                status: .error
            )
        }
    }

    private func whisperBeatChatRoomStartVoiceRecording() {
        guard !QeixbgBriwyState.qeixbgBriwyIsGuestUser() else {
            whisperBeatChatRoomCancelScheduledVoiceRecording()
            whisperBeatChatRoomGuestGate.CBnxweZGoLogPresent()
            return
        }

        guard !whisperBeatChatRoomIsRecording else {
            return
        }

        let whisperBeatChatRoomAudioSession = AVAudioSession.sharedInstance()
        switch whisperBeatChatRoomAudioSession.recordPermission {
        case .granted:
            whisperBeatChatRoomBeginVoiceRecording()
        case .denied:
            whisperBeatChatRoomFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Microphone permission denied",
                status: .error
            )
        case .undetermined:
            whisperBeatChatRoomAudioSession.requestRecordPermission { whisperBeatChatRoomIsAllowed in
                DispatchQueue.main.async {
                    if whisperBeatChatRoomIsAllowed {
                        whisperBeatChatRoomBeginVoiceRecording()
                    } else {
                        whisperBeatChatRoomFeedbackCenter.ziveGlobalFeedbackShowToast(
                            text: "Microphone permission denied",
                            status: .error
                        )
                    }
                }
            }
        @unknown default:
            whisperBeatChatRoomFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Microphone unavailable",
                status: .error
            )
        }
    }

    private var whisperBeatChatRoomRecordGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                whisperBeatChatRoomScheduleVoiceRecording()
            }
            .onEnded { _ in
                whisperBeatChatRoomCancelScheduledVoiceRecording()
                whisperBeatChatRoomFinishVoiceRecording()
            }
    }

    private func whisperBeatChatRoomScheduleVoiceRecording() {
        guard whisperBeatChatRoomRecordPressTask == nil,
              !whisperBeatChatRoomIsRecording else {
            return
        }

        whisperBeatChatRoomRecordPressTask = Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                whisperBeatChatRoomRecordPressTask = nil
                whisperBeatChatRoomStartVoiceRecording()
            }
        }
    }

    private func whisperBeatChatRoomCancelScheduledVoiceRecording() {
        whisperBeatChatRoomRecordPressTask?.cancel()
        whisperBeatChatRoomRecordPressTask = nil
    }

    private func whisperBeatChatRoomCollapseVoiceInput() {
        whisperBeatChatRoomCancelScheduledVoiceRecording()
        if whisperBeatChatRoomIsRecording {
            whisperBeatChatRoomFinishVoiceRecording()
        }
        whisperBeatChatRoomInputMode = .text
    }

    private func whisperBeatChatRoomBeginVoiceRecording() {
        do {
            let whisperBeatChatRoomAudioSession = AVAudioSession.sharedInstance()
            try whisperBeatChatRoomAudioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try whisperBeatChatRoomAudioSession.setActive(true)

            let whisperBeatChatRoomAudioUrl = whisperBeatChatRoomDocumentsDirectory()
                .appendingPathComponent("whisperBeatVoice_\(UUID().uuidString).m4a")
            let whisperBeatChatRoomSettings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let whisperBeatChatRoomRecorder = try AVAudioRecorder(
                url: whisperBeatChatRoomAudioUrl,
                settings: whisperBeatChatRoomSettings
            )
            whisperBeatChatRoomRecorder.record()

            whisperBeatChatRoomAudioRecorder = whisperBeatChatRoomRecorder
            whisperBeatChatRoomRecordingUrl = whisperBeatChatRoomAudioUrl
            whisperBeatChatRoomRecordingStartTime = Date()
            whisperBeatChatRoomIsRecording = true
        } catch {
            whisperBeatChatRoomFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Failed to start recording",
                status: .error
            )
        }
    }

    private func whisperBeatChatRoomFinishVoiceRecording() {
        guard whisperBeatChatRoomIsRecording,
              let whisperBeatChatRoomAudioRecorder,
              let whisperBeatChatRoomRecordingUrl else {
            return
        }

        whisperBeatChatRoomAudioRecorder.stop()
        whisperBeatChatRoomIsRecording = false
        self.whisperBeatChatRoomAudioRecorder = nil

        let whisperBeatChatRoomDuration = Date().timeIntervalSince(
            whisperBeatChatRoomRecordingStartTime ?? Date()
        )
        whisperBeatChatRoomRecordingStartTime = nil
        self.whisperBeatChatRoomRecordingUrl = nil

        guard whisperBeatChatRoomDuration >= 0.5 else {
            try? FileManager.default.removeItem(at: whisperBeatChatRoomRecordingUrl)
            whisperBeatChatRoomFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Hold to record voice",
                status: .error
            )
            return
        }

        whisperBeatChatRoomCreateMediaMessage(
            imagePath: "",
            voicePath: whisperBeatChatRoomRecordingUrl.path,
            voiceDuration: whisperBeatChatRoomDuration,
            lastMessageText: "[Voice]"
        )
    }

    private func whisperBeatChatRoomPlayVoiceMessage(_ whisperBeatChatRoomMessageItem: WhisperMessageModel) {
        let whisperBeatChatRoomVoicePath = whisperBeatChatRoomMessageItem.whisperMessageVoicePath
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !whisperBeatChatRoomVoicePath.isEmpty else {
            return
        }

        do {
            let whisperBeatChatRoomVoiceUrl = URL(fileURLWithPath: whisperBeatChatRoomVoicePath)
            whisperBeatChatRoomAudioPlayer = try AVAudioPlayer(contentsOf: whisperBeatChatRoomVoiceUrl)
            whisperBeatChatRoomAudioPlayer?.play()
        } catch {
            whisperBeatChatRoomFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Failed to play voice",
                status: .error
            )
        }
    }

    private func whisperBeatChatRoomSaveMediaData(
        _ whisperBeatChatRoomData: Data,
        prefix: String,
        preferredExtension: String
    ) throws -> URL {
        let whisperBeatChatRoomSafeExtension = preferredExtension.isEmpty ? "dat" : preferredExtension
        let whisperBeatChatRoomFileUrl = whisperBeatChatRoomDocumentsDirectory()
            .appendingPathComponent("\(prefix)_\(UUID().uuidString).\(whisperBeatChatRoomSafeExtension)")

        try whisperBeatChatRoomData.write(to: whisperBeatChatRoomFileUrl, options: .atomic)
        return whisperBeatChatRoomFileUrl
    }

    private func whisperBeatChatRoomDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func whisperBeatChatRoomMarkCurrentRoomAsRead() {
        whisperBeatChatRoomRoomStore.rhythmRoomMarkAsRead(roomId: whisperBeatChatRoomId)
    }

    private func whisperBeatChatRoomScrollToBottom(_ whisperBeatChatRoomScrollProxy: ScrollViewProxy) {
        guard let whisperBeatChatRoomLastMessageId = whisperBeatChatRoomMessagesList.last?.id else {
            return
        }

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.2)) {
                whisperBeatChatRoomScrollProxy.scrollTo(whisperBeatChatRoomLastMessageId, anchor: .bottom)
            }
        }
    }

    private func whisperBeatChatRoomShowReportSheet() {
        guard !QeixbgBriwyState.qeixbgBriwyIsGuestUser() else {
            whisperBeatChatRoomGuestGate.CBnxweZGoLogPresent()
            return
        }

        guard let whisperBeatChatRoomOtherUser else {
            return
        }

        whisperBeatChatRoomActionSheetCenter.traceGlowActionSheetCenterPresent(
            targetUserId: whisperBeatChatRoomOtherUser.id
        ) {
            whisperBeatChatRoomNavigator.weioZwivbePopToRoot()
        }
    }
}
