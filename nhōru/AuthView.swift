import SwiftUI
import AuthenticationServices
import GoogleSignIn

struct AuthView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State fileprivate var navigateToEmailSignInView: Bool = false
    @State private var navigateToChatView: Bool = false
    private let appleAuthManager = AppleAuthManager()
    
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
                        appleAuthManager.onCompletion = { result in
                            switch result {
                            case .success(let credential):
                                let userID = credential.user
                                let email = credential.email
                                let fullName = credential.fullName
                                
                                SharedMethods.debugLog("Apple User ID: \(userID)")
                                SharedMethods.debugLog("Email: \(email ?? "N/A")")
                                SharedMethods.debugLog("Name:\(fullName?.givenName ?? "")")
                                
                                UserDefaults.standard[.isLogged] = true
                                
                                navigateToChatView = true
                                
                            case .failure(let error):
                                SharedMethods.debugLog("Apple Sign-In failed: \(error.localizedDescription)")
                            }
                        }
                        
                        appleAuthManager.signIn()
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
        .navigationDestination(isPresented: $navigateToChatView) {
            ChatView()
                .navigationBarBackButtonHidden(true)
        }
        .appGradientBackground()
    }
    
    private func googleSignIn() {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                SharedMethods.debugLog("Google Sign-In error: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }
            
            let email = user.profile?.email
            let name = user.profile?.name
            let idToken = user.idToken?.tokenString
            
            SharedMethods.debugLog("Google email: \(email ?? "")")
            SharedMethods.debugLog("Name: \(name ?? "")")
            SharedMethods.debugLog("ID Token: \(idToken ?? "")")
            
            UserDefaults.standard[.isLogged] = true
            
            navigateToChatView = true
        }
    }
}

final class AppleAuthManager: NSObject {
    
    var onCompletion: ((Result<ASAuthorizationAppleIDCredential, Error>) -> Void)?
    
    func signIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension AppleAuthManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            onCompletion?(.success(credential))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onCompletion?(.failure(error))
    }
}

extension AppleAuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? UIWindow()
    }
}
