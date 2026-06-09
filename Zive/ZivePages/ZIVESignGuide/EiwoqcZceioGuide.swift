import SwiftUI

struct EiwoqcZceioGuide: View {
    @EnvironmentObject private var weioZwivbeNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var eiwoqcZeicLoToast: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var eiwoqcZceioGuideUserStore: OrbitUserStore
    @StateObject private var eiwoqcZceioGuideBInitModel = PulseGateInitViewModel()
    @StateObject private var eiwoqcZceioGuideLocationManager = GrooveSignalLocationManager.shared
    @State private var eiwoqcZceioGuideShowEULA = false
    
    @AppStorage("qeixbgBriwyAgree") var eiwoqcZceioGuideAgreeTerms: Bool = false
    @AppStorage("qeixbgBriwyAgreeEULA") var eiwoqcZceioIsAgreeEula: Bool = false

    var body: some View {
        ZStack {
            GeometryReader { _ in
                Image("ZIVEGuideBg")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea()
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.02),
                    ZiveStyle.ColorPalette.background.opacity(0.35),
                    ZiveStyle.ColorPalette.background.opacity(0.82),
                    ZiveStyle.ColorPalette.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer(minLength: 150)

                eiwoqcZceioGuideHeroIdentity

                Spacer()

                eiwoqcZceioGuideBottomArea
            }
            .padding(.horizontal, 23)
            .padding(.top, 14)
            .padding(.bottom, 30)

            if eiwoqcZceioGuideShowEULA {
                PulseLedgerEULASheet(
                    pulseLedgerEULAIsPresented: $eiwoqcZceioGuideShowEULA
                )
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: eiwoqcZceioGuideShowEULA)
        .task {
            await eiwoqcZceioGuideStartBInit()
        }
        .ziveScreenBackground()
    }


    private var eiwoqcZceioGuideHeroIdentity: some View {
        VStack(spacing: 12) {
            Image("ZIVELogo")
                .resizable()
                .frame(width: 98, height: 98)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Text("Zive")
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(ZiveStyle.ColorPalette.white)
        }
    }

    @ViewBuilder
    private var eiwoqcZceioGuideBottomArea: some View {
        switch eiwoqcZceioGuideBInitModel.pulseGateStatus {
        case .pulseGateLoading:
            eiwoqcZceioGuideBLoadingArea
        case .pulseGateB:
            eiwoqcZceioGuideBQuickLoginArea
        case .pulseGateA:
            eiwoqcZceioGuideActionArea
        }
    }

