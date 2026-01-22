import SwiftUI

extension View {
    func appGradientBackground() -> some View {
        self.background(
            LinearGradient(
                colors: [
                    Color(red: 247/255, green: 247/255, blue: 247/255),
                    Color(red: 229/255, green: 229/255, blue: 229/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    
    func appText(family: AppFontFamily = .dmSans,
                 size: CGFloat = 17,
                 weight: Font.Weight = .regular,
                 textColor: Color = .textPrimary) -> some View {
        self
            .font(.appFont(family: family, size: size, weight: weight))
            .foregroundColor(textColor)
    }
}
