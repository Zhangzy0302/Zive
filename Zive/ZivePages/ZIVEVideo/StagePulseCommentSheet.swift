import SwiftUI
import Combine

enum StagePulseCommentSheetFocusField {
    case comment
}

struct StagePulseCommentSheet: View {
    let stagePulseCommentSheetVideoId: String
    @Binding var stagePulseCommentSheetIsPresented: Bool
    @State private var stagePulseCommentSheetText = ""
    @State private var stagePulseCommentSheetKeyboardHeight: CGFloat = 0
    @FocusState private var stagePulseCommentSheetFocusField: StagePulseCommentSheetFocusField?
    @EnvironmentObject private var stagePulseCommentSheetNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var stagePulseCommentSheetActionSheetCenter: TraceGlowActionSheetCenter
    @EnvironmentObject private var stagePulseCommentSheetUserStore: OrbitUserStore
    @EnvironmentObject private var stagePulseCommentSheetVideoStore: ReelVideoStore
    @EnvironmentObject private var stagePulseCommentSheetCommentStore: EchoCommentStore
    @EnvironmentObject private var stagePulseCommentSheetFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var stagePulseCommentSheetGuestGate: CBnxweZGoLogCenter

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.02)
                .ignoresSafeArea()
                .onTapGesture {
                    if stagePulseCommentSheetFocusField != nil {
                        stagePulseCommentSheetFocusField = nil
                    } else {
                        stagePulseCommentSheetIsPresented = false
                    }
                }

            VStack(alignment: .leading, spacing: 14) {
                Text("comments:")
                    .font(ZiveStyle.FontBook.boldItalic(18))
                    .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
                    .padding(.top, 22)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(stagePulseCommentSheetVisibleComments) { stagePulseCommentSheetComment in
                            HStack(alignment: .top, spacing: 12) {
                                ZiveSmartImage(
                                    ziveSmartImagePath: stagePulseCommentSheetUser(
                                        for: stagePulseCommentSheetComment
                                    )?.orbitUserAvatar ?? ""
                                ) {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.black.opacity(0.08))
                                }
                                .frame(width: 52, height: 52)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .onTapGesture {
                                    guard let stagePulseCommentSheetUser = stagePulseCommentSheetUser(
                                        for: stagePulseCommentSheetComment
                                    ) else {
                                        return
                                    }

                                    stagePulseCommentSheetNavigator.weioZwivbePush(
                                        .echoPulseProfile(stagePulseCommentSheetUser.id)
                                    )
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(
                                        stagePulseCommentSheetUser(
                                            for: stagePulseCommentSheetComment
                                        )?.orbitUserName ?? "Zive User"
                                    )
                                    .font(ZiveStyle.FontBook.italic(14))
                                    .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)

                                    Text(stagePulseCommentSheetComment.echoCommentContent)
                                        .font(ZiveStyle.FontBook.regular(12))
                                        .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer()

                                if !stagePulseCommentSheetIsMyComment(stagePulseCommentSheetComment) {
                                    Image("ZIVEIconReport")
                                        .resizable()
                                        .frame(width: 22, height: 22)
                                        .onTapGesture {
                                            stagePulseCommentSheetGuestGate.CBnxweZGoLogRequireLogin {
                                                stagePulseCommentSheetShowReportSheet(
                                                    for: stagePulseCommentSheetComment
                                                )
                                            }
                                        }
                                }
                            }
                        }
                    }
                }

                HStack(spacing: 8) {
                    ZiveTextField(
                        placeholder: "Say something...",
                        text: $stagePulseCommentSheetText,
                        isFocused: stagePulseCommentSheetFocusField == .comment,
                        focusState: $stagePulseCommentSheetFocusField,
                        focusEquals: .comment
                    )
                    .frame(height: 42)
                    
                    // 发布评论
                    Button {
                        stagePulseCommentSheetGuestGate.CBnxweZGoLogRequireLogin {
                            stagePulseCommentSheetSendComment()
                        }
                    } label: {
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
                                .padding(.horizontal, 3)
                                .padding(.vertical, 2)
                                .blur(radius: 4)
                            Image("ZIVESend")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }.frame(width: 72, height: 53)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 17)
            .frame(maxWidth: .infinity)
            .frame(height: 500)
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
            .padding(.bottom, stagePulseCommentSheetKeyboardHeight)
            .contentShape(Rectangle())
            .onTapGesture {
                stagePulseCommentSheetFocusField = nil
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .ignoresSafeArea(edges: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        ) { stagePulseCommentSheetNotification in
            guard let stagePulseCommentSheetKeyboardFrame = stagePulseCommentSheetNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }

            withAnimation(.easeInOut(duration: 0.22)) {
                stagePulseCommentSheetKeyboardHeight = max(0, stagePulseCommentSheetKeyboardFrame.height - 20)
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        ) { _ in
            withAnimation(.easeInOut(duration: 0.22)) {
                stagePulseCommentSheetKeyboardHeight = 0
            }
        }
    }

    private var stagePulseCommentSheetVisibleComments: [EchoCommentModel] {
        let stagePulseCommentSheetBlockedUserIds = Set(
            stagePulseCommentSheetCurrentUser?.orbitUserBlockedIds ?? []
        )

        return stagePulseCommentSheetCommentStore
            .echoCommentFetchByVideoId(stagePulseCommentSheetVideoId)
            .filter { !stagePulseCommentSheetBlockedUserIds.contains($0.echoCommentPublisherId) }
            .sorted { $0.echoCommentTime < $1.echoCommentTime }
    }

    private var stagePulseCommentSheetCurrentUser: OrbitUserModel? {
        let stagePulseCommentSheetCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return stagePulseCommentSheetUserStore.orbitUserFetch(by: stagePulseCommentSheetCurrentUserId)
    }

    private var stagePulseCommentSheetVideoPublisherId: String? {
        stagePulseCommentSheetVideoStore
            .reelVideoFetch(by: stagePulseCommentSheetVideoId)?
            .reelVideoPublisherId
    }

    private func stagePulseCommentSheetUser(for stagePulseCommentSheetComment: EchoCommentModel) -> OrbitUserModel? {
        stagePulseCommentSheetUserStore.orbitUserFetch(by: stagePulseCommentSheetComment.echoCommentPublisherId)
    }

    private func stagePulseCommentSheetIsMyComment(_ stagePulseCommentSheetComment: EchoCommentModel) -> Bool {
        stagePulseCommentSheetComment.echoCommentPublisherId == stagePulseCommentSheetCurrentUser?.id
    }

    private func stagePulseCommentSheetSendComment() {
        let stagePulseCommentSheetTrimmedText = stagePulseCommentSheetText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !stagePulseCommentSheetTrimmedText.isEmpty else {
            stagePulseCommentSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Comment cannot be empty",
                status: .error
            )
            return
        }

        guard let stagePulseCommentSheetCurrentUser else {
            stagePulseCommentSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Current user not found",
                status: .error
            )
            return
        }

        let stagePulseCommentSheetNewComment = EchoCommentModel(
            id: "comment_\(UUID().uuidString)",
            echoCommentVideoId: stagePulseCommentSheetVideoId,
            echoCommentPublisherId: stagePulseCommentSheetCurrentUser.id,
            echoCommentContent: stagePulseCommentSheetTrimmedText,
            echoCommentTime: Date()
        )

        stagePulseCommentSheetCommentStore.echoCommentCreate(stagePulseCommentSheetNewComment)
        stagePulseCommentSheetText = ""
        stagePulseCommentSheetFocusField = nil
        stagePulseCommentSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
            text: "Comment sent",
            status: .success
        )
    }

    private func stagePulseCommentSheetShowReportSheet(for stagePulseCommentSheetComment: EchoCommentModel) {
        stagePulseCommentSheetFocusField = nil
        let stagePulseCommentSheetTargetUserId = stagePulseCommentSheetComment.echoCommentPublisherId

        if stagePulseCommentSheetTargetUserId == stagePulseCommentSheetVideoPublisherId {
            stagePulseCommentSheetActionSheetCenter.traceGlowActionSheetCenterPresent(
                targetUserId: stagePulseCommentSheetTargetUserId
            ) {
                stagePulseCommentSheetIsPresented = false
                stagePulseCommentSheetNavigator.weioZwivbePopToRoot()
            }
            return
        }

        stagePulseCommentSheetActionSheetCenter.traceGlowActionSheetCenterPresent(
            targetUserId: stagePulseCommentSheetTargetUserId
        )
    }
}
