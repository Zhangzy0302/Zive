import SwiftUI

struct TraceGlowReportDetail: View {
    @State private var traceGlowReportDetailSelectedReason = "Pornographi\nc & Vulgar"
    @EnvironmentObject private var traceGlowReportDetailNavigator: WeioZwivbeNavigator
    @EnvironmentObject private var traceGlowReportDetailFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var traceGlowReportDetailGuestGate: CBnxweZGoLogCenter

    private let traceGlowReportDetailReasons = [
        "Pornographi\nc & Vulgar",
        "Violent &\nBloody",
        "Insult &\nPersonal Attack",
        "Plagiarism &\nReposting",
        "Bad\nGuidance",
        "Others"
    ]

    var body: some View {
        VStack(spacing: 0) {
            GrooveStreakTopNavigationBar(title: "Report")
                .padding(.horizontal, 16)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 40) {
                Text("Please select the type of report:")
                    .font(ZiveStyle.FontBook.regular(14))
                    .foregroundStyle(ZiveStyle.ColorPalette.white.opacity(0.9))

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 14
                ) {
                    ForEach(traceGlowReportDetailReasons, id: \.self) { traceGlowReportDetailReason in
                        traceGlowReportDetailReasonButton(
                            title: traceGlowReportDetailReason,
                            isSelected: traceGlowReportDetailSelectedReason == traceGlowReportDetailReason
                        ) {
                            traceGlowReportDetailSelectedReason = traceGlowReportDetailReason
                        }
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)

            Spacer()

            GrooveStreakButton(title: "Submit", width: 306, height: 45) {
                traceGlowReportDetailGuestGate.CBnxweZGoLogRequireLogin {
                    traceGlowReportDetailSubmit()
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 66)
        }
        .ziveScreenBackground()
        .navigationBarHidden(true)
    }

    private func traceGlowReportDetailReasonButton(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(ZiveStyle.FontBook.boldItalic(16))
                .multilineTextAlignment(.center)
                .foregroundStyle(ZiveStyle.ColorPalette.white)
                .frame(maxWidth: .infinity)
                .frame(height: 78)
            
                .background(
                    Group {
                        if isSelected {
                            ZStack{
                                Color.white.opacity(0.15)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                LinearGradient(
                                    colors: [
                                        ZiveStyle.ColorPalette.brandPink,
                                        ZiveStyle.ColorPalette.brandOrange
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ).padding(2)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .blur(radius: 10)
                            }
                            
                        } else {
                            Color.white.opacity(0.15)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                )
                
                .shadow(
                    color: isSelected ? ZiveStyle.ColorPalette.brandPink.opacity(0.45) : .clear,
                    radius: 12,
                    x: 0,
                    y: 0
                )
        }
        .buttonStyle(.plain)
    }

    private func traceGlowReportDetailSubmit() {
        traceGlowReportDetailFeedbackCenter.ziveGlobalFeedbackShowToast(
            text: "Report submitted successfully",
            status: .success
        )
        traceGlowReportDetailNavigator.weioZwivbePop()
    }
}
