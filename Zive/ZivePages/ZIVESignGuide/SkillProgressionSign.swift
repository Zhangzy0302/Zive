import SwiftUI

enum SkillProgressionSignFocusField {
    case email
    case password
    case rePassword
}

enum SkillProgressionSignMode {
    case signIn
    case signUp
    case forgotPassword

    var title: String {
        switch self {
        case .signIn:
            return SkillProgressionSignCipherText.signIn.grooveCipherAESDecrypt()
        case .signUp:
            return SkillProgressionSignCipherText.signUp.grooveCipherAESDecrypt()
        case .forgotPassword:
            return SkillProgressionSignCipherText.forgotPassword.grooveCipherAESDecrypt()
        }
    }

    var buttonTitle: String {
        switch self {
        case .signIn:
            return SkillProgressionSignCipherText.signIn.grooveCipherAESDecrypt()
        case .signUp:
            return SkillProgressionSignCipherText.signUp.grooveCipherAESDecrypt()
        case .forgotPassword:
            return SkillProgressionSignCipherText.resetPassword.grooveCipherAESDecrypt()
        }
    }

    var cardHeight: CGFloat {
        switch self {
        case .signIn:
            return 260
        case .signUp:
            return 349
        case .forgotPassword:
            return 349
        }
    }
}

private enum SkillProgressionSignCipherText {
    static let signIn = "ae764d45d6ecb20bca525f6bbc1ad057"
    static let signUp = "aff99501866f5e9757bd9074237abc8f"
    static let forgotPassword = "190dea8068477ccb579f542616f93705"
    static let resetPassword = "40bf40177689b8ced4c8f15fece9e092"
    static let emailLabel = "51e73e7c66565edc3152226da3b327c7"
    static let enterEmailAddress = "91a13a871f3f50888419a39784664ba70300fcd1a7ce9b966d362181c7583efb"
    static let passwordLabel = "098e53518caea2b12bf715d11c1aa525"
    static let forgotUpper = "f755cf2deb2baf4a7511105ec1c6c9fa"
    static let enterPassword = "cfa6bed1ee392b65ad371dbb0b3efea8"
    static let confirmPasswordLabel = "7ab2061ec491713f2efd3bc91eda560aa8c6d5273188f80c310a63bc6060a634"
    static let enterPasswordAgain = "09e9127a1c08d0f08e34f346a21c9ecf7423eb844d4f842cbd291d521b5d454f"
    static let emailCannotBeEmpty = "eeb53957a06e397aa59f50c910cc24c4484a6b360b588552615acffc21edce23"
    static let pleaseEnterValidEmail = "2942bcb609858aaddd4f5a57f158c1013a2e34f78a693b12cfc7100d65d3717c492f0724f8848b336347a333531c6e5d"
    static let passwordCannotBeEmpty = "873818e887a30fb3011daa261958f5c5bff20ded65a1350046630e60876a63f9"
    static let incorrectEmailOrPassword = "9392ff91011a2a845965301d3306f84f5acfec6f66cf83c8c0fe66ae116c7772"
    static let signingInLoading = "f28ebd2fc4fc77ffb1522eeadeb05cf6"
    static let passwordFieldsCannotBeEmpty = "2d348c3aed8c4cda35ed38ea6cedb755081bf590e7900e7d97442f74b358d2ec"
    static let passwordAtLeast3 = "691c0a3a5774e246c7e7d454610f4e0e7980aed086b458847c300385cae503df93c306a0516dc38f85d79d1213b2782f"
    static let twoPasswordsDoNotMatch = "cd060b525aef0a2d183be121e79646d4bd56b4ec8faafb0bbe6464705e371836"
    static let emailAlreadyRegistered = "ce82b40db4ae1305e0d62573aa826828dbfeb24e0d8bc272262d54a38b26d3b69d28c5895b85a6366858a86442e7f79d"
    static let passwordAtLeast6 = "691c0a3a5774e246c7e7d454610f4e0e35a59f339aa762c19b94a31e531be1875ef96d46adb73f3ebf16c15021206c59"
    static let emailNotRegistered = "e815bb5b1d09371d7d3ed13190326f973722cc2e3b4082f68e83895c602e0e3f"
    static let passwordResetSuccessful = "6bec44b05a51b29b29b8523446b566a72fd5f719c8865b4c824892a6b1d4f153"
}

