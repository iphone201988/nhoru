import SwiftUI

struct ToastView: View {
    
    var type: ToastViewStyle
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)
    
    @State private var isHideToast: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: type.iconFileName)
                    .foregroundColor(type.themeColor)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .appText(size: 14, weight: .semibold)
                    
                    Text(message)
                        .appText(size: 12, weight: .medium)
                }
                
                Spacer(minLength: 10)
                
                Button {
                    onCancelTapped()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.textPrimary)
                }
            }
            .padding()
        }
        .background(
            Color.black
                .overlay(
                    LinearGradient(
                        colors: [
                            Color(red: 247/255, green: 247/255, blue: 247/255),
                            Color(red: 229/255, green: 229/255, blue: 229/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            Rectangle()
                .fill(type.themeColor)
                .frame(width: 6)
                .clipped()
            , alignment: .leading
        )
        .frame(minWidth: 0, maxWidth: .infinity)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
        .onAppear {
            isHideToast = false
        }
        .isHidden(isHideToast, remove: isHideToast)
    }
}
