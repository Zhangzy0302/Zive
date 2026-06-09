import SwiftUI

enum RhythmBloomProfileFocusField {
    case username
}

enum RhythmBloomProfileGender {
    case male
    case female
}

struct RhythmBloomProfile: View {
    private let rhythmBloomProfileLocationOptions = [
        "Los Angeles",
        "New York",
        "Chicago",
        "Houston",
        "San Francisco"
    ]

    @State private var rhythmBloomProfileAvatar = "http://huanniuchat.oss-accelerate.aliyuncs.com/Zive2026/ZIVEDefaultAva.png"
    @State private var rhythmBloomProfileShowsAvatarPicker = false
    @State private var rhythmBloomProfileUsername = ""
    @State private var rhythmBloomProfileLocation = "Los Angeles"
    @State private var rhythmBloomProfileGender: RhythmBloomProfileGender = .female
    @FocusState private var rhythmBloomProfileFocusField: RhythmBloomProfileFocusField?
    @EnvironmentObject private var rhythmBloomProfileNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var rhythmBloomProfileFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var rhythmBloomProfileUserStore: OrbitUserStore
    @EnvironmentObject private var rhythmBloomProfileSignUpDraftCenter: SkillProgressionSignUpDraftCenter

    var body: some View {
        ZStack {
            ZiveStyle.ColorPalette.background
                .ignoresSafeArea()
                .onTapGesture {
                    rhythmBloomProfileFocusField = nil
                }

            VStack(spacing: 0) {
                GrooveStreakTopNavigationBar(title: nil)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                VStack(spacing: 0) {
                    rhythmBloomProfileAvatarSection
                        .padding(.top, 48)

                    rhythmBloomProfileFormSection
                        .padding(.top, 34)

                    Spacer()

                    if rhythmBloomProfileFocusField == nil {
                        GrooveStreakButton(title: "Complete", width: 279, height: 39) {
                            rhythmBloomProfileFocusField = nil
                            Task {
                                await rhythmBloomProfileCompleteSignUp()
                            }
                        }
                        .padding(.bottom, 66)
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 17)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            rhythmBloomProfileFocusField = nil
        }
        .animation(.easeInOut(duration: 0.2), value: rhythmBloomProfileFocusField == nil)
        .navigationBarHidden(true)
        .onAppear {
            rhythmBloomProfilePrefillUsernameIfNeeded()
        }
        .sheet(isPresented: $rhythmBloomProfileShowsAvatarPicker) {
            ZiveLegacyMediaPicker(
                ziveLegacyMediaPickerKind: .image,
                ziveLegacyMediaPickerOnImageData: { rhythmBloomProfileAvatarData in
                    rhythmBloomProfileSaveSelectedAvatar(rhythmBloomProfileAvatarData)
                },
                ziveLegacyMediaPickerOnVideoUrl: nil
            )
        }
    }

    private var rhythmBloomProfileAvatarSection: some View {
        Button {
            rhythmBloomProfileShowsAvatarPicker = true
        } label: {
            ZStack(alignment: .bottomTrailing) {
                ZiveSmartImage(ziveSmartImagePath: rhythmBloomProfileAvatar)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZiveStyle.ColorPalette.brandPink,
                                ZiveStyle.ColorPalette.brandOrange
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image("ZIVECamera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    }
                    .offset(x: 10, y: 8)
            }
        }
        .buttonStyle(.plain)
    }

    private var rhythmBloomProfileFormSection: some View {
        VStack(alignment: .leading, spacing: 19) {
            rhythmBloomProfileInputGroup(
                title: "Username",
                content: AnyView(
                    ZiveTextField(
                        placeholder: "please enter",
                        text: $rhythmBloomProfileUsername,
                        isFocused: rhythmBloomProfileFocusField == .username,
                        variant: .translucent,
                        focusState: $rhythmBloomProfileFocusField,
                        focusEquals: .username,
                        
                    )
                )
            )

            rhythmBloomProfileInputGroup(
                title: "Location",
                content: AnyView(
                    rhythmBloomProfileLocationMenu
                )
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("Gender")
                    .font(ZiveStyle.FontBook.boldItalic(20))
                    .foregroundStyle(ZiveStyle.ColorPalette.white)

                HStack(spacing: 10) {
                    rhythmBloomProfileGenderButton(
                        imageName: "ZIVEMale",
                        gender: .male
                    )

                    rhythmBloomProfileGenderButton(
                        imageName: "ZIVEFemale",
                        gender: .female
                    )
                }
            }
        }
    }

    private func rhythmBloomProfileInputGroup(title: String, content: AnyView) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(ZiveStyle.ColorPalette.white)

            content
        }
    }

    private var rhythmBloomProfileLocationMenu: some View {
        Menu {
            ForEach(rhythmBloomProfileLocationOptions, id: \.self) { rhythmBloomProfileLocationOption in
                Button {
                    rhythmBloomProfileLocation = rhythmBloomProfileLocationOption
                    rhythmBloomProfileFocusField = nil
                } label: {
                    if rhythmBloomProfileLocation == rhythmBloomProfileLocationOption {
                        Label(rhythmBloomProfileLocationOption, systemImage: "checkmark")
                    } else {
                        Text(rhythmBloomProfileLocationOption)
                    }
                }
            }
        } label: {
            HStack {
                Text(rhythmBloomProfileLocation)
                    .font(ZiveStyle.FontBook.regular(16))
                    .foregroundStyle(ZiveStyle.ColorPalette.white.opacity(0.9))

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ZiveStyle.ColorPalette.brandOrange)
            }
            .padding(.horizontal, 16)
            .frame(height: 46)
            .background(Color.white.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func rhythmBloomProfileGenderButton(
        imageName: String,
        gender: RhythmBloomProfileGender
    ) -> some View {
        Button {
            rhythmBloomProfileGender = gender
            rhythmBloomProfileFocusField = nil
        } label: {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(rhythmBloomProfileGender == gender ? 0.18 : 0.12))
                .frame(width: 58, height: 64)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            rhythmBloomProfileGender == gender
                            ? ZiveStyle.ColorPalette.white
                            : ZiveStyle.ColorPalette.clear,
                            lineWidth: 1
                        )
                }
                .overlay {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
        }
        .buttonStyle(.plain)
    }

    private func rhythmBloomProfilePrefillUsernameIfNeeded() {
        guard rhythmBloomProfileUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let rhythmBloomProfileDraftEmail = rhythmBloomProfileSignUpDraftCenter.skillProgressionSignUpDraftEmail
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let rhythmBloomProfileSuggestedUsername = rhythmBloomProfileDraftEmail
            .components(separatedBy: "@")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if !rhythmBloomProfileSuggestedUsername.isEmpty {
            rhythmBloomProfileUsername = rhythmBloomProfileSuggestedUsername
        }
    }

    private func rhythmBloomProfileCompleteSignUp() async {
        guard rhythmBloomProfileSignUpDraftCenter.skillProgressionSignUpDraftHasPendingData else {
            rhythmBloomProfileFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Registration information has expired",
                status: .error
            )
            rhythmBloomProfileNavigator.weioZwivbeReplaceStack(with: .skillProgressionSignUp)
            return
        }

        let rhythmBloomProfileTrimmedUsername = rhythmBloomProfileUsername
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !rhythmBloomProfileTrimmedUsername.isEmpty else {
            rhythmBloomProfileFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Please enter a username",
                status: .error
            )
            return
        }

