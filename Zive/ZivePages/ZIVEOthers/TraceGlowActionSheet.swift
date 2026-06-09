import SwiftUI
import Combine

final class TraceGlowActionSheetCenter: ObservableObject {
    @Published var traceGlowActionSheetCenterIsPresented = false
    var traceGlowActionSheetCenterTargetUserId: String?
    var traceGlowActionSheetCenterAfterBlock: (() -> Void)?

    func traceGlowActionSheetCenterPresent(
        targetUserId: String,
        afterBlock: (() -> Void)? = nil
    ) {
        traceGlowActionSheetCenterTargetUserId = targetUserId
        traceGlowActionSheetCenterAfterBlock = afterBlock
        traceGlowActionSheetCenterIsPresented = true
    }

    func traceGlowActionSheetCenterDismiss() {
        traceGlowActionSheetCenterIsPresented = false
        traceGlowActionSheetCenterTargetUserId = nil
        traceGlowActionSheetCenterAfterBlock = nil
    }
}

struct TraceGlowActionSheet: View {
    @Binding var traceGlowActionSheetIsPresented: Bool
    var traceGlowActionSheetTargetUserId: String?
    var traceGlowActionSheetBlockAction: (() -> Void)? = nil
    
    @EnvironmentObject var traceGlowNavi: WeioZwivbeNavigator
    @EnvironmentObject private var traceGlowActionSheetUserStore: OrbitUserStore
    @EnvironmentObject private var traceGlowActionSheetFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var traceGlowActionSheetGuestGate: CBnxweZGoLogCenter

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    traceGlowActionSheetDismiss()
                }

            VStack(spacing: 0) {
                HStack(spacing: 32) {
                    traceGlowActionSheetButton(
                        title: "Report",
                        backgroundImageName: "ZIVEReportBtnBg"
                    ) {
                        traceGlowActionSheetGuestGate.CBnxweZGoLogRequireLogin {
                            traceGlowActionSheetDismiss()
                            traceGlowNavi.weioZwivbePush(.traceGlowReportDetail)
                        }
                    }

                    traceGlowActionSheetButton(
                        title: "Block",
                        backgroundImageName: "ZIVEBlockBtnBg"
                    ) {
                        traceGlowActionSheetGuestGate.CBnxweZGoLogRequireLogin {
                            traceGlowActionSheetBlockTarget()
                        }
                    }
                }.padding(.horizontal, 40)
                .padding(.top, 40)

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
                    Text("Cancel")
                        .font(ZiveStyle.FontBook.boldItalic(20))
                        .foregroundStyle(Color(red: 1, green: 235/255, blue: 235/255))
                }.frame(height: 53)
                    .onTapGesture {
                        traceGlowActionSheetDismiss()
                    }
                .padding(.horizontal, 40)
                .padding(.top, 24)
                .padding(.bottom, 22)
            }
            .frame(maxWidth: .infinity)
            .background(
                ZStack(alignment: .top) {
                    Color(red: 242/255, green: 242/255, blue: 242/255)
                    Image("ZIVECardBg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240)
                }
            )
            .clipShape(
                ZiveTopRoundedCornerShape(ziveTopRoundedCornerRadius: 20)
            )
            
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }.ignoresSafeArea(edges: .bottom)
    }

    private func traceGlowActionSheetButton(
        title: String,
        backgroundImageName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                Image(backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text(title)
                    .font(ZiveStyle.FontBook.boldItalic(18))
                    .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }

    private var traceGlowActionSheetCurrentUserId: String {
        QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func traceGlowActionSheetDismiss() {
        traceGlowActionSheetIsPresented = false
    }

    private func traceGlowActionSheetBlockTarget() {
        guard let traceGlowActionSheetTargetUserId,
              !traceGlowActionSheetTargetUserId.isEmpty else {
            traceGlowActionSheetDismiss()
            traceGlowActionSheetBlockAction?()
            return
        }

        guard !traceGlowActionSheetCurrentUserId.isEmpty else {
            traceGlowActionSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Current user not found",
                status: .error
            )
            traceGlowActionSheetDismiss()
            return
        }

        guard traceGlowActionSheetCurrentUserId != traceGlowActionSheetTargetUserId else {
            traceGlowActionSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "You cannot block yourself",
                status: .error
            )
            traceGlowActionSheetDismiss()
            return
        }

        if traceGlowActionSheetCurrentUser?.orbitUserBlockedIds.contains(traceGlowActionSheetTargetUserId) == true {
            traceGlowActionSheetDismiss()
            traceGlowActionSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "User already blocked",
                status: .success
            )
            traceGlowActionSheetBlockAction?()
            return
        }

        let traceGlowActionSheetDidBlock = traceGlowActionSheetUserStore.orbitUserBlockUser(
            currentUserId: traceGlowActionSheetCurrentUserId,
            blockedUserId: traceGlowActionSheetTargetUserId
        )

        traceGlowActionSheetDismiss()

        guard traceGlowActionSheetDidBlock else {
            traceGlowActionSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Unable to block user",
                status: .error
            )
            return
        }

        traceGlowActionSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
            text: "User blocked",
            status: .success
        )
        traceGlowActionSheetBlockAction?()
    }

    private var traceGlowActionSheetCurrentUser: OrbitUserModel? {
        traceGlowActionSheetUserStore.orbitUserFetch(by: traceGlowActionSheetCurrentUserId)
    }
}
