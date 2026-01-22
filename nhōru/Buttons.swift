import SwiftUI

enum AuthProvider: CaseIterable {
    case google
    case apple
    case email
    
    var title: String {
        switch self {
        case .google: return "Continue with Google"
        case .apple:  return "Continue with Apple"
        case .email:  return "Continue with Email"
        }
    }
    
    var iconName: String {
        switch self {
        case .google: return "google"
        case .apple:  return "apple"
        case .email:  return "mail"
        }
    }
}

struct AuthButton: View {
    
    let provider: AuthProvider
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                
                Image(provider.iconName)
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text(provider.title)
                    .appText(family: .nunito, size: 18, weight: .semibold)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.white.opacity(0.6)
                .background(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color(red: 213/255, green: 208/255, blue: 197/255)
                        .opacity(0.3),
                    lineWidth: 1
                )
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }
}

struct AppButton: View {
    
    let title: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .appText(family: .nunito, size: 18, weight: .semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .opacity(isEnabled ? 1.0 : 0.4)
        }
        .disabled(!isEnabled)
        .background(
            Color.white
                .opacity(isEnabled ? 0.6 : 0.4)
                .background(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color(red: 213/255, green: 208/255, blue: 197/255)
                        .opacity(isEnabled ? 0.3 : 0.3),
                    lineWidth: 1
                )
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }
}
