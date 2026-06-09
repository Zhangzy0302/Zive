import SwiftUI

struct EchoPulseProfile: View {
    let echoPulseProfileUserId: String
    @EnvironmentObject private var echoPulseProfileNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var echoPulseProfileActionSheetCenter: TraceGlowActionSheetCenter
    @EnvironmentObject private var echoPulseProfileUserStore: OrbitUserStore
    @EnvironmentObject private var echoPulseProfileVideoStore: ReelVideoStore
    @EnvironmentObject private var echoPulseProfileRoomStore: RhythmRoomStore
    @EnvironmentObject private var echoPulseProfileGuestGate: CBnxweZGoLogCenter
    @State private var echoPulseProfileShowsChatAlert = false

    var body: some View {
        ZStack(alignment: .top) {
            echoPulseProfileTopBackground

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    echoPulseProfileProfileSection
                    echoPulseProfileStatsSection
                    echoPulseProfileActionSection
                    echoPulseProfilePostSection
                }
                .padding(.horizontal, 12)
                .padding(.top, 78)
                .padding(.bottom, 24)
            }

            echoPulseProfileTopBar
                .padding(.horizontal, 12)
                .padding(.top, 12)

            if echoPulseProfileShowsChatAlert {
                ZvjieNAlveChatAlert(zvjieNAlveIsPresented: $echoPulseProfileShowsChatAlert)
                    .zIndex(10)
            }
        }
        .ziveScreenBackground()
        .navigationBarHidden(true)
    }

    private var echoPulseProfileTopBackground: some View {
        ZStack(alignment: .topLeading) {
            Image("ZIVETopDecoration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipped()
                .ignoresSafeArea()
        }
    }

    private var echoPulseProfileTopBar: some View {
        HStack {
            GrooveStreakTopNavigationBar(title: nil)

            if !echoPulseProfileIsCurrentUser {
                Button {
                    echoPulseProfileGuestGate.CBnxweZGoLogRequireLogin {
                        echoPulseProfileShowReportSheet()
                    }
                } label: {
                    Image("ZIVEBarReport")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var echoPulseProfileProfileSection: some View {
        VStack(spacing: 8) {
            ZiveSmartImage(ziveSmartImagePath: echoPulseProfileUser?.orbitUserAvatar ?? "") {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.15))
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            HStack(spacing: 8) {
                Text(echoPulseProfileUser?.orbitUserName ?? "Zive User")
                    .font(ZiveStyle.FontBook.italic(18))
                    .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var echoPulseProfileStatsSection: some View {
        HStack {
            echoPulseProfileStatItem(
                value: "\(echoPulseProfileUser?.orbitUserFollowingIds.count ?? 0)",
                title: "Followings"
            )
            Spacer()
            echoPulseProfileStatItem(
                value: "\(echoPulseProfileUser?.orbitUserFollowerIds.count ?? 0)",
                title: "Followers"
            )
            Spacer()
            echoPulseProfileStatItem(
                value: "\(echoPulseProfileUser?.orbitUserReceivedGiftValue ?? 0)",
                title: "Popularity value"
            )
        }
        .padding(.horizontal, 22)
    }

    private func echoPulseProfileStatItem(value: String, title: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(Color.white)

            Text(title)
                .font(ZiveStyle.FontBook.regular(14))
                .foregroundStyle(Color.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
    }

    private var echoPulseProfileActionSection: some View {
        Group {
            if !echoPulseProfileIsCurrentUser {
                HStack(spacing: 13) {
                    Button {
                        echoPulseProfileGuestGate.CBnxweZGoLogRequireLogin {
                            echoPulseProfileToggleFollow()
                        }
                    } label: {
                        HStack(spacing: 9) {
                            Image(systemName: echoPulseProfileIsFollowing ? "checkmark" : "plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text(echoPulseProfileIsFollowing ? "Following" : "Follow")
                                .font(ZiveStyle.FontBook.boldItalic(18))
                        }
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 53)
                        .background(
                            ZStack {
                                Color.white.opacity(0.23)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                LinearGradient(
                                    colors: [
                                        ZiveStyle.ColorPalette.brandPink,
                                        ZiveStyle.ColorPalette.brandOrange
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ).padding(2)
                                    .blur(radius: 8)
                            }
                           
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: ZiveStyle.ColorPalette.brandPink.opacity(0.35), radius: 12, x: 0, y: 0)
                    }
                    .buttonStyle(.plain)

                    Button {
                        echoPulseProfileGuestGate.CBnxweZGoLogRequireLogin {
                            echoPulseProfileOpenChatRoom()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image("ZIVEComment")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                            Text("Chat")
                                .font(ZiveStyle.FontBook.boldItalic(18))
                        }
                        .foregroundStyle(Color.white.opacity(0.95))
                        .frame(maxWidth: .infinity)
                        .frame(height: 53)
                        .background(Color.white.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var echoPulseProfilePostSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Post")
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(Color.white)

            LazyVStack(spacing: 16) {
                ForEach(echoPulseProfilePostVideos) { echoPulseProfileVideo in
                    LegerOerxvPostCard(legerOerxvPostCardVideo: echoPulseProfileVideo)
                }
            }
        }
    }

    private var echoPulseProfileUser: OrbitUserModel? {
        echoPulseProfileUserStore.orbitUserFetch(by: echoPulseProfileUserId)
    }

    private var echoPulseProfileCurrentUserId: String {
        QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var echoPulseProfileIsCurrentUser: Bool {
        echoPulseProfileCurrentUserId == echoPulseProfileUserId
    }

    private var echoPulseProfileIsFollowing: Bool {
        guard let echoPulseProfileCurrentUser = echoPulseProfileUserStore.orbitUserFetch(by: echoPulseProfileCurrentUserId) else {
            return false
        }

        return echoPulseProfileCurrentUser.orbitUserFollowingIds.contains(echoPulseProfileUserId)
    }

    private var echoPulseProfileIsMutualFollowing: Bool {
        guard let echoPulseProfileCurrentUser = echoPulseProfileUserStore.orbitUserFetch(by: echoPulseProfileCurrentUserId),
              let echoPulseProfileUser else {
            return false
        }

        return echoPulseProfileCurrentUser.orbitUserFollowingIds.contains(echoPulseProfileUserId)
            && echoPulseProfileUser.orbitUserFollowingIds.contains(echoPulseProfileCurrentUserId)
    }

    private var echoPulseProfilePostVideos: [ReelVideoModel] {
        echoPulseProfileVideoStore
            .reelVideoFetchByPublisherId(echoPulseProfileUserId)
            .sorted { $0.id > $1.id }
    }

    private func echoPulseProfileToggleFollow() {
        guard !echoPulseProfileCurrentUserId.isEmpty else {
            return
        }

        _ = echoPulseProfileUserStore.orbitUserToggleFollow(
            currentUserId: echoPulseProfileCurrentUserId,
            targetUserId: echoPulseProfileUserId
        )
    }

    private func echoPulseProfileOpenChatRoom() {
        guard !echoPulseProfileCurrentUserId.isEmpty,
              echoPulseProfileCurrentUserId != echoPulseProfileUserId else {
            return
        }

        guard echoPulseProfileIsMutualFollowing else {
            echoPulseProfileShowsChatAlert = true
            return
        }

        if let echoPulseProfileExistingRoom = echoPulseProfileRoomStore.rhythmRoomFetchBetweenUsers([
            echoPulseProfileCurrentUserId,
            echoPulseProfileUserId
        ]) {
            echoPulseProfileNavigator.weioZwivbePush(
                .whisperBeatChatRoom(echoPulseProfileExistingRoom.id)
            )
            return
        }

        let echoPulseProfileNewRoom = RhythmRoomModel(
            id: "room_\(UUID().uuidString)",
            rhythmRoomUserIds: [echoPulseProfileCurrentUserId, echoPulseProfileUserId],
            rhythmRoomLastMessageTime: Date(),
            rhythmRoomLastSenderId: echoPulseProfileCurrentUserId,
            rhythmRoomLastMessageText: "",
            rhythmRoomUnreadMessageCount: 0
        )

        echoPulseProfileRoomStore.rhythmRoomCreate(echoPulseProfileNewRoom)
        echoPulseProfileNavigator.weioZwivbePush(
            .whisperBeatChatRoom(echoPulseProfileNewRoom.id)
        )
    }

    private func echoPulseProfileShowReportSheet() {
        guard !echoPulseProfileIsCurrentUser else {
            return
        }

        echoPulseProfileActionSheetCenter.traceGlowActionSheetCenterPresent(
            targetUserId: echoPulseProfileUserId
        ) {
            echoPulseProfileNavigator.weioZwivbePopToRoot()
        }
    }
}
