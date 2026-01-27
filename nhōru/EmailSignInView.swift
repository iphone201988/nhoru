import SwiftUI

struct EmailSignInView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var linkSent: Bool = false
    @State private var navigateToChatView: Bool = false
    @FocusState private var isEmailFocused: Bool
    
    var isEmailValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 128)
                
                BackButton {
                    dismiss()
                }
                .padding(.bottom, 40)
                
                Text("Enter your email")
                    .appText(size: 24, weight: .medium, textColor: .color4A4740)
                    .padding(.bottom, 12)
                
                Text("We'll send you a magic link to sign in.")
                    .appText(size: 17, textColor: .color6B675F)
                    .lineSpacing(1.6 * 17)
                    .padding(.bottom, 30)
                
                ZStack(alignment: .leading) {
                    
                    if email.isEmpty {
                        Text("you@example.com")
                            .appText(family: .nunito, size: 17)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                            .tint(Color("#8F8B81"))
                    }
                    
                    TextField("", text: $email)
                        .focused($isEmailFocused)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .appText(family: .nunito, size: 17, textColor: .color4A4740)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                }
                .background(
                    Color.white
                        .opacity((!email.isEmpty) ? 0.6 : 0.4)
                        .background(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color(red: 213/255, green: 208/255, blue: 197/255)
                                .opacity(email.isEmpty ? 0.5 : 0.3),
                            lineWidth: 1
                        )
                )
                .cornerRadius(12)
                .contentShape(Rectangle())
                .animation(.easeInOut(duration: 0.15), value: email.isEmpty)
                
                Spacer().frame(height: 16)
                
                AppButton(title: linkSent ? "Resend sign-in link" : "Send sign-in link",
                          isEnabled: (!email.isEmpty && linkSent == false)) {
                    sendLink()
                }
                
                if linkSent {
                    Spacer().frame(height: 30)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                            Text("We've sent a sign-in link to \(email)")
                        }
                        .appText(size: 15, textColor: .color4A4740)
                        
                        Text("It usually arrives within a minute.")
                            .appText(size: 15, textColor: .color6B675F)
                    }
                    .foregroundColor(.textPrimary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
            .navigationDestination(isPresented: $navigateToChatView) {
                ChatView()
                    .navigationBarBackButtonHidden(true)
            }
        }
        .navigationBarBackButtonHidden(true)
        .appGradientBackground()
    }
    
    private func sendLink() {
        guard isEmailValid else { return }
        withAnimation(.easeInOut) {
            linkSent = true
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2.0) {
                UserDefaults.standard[.isLogged] = true
                navigateToChatView = true
            }
        }
    }
}
