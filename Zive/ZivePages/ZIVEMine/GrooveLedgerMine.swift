import SwiftUI

struct GrooveLedgerMine: View {
    @EnvironmentObject var groroveNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var grooveLedgerMineGuestGate: CBnxweZGoLogCenter
    @EnvironmentObject private var grooveLedgerMineUserStore: OrbitUserStore
    @EnvironmentObject private var grooveLedgerMineVideoStore: ReelVideoStore

    var body: some View {
            ZStack(alignment: .top) {
                grooveLedgerMineTopBackground
                ScrollView{
                    VStack(alignment: .leading, spacing: 20) {
                        grooveLedgerMineProfileSection
                        grooveLedgerMineStatsSection
                        grooveLedgerMineWalletCard
                            .onTapGesture {
                                grooveLedgerMineGuestGate.CBnxweZGoLogRequireLogin {
                                    groroveNavigator.weioZwivbePush(.cocoaPulseWallet)
                                }
                            }
                        grooveLedgerMinePostSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 26)
                }
                
                grooveLedgerMineTopBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
            }
        
        .ziveScreenBackground()
        .navigationBarHidden(true)
    }

    private var grooveLedgerMineCurrentUser: OrbitUserModel? {
        let grooveLedgerMineCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return grooveLedgerMineUserStore.orbitUserFetch(by: grooveLedgerMineCurrentUserId)
    }

    private var grooveLedgerMineTopBackground: some View {
        ZStack(alignment: .top) {
            Image("ZIVEGuideBg")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipped()
                .ignoresSafeArea()
        }
    }

    private var grooveLedgerMineTopBar: some View {
        HStack {
            GrooveStreakTopNavigationBar(title: nil)

            Image("ZIVESetting")
                .resizable()
                .frame(width: 40, height: 40)
                .onTapGesture {
                    groroveNavigator.weioZwivbePush(.beatNestSettings)
                }
        }
    }

    private var grooveLedgerMineProfileSection: some View {
        VStack(spacing: 8) {
            ZiveSmartImage(ziveSmartImagePath: grooveLedgerMineCurrentUser?.orbitUserAvatar ?? "") {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .overlay {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 46, height: 46)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        ZiveStyle.ColorPalette.brandOrange,
                                        ZiveStyle.ColorPalette.brandPink
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            HStack(spacing: 8) {
                Text(grooveLedgerMineCurrentUser?.orbitUserName ?? "Zive User")
                    .font(ZiveStyle.FontBook.italic(18))
                    .foregroundStyle(Color.white)

                Image("ZIVEEdit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }.onTapGesture {
                grooveLedgerMineGuestGate.CBnxweZGoLogRequireLogin {
                    groroveNavigator.weioZwivbePush(.stepGlowEditProfile)
                }
            }
            .frame(maxWidth: .infinity)
        }.padding(.top, 56)
    }

    private var grooveLedgerMineStatsSection: some View {
        HStack {
            grooveLedgerMineStatItem(
                value: "\(grooveLedgerMineCurrentUser?.orbitUserFollowingIds.count ?? 0)",
                title: "Followings"
            )
            Spacer()
            grooveLedgerMineStatItem(
                value: "\(grooveLedgerMineCurrentUser?.orbitUserFollowerIds.count ?? 0)",
                title: "Followers"
            )
            Spacer()
            grooveLedgerMineStatItem(
                value: "\(grooveLedgerMineCurrentUser?.orbitUserReceivedGiftValue ?? 0)",
                title: "Popularity value"
            )
        }
    }

    private func grooveLedgerMineStatItem(value: String, title: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(Color.white)

            Text(title)
                .font(ZiveStyle.FontBook.regular(14))
                .foregroundStyle(Color.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity)
    }

    private var grooveLedgerMineWalletCard: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .frame(height: 104)

            Image("ZIVEWalBg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 104)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(grooveLedgerMineCurrentUser?.orbitUserCoinCount ?? 0)")
                        .font(ZiveStyle.FontBook.boldItalic(36))
                        .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
                    
                    Text("Wallet")
                        .font(ZiveStyle.FontBook.regular(14))
                        .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
                }

                Spacer()

                Image("ZIVEGoldCoin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 89, height: 89)
            }
            .padding(.horizontal, 24)
        }
    }

    private var grooveLedgerMinePostSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Post")
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(Color.white)
            
            LazyVStack(spacing: 16) {
                ForEach(grooveLedgerMinePostVideos) { grooveLedgerMineVideo in
                    LegerOerxvPostCard(legerOerxvPostCardVideo: grooveLedgerMineVideo)
                }
            }
        }
    }

    private var grooveLedgerMinePostVideos: [ReelVideoModel] {
        guard let grooveLedgerMineCurrentUser else {
            return []
        }

        return grooveLedgerMineVideoStore
            .reelVideoFetchByPublisherId(grooveLedgerMineCurrentUser.id)
            .sorted { $0.id > $1.id }
    }
}