struct SkillProgressionSign: View {
    @State private var skillProgressionSignMode: SkillProgressionSignMode
    @State private var skillProgressionSignEmail = ""
    @State private var skillProgressionSignPassword = ""
    @State private var skillProgressionSignRePassword = ""
    @FocusState private var skillProgressionSignFocusField: SkillProgressionSignFocusField?
    @EnvironmentObject private var skillProgreNavi: WeioZwivbeNavigator
    @EnvironmentObject private var ziveGlobalFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var skillProgressionSignUpDraftCenter: SkillProgressionSignUpDraftCenter

    init(skillProgressionSignInitialMode: SkillProgressionSignMode = .signIn) {
        _skillProgressionSignMode = State(initialValue: skillProgressionSignInitialMode)
    }

    var body: some View {
        ZStack {
            ZiveStyle.ColorPalette.background
                .ignoresSafeArea()
                .onTapGesture {
                    skillProgressionSignFocusField = nil
                }

            VStack(spacing: 0) {
                GrooveStreakTopNavigationBar(title: skillProgressionSignMode.title)
                    .padding(.horizontal, 18)
                    .padding(.top, 10)

                VStack(spacing: 0) {
                    skillProgressionSignCard
                        .padding(.top, 58)

                    Spacer()

                    if skillProgressionSignFocusField == nil {
                        GrooveStreakButton(
                            title: skillProgressionSignMode.buttonTitle,
                            width: 279,
                            height: 39
                        ) {
                            skillProgressionSignFocusField = nil
                            Task {
                                await skillProgressionSignHandlePrimaryAction()
                            }
                        }
                        .padding(.bottom, 66)
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            skillProgressionSignFocusField = nil
        }
        .animation(.easeInOut(duration: 0.2), value: skillProgressionSignFocusField == nil)
        .navigationBarHidden(true)
    }

    private var skillProgressionSignCard: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white)
                .frame(height: skillProgressionSignMode.cardHeight)
                .overlay(alignment: .top) {
                    Image("ZIVECardBg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                }

            Image("ZIVECardTopDecration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 125)
                .offset(y: -16)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(SkillProgressionSignCipherText.emailLabel.grooveCipherAESDecrypt())
                        .font(ZiveStyle.FontBook.boldItalic(20))
                        .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)

                    ZiveTextField(
                        placeholder: SkillProgressionSignCipherText.enterEmailAddress.grooveCipherAESDecrypt(),
                        text: $skillProgressionSignEmail,
                        isFocused: skillProgressionSignFocusField == .email,
                        focusState: $skillProgressionSignFocusField,
                        focusEquals: .email
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(SkillProgressionSignCipherText.passwordLabel.grooveCipherAESDecrypt())
                            .font(ZiveStyle.FontBook.boldItalic(20))
                            .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)

                        Spacer()

                        if skillProgressionSignMode == .signIn {
                            Button(SkillProgressionSignCipherText.forgotUpper.grooveCipherAESDecrypt()) {
                                skillProgressionSignMode = .forgotPassword
                                skillProgressionSignFocusField = .email
                            }
                            .buttonStyle(.plain)
                            .font(ZiveStyle.FontBook.regular(14))
                            .foregroundStyle(ZiveStyle.ColorPalette.textPrimary.opacity(0.85))
                        }
                    }

                    ZiveSecureField(
                        placeholder: SkillProgressionSignCipherText.enterPassword.grooveCipherAESDecrypt(),
                        text: $skillProgressionSignPassword,
                        isFocused: skillProgressionSignFocusField == .password,
                        focusState: $skillProgressionSignFocusField,
                        focusEquals: .password
                    )
                }

                if skillProgressionSignMode != .signIn {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(SkillProgressionSignCipherText.confirmPasswordLabel.grooveCipherAESDecrypt())
                            .font(ZiveStyle.FontBook.boldItalic(20))
                            .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)

                        ZiveSecureField(
                            placeholder: SkillProgressionSignCipherText.enterPasswordAgain.grooveCipherAESDecrypt(),
                            text: $skillProgressionSignRePassword,
                            isFocused: skillProgressionSignFocusField == .rePassword,
                            focusState: $skillProgressionSignFocusField,
                            focusEquals: .rePassword
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 38)
        }
    }

