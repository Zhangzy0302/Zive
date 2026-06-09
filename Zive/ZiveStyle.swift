import SwiftUI
import UIKit

enum ZiveStyle {
    enum ColorPalette {
        static let background = Color(red: 14 / 255, green: 15 / 255, blue: 20 / 255)
        static let brandOrange = Color(red: 239 / 255, green: 153 / 255, blue: 72 / 255)
        static let brandPink = Color(red: 246 / 255, green: 79 / 255, blue: 142 / 255)
        static let inputPlaceholder = Color(red: 14 / 255, green: 15 / 255, blue: 20 / 255).opacity(0.3)
        static let inputBackground = Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255)
        static let inputDarkPlaceholder = Color.white.opacity(0.3)
        static let inputDarkBackground = Color.white.opacity(0.15)

        static let textPrimary = Color(red: 14 / 255, green: 15 / 255, blue: 20 / 255)
        static let textSecondary = Color(red: 14 / 255, green: 15 / 255, blue: 20 / 255).opacity(0.65)
        static let textPink = Color(red: 1, green: 235/255, blue: 235/255)
        static let white = Color.white
        static let clear = Color.clear
    }

    enum FontBook {
        private static let regularName = "Roboto-Regular"
        private static let italicName = "Roboto-Italic"
        private static let boldName = "Roboto-Bold"
        private static let boldItalicName = "Roboto-BoldItalic"

        static func regular(_ size: CGFloat) -> Font {
            .custom(regularName, size: size)
        }

        static func italic(_ size: CGFloat) -> Font {
            .custom(italicName, size: size)
        }

        static func bold(_ size: CGFloat) -> Font {
            .custom(boldName, size: size)
        }

        static func boldItalic(_ size: CGFloat) -> Font {
            .custom(boldItalicName, size: size)
        }

        static func printAllFonts() {
            for family in UIFont.familyNames.sorted() {
                print("Font Family: \(family)")

                for fontName in UIFont.fontNames(forFamilyName: family).sorted() {
                    print("  - \(fontName)")
                }
            }
        }

        static func printFontDiagnostics() {
            let fontFiles = [
                "Roboto-Regular.ttf",
                "Roboto-Italic.ttf",
                "Roboto-Bold.ttf",
                "Roboto-BoldItalic.ttf"
            ]

            print("========== Font Diagnostics ==========")

            if let appFonts = Bundle.main.object(forInfoDictionaryKey: "UIAppFonts") as? [String] {
                print("UIAppFonts in bundle plist:")
                appFonts.forEach { print("  - \($0)") }
            } else {
                print("UIAppFonts missing from bundle plist")
            }

            print("Bundle font file lookup:")
            for file in fontFiles {
                let fileName = (file as NSString).deletingPathExtension
                let fileExtension = (file as NSString).pathExtension
                let existsAtRoot = Bundle.main.url(forResource: fileName, withExtension: fileExtension) != nil
                let existsInFolder = Bundle.main.url(forResource: fileName, withExtension: fileExtension, subdirectory: "ZiveFonts") != nil
                print("  - \(file) | root: \(existsAtRoot) | ZiveFonts/: \(existsInFolder)")
            }
        }
    }
}

enum ZiveInputVariant {
    case light
    case translucent

    var backgroundColor: Color {
        switch self {
        case .light:
            return ZiveStyle.ColorPalette.inputBackground
        case .translucent:
            return ZiveStyle.ColorPalette.inputDarkBackground
        }
    }

    var placeholderColor: Color {
        switch self {
        case .light:
            return ZiveStyle.ColorPalette.inputPlaceholder
        case .translucent:
            return ZiveStyle.ColorPalette.inputDarkPlaceholder
        }
    }

    var cursorColor: Color {
        switch self {
        case .light:
            return ZiveStyle.ColorPalette.textPrimary
        case .translucent:
            return ZiveStyle.ColorPalette.white
        }
    }

    var textColor: Color {
        switch self {
        case .light:
            return ZiveStyle.ColorPalette.textPrimary
        case .translucent:
            return ZiveStyle.ColorPalette.white
        }
    }
}

