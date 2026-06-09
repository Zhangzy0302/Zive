import SwiftUI

struct ZiveGlobalFeedbackHost<Content: View>: View {
    @EnvironmentObject private var ziveGlobalFeedbackCenter: ZiveGlobalFeedbackCenter
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content

            if let ziveGlobalFeedbackLoading = ziveGlobalFeedbackCenter.ziveGlobalFeedbackLoading {
                ziveGlobalFeedbackLoadingView(ziveGlobalFeedbackLoading)
                    .zIndex(100)
            }

            if let ziveGlobalFeedbackToast = ziveGlobalFeedbackCenter.ziveGlobalFeedbackToast {
                VStack {
                    Spacer()

                    ziveGlobalFeedbackToastView(ziveGlobalFeedbackToast)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 48)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(101)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: ziveGlobalFeedbackCenter.ziveGlobalFeedbackLoading != nil)
        .animation(.easeInOut(duration: 0.2), value: ziveGlobalFeedbackCenter.ziveGlobalFeedbackToast != nil)
    }

    private func ziveGlobalFeedbackLoadingView(_ ziveGlobalFeedbackLoading: ZiveLoadingPayload) -> some View {
        ZStack {
            if ziveGlobalFeedbackLoading.showsMask {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
            } else {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
            }

            VStack(spacing: 14) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(ZiveStyle.ColorPalette.white)
                    .scaleEffect(1.25)

                if let ziveGlobalFeedbackText = ziveGlobalFeedbackLoading.text,
                   !ziveGlobalFeedbackText.isEmpty {
                    Text(ziveGlobalFeedbackText)
                        .font(ZiveStyle.FontBook.regular(15))
                        .foregroundStyle(ZiveStyle.ColorPalette.white)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 22)
            .background(Color.black.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .white.opacity(0.5), radius: 8)
        }
    }

    private func ziveGlobalFeedbackToastView(_ ziveGlobalFeedbackToast: ZiveToastPayload) -> some View {
        Button {
            ziveGlobalFeedbackCenter.ziveGlobalFeedbackDismissToast()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: ziveGlobalFeedbackToast.status.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(ziveGlobalFeedbackToast.status.iconColor)

                Text(ziveGlobalFeedbackToast.text)
                    .font(ZiveStyle.FontBook.regular(15))
                    .foregroundStyle(ZiveStyle.ColorPalette.white)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.black.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