    private func skillProgressionSignHandlePrimaryAction() async {
        let skillProgressionSignUserStore = OrbitUserStore()
        let skillProgressionSignEmail = skillProgressionSignEmail
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let skillProgressionSignPassword = skillProgressionSignPassword
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let skillProgressionSignRePassword = skillProgressionSignRePassword
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !skillProgressionSignEmail.isEmpty else {
            ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: SkillProgressionSignCipherText.emailCannotBeEmpty.grooveCipherAESDecrypt(),
                status: .error
            )
            return
        }

        switch skillProgressionSignMode {
        case .signIn:
            guard skillProgressionSignValidateEmail(skillProgressionSignEmail) else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.pleaseEnterValidEmail.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            let skillProgressionSignUserModel: OrbitUserModel

            guard !skillProgressionSignPassword.isEmpty else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.passwordCannotBeEmpty.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            guard let skillProgressionSignValidatedUser = skillProgressionSignUserStore.orbitUserValidateLogin(
                email: skillProgressionSignEmail,
                password: skillProgressionSignPassword
            ) else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.incorrectEmailOrPassword.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            skillProgressionSignUserModel = skillProgressionSignValidatedUser
            QeixbgBriwyState.qeixbgBriwyCurrentUserId = skillProgressionSignUserModel.id

            await skillProgressionSignPerformSuccessTransition(
                loadingText: SkillProgressionSignCipherText.signingInLoading.grooveCipherAESDecrypt()
            )
            skillProgreNavi.weioZwivbePresentRoot(.pulseVistaHome)

        case .signUp:
            guard !skillProgressionSignPassword.isEmpty,
                  !skillProgressionSignRePassword.isEmpty else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.passwordFieldsCannotBeEmpty.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            guard skillProgressionSignPassword.count >= 3 else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.passwordAtLeast3.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            guard skillProgressionSignPassword == skillProgressionSignRePassword else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.twoPasswordsDoNotMatch.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            guard !skillProgressionSignUserStore.orbitUserEmailExists(skillProgressionSignEmail) else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.emailAlreadyRegistered.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            skillProgressionSignUpDraftCenter.skillProgressionSignUpDraftStore(
                email: skillProgressionSignEmail,
                password: skillProgressionSignPassword
            )
            skillProgreNavi.weioZwivbePush(.rhythmBloomProfile)

        case .forgotPassword:
            guard skillProgressionSignValidateEmail(skillProgressionSignEmail) else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.pleaseEnterValidEmail.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            guard !skillProgressionSignPassword.isEmpty,
                  !skillProgressionSignRePassword.isEmpty else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.passwordFieldsCannotBeEmpty.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            guard skillProgressionSignPassword.count >= 6 else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.passwordAtLeast6.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            guard skillProgressionSignPassword == skillProgressionSignRePassword else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.twoPasswordsDoNotMatch.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            guard skillProgressionSignUserStore.orbitUserResetPassword(
                email: skillProgressionSignEmail,
                newPassword: skillProgressionSignPassword
            ) else {
                ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                    text: SkillProgressionSignCipherText.emailNotRegistered.grooveCipherAESDecrypt(),
                    status: .error
                )
                return
            }

            ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: SkillProgressionSignCipherText.passwordResetSuccessful.grooveCipherAESDecrypt(),
                status: .success
            )
            skillProgreNavi.weioZwivbeReplaceStack(with: .skillProgressionSignIn)
        }
    }

    private func skillProgressionSignValidateEmail(_ skillProgressionSignEmail: String) -> Bool {
        let skillProgressionSignEmailPattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return skillProgressionSignEmail.range(
            of: skillProgressionSignEmailPattern,
            options: .regularExpression
        ) != nil
    }

    private func skillProgressionSignPerformSuccessTransition(
        loadingText: String
    ) async {
        await MainActor.run {
            ziveGlobalFeedbackCenter.ziveGlobalFeedbackShowLoading(text: loadingText)
        }
        await delay(1)
        await MainActor.run {
            ziveGlobalFeedbackCenter.ziveGlobalFeedbackHideLoading()
        }
    }
}
