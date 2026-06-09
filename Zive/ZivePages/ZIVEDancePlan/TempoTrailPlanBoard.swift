import SwiftUI

struct TempoTrailPlanDayItem: Identifiable {
    let date: Date
    let dayNumber: String
    let weekday: String
    let isToday: Bool

    var id: Date {
        date
    }
}

struct TempoTrailPlanBoard: View {
    @State private var tempoTrailPlanBoardShowCreateSheet = false
    @State private var tempoTrailPlanBoardSelectedDate = Calendar.current.startOfDay(for: Date())
    @EnvironmentObject private var tempoTrailPlanBoardUserStore: OrbitUserStore
    @EnvironmentObject private var tempoTrailPlanBoardPlanStore: TempoPlanStore
    @EnvironmentObject private var tempoTrailPlanBoardFeedbackCenter: ZiveGlobalFeedbackCenter
    @EnvironmentObject private var tempoTrailPlanBoardGuestGate: CBnxweZGoLogCenter

    private let tempoTrailPlanBoardDays: [TempoTrailPlanDayItem] = {
        let tempoTrailPlanBoardCalendar = Calendar.current
        let tempoTrailPlanBoardToday = Date()
        let tempoTrailPlanBoardTodayStart = tempoTrailPlanBoardCalendar.startOfDay(for: tempoTrailPlanBoardToday)
        let tempoTrailPlanBoardFormatter = DateFormatter()
        tempoTrailPlanBoardFormatter.locale = Locale.current
        tempoTrailPlanBoardFormatter.dateFormat = "E"

        return (-2...2).compactMap { tempoTrailPlanBoardOffset in
            guard let tempoTrailPlanBoardDate = tempoTrailPlanBoardCalendar.date(
                byAdding: .day,
                value: tempoTrailPlanBoardOffset,
                to: tempoTrailPlanBoardToday
            ) else {
                return nil
            }

            let tempoTrailPlanBoardStartDate = tempoTrailPlanBoardCalendar.startOfDay(for: tempoTrailPlanBoardDate)
            let tempoTrailPlanBoardDayNumber = String(
                tempoTrailPlanBoardCalendar.component(.day, from: tempoTrailPlanBoardDate)
            )
            let tempoTrailPlanBoardWeekday = tempoTrailPlanBoardFormatter.string(from: tempoTrailPlanBoardDate)

            return TempoTrailPlanDayItem(
                date: tempoTrailPlanBoardStartDate,
                dayNumber: tempoTrailPlanBoardDayNumber,
                weekday: tempoTrailPlanBoardWeekday,
                isToday: tempoTrailPlanBoardStartDate == tempoTrailPlanBoardTodayStart
            )
        }
    }()

    var body: some View {
        ZStack(alignment: .top) {
            Image("ZIVETopDecoration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipped()
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                GrooveStreakTopNavigationBar(title: "Plan")
                    .padding(.horizontal, 18)
                    .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        tempoTrailPlanBoardDayStrip
                            .padding(.top, 20)
                            .padding(.horizontal, 20)

                        if let tempoTrailPlanBoardSelectedPlan {
                            tempoTrailPlanBoardPlanContent(tempoTrailPlanBoardSelectedPlan)
                                .padding(.top, 36)
                        } else {
                            tempoTrailPlanBoardEmptyContent
                                .padding(.top, 38)
                        }
                    }
                }
            }

