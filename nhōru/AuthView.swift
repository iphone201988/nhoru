import SwiftUI
import AuthenticationServices
import GoogleSignIn
import FirebaseAuth

struct AuthView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State fileprivate var navigateToEmailSignInView: Bool = false
    private let appleAuthManager = AppleAuthManager()
    @EnvironmentObject var auth: AuthManager
    
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
                        googleSignIn()
                    }
                    
                    AuthButton(provider: .apple) {
                        appleSignIn()
                    }
                    
                    AuthButton(provider: .email) {
                        navigateToEmailSignInView = true
                    }
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 30)
                
                TermsPrivacyAgreeView()
            }
            
            VStack {
                Spacer()
                Text(verbatim: "support@nhoru.com")
                    .appText(family: .nunito, size: 13, weight: .medium)
                    .onTapGesture {
                        if let url = URL(string: "mailto:support@nhoru.com") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .lineSpacing(13 * 0.6)
                    .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToEmailSignInView) {
            EmailSignInView()
        }
        .onAppear(perform: {
            LogActivities.shared.log(using: .authView)
        })
        .appGradientBackground()
    }
    
    private func googleSignIn() {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController else { return }
        
        signInWithGoogle(rootVC: rootVC) { result in
            switch result {
            case .success(let user):
                SharedMethods.debugLog("Logged in Firebase user: \(user.uid)")
                auth.login(uid: user.uid, uname: user.displayName ?? "", event: .authViaGoogle)
            case .failure(let error):
                SharedMethods.debugLog("Login failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func appleSignIn() {
        appleAuthManager.onCompletion = { result in
            switch result {
            case .success(let data):
                FirebaseManager.shared.signInWithApple(
                    idToken: data.idToken,
                    rawNonce: data.rawNonce,
                    fullName: data.fullName
                ) { result in
                    switch result {
                    case .success(let user):
                        SharedMethods.debugLog("Firebase Apple Sign-In Success: \(user.uid)")
                        auth.login(uid: user.uid, uname: user.displayName ?? "", event: .authViaApple)
                    case .failure(let error):
                        SharedMethods.debugLog("Firebase Apple Sign-In Error: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                SharedMethods.debugLog("Apple Sign-In failed: \(error.localizedDescription)")
            }
        }
        
        appleAuthManager.signIn()
    }
}
