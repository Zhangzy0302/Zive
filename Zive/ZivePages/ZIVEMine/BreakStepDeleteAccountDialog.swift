import SwiftUI

struct BreakStepDeleteAccountDialog: View {
    @Binding var breakStepDeleteAccountIsPresented: Bool
    var breakStepDeleteAccountOnConfirm: () -> Void = {}

    var body: some View {
        ZStack {
            Color.black.opacity(0.68)
                .ignoresSafeArea()
                .onTapGesture {
                    breakStepDeleteAccountIsPresented = false
                }

            VStack(spacing: 0) {
                Text("Are you sure you want to delete\nthis account? All data will be\ncleared after deletion and cannot\nbe recovered.")
                    .font(ZiveStyle.FontBook.regular(17))
                    .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(1)
                    .padding(.top, 24)
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
                    Text("Sure")
                        .font(ZiveStyle.FontBook.boldItalic(20))
                        .foregroundStyle(Color(red: 1, green: 235/255, blue: 235/255))
                }.frame(height: 53)
                    .onTapGesture {
                        breakStepDeleteAccountIsPresented = false
                        breakStepDeleteAccountOnConfirm()
                    }
                .padding(.top, 23)
                .padding(.horizontal, 16)

                Button("Cancel") {
                    breakStepDeleteAccountIsPresented = false
                }
                .buttonStyle(.plain)
                .font(ZiveStyle.FontBook.regular(17))
                .foregroundStyle(ZiveStyle.ColorPalette.textPrimary.opacity(0.52))
                .padding(.top, 18)
                .padding(.bottom, 23)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
            .padding(.horizontal, 23)
        }
        .transition(.opacity)
    }
}
