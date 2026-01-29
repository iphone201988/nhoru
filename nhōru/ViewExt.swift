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
    
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func toastView(toast: Binding<Toast?>) -> some View {
        self.modifier(ToastViewModifier(toast: toast))
    }
}