struct ZiveInputFieldStyle: TextFieldStyle {
    var isFocused: Bool = false
    var variant: ZiveInputVariant = .light

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(ZiveStyle.FontBook.regular(16))
            .foregroundStyle(variant.textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(variant.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isFocused ? ZiveStyle.ColorPalette.brandOrange : ZiveStyle.ColorPalette.clear,
                        lineWidth: 1.5
                    )
            }
    }
}

struct ZiveTextField<Field: Hashable>: View {
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool = false
    var variant: ZiveInputVariant = .light
    var focusState: FocusState<Field?>.Binding? = nil
    var focusEquals: Field? = nil

    var body: some View {
        ziveTextFieldContent
            .textFieldStyle(
                ZiveInputFieldStyle(
                    isFocused: isFocused,
                    variant: variant
                )
            )
            .overlay(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(ZiveStyle.FontBook.regular(16))
                        .foregroundStyle(variant.placeholderColor)
                        .padding(.horizontal, 16)
                        .allowsHitTesting(false)
                }
            }
    }

    @ViewBuilder
    private var ziveTextFieldContent: some View {
        if let focusState, let focusEquals {
            TextField("", text: $text)
                .font(ZiveStyle.FontBook.regular(16))
                .foregroundStyle(variant.textColor)
                .tint(variant.cursorColor)
                .focused(focusState, equals: focusEquals)
                .textInputAutocapitalization(.never)
        } else {
            TextField("", text: $text)
                .font(ZiveStyle.FontBook.regular(16))
                .foregroundStyle(variant.textColor)
                .tint(variant.cursorColor)
                .textInputAutocapitalization(.never)
        }
    }
}

struct ZiveSecureField<Field: Hashable>: View {
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool = false
    var variant: ZiveInputVariant = .light
    var focusState: FocusState<Field?>.Binding? = nil
    var focusEquals: Field? = nil

    var body: some View {
        ziveSecureFieldContent
            .textFieldStyle(
                ZiveInputFieldStyle(
                    isFocused: isFocused,
                    variant: variant
                )
            )
            .overlay(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(ZiveStyle.FontBook.regular(16))
                        .foregroundStyle(variant.placeholderColor)
                        .padding(.horizontal, 16)
                        .allowsHitTesting(false)
                }
            }
    }

    @ViewBuilder
    private var ziveSecureFieldContent: some View {
        if let focusState, let focusEquals {
            SecureField("", text: $text)
                .font(ZiveStyle.FontBook.regular(16))
                .foregroundStyle(variant.textColor)
                .tint(variant.cursorColor)
                .focused(focusState, equals: focusEquals)
        } else {
            SecureField("", text: $text)
                .font(ZiveStyle.FontBook.regular(16))
                .foregroundStyle(variant.textColor)
                .tint(variant.cursorColor)
        }
    }
}

extension View {
    func ziveLegacyUnderline(color: Color = ZiveStyle.ColorPalette.white.opacity(0.86)) -> some View {
        overlay(alignment: .bottom) {
            Rectangle()
                .fill(color)
                .frame(height: 0.7)
                .offset(y: 1)
        }
    }

    @ViewBuilder
    func ziveHideTextEditorBackground() -> some View {
        if #available(iOS 16.0, *) {
            scrollContentBackground(.hidden)
        } else {
            onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}

extension View {
    func ziveTitleFont(_ size: CGFloat) -> some View {
        font(ZiveStyle.FontBook.bold(size))
    }

    func ziveBodyFont(_ size: CGFloat = 16) -> some View {
        font(ZiveStyle.FontBook.regular(size))
    }

    func ziveScreenBackground() -> some View {
        background(ZiveStyle.ColorPalette.background.ignoresSafeArea())
    }
}

// 桥接 UIKit 恢复手势
struct SwixoanAliwSwipeBack: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        DispatchQueue.main.async {
            if let biuqkskxAw = controller.navigationController {
                biuqkskxAw.interactivePopGestureRecognizer?.isEnabled = true
                biuqkskxAw.interactivePopGestureRecognizer?.delegate = nil
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

func delay(_ seconds: Double) async {
  try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
}