    private var eiwoqcZceioGuideBLoadingArea: some View {
        VStack(spacing: 28) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(ZiveStyle.ColorPalette.white)
                .scaleEffect(1.6)

            Text("Loading...")
                .font(ZiveStyle.FontBook.regular(16))
                .foregroundStyle(ZiveStyle.ColorPalette.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .padding(.bottom, 26)
    }

    private var eiwoqcZceioGuideBQuickLoginArea: some View {
        VStack(spacing: 28) {
            Button {
                Task {
                    await eiwoqcZceioGuideQuickLogin()
                }
            } label: {
                eiwoqcZceioGuideButtonLabel(title: "Quick Login")
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .padding(.bottom, 26)
    }

    private var eiwoqcZceioGuideActionArea: some View {
        VStack(spacing: 0) {
            VStack(spacing: 40) {
                eiwoqcZceioGuideButton(title: "3c4a975e21ee38e17d346489c01491ab".grooveCipherAESDecrypt())
                eiwoqcZceioGuideButton(title: "8bd3d5c05d338d56f34a0c6437b4e7bc".grooveCipherAESDecrypt())
            }

            VStack(spacing: 18) {
                HStack(spacing: 4) {
                    Text("6831128d394ee0259b2083f1310b258a48efda8e12e3e9c02817d7fe62acbe97".grooveCipherAESDecrypt())
                        .font(ZiveStyle.FontBook.regular(14))
                        .foregroundStyle(ZiveStyle.ColorPalette.white.opacity(0.82))

                    Button("aff99501866f5e9757bd9074237abc8f".grooveCipherAESDecrypt()) {
                        if !eiwoqcZceioIsAgreeEula {
                            eiwoqcZceioGuideShowEULA = true
                            return
                        }
                        if !eiwoqcZceioGuideAgreeTerms {
                            eiwoqcZeicLoToast.ziveGlobalFeedbackShowToast(text: "3139890dcd5639454dcb6646e2f92ba31a22b8d33715ca4997800f708779abf664e3ccd1f15b70386e3f33ecba3acc81066eaf1ea1122c05a6f34783902aa7e6558ddcdaeb567d90958fd3372c465911".grooveCipherAESDecrypt())
                            return
                        }
                        weioZwivbeNavigator.weioZwivbePush(.skillProgressionSignUp)
                    }
                        .buttonStyle(.plain)
                        .font(ZiveStyle.FontBook.regular(14))
                        .foregroundStyle(ZiveStyle.ColorPalette.white)
                        .ziveLegacyUnderline(color: ZiveStyle.ColorPalette.white)
                }
                .padding(.top, 28)

                HStack(alignment: .center, spacing: 8) {
                    Button {
                        eiwoqcZceioGuideAgreeTerms.toggle()
                    } label: {
                        Circle()
                            .fill(eiwoqcZceioGuideAgreeTerms ? ZiveStyle.ColorPalette.brandPink : Color.white.opacity(0.22))
                            .frame(width: 21, height: 21)
                            .overlay {
                                if eiwoqcZceioGuideAgreeTerms {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(ZiveStyle.ColorPalette.white)
                                }
                            }
                    }
                    .buttonStyle(.plain)

                    eiwoqcZceioGuideAgreementText
                }
            }
        }
    }

    private var eiwoqcZceioGuideAgreementText: some View {
        HStack(spacing: 0) {
            Text("1599fb76853a1bb579c2a2ebed6dda29".grooveCipherAESDecrypt())
                .font(ZiveStyle.FontBook.regular(11))
                .foregroundStyle(ZiveStyle.ColorPalette.white.opacity(0.7))

            Button("4d5b130954398e160834ad10b538d92f".grooveCipherAESDecrypt()) {
                weioZwivbeNavigator.weioZwivbePush(.sedivaoBeiwWeb("234134a38cb97bfc9ac9197dad451a22fdf99b352d9bf551bb196dd79f385219".grooveCipherAESDecrypt()))
            }
                .buttonStyle(.plain)
                .font(ZiveStyle.FontBook.regular(11))
                .foregroundStyle(ZiveStyle.ColorPalette.white.opacity(0.86))
                .ziveLegacyUnderline(color: ZiveStyle.ColorPalette.white.opacity(0.86))

            Text("83cf82c8da5d3c120db805f8f17efe31".grooveCipherAESDecrypt())
                .font(ZiveStyle.FontBook.regular(11))
                .foregroundStyle(ZiveStyle.ColorPalette.white.opacity(0.7))

            Button("a4f27d37b5b103ca95dd63121fafa3cd".grooveCipherAESDecrypt()) {
                weioZwivbeNavigator.weioZwivbePush(.sedivaoBeiwWeb("234134a38cb97bfc9ac9197dad451a22c7798ce7a7d729583e7c7d8fe2bbcb89370552b5fd79dedf69202a3890f0417a".grooveCipherAESDecrypt()))
            }
                .buttonStyle(.plain)
                .font(ZiveStyle.FontBook.regular(11))
                .foregroundStyle(ZiveStyle.ColorPalette.white.opacity(0.86))
                .ziveLegacyUnderline(color: ZiveStyle.ColorPalette.white.opacity(0.86))
        }
    }

    private func eiwoqcZceioGuideButton(title: String) -> some View {
        Group {
            if title == "Login by email" {
                Button {
                    if !eiwoqcZceioIsAgreeEula {
                        eiwoqcZceioGuideShowEULA = true
                        return
                    }
                    if !eiwoqcZceioGuideAgreeTerms {
                        eiwoqcZeicLoToast.ziveGlobalFeedbackShowToast(text: "3139890dcd5639454dcb6646e2f92ba31a22b8d33715ca4997800f708779abf664e3ccd1f15b70386e3f33ecba3acc81066eaf1ea1122c05a6f34783902aa7e6558ddcdaeb567d90958fd3372c465911".grooveCipherAESDecrypt())
                        return
                    }
                    weioZwivbeNavigator.weioZwivbePush(.skillProgressionSignIn)
                } label: {
                    eiwoqcZceioGuideButtonLabel(title: title)
                }
                .buttonStyle(.plain)
            } else if title == "I’m new" {
                Button {
                    if !eiwoqcZceioIsAgreeEula {
                        eiwoqcZceioGuideShowEULA = true
                        return
                    }
                    if !eiwoqcZceioGuideAgreeTerms {
                        eiwoqcZeicLoToast.ziveGlobalFeedbackShowToast(text: "3139890dcd5639454dcb6646e2f92ba31a22b8d33715ca4997800f708779abf664e3ccd1f15b70386e3f33ecba3acc81066eaf1ea1122c05a6f34783902aa7e6558ddcdaeb567d90958fd3372c465911".grooveCipherAESDecrypt())
                        return
                    }
                    Task {
                        await eiwoqcZceioGuideGuestLogin()
                    }
                } label: {
                    eiwoqcZceioGuideButtonLabel(title: title)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: {}) {
                    eiwoqcZceioGuideButtonLabel(title: title)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func eiwoqcZceioGuideButtonLabel(title: String) -> some View {
        Text(title)
            .font(ZiveStyle.FontBook.boldItalic(20))
            .foregroundStyle(ZiveStyle.ColorPalette.white.opacity(0.92))
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(Color.white.opacity(0.24))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func eiwoqcZceioGuideGuestLogin() async {
        let eiwoqcZceioGuideGuestUser = OrbitUserModel(
            id: "guest_\(UUID().uuidString)",
            orbitUserEmail: "",
            orbitUserPassword: "",
            orbitUserAvatar: "http://huanniuchat.oss-accelerate.aliyuncs.com/Zive2026/ZIVEDefaultAva.png",
            orbitUserName: "Guest",
            orbitUserFollowerIds: [],
            orbitUserFollowingIds: [],
            orbitUserBlockedIds: [],
            orbitUserLikedVideoIds: [],
            orbitUserCoinCount: 0,
            orbitUserReceivedGiftValue: 0
        )

        await MainActor.run {
            eiwoqcZeicLoToast.ziveGlobalFeedbackShowLoading(text: "Entering...")
        }

        await delay(1)

        await MainActor.run {
            eiwoqcZceioGuideUserStore.orbitUserCreate(eiwoqcZceioGuideGuestUser)
            QeixbgBriwyState.qeixbgBriwyCurrentUserId = eiwoqcZceioGuideGuestUser.id
            eiwoqcZeicLoToast.ziveGlobalFeedbackHideLoading()
            weioZwivbeNavigator.weioZwivbePresentRoot(.pulseVistaHome)
        }
    }

    private func eiwoqcZceioGuideStartBInit() async {
        await eiwoqcZceioGuideBInitModel.pulseGateInitFlow()

        await MainActor.run {
            guard eiwoqcZceioGuideBInitModel.pulseGateNextRoute != nil else {
                return
            }

            eiwoqcZceioGuideBInitModel.pulseGateNextRoute = nil
            eiwoqcZceioGuideOpenBWebPage()
        }
    }

    private func eiwoqcZceioGuideQuickLogin() async {
        await MainActor.run {
            eiwoqcZceioGuideBInitModel.pulseGateStatus = .pulseGateLoading
        }

        let eiwoqcZceioGuideBRoute = await PulseGateInitUtils.shared.pulseGateGoLogin()

        await MainActor.run {
            if eiwoqcZceioGuideBRoute != nil {
                eiwoqcZceioGuideOpenBWebPage()
            } else {
                eiwoqcZceioGuideBInitModel.pulseGateStatus = .pulseGateB
            }
        }
    }

    private func eiwoqcZceioGuideOpenBWebPage() {
        let eiwoqcZceioGuideBWebURL = GrooveSignalInformationCreate.grooveSignalBuildH5Url(
            grooveSignalBaseUrl: RhythmVaultAppStorage.rhythmVaultH5Url,
            grooveSignalToken: RhythmVaultAppStorage.rhythmVaultUserToken
        )

        guard !eiwoqcZceioGuideBWebURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            eiwoqcZceioGuideBInitModel.pulseGateStatus = .pulseGateB
            return
        }

        weioZwivbeNavigator.weioZwivbePresentRoot(
            .sedivaoBeiwWeb(eiwoqcZceioGuideBWebURL)
        )
    }
}