        let rhythmBloomProfileUser = OrbitUserModel(
            id: "user_\(UUID().uuidString)",
            orbitUserEmail: rhythmBloomProfileSignUpDraftCenter.skillProgressionSignUpDraftEmail,
            orbitUserPassword: rhythmBloomProfileSignUpDraftCenter.skillProgressionSignUpDraftPassword,
            orbitUserAvatar: rhythmBloomProfileAvatar,
            orbitUserName: rhythmBloomProfileTrimmedUsername,
            orbitUserFollowerIds: [],
            orbitUserFollowingIds: [],
            orbitUserBlockedIds: [],
            orbitUserLikedVideoIds: [],
            orbitUserCoinCount: 0,
            orbitUserReceivedGiftValue: 0
        )

        rhythmBloomProfileUserStore.orbitUserCreate(rhythmBloomProfileUser)
        rhythmBloomProfileSignUpDraftCenter.skillProgressionSignUpDraftClear()
        QeixbgBriwyState.qeixbgBriwyCurrentUserId = rhythmBloomProfileUser.id
        await rhythmBloomProfilePerformSuccessTransition(
            loadingText: "Signing up..."
        )
        rhythmBloomProfileNavigator.weioZwivbePresentRoot(.pulseVistaHome)
    }

    private func rhythmBloomProfileSaveSelectedAvatar(_ rhythmBloomProfileAvatarData: Data) {
        do {
            let rhythmBloomProfileAvatarUrl = try rhythmBloomProfileSaveAvatarData(
                rhythmBloomProfileAvatarData,
                preferredExtension: "jpg"
            )

            rhythmBloomProfileAvatar = rhythmBloomProfileAvatarUrl.path
        } catch {
            rhythmBloomProfileFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Failed to update avatar",
                status: .error
            )
        }
    }

    private func rhythmBloomProfileSaveAvatarData(
        _ rhythmBloomProfileAvatarData: Data,
        preferredExtension: String
    ) throws -> URL {
        let rhythmBloomProfileSafeExtension = preferredExtension.isEmpty ? "jpg" : preferredExtension
        let rhythmBloomProfileAvatarUrl = rhythmBloomProfileDocumentsDirectory()
            .appendingPathComponent(
                "rhythmBloomAvatar_\(UUID().uuidString).\(rhythmBloomProfileSafeExtension)"
            )

        try rhythmBloomProfileAvatarData.write(to: rhythmBloomProfileAvatarUrl, options: .atomic)
        return rhythmBloomProfileAvatarUrl
    }

    private func rhythmBloomProfileDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func rhythmBloomProfilePerformSuccessTransition(
        loadingText: String
    ) async {
        await MainActor.run {
            rhythmBloomProfileFeedbackCenter.ziveGlobalFeedbackShowLoading(text: loadingText)
        }
        await delay(1)
        await MainActor.run {
            rhythmBloomProfileFeedbackCenter.ziveGlobalFeedbackHideLoading()
        }
    }
}