            if tempoTrailPlanBoardShowCreateSheet {
                TempoTrailCreatePlanSheet(
                    tempoTrailCreatePlanSheetIsPresented: $tempoTrailPlanBoardShowCreateSheet
                )
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: tempoTrailPlanBoardShowCreateSheet)
        .ziveScreenBackground()
        .navigationBarHidden(true)
    }


    private var tempoTrailPlanBoardDayStrip: some View {
        HStack(spacing: 10) {
            ForEach(tempoTrailPlanBoardDays) { tempoTrailPlanBoardDay in
                Button {
                    tempoTrailPlanBoardSelectedDate = tempoTrailPlanBoardDay.date
                } label: {
                    VStack(spacing: 8) {
                        Text(tempoTrailPlanBoardDay.dayNumber)
                            .font(ZiveStyle.FontBook.boldItalic(22))
                            .foregroundStyle(Color.white)

                        Text(tempoTrailPlanBoardDay.weekday)
                            .font(ZiveStyle.FontBook.regular(15))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 84)
                    .background(
                        Group {
                            if tempoTrailPlanBoardIsSelected(tempoTrailPlanBoardDay) {
                                ZStack{
                                    Color.white.opacity(0.23)
                                    LinearGradient(
                                        colors: [
                                            ZiveStyle.ColorPalette.brandPink,
                                            ZiveStyle.ColorPalette.brandOrange
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ).blur(radius: 10)
                                }
                                
                            } else {
                                Color.white.opacity(0.14)
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(
                        color: tempoTrailPlanBoardIsSelected(tempoTrailPlanBoardDay)
                        ? ZiveStyle.ColorPalette.brandPink.opacity(0.5)
                        : .clear,
                        radius: 16,
                        x: 0,
                        y: 0
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var tempoTrailPlanBoardEmptyContent: some View {
        VStack(spacing: 0) {
            Image("ZIVEEmptyData")
                .resizable()
                .scaledToFit()
                .frame(width: 152, height: 253)

            Text(tempoTrailPlanBoardIsSelectedToday ? "No practice plan yet. Create one now!" : "No practice plan for this day.")
                .font(ZiveStyle.FontBook.regular(14))
                .foregroundStyle(Color.white)
                .padding(.top, 8)

            Spacer(minLength: 160)

            if tempoTrailPlanBoardIsSelectedToday {
                GrooveStreakButton(title: "Create", width: 302, height: 45) {
                    tempoTrailPlanBoardGuestGate.CBnxweZGoLogRequireLogin {
                        tempoTrailPlanBoardShowCreateSheet = true
                    }
                }
                .padding(.bottom, 66)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func tempoTrailPlanBoardPlanContent(_ tempoTrailPlanBoardPlan: TempoPlanModel) -> some View {
        VStack(alignment: .leading, spacing: 28) {
            Text("Formulate a plan")
                .font(ZiveStyle.FontBook.boldItalic(20))
                .foregroundStyle(Color.white)

            tempoTrailPlanBoardPlanCard(tempoTrailPlanBoardPlan)
                .padding(.horizontal, 16)

            if tempoTrailPlanBoardPlan.tempoPlanIsFinished {
                Text("Great job! You've finished today's\ndance practice.")
                    .font(ZiveStyle.FontBook.regular(14))
                    .foregroundStyle(Color(red: 72/255, green: 240/255, blue: 122/255))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            } else if tempoTrailPlanBoardIsSelectedToday {
                Spacer(minLength: 72)

                Text("Tap to complete your daily goal.")
                    .font(ZiveStyle.FontBook.regular(12))
                    .foregroundStyle(Color.white.opacity(0.41))
                    .frame(maxWidth: .infinity)

                GrooveStreakButton(title: "Complete Goal", width: 302, height: 45) {
                    tempoTrailPlanBoardGuestGate.CBnxweZGoLogRequireLogin {
                        tempoTrailPlanBoardCompletePlan(tempoTrailPlanBoardPlan)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.bottom, 66)
            }
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tempoTrailPlanBoardPlanCard(_ tempoTrailPlanBoardPlan: TempoPlanModel) -> some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.white.opacity(0.3))
                .frame(height: 221)

            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.white)
                .overlay {
                    Image(tempoTrailPlanBoardPlan.tempoPlanIsFinished ? "ZIVEPlanCompletedBg" : "ZIVECardBg")
                        .resizable()
                        .frame(height: 209)
                }
                .frame(height: 209)
                .padding(.top, 6)
                .padding(.horizontal, 6)

            Image("ZIVECardTopDecration")
                .resizable()
                .frame(width: 125, height: 30)
                .offset(y: -11)

            VStack(alignment: .leading, spacing: 20) {
                Text("Training Goal: \(tempoTrailPlanBoardPlan.tempoPlanGoal)")
                    .font(ZiveStyle.FontBook.boldItalic(18))
                    .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .padding(.top, 43)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Training Duration: \(tempoTrailPlanBoardPlan.tempoPlanDurationMinutes)mins")
                        .font(ZiveStyle.FontBook.regular(14))
                        .foregroundStyle(ZiveStyle.ColorPalette.textPrimary.opacity(0.88))

                    tempoTrailPlanBoardProgressBar(tempoTrailPlanBoardPlan)
                }
                Spacer()

                if !tempoTrailPlanBoardPlan.tempoPlanIsFinished {
                    Text("Plan Unfinished")
                        .font(ZiveStyle.FontBook.regular(14))
                        .foregroundStyle(ZiveStyle.ColorPalette.brandPink)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 14)
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 214)
    }

    private func tempoTrailPlanBoardProgressBar(_ tempoTrailPlanBoardPlan: TempoPlanModel) -> some View {
        GeometryReader { tempoTrailPlanBoardGeometry in
            let tempoTrailPlanBoardProgress = tempoTrailPlanBoardProgressValue(tempoTrailPlanBoardPlan)
            let tempoTrailPlanBoardWidth = tempoTrailPlanBoardGeometry.size.width
            let tempoTrailPlanBoardFillWidth = max(12, tempoTrailPlanBoardWidth * tempoTrailPlanBoardProgress)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(red: 242/255, green: 242/255, blue: 242/255))
                    .frame(height: 12)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: tempoTrailPlanBoardPlan.tempoPlanIsFinished
                            ? [
                                Color(red: 72/255, green: 240/255, blue: 122/255),
                                Color(red: 78/255, green: 245/255, blue: 198/255)
                            ]
                            : [
                                Color(red: 246/255, green: 79/255, blue: 142/255),
                                Color(red: 239/255, green: 153/255, blue: 72/255)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: tempoTrailPlanBoardFillWidth, height: 12)
                VStack(spacing: 0){
                    Image("ZIVEPlanProcessLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        

                    if tempoTrailPlanBoardPlan.tempoPlanIsFinished {
                        Text("WoW")
                            .font(ZiveStyle.FontBook.boldItalic(14))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 8)
                            .background(LinearGradient(colors: [
                                Color(red: 72/255, green: 240/255, blue: 122/255),
                                Color(red: 78/255, green: 245/255, blue: 198/255)
                            ], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                            .shadow(color: Color.green.opacity(0.55), radius: 10, x: 0, y: 0)
                    } else {
                        Text("Come on")
                            .font(ZiveStyle.FontBook.boldItalic(14))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 8)
                            .background(LinearGradient(colors: [
                                Color(red: 246/255, green: 79/255, blue: 142/255),
                                Color(red: 239/255, green: 153/255, blue: 72/255)
                            ], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                            .shadow(color: ZiveStyle.ColorPalette.brandPink.opacity(0.55), radius: 12, x: 0, y: 0)
                    }
                }.offset(x: min(max(0, tempoTrailPlanBoardFillWidth - 30), max(0, tempoTrailPlanBoardWidth - 32)), y: 12)
                
            }
        }
        .frame(height: 38)
    }

    private var tempoTrailPlanBoardCurrentUser: OrbitUserModel? {
        let tempoTrailPlanBoardCurrentUserId = QeixbgBriwyState.qeixbgBriwyCurrentUserId
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return tempoTrailPlanBoardUserStore.orbitUserFetch(by: tempoTrailPlanBoardCurrentUserId)
    }

    private var tempoTrailPlanBoardSelectedPlan: TempoPlanModel? {
        guard let tempoTrailPlanBoardCurrentUser else {
            return nil
        }

        return tempoTrailPlanBoardPlanStore
            .tempoPlanFetchByPublisherId(tempoTrailPlanBoardCurrentUser.id)
            .filter {
                Calendar.current.isDate($0.tempoPlanPublishTime, inSameDayAs: tempoTrailPlanBoardSelectedDate)
            }
            .sorted { $0.tempoPlanPublishTime > $1.tempoPlanPublishTime }
            .first
    }

    private var tempoTrailPlanBoardIsSelectedToday: Bool {
        Calendar.current.isDateInToday(tempoTrailPlanBoardSelectedDate)
    }

    private func tempoTrailPlanBoardIsSelected(_ tempoTrailPlanBoardDay: TempoTrailPlanDayItem) -> Bool {
        Calendar.current.isDate(tempoTrailPlanBoardDay.date, inSameDayAs: tempoTrailPlanBoardSelectedDate)
    }

    private func tempoTrailPlanBoardProgressValue(_ tempoTrailPlanBoardPlan: TempoPlanModel) -> CGFloat {
        tempoTrailPlanBoardPlan.tempoPlanIsFinished ? 1 : 0.62
    }

    private func tempoTrailPlanBoardCompletePlan(_ tempoTrailPlanBoardPlan: TempoPlanModel) {
        guard tempoTrailPlanBoardIsSelectedToday else {
            return
        }

        var tempoTrailPlanBoardUpdatedPlan = tempoTrailPlanBoardPlan
        tempoTrailPlanBoardUpdatedPlan.tempoPlanIsFinished = true
        tempoTrailPlanBoardPlanStore.tempoPlanUpdate(tempoTrailPlanBoardUpdatedPlan)
        tempoTrailPlanBoardFeedbackCenter.ziveGlobalFeedbackShowToast(
            text: "Goal completed",
            status: .success
        )
    }
}
