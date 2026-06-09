import SwiftUI

enum StepGlowEditProfileFocusField {
    case username
}

struct StepGlowEditProfile: View {
    @State private var stepGlowEditProfileUsername = ""
    @State private var stepGlowEditProfileAvatar = ""
    @State private var stepGlowEditProfileShowsAvatarPicker = false
    @FocusState private var stepGlowEditProfileFocusField: StepGlowEditProfileFocusField?
    @EnvironmentObject private var stepGlowEditProfileUserStore: OrbitUserStore
    @EnvironmentObject private var stepGlowEditProfileNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var stepGlowEditProfileFeedbackCenter: ZiveGlobalFeedbackCenter

    var body: some View {
        ZStack {
            ZiveStyle.ColorPalette.background
                .ignoresSafeArea()
                .onTapGesture {
                    stepGlowEditProfileFocusField = nil
                }

            VStack(spacing: 0) {
                GrooveStreakTopNavigationBar(title: "Edit")
                    .padding(.horizontal, 18)
                    .padding(.top, 10)

                VStack(spacing: 0) {
                    stepGlowEditProfileAvatarSection
                        .padding(.top, 34)

                    stepGlowEditProfileFormSection
                        .padding(.top, 45)

                    Spacer()

                    if stepGlowEditProfileFocusField == nil {
                        GrooveStreakButton(title: "Save", width: 297, height: 39) {
                            stepGlowEditProfileFocusField = nil
                            stepGlowEditProfileSaveProfile()
                        }
                        .padding(.bottom, 66)
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 18)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            stepGlowEditProfileFocusField = nil
        }
        .onAppear {
            stepGlowEditProfileLoadCurrentUser()
        }
        .sheet(isPresented: $stepGlowEditProfileShowsAvatarPicker) {
            ZiveLegacyMediaPicker(
                ziveLegacyMediaPickerKind: .image,
                ziveLegacyMediaPickerOnImageData: { stepGlowEditProfileAvatarData in
                    stepGlowEditProfileHandleSelectedAvatarData(stepGlowEditProfileAvatarData)
                },
                ziveLegacyMediaPickerOnVideoUrl: nil
            )
        }
        .animation(.easeInOut(duration: 0.2), value: stepGlowEditProfileFocusField == nil)
        .navigationBarHidden(true)
    }

    private var stepGlowEditProfileCurrentUser: OrbitUserModel? {
        let stepGlowEditProfileCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return stepGlowEditProfileUserStore.orbitUserFetch(by: stepGlowEditProfileCurrentUserId)
    }

    private var stepGlowEditProfileAvatarSection: some View {
        Button {
            stepGlowEditProfileShowsAvatarPicker = true
        } label: {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .overlay {
                        ZiveSmartImage(ziveSmartImagePath: stepGlowEditProfileAvatar)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                RoundedRectangle(cornerRadius: 18, style: .continuous)
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
                    .frame(width: 45, height: 45)
                    .overlay {
                        Image("ZIVECamera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    .offset(x: 14, y: 10)
            }
        }
        .buttonStyle(.plain)
    }

    private var stepGlowEditProfileFormSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Username:")
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(ZiveStyle.ColorPalette.white)

            ZiveTextField(
                placeholder: "Enter your username",
                text: $stepGlowEditProfileUsername,
                isFocused: stepGlowEditProfileFocusField == .username,
                variant: .translucent,
                focusState: $stepGlowEditProfileFocusField,
                focusEquals: .username
            )
        }
    }

    private func stepGlowEditProfileLoadCurrentUser() {
        guard let stepGlowEditProfileCurrentUser else {
            return
        }

        if stepGlowEditProfileUsername.isEmpty {
            stepGlowEditProfileUsername = stepGlowEditProfileCurrentUser.orbitUserName
        }
        stepGlowEditProfileAvatar = stepGlowEditProfileCurrentUser.orbitUserAvatar
    }

    private func stepGlowEditProfileSaveProfile() {
        let stepGlowEditProfileTrimmedUsername = stepGlowEditProfileUsername
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !stepGlowEditProfileTrimmedUsername.isEmpty else {
            stepGlowEditProfileFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Username cannot be empty",
                status: .error
            )
            return
        }

        guard var stepGlowEditProfileCurrentUser else {
            stepGlowEditProfileFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Current user not found",
                status: .error
            )
            return
        }

        stepGlowEditProfileCurrentUser.orbitUserName = stepGlowEditProfileTrimmedUsername
        stepGlowEditProfileCurrentUser.orbitUserAvatar = stepGlowEditProfileAvatar
        stepGlowEditProfileUserStore.orbitUserUpdate(stepGlowEditProfileCurrentUser)
        stepGlowEditProfileFeedbackCenter.ziveGlobalFeedbackShowToast(
            text: "Profile updated",
            status: .success
        )
        stepGlowEditProfileNavigator.weioZwivbePop()
    }

    private func stepGlowEditProfileHandleSelectedAvatarData(_ stepGlowEditProfileAvatarData: Data) {
        do {
            let stepGlowEditProfileAvatarUrl = try stepGlowEditProfileSaveAvatarData(
                stepGlowEditProfileAvatarData,
                preferredExtension: "jpg"
            )

            stepGlowEditProfileAvatar = stepGlowEditProfileAvatarUrl.path
        } catch {
            stepGlowEditProfileFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Failed to update avatar",
                status: .error
            )
        }
    }

    private func stepGlowEditProfileSaveAvatarData(
        _ stepGlowEditProfileAvatarData: Data,
        preferredExtension: String
    ) throws -> URL {
        let stepGlowEditProfileSafeExtension = preferredExtension.isEmpty ? "jpg" : preferredExtension
        let stepGlowEditProfileAvatarUrl = stepGlowEditProfileDocumentsDirectory()
            .appendingPathComponent("stepGlowAvatar_\(UUID().uuidString).\(stepGlowEditProfileSafeExtension)")

        try stepGlowEditProfileAvatarData.write(to: stepGlowEditProfileAvatarUrl, options: .atomic)
        return stepGlowEditProfileAvatarUrl
    }

    private func stepGlowEditProfileDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
