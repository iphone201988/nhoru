import SwiftUI

struct OnboardingView: View {
    
    @State private var navigateToAuthView = false
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 32) {
                Image("logo")
                    .resizable()
                    .frame(width: 178, height: 48)
                
                Text("A quick offload to feel lighter.")
                    .appText()
                    .multilineTextAlignment(.center)
                    .lineSpacing(17 * 0.6)
                    .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.top, 60)
            
            VStack(spacing: 25) {
                AppButton(title: "Try nhōru free", isEnabled: true) {
                    navigateToAuthView = true
                }
                .padding(.horizontal, 32)

                Text("Free for 30 days, then $1.99/month")
                    .appText(size: 15)
            }
            
            VStack {
                Spacer()

                Text("Terms and Privacy  •  support@nhoru.com")
                    .appText(family: .nunito, size: 13)
                    .padding(.bottom, 20)
            }
        }
        
        .navigationDestination(isPresented: $navigateToAuthView) {
            AuthView()
                
        }
        
        .appGradientBackground()
    }
}
