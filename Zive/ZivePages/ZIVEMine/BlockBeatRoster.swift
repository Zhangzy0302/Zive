import SwiftUI

struct BlockBeatRoster: View {
    @EnvironmentObject private var blockBeatRosterUserStore: OrbitUserStore
    @EnvironmentObject private var blockBeatRosterFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var blockBeatRosterGuestGate: CBnxweZGoLogCenter

    var body: some View {
        ZStack(alignment: .top) {
            Image("ZIVETopDecoration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                GrooveStreakTopNavigationBar(title: "Blacklist")
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                ScrollView {
                    if blockBeatRosterBlockedUsers.isEmpty {
                        VStack(spacing: 14) {
                            Text("No blocked users yet")
                                .font(ZiveStyle.FontBook.boldItalic(18))
                                .foregroundStyle(Color.white.opacity(0.92))

                            Text("Users you block will appear here.")
                                .font(ZiveStyle.FontBook.regular(14))
                                .foregroundStyle(Color.white.opacity(0.52))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else {
                        VStack(spacing: 13) {
                            ForEach(blockBeatRosterBlockedUsers) { blockBeatRosterUser in
                                blockBeatRosterUserRow(blockBeatRosterUser: blockBeatRosterUser)
                            }
                        }
                        .padding(.top, 29)
                    }
                    
                }.padding(.horizontal, 18)

                Spacer()
            }
        }
        .ziveScreenBackground()
        .navigationBarHidden(true)
    }

    private func blockBeatRosterUserRow(blockBeatRosterUser: OrbitUserModel) -> some View {
        HStack(spacing: 12) {
            ZiveSmartImage(ziveSmartImagePath: blockBeatRosterUser.orbitUserAvatar) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.15))
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(blockBeatRosterUser.orbitUserName)
                .font(ZiveStyle.FontBook.boldItalic(14))
                .foregroundStyle(ZiveStyle.ColorPalette.textPink)

            Spacer()

            GrooveStreakButton(title: "Remove", width: 156, height: 39) {
                blockBeatRosterGuestGate.CBnxweZGoLogRequireLogin {
                    blockBeatRosterRemoveBlockedUser(blockBeatRosterUser.id)
                }
            }
        }
        .padding(.leading, 11)
        .padding(.trailing, 19)
        .frame(height: 68)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private var blockBeatRosterCurrentUser: OrbitUserModel? {
        let blockBeatRosterCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return blockBeatRosterUserStore.orbitUserFetch(by: blockBeatRosterCurrentUserId)
    }

    private var blockBeatRosterBlockedUsers: [OrbitUserModel] {
        let blockBeatRosterBlockedIds = blockBeatRosterCurrentUser?.orbitUserBlockedIds ?? []

        return blockBeatRosterBlockedIds.compactMap { blockBeatRosterBlockedUserId in
            blockBeatRosterUserStore.orbitUserFetch(by: blockBeatRosterBlockedUserId)
        }
    }

    private func blockBeatRosterRemoveBlockedUser(_ blockBeatRosterBlockedUserId: String) {
        guard let blockBeatRosterCurrentUser else {
            blockBeatRosterFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Current user not found",
                status: .error
            )
            return
        }

        let blockBeatRosterDidRemove = blockBeatRosterUserStore.orbitUserRemoveBlockedUser(
            currentUserId: blockBeatRosterCurrentUser.id,
            blockedUserId: blockBeatRosterBlockedUserId
        )

        if blockBeatRosterDidRemove {
            blockBeatRosterFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Removed from blacklist",
                status: .success
            )
        }
    }
}
