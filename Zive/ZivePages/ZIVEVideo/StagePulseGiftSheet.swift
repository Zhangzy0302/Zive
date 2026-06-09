import SwiftUI

struct StagePulseGiftSheet: View {
    let stagePulseGiftSheetVideoId: String
    let stagePulseGiftSheetRecipientUserId: String
    @Binding var stagePulseGiftSheetIsPresented: Bool
    @State private var stagePulseGiftSheetSelectedGiftIndex = 1
    let stagePulseGiftSheetOnGive: (StagePulseGiftOption) -> Void
    @EnvironmentObject private var stagePulseGiftSheetUserStore: OrbitUserStore

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.02)
                .ignoresSafeArea()
                .onTapGesture {
                    stagePulseGiftSheetIsPresented = false
                }

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Text("Give to")
                        .font(ZiveStyle.FontBook.regular(12))
                        .foregroundStyle(ZiveStyle.ColorPalette.textPrimary.opacity(0.7))

                    ZiveSmartImage(ziveSmartImagePath: stagePulseGiftSheetRecipientUser?.orbitUserAvatar ?? "") {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                    }
                    .frame(width: 18, height: 18)
                    .clipShape(Circle())

                    Text(stagePulseGiftSheetRecipientUser?.orbitUserName ?? "Zive User")
                        .font(ZiveStyle.FontBook.boldItalic(12))
                        .foregroundStyle(ZiveStyle.ColorPalette.textPrimary.opacity(0.7))
                }
                .padding(.top, 18)
                // 礼物选择
                HStack {
                    stagePulseGiftSheetGiftItem(
                        imageName: "ZIVEXIAGift_1",
                        value: "50",
                        isSelected: stagePulseGiftSheetSelectedGiftIndex == 0
                    )
                    .onTapGesture {
                        stagePulseGiftSheetSelectedGiftIndex = 0
                    }
                    Spacer()
                    stagePulseGiftSheetGiftItem(
                        imageName: "ZIVEXIAGift_2",
                        value: "100",
                        isSelected: stagePulseGiftSheetSelectedGiftIndex == 1
                    )
                    .onTapGesture {
                        stagePulseGiftSheetSelectedGiftIndex = 1
                    }
                    Spacer()
                    stagePulseGiftSheetGiftItem(
                        imageName: "ZIVEXIAGift_3",
                        value: "200",
                        isSelected: stagePulseGiftSheetSelectedGiftIndex == 2
                    )
                    .onTapGesture {
                        stagePulseGiftSheetSelectedGiftIndex = 2
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)

                Spacer()

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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .blur(radius: 4)
                    Text("Give")
                        .font(ZiveStyle.FontBook.boldItalic(20))
                        .foregroundStyle(Color(red: 1, green: 235/255, blue: 235/255))
                }.frame(height: 53)
                    .onTapGesture {
                        stagePulseGiftSheetOnGive(stagePulseGiftSheetSelectedGift)
                    }
                .padding(.top, 23)
                .padding(.horizontal, 16)
                .padding(.bottom, 41)
            }
            .padding(.horizontal, 17)
            .frame(maxWidth: .infinity)
            .frame(height: 316)
            .background(
                ZStack(alignment: .top) {
                    Color.white
                    Image("ZIVECardBg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 295, height: 208)
                }
            )
            .clipShape(ZiveTopRoundedCornerShape(ziveTopRoundedCornerRadius: 20))
            
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }.ignoresSafeArea(edges: .bottom)
    }

    private func stagePulseGiftSheetGiftItem(
        imageName: String,
        value: String,
        isSelected: Bool
    ) -> some View {
        VStack(spacing: 7) {
            if isSelected {
                VStack(spacing: 10) {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)

                    HStack(spacing: 4) {
                        Image("ZIVEGoldCoin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)

                        Text(value)
                            .font(ZiveStyle.FontBook.regular(14))
                            .foregroundStyle(ZiveStyle.ColorPalette.textPrimary.opacity(0.9))
                    }
                }
                .frame(width: 112, height: 112)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
            }
        }
        .frame(width: isSelected ? 112 : 56, height: isSelected ? 112 : 56)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private var stagePulseGiftSheetRecipientUser: OrbitUserModel? {
        stagePulseGiftSheetUserStore.orbitUserFetch(by: stagePulseGiftSheetRecipientUserId)
    }

    private var stagePulseGiftSheetSelectedGift: StagePulseGiftOption {
        stagePulseGiftSheetGiftOptions[stagePulseGiftSheetSelectedGiftIndex]
    }

    private var stagePulseGiftSheetGiftOptions: [StagePulseGiftOption] {
        [
            StagePulseGiftOption(
                stagePulseGiftOptionImageName: "ZIVEXIAGift_1",
                stagePulseGiftOptionValue: 1,
                stagePulseGiftOptionPurchaseCoins: 50
            ),
            StagePulseGiftOption(
                stagePulseGiftOptionImageName: "ZIVEXIAGift_2",
                stagePulseGiftOptionValue: 2,
                stagePulseGiftOptionPurchaseCoins: 100
            ),
            StagePulseGiftOption(
                stagePulseGiftOptionImageName: "ZIVEXIAGift_3",
                stagePulseGiftOptionValue: 5,
                stagePulseGiftOptionPurchaseCoins: 200
            )
        ]
    }
}
