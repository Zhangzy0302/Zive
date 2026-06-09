import SwiftUI

struct ChatPulseRecently: View {
    @EnvironmentObject private var chatPulseRecentlyNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var chatPulseRecentlyUserStore: OrbitUserStore
    @EnvironmentObject private var chatPulseRecentlyRoomStore: RhythmRoomStore

    var body: some View {
        ZStack(alignment: .top) {
            Image("ZIVETopDecoration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                GrooveStreakTopNavigationBar(title: "Recently")
                    .padding(.horizontal, 18)
                    .padding(.top, 12)

                VStack(spacing: 12) {
                    ForEach(chatPulseRecentlyVisibleRooms) { chatPulseRecentlyRoom in
                        chatPulseRecentlyMessageRow(chatPulseRecentlyRoom: chatPulseRecentlyRoom)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 20)

                Spacer()
            }
        }
        .ziveScreenBackground()
        .navigationBarHidden(true)
    }

    private func chatPulseRecentlyMessageRow(chatPulseRecentlyRoom: RhythmRoomModel) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZiveSmartImage(
                ziveSmartImagePath: chatPulseRecentlyOtherUser(in: chatPulseRecentlyRoom)?.orbitUserAvatar ?? ""
            ) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.15))
            }
            .frame(width: 53, height: 53)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(chatPulseRecentlyOtherUser(in: chatPulseRecentlyRoom)?.orbitUserName ?? "Zive User")
                        .font(ZiveStyle.FontBook.boldItalic(14))
                        .foregroundStyle(ZiveStyle.ColorPalette.textPink)

                    Spacer()

                    Text(chatPulseRecentlyTimeText(chatPulseRecentlyRoom.rhythmRoomLastMessageTime))
                        .font(ZiveStyle.FontBook.regular(14))
                        .foregroundStyle(Color.white.opacity(0.45))
                }

                Text(chatPulseRecentlyRoom.rhythmRoomLastMessageText)
                    .font(ZiveStyle.FontBook.regular(14))
                    .foregroundStyle(Color.white.opacity(0.9))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 2)
        }
        .padding(.leading, 11)
        .padding(.trailing, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture {
            chatPulseRecentlyNavigator.weioZwivbePush(
                .whisperBeatChatRoom(chatPulseRecentlyRoom.id)
            )
        }
    }

    private var chatPulseRecentlyCurrentUser: OrbitUserModel? {
        let chatPulseRecentlyCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return chatPulseRecentlyUserStore.orbitUserFetch(by: chatPulseRecentlyCurrentUserId)
    }

    private var chatPulseRecentlyVisibleRooms: [RhythmRoomModel] {
        guard let chatPulseRecentlyCurrentUser else {
            return []
        }

        let chatPulseRecentlyBlockedIds = Set(chatPulseRecentlyCurrentUser.orbitUserBlockedIds)

        return chatPulseRecentlyRoomStore
            .rhythmRoomFetchByUserId(chatPulseRecentlyCurrentUser.id)
            .filter { chatPulseRecentlyRoom in
                let chatPulseRecentlyOtherUserIds = chatPulseRecentlyRoom.rhythmRoomUserIds.filter {
                    $0 != chatPulseRecentlyCurrentUser.id
                }
                return !chatPulseRecentlyOtherUserIds.contains { chatPulseRecentlyBlockedIds.contains($0) }
            }
            .sorted { $0.rhythmRoomLastMessageTime > $1.rhythmRoomLastMessageTime }
    }

    private func chatPulseRecentlyOtherUser(in chatPulseRecentlyRoom: RhythmRoomModel) -> OrbitUserModel? {
        guard let chatPulseRecentlyCurrentUser else {
            return nil
        }

        let chatPulseRecentlyOtherUserId = chatPulseRecentlyRoom.rhythmRoomUserIds.first {
            $0 != chatPulseRecentlyCurrentUser.id
        }

        guard let chatPulseRecentlyOtherUserId else {
            return nil
        }

        return chatPulseRecentlyUserStore.orbitUserFetch(by: chatPulseRecentlyOtherUserId)
    }

    private func chatPulseRecentlyTimeText(_ chatPulseRecentlyDate: Date) -> String {
        let chatPulseRecentlyFormatter = DateFormatter()
        chatPulseRecentlyFormatter.dateFormat = "h : mm a"
        return chatPulseRecentlyFormatter.string(from: chatPulseRecentlyDate)
    }
}
