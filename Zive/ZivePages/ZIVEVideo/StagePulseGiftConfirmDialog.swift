import SwiftUI

struct StagePulseGiftOption: Equatable {
    let stagePulseGiftOptionImageName: String
    let stagePulseGiftOptionValue: Int
    let stagePulseGiftOptionPurchaseCoins: Int
}

struct StagePulseGiftConfirmDialog: View {
    let stagePulseGiftConfirmVideoId: String
    let stagePulseGiftConfirmGift: StagePulseGiftOption
    @Binding var stagePulseGiftConfirmIsPresented: Bool
    let stagePulseGiftConfirmOnCloseSheet: () -> Void

    @EnvironmentObject private var stagePulseGiftConfirmNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var stagePulseGiftConfirmFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var stagePulseGiftConfirmUserStore: OrbitUserStore
    @EnvironmentObject private var stagePulseGiftConfirmVideoStore: ReelVideoStore
    @EnvironmentObject private var stagePulseGiftConfirmGuestGate: CBnxweZGoLogCenter

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    stagePulseGiftConfirmIsPresented = false
                }
            ZStack(alignment: .top){
                Image(stagePulseGiftConfirmHasEnoughCoins ? "ZIVEPayGiftBg" : "ZiveNoMoneyBg")
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 379)
                    .onTapGesture {
                        stagePulseGiftConfirmIsPresented = false
                    }
                
                VStack(spacing: 0) {
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1, green: 244/255, blue: 235/255),
                                        Color(red: 1, green: 199/255, blue: 220/255)
                                    ],
                                    startPoint: .trailing,
                                    endPoint: .leading
                                )
                            )
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ZiveStyle.ColorPalette.brandOrange,
                                        ZiveStyle.ColorPalette.brandPink
                                    ],
                                    startPoint: .trailing,
                                    endPoint: .leading
                                )
                            )
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .blur(radius: 4)
                        Text(stagePulseGiftConfirmHasEnoughCoins ? "Give" : "Recharge")
                            .font(ZiveStyle.FontBook.boldItalic(20))
                            .foregroundStyle(Color(red: 1, green: 235/255, blue: 235/255))
                    }
                    .frame(height: 53)
                    .padding(.top, 28)
                    .padding(.horizontal, 16)
                    .onTapGesture {
                        if stagePulseGiftConfirmHasEnoughCoins {
                            stagePulseGiftConfirmGiveGift()
                        } else {
                            stagePulseGiftConfirmRecharge()
                        }
                    }

                    Button("Cancel") {
                        stagePulseGiftConfirmIsPresented = false
                    }
                    .buttonStyle(.plain)
                    .font(ZiveStyle.FontBook.regular(17))
                    .foregroundStyle(ZiveStyle.ColorPalette.textPrimary.opacity(0.52))
                    .padding(.top, 18)
                    .padding(.bottom, 23)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 336, alignment: .bottom)
                .background(
                    ZStack(alignment: .top) {
                        Color.white
                        Image("ZIVECardBg")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 295, height: 208)
                            .saturation(stagePulseGiftConfirmHasEnoughCoins ? 1 : 0)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 24)
                .padding(.top, 110)
                    
                if stagePulseGiftConfirmHasEnoughCoins {
                    Image(stagePulseGiftConfirmGift.stagePulseGiftOptionImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .padding(.top, 44)
                    VStack{
                        HStack(spacing: 6) {
                            Image("ZIVEGoldCoin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)

                            Text("\(stagePulseGiftConfirmGift.stagePulseGiftOptionPurchaseCoins)")
                                .font(ZiveStyle.FontBook.regular(18))
                                .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
                        }
                        .padding(.top, 8)

                        Text("Are you sure you want to give a\ngift to this user?")
                            .font(ZiveStyle.FontBook.regular(16))
                            .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                    }.padding(.top, 188)
                    
                } else {
                    VStack(spacing: 32){
                        Image("ZIVEGoldCoin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 144, height: 144)
                            .saturation(0)
                            .padding(.top, 61)

                        Text("The balance in your account is\ninsufficient to cover this fee.\nPlease go to recharge.")
                            .font(ZiveStyle.FontBook.regular(16))
                            .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    
                }

            }
            
            
        }
        .transition(.opacity)
    }

    private var stagePulseGiftConfirmCurrentUser: OrbitUserModel? {
        let stagePulseGiftConfirmCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return stagePulseGiftConfirmUserStore.orbitUserFetch(by: stagePulseGiftConfirmCurrentUserId)
    }

    private var stagePulseGiftConfirmVideo: ReelVideoModel? {
        stagePulseGiftConfirmVideoStore.reelVideoFetch(by: stagePulseGiftConfirmVideoId)
    }

    private var stagePulseGiftConfirmHasEnoughCoins: Bool {
        (stagePulseGiftConfirmCurrentUser?.orbitUserCoinCount ?? 0) >= stagePulseGiftConfirmGift.stagePulseGiftOptionPurchaseCoins
    }

    private func stagePulseGiftConfirmGiveGift() {
        guard let stagePulseGiftConfirmCurrentUser else {
            stagePulseGiftConfirmFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Current user not found",
                status: .error
            )
            return
        }

        guard let stagePulseGiftConfirmVideo else {
            stagePulseGiftConfirmFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Video not found",
                status: .error
            )
            return
        }

        guard stagePulseGiftConfirmUserStore.orbitUserFetch(by: stagePulseGiftConfirmVideo.reelVideoPublisherId) != nil else {
            stagePulseGiftConfirmFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Publisher not found",
                status: .error
            )
            return
        }

        let stagePulseGiftConfirmDidDeduct = stagePulseGiftConfirmUserStore.orbitUserAdjustCoinCount(
            userId: stagePulseGiftConfirmCurrentUser.id,
            delta: -stagePulseGiftConfirmGift.stagePulseGiftOptionPurchaseCoins
        )
        guard stagePulseGiftConfirmDidDeduct else {
            stagePulseGiftConfirmFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Insufficient balance",
                status: .error
            )
            return
        }

        stagePulseGiftConfirmVideoStore.reelVideoAdjustGiftValue(
            videoId: stagePulseGiftConfirmVideoId,
            delta: stagePulseGiftConfirmGift.stagePulseGiftOptionValue
        )
        _ = stagePulseGiftConfirmUserStore.orbitUserAdjustReceivedGiftValue(
            userId: stagePulseGiftConfirmVideo.reelVideoPublisherId,
            delta: stagePulseGiftConfirmGift.stagePulseGiftOptionValue
        )
        stagePulseGiftConfirmIsPresented = false
        stagePulseGiftConfirmOnCloseSheet()
        stagePulseGiftConfirmFeedbackCenter.ziveGlobalFeedbackShowToast(
            text: "Gift sent successfully",
            status: .success
        )
    }

    private func stagePulseGiftConfirmRecharge() {
        stagePulseGiftConfirmIsPresented = false
        stagePulseGiftConfirmOnCloseSheet()
        stagePulseGiftConfirmGuestGate.CBnxweZGoLogRequireLogin {
            stagePulseGiftConfirmNavigator.weioZwivbePush(.cocoaPulseWallet)
        }
    }
}
