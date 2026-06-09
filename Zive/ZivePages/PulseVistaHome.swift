import SwiftUI

struct PulseVistaHome: View {
    @EnvironmentObject var pulseVistaNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var pulseVistaHomeGuestGate: CBnxweZGoLogCenter
    @EnvironmentObject private var pulseVistaHomeUserStore: OrbitUserStore
    @EnvironmentObject private var pulseVistaHomeVideoStore: ReelVideoStore

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    ZStack(alignment: .top){
                        
                        pulseVistaHomeHeroCard
                            .onTapGesture {
                                pulseVistaHomeGuestGate.CBnxweZGoLogRequireLogin {
                                    pulseVistaNavigator.weioZwivbePush(.tempoTrailPlanBoard)
                                }
                            }
                        pulseVistaHomeTopBar
                    }.padding(.horizontal, 20)
                    
                    pulseVistaHomeCoachRow()
                    pulseVistaHomeTrendingSection
                        .padding(.horizontal, 20)
                }
                
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .ziveScreenBackground()
            .navigationBarHidden(true)
        }
        
    }

    private var pulseVistaHomeTopBar: some View {
        HStack {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
                    .frame(width: 42, height: 42)

                ZiveSmartImage(ziveSmartImagePath: pulseVistaHomeCurrentUser?.orbitUserAvatar ?? "ZIVELogo") {
                    Image("ZIVELogo")
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: 38, height: 38)
                .clipShape(Circle())
            }.onTapGesture {
                pulseVistaNavigator.weioZwivbePush(.grooveLedgerMine)
            }

            Spacer()

            Image("ZIVEMessageGo")
                .resizable()
                .frame(width: 40, height: 40)
                .onTapGesture {
                    pulseVistaHomeGuestGate.CBnxweZGoLogRequireLogin {
                        pulseVistaNavigator.weioZwivbePush(.chatPulseRecently)
                    }
                }
        }
    }

    private var pulseVistaHomeHeroCard: some View {
        ZStack(alignment: .bottomLeading) {

            Image("ZIVEDancePlanBoardBg")
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 186)
                .padding(.horizontal, 15)

            VStack(alignment: .leading, spacing: 10) {
                
                Text("Come and make your dance plan now.\nZive will witness your progress.")
                    .font(ZiveStyle.FontBook.regular(15))
                    .foregroundStyle(Color.white.opacity(0.41))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 28)
            .padding(.bottom, 35)
            HStack{
                Spacer()
                Image("ZIVEDancePlanBoardCharacter")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 163, height: 233)
            }
            

        }
    }
    

    

    

    private var pulseVistaHomeTrendingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trending")
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(ZiveStyle.ColorPalette.textPink)

            Text("Take a look at what's popular now")
                .font(ZiveStyle.FontBook.regular(15))
                .foregroundStyle(ZiveStyle.ColorPalette.textPink.opacity(0.44))

            VStack(spacing: 16) {
                ForEach(pulseVistaHomeTrendingVideos) { pulseVistaHomeVideo in
                    LegerOerxvPostCard(legerOerxvPostCardVideo: pulseVistaHomeVideo)
                }
            }
        }
    }

    private var pulseVistaHomeCurrentUser: OrbitUserModel? {
        let pulseVistaHomeCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return pulseVistaHomeUserStore.orbitUserFetch(by: pulseVistaHomeCurrentUserId)
    }

    private var pulseVistaHomeTrendingVideos: [ReelVideoModel] {
        let pulseVistaHomeBlockedPublisherIds = Set(
            pulseVistaHomeCurrentUser?.orbitUserBlockedIds ?? []
        )

        return pulseVistaHomeVideoStore.reelVideoItems
            .filter { !pulseVistaHomeBlockedPublisherIds.contains($0.reelVideoPublisherId) }
            .sorted { pulseVistaHomeLeft, pulseVistaHomeRight in
                if pulseVistaHomeLeft.reelVideoGiftValue == pulseVistaHomeRight.reelVideoGiftValue {
                    return pulseVistaHomeLeft.id > pulseVistaHomeRight.id
                }

                return pulseVistaHomeLeft.reelVideoGiftValue > pulseVistaHomeRight.reelVideoGiftValue
            }
    }

    
}

