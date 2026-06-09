import SwiftUI

enum TempoTrailCreatePlanSheetFocusField {
    case goal
}

struct TempoTrailCreatePlanSheet: View {
    @Binding var tempoTrailCreatePlanSheetIsPresented: Bool
    @State private var tempoTrailCreatePlanSheetGoal = ""
    @State private var tempoTrailCreatePlanSheetDurationMinutes = 30
    @FocusState private var tempoTrailCreatePlanSheetFocusField: TempoTrailCreatePlanSheetFocusField?
    @EnvironmentObject private var tempoTrailCreatePlanSheetUserStore: OrbitUserStore
    @EnvironmentObject private var tempoTrailCreatePlanSheetPlanStore: TempoPlanStore
    @EnvironmentObject private var tempoTrailCreatePlanSheetFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var tempoTrailCreatePlanSheetGuestGate: CBnxweZGoLogCenter

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    tempoTrailCreatePlanSheetFocusField = nil
                }

            VStack(spacing: 24) {
                tempoTrailCreatePlanSheetCard

                HStack(spacing: 20) {
                    Button {
                        tempoTrailCreatePlanSheetIsPresented = false
                    } label: {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.14))
                            .frame(width: 80, height: 42)
                            .overlay {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(ZiveStyle.ColorPalette.white)
                            }
                    }
                    .buttonStyle(.plain)

                    GrooveStreakButton(title: "Create", width: 186, height: 42) {
                        tempoTrailCreatePlanSheetGuestGate.CBnxweZGoLogRequireLogin {
                            tempoTrailCreatePlanSheetCreatePlan()
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
        }
        .transition(.opacity)
    }

    private var tempoTrailCreatePlanSheetCard: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white)
                .overlay(alignment: .topTrailing) {
                    Image("ZIVECardBg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 295)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                }.padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(red: 204/255, green: 204/255, blue: 204/255))
                )

            Image("ZIVECardTopDecration")
                .resizable()
                .scaledToFit()
                .frame(width: 125)
                .offset(y: -16)

            VStack(spacing: 18) {
                Text("Come and make your dance plan now.\nZive will witness your progress.")
                    .font(ZiveStyle.FontBook.regular(14))
                    .foregroundStyle(ZiveStyle.ColorPalette.textPrimary.opacity(0.86))
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Training Goal:")
                            .font(ZiveStyle.FontBook.boldItalic(18))
                            .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)

                        ZiveTextField(
                            placeholder: "Enter your dance training goal",
                            text: $tempoTrailCreatePlanSheetGoal,
                            isFocused: tempoTrailCreatePlanSheetFocusField == .goal,
                            focusState: $tempoTrailCreatePlanSheetFocusField,
                            focusEquals: .goal
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Training Duration(Minutes):")
                            .font(ZiveStyle.FontBook.boldItalic(18))
                            .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)

                        tempoTrailCreatePlanSheetDurationPicker
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        .frame(height: 281)
    }

    private var tempoTrailCreatePlanSheetDurationPicker: some View {
        VStack(spacing: 10) {
            Picker("Training Duration", selection: $tempoTrailCreatePlanSheetDurationMinutes) {
                ForEach(1...120, id: \.self) { tempoTrailCreatePlanSheetMinute in
                    Text("\(tempoTrailCreatePlanSheetMinute)")
                        .font(ZiveStyle.FontBook.boldItalic(18))
                        .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
                        .rotationEffect(.degrees(90))
                        .tag(tempoTrailCreatePlanSheetMinute)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 50, height: 300)
            .rotationEffect(.degrees(-90))
            .frame(maxWidth: .infinity)
            .clipped()

        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(Color.black.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var tempoTrailCreatePlanSheetCurrentUser: OrbitUserModel? {
        let tempoTrailCreatePlanSheetCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return tempoTrailCreatePlanSheetUserStore.orbitUserFetch(by: tempoTrailCreatePlanSheetCurrentUserId)
    }

    private func tempoTrailCreatePlanSheetCreatePlan() {
        let tempoTrailCreatePlanSheetTrimmedGoal = tempoTrailCreatePlanSheetGoal
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !tempoTrailCreatePlanSheetTrimmedGoal.isEmpty else {
            tempoTrailCreatePlanSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Training goal cannot be empty",
                status: .error
            )
            return
        }

        guard (1...120).contains(tempoTrailCreatePlanSheetDurationMinutes) else {
            tempoTrailCreatePlanSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Training duration must be between 1 and 120 minutes",
                status: .error
            )
            return
        }

        guard let tempoTrailCreatePlanSheetCurrentUser else {
            tempoTrailCreatePlanSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
                text: "Current user not found",
                status: .error
            )
            return
        }

        let tempoTrailCreatePlanSheetNewPlan = TempoPlanModel(
            id: "plan_\(UUID().uuidString)",
            tempoPlanPublisherId: tempoTrailCreatePlanSheetCurrentUser.id,
            tempoPlanPublishTime: Date(),
            tempoPlanGoal: tempoTrailCreatePlanSheetTrimmedGoal,
            tempoPlanDurationMinutes: tempoTrailCreatePlanSheetDurationMinutes,
            tempoPlanIsFinished: false
        )

        tempoTrailCreatePlanSheetPlanStore.tempoPlanCreate(tempoTrailCreatePlanSheetNewPlan)
        tempoTrailCreatePlanSheetFocusField = nil
        tempoTrailCreatePlanSheetFeedbackCenter.ziveGlobalFeedbackShowToast(
            text: "Plan created successfully",
            status: .success
        )
        tempoTrailCreatePlanSheetIsPresented = false
    }
}
