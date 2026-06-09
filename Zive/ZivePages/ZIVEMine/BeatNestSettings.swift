import SwiftUI

struct BeatNestSettings: View {
    @EnvironmentObject private var weioZwivbeNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var beatNestSettingsFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var beatNestSettingsUserStore: OrbitUserStore
    @EnvironmentObject private var beatNestSettingsVideoStore: ReelVideoStore
    @EnvironmentObject private var beatNestSettingsCommentStore: EchoCommentStore
    @EnvironmentObject private var beatNestSettingsPlanStore: TempoPlanStore
    @EnvironmentObject private var beatNestSettingsRoomStore: RhythmRoomStore
    @EnvironmentObject private var beatNestSettingsMessageStore: WhisperMessageStore
    @State private var beatNestSettingsShowDeleteAccountDialog = false
    @State private var beatNestSettingsIsDeletingAccount = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GrooveStreakTopNavigationBar(title: nil)
                    .padding(.horizontal, 17)
                    .padding(.top, 12)

                VStack(spacing: 15) {
                    beatNestSettingsRow(title: "c30548121139617d35d0c4820cd8cc0b".grooveCipherAESDecrypt()) {
                        weioZwivbeNavigator.weioZwivbePush(.blockBeatRoster)
                    }

                    beatNestSettingsRow(title: "a4f27d37b5b103ca95dd63121fafa3cd".grooveCipherAESDecrypt()) {
                        weioZwivbeNavigator.weioZwivbePush(.sedivaoBeiwWeb("234134a38cb97bfc9ac9197dad451a22c7798ce7a7d729583e7c7d8fe2bbcb89370552b5fd79dedf69202a3890f0417a".grooveCipherAESDecrypt()))
                    }
                    beatNestSettingsRow(title: "4d5b130954398e160834ad10b538d92f".grooveCipherAESDecrypt()) {
                        weioZwivbeNavigator.weioZwivbePush(.sedivaoBeiwWeb("234134a38cb97bfc9ac9197dad451a22fdf99b352d9bf551bb196dd79f385219".grooveCipherAESDecrypt()))
                    }
                    beatNestSettingsRow(title: "bd28b8fc8547d889b87b590e174631c4".grooveCipherAESDecrypt()) {
                        beatNestSettingsShowDeleteAccountDialog = true
                    }
                    beatNestSettingsRow(title: "1574fbc1646976468bbd507034a08305".grooveCipherAESDecrypt()) {
                        beatNestSettingsLogOut()
                    }
                }
                .padding(.horizontal, 17)
                .padding(.top, 30)