struct pulseVistaHomeCoachRow: View {
    @EnvironmentObject var pulseVistaNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var pulseVistaHomeGuestGate: CBnxweZGoLogCenter
    @EnvironmentObject private var pulseVistaHomeUserStore: OrbitUserStore
    @State private var pulseVistaHomeCoachRowOffset: CGFloat = 0
    @State private var pulseVistaHomeCoachRowDragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { pulseVistaHomeCoachRowGeometry in
            let pulseVistaHomeCoachRowMaxOffset = pulseVistaHomeCoachRowMaxScrollOffset(
                containerWidth: pulseVistaHomeCoachRowGeometry.size.width
            )

            HStack(alignment: .top, spacing: 12) {
                pulseVistaHomeShareWorkCard

                ForEach(pulseVistaHomeCoachUsers) { pulseVistaHomeCoachUser in
                    pulseVistaHomeCoachCard(
                        imageName: pulseVistaHomeCoachUser.orbitUserAvatar,
                        username: pulseVistaHomeCoachUser.orbitUserName
                    )
                    .onTapGesture {
                        pulseVistaNavigator.weioZwivbePush(
                            .echoPulseProfile(pulseVistaHomeCoachUser.id)
                        )
                    }
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .offset(
                x: pulseVistaHomeCoachRowClampedOffset(
                    pulseVistaHomeCoachRowOffset + pulseVistaHomeCoachRowDragOffset,
                    maxOffset: pulseVistaHomeCoachRowMaxOffset
                )
            )
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { pulseVistaHomeCoachRowValue in
                        guard abs(pulseVistaHomeCoachRowValue.translation.width)
                            > abs(pulseVistaHomeCoachRowValue.translation.height) else {
                            return
                        }

                        pulseVistaHomeCoachRowDragOffset = pulseVistaHomeCoachRowValue.translation.width
                    }
                    .onEnded { pulseVistaHomeCoachRowValue in
                        let pulseVistaHomeCoachRowNextOffset = pulseVistaHomeCoachRowOffset
                            + pulseVistaHomeCoachRowValue.translation.width

                        pulseVistaHomeCoachRowOffset = pulseVistaHomeCoachRowClampedOffset(
                            pulseVistaHomeCoachRowNextOffset,
                            maxOffset: pulseVistaHomeCoachRowMaxOffset
                        )
                        pulseVistaHomeCoachRowDragOffset = 0
                    }
            )
        }
        .clipped()
        .frame(height: 128)
        .contentShape(Rectangle())
    }
    
    private func pulseVistaHomeCoachCard(imageName: String, username: String) -> some View {
        VStack(spacing: 8) {
            ZiveSmartImage(ziveSmartImagePath: imageName) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.12))
            }
            .frame(width: 82, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            Text(username)
                .font(ZiveStyle.FontBook.italic(14))
                .foregroundStyle(Color.white)
        }.frame(height: 128)
            .frame(width: 82)
    }
    
    private var pulseVistaHomeShareWorkCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.23))
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZiveStyle.ColorPalette.brandPink.opacity(0.9),
                                ZiveStyle.ColorPalette.brandOrange.opacity(0.9)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 95, height: 100)
                    .blur(radius: 8)

                Image("ZIVEIconAdd")
                    .resizable()
                    .frame(width: 32, height: 32)
            }.frame(width: 95, height: 100)
            Text("Share work")
                .font(ZiveStyle.FontBook.italic(14))
                .foregroundStyle(Color.white)
                .padding(.leading, 8)
        }
            .onTapGesture {
            pulseVistaHomeGuestGate.CBnxweZGoLogRequireLogin {
                pulseVistaNavigator.weioZwivbePush(.frameFlowUploadPost)
            }
        }
    }
    
    private var pulseVistaHomeCoachUsers: [OrbitUserModel] {
        let pulseVistaHomeCurrentUserId = pulseVistaHomeCurrentUser?.id ?? ""
        let pulseVistaHomeBlockedUserIds = Set(
            pulseVistaHomeCurrentUser?.orbitUserBlockedIds ?? []
        )

        return pulseVistaHomeUserStore.orbitUserItems
            .filter { pulseVistaHomeUser in
                pulseVistaHomeUser.id != pulseVistaHomeCurrentUserId
                    && !pulseVistaHomeBlockedUserIds.contains(pulseVistaHomeUser.id)
                    && !pulseVistaHomeUser.orbitUserEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    && !pulseVistaHomeUser.orbitUserPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .sorted { $0.orbitUserName.localizedCaseInsensitiveCompare($1.orbitUserName) == .orderedAscending }
    }

    private func pulseVistaHomeCoachRowMaxScrollOffset(containerWidth: CGFloat) -> CGFloat {
        let pulseVistaHomeShareCardWidth: CGFloat = 95
        let pulseVistaHomeCoachCardWidth: CGFloat = 82
        let pulseVistaHomeCoachRowSpacing: CGFloat = 12
        let pulseVistaHomeCoachRowHorizontalPadding: CGFloat = 40
        let pulseVistaHomeCoachRowItemCount = 1 + pulseVistaHomeCoachUsers.count
        let pulseVistaHomeCoachRowSpacingCount = max(0, pulseVistaHomeCoachRowItemCount - 1)
        let pulseVistaHomeCoachRowContentWidth = pulseVistaHomeShareCardWidth
            + CGFloat(pulseVistaHomeCoachUsers.count) * pulseVistaHomeCoachCardWidth
            + CGFloat(pulseVistaHomeCoachRowSpacingCount) * pulseVistaHomeCoachRowSpacing
            + pulseVistaHomeCoachRowHorizontalPadding

        return max(0, pulseVistaHomeCoachRowContentWidth - containerWidth)
    }

    private func pulseVistaHomeCoachRowClampedOffset(_ offset: CGFloat, maxOffset: CGFloat) -> CGFloat {
        min(0, max(-maxOffset, offset))
    }
    
    private var pulseVistaHomeCurrentUser: OrbitUserModel? {
        let pulseVistaHomeCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return pulseVistaHomeUserStore.orbitUserFetch(by: pulseVistaHomeCurrentUserId)
    }
}
