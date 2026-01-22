import SwiftUI
import AuthenticationServices

struct AuthView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State fileprivate var navigateToEmailSignInView: Bool = false
    
    var body: some View {
        ZStack {

            VStack(spacing: 32) {
                Image("logo")
                    .resizable()
                    .frame(width: 178, height: 48)
                
                Text("A quick offload to feel lighter.")
                    .appText(textColor: .clear)
                    .multilineTextAlignment(.center)
                    .lineSpacing(17 * 0.6)
                    .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.top, 60)
            
            VStack {
                
                VStack(spacing: 16) {
                    AuthButton(provider: .google) {
                        
                    }
                    
                    AuthButton(provider: .apple) {
                        
                    }
                    
                    AuthButton(provider: .email) {
                        navigateToEmailSignInView = true
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
                
                // Terms
                Text("By continuing, you agree to our Terms and Privacy.")
                    .appText(size: 13)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack {
                Spacer()
                // Footer
                Text("Terms and Privacy  •  support@nhoru.com")
                    .appText(family: .nunito, size: 13)
                    .padding(.bottom, 20)
            }
        }
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .appText(family: .nunito, size: 15, weight: .medium)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        
        .navigationDestination(isPresented: $navigateToEmailSignInView) {
            EmailSignInView()
        }
        
        .appGradientBackground()
    }
}