                Spacer()
            }

            if beatNestSettingsShowDeleteAccountDialog {
                BreakStepDeleteAccountDialog(
                    breakStepDeleteAccountIsPresented: $beatNestSettingsShowDeleteAccountDialog
                ) {
                    beatNestSettingsDeleteCurrentAccountWithLoading()
                }
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: beatNestSettingsShowDeleteAccountDialog)
        .ziveScreenBackground()
        .navigationBarHidden(true)
    }

    private func beatNestSettingsRow(
        title: String,
        action: (() -> Void)? = nil
    ) -> some View {
        Button {
            if let action {
                action()
            }
        } label: {
            beatNestSettingsRowContent(title: title)
        }
        .buttonStyle(.plain)
    }

    private func beatNestSettingsRowContent(title: String) -> some View {
        HStack {
            Text(title)
                .font(ZiveStyle.FontBook.boldItalic(18))
                .foregroundStyle(ZiveStyle.ColorPalette.textPink)

            Spacer()

            Image("ZIVESettingGo")
                .resizable()
                .frame(width: 20, height: 20)
        }
        .padding(.horizontal, 24)
        .frame(height: 49)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var beatNestSettingsCurrentUserId: String {
        QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func beatNestSettingsLogOut() {
        QeixbgBriwyState.qeixbgBriwyCurrentUserId = ""
        weioZwivbeNavigator.weioZwivbePresentRoot(.eiwoqcZceioGuide)
    }

    private func beatNestSettingsDeleteCurrentAccountWithLoading() {
        guard !beatNestSettingsIsDeletingAccount else {
            return
        }

        beatNestSettingsIsDeletingAccount = true
        beatNestSettingsFeedbackCenter.ziveGlobalFeedbackShowLoading(
            text: "Deleting..."
        )

        Task {
            await delay(2)
            await MainActor.run {
                beatNestSettingsFeedbackCenter.ziveGlobalFeedbackHideLoading()
                beatNestSettingsIsDeletingAccount = false
                beatNestSettingsDeleteCurrentAccount()
            }
        }
    }

    private func beatNestSettingsDeleteCurrentAccount() {
        let beatNestSettingsDeletingUserId = beatNestSettingsCurrentUserId

        guard !beatNestSettingsDeletingUserId.isEmpty,
              let beatNestSettingsDeletingUser = beatNestSettingsUserStore.orbitUserFetch(
                by: beatNestSettingsDeletingUserId
              ) else {
            beatNestSettingsFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Current user not found",
                status: .error
            )
            beatNestSettingsLogOut()
            return
        }

        let beatNestSettingsDeletedVideoIds = Set(
            beatNestSettingsVideoStore.reelVideoItems
                .filter { $0.reelVideoPublisherId == beatNestSettingsDeletingUserId }
                .map(\.id)
        )

        beatNestSettingsDeleteLocalFileIfNeeded(beatNestSettingsDeletingUser.orbitUserAvatar)
        beatNestSettingsVideoStore.reelVideoItems
            .filter { $0.reelVideoPublisherId == beatNestSettingsDeletingUserId }
            .forEach { beatNestSettingsVideo in
                beatNestSettingsDeleteLocalFileIfNeeded(beatNestSettingsVideo.reelVideoCoverUrl)
                beatNestSettingsDeleteLocalFileIfNeeded(beatNestSettingsVideo.reelVideoUrl)
            }

        beatNestSettingsCommentStore.echoCommentReplaceAll(
            with: beatNestSettingsCommentStore.echoCommentItems.filter { beatNestSettingsComment in
                beatNestSettingsComment.echoCommentPublisherId != beatNestSettingsDeletingUserId
                && !beatNestSettingsDeletedVideoIds.contains(beatNestSettingsComment.echoCommentVideoId)
            }
        )

        beatNestSettingsVideoStore.reelVideoReplaceAll(
            with: beatNestSettingsVideoStore.reelVideoItems.filter {
                $0.reelVideoPublisherId != beatNestSettingsDeletingUserId
            }
        )

        beatNestSettingsPlanStore.tempoPlanReplaceAll(
            with: beatNestSettingsPlanStore.tempoPlanItems.filter {
                $0.tempoPlanPublisherId != beatNestSettingsDeletingUserId
            }
        )

        let beatNestSettingsDeletedRoomIds = Set(
            beatNestSettingsRoomStore.rhythmRoomItems
                .filter { $0.rhythmRoomUserIds.contains(beatNestSettingsDeletingUserId) }
                .map(\.id)
        )

        beatNestSettingsDeletedRoomIds.forEach {
            beatNestSettingsMessageStore.whisperMessageDeleteByRoomId($0)
        }
        beatNestSettingsRoomStore.rhythmRoomReplaceAll(
            with: beatNestSettingsRoomStore.rhythmRoomItems.filter {
                !$0.rhythmRoomUserIds.contains(beatNestSettingsDeletingUserId)
            }
        )

        beatNestSettingsUserStore.orbitUserReplaceAll(
            with: beatNestSettingsUserStore.orbitUserItems
                .filter { $0.id != beatNestSettingsDeletingUserId }
                .map { beatNestSettingsUser in
                    var beatNestSettingsCleanedUser = beatNestSettingsUser
                    beatNestSettingsCleanedUser.orbitUserFollowerIds.removeAll {
                        $0 == beatNestSettingsDeletingUserId
                    }
                    beatNestSettingsCleanedUser.orbitUserFollowingIds.removeAll {
                        $0 == beatNestSettingsDeletingUserId
                    }
                    beatNestSettingsCleanedUser.orbitUserBlockedIds.removeAll {
                        $0 == beatNestSettingsDeletingUserId
                    }
                    beatNestSettingsCleanedUser.orbitUserLikedVideoIds.removeAll {
                        beatNestSettingsDeletedVideoIds.contains($0)
                    }
                    return beatNestSettingsCleanedUser
                }
        )

        QeixbgBriwyState.qeixbgBriwyCurrentUserId = ""
        beatNestSettingsFeedbackCenter.ziveGlobalFeedbackShowToast(
            text: "Account deleted",
            status: .success
        )
        weioZwivbeNavigator.weioZwivbePresentRoot(.eiwoqcZceioGuide)
    }

    private func beatNestSettingsDeleteLocalFileIfNeeded(_ beatNestSettingsPath: String) {
        let beatNestSettingsTrimmedPath = beatNestSettingsPath.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !beatNestSettingsTrimmedPath.isEmpty else {
            return
        }

        let beatNestSettingsUrl: URL?
        if let beatNestSettingsParsedUrl = URL(string: beatNestSettingsTrimmedPath),
           beatNestSettingsParsedUrl.scheme?.lowercased() == "file" {
            beatNestSettingsUrl = beatNestSettingsParsedUrl
        } else if beatNestSettingsTrimmedPath.hasPrefix("/") {
            beatNestSettingsUrl = URL(fileURLWithPath: beatNestSettingsTrimmedPath)
        } else {
            beatNestSettingsUrl = nil
        }

        guard let beatNestSettingsUrl else {
            return
        }

        try? FileManager.default.removeItem(at: beatNestSettingsUrl)
    }
}
