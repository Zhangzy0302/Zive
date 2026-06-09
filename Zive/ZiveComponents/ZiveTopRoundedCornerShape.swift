import SwiftUI

struct ZiveTopRoundedCornerShape: Shape {
    var ziveTopRoundedCornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let ziveTopRoundedCornerPath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(
                width: ziveTopRoundedCornerRadius,
                height: ziveTopRoundedCornerRadius
            )
        )
        return Path(ziveTopRoundedCornerPath.cgPath)
    }
}
