//import AuthenticationServices
//
//final class AppleAuthManager: NSObject {
//    
//    var onCompletion: ((Result<ASAuthorizationAppleIDCredential, Error>) -> Void)?
//    
//    func signIn() {
//        let provider = ASAuthorizationAppleIDProvider()
//        let request = provider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        
//        let controller = ASAuthorizationController(authorizationRequests: [request])
//        controller.delegate = self
//        controller.presentationContextProvider = self
//        controller.performRequests()
//    }
//}
//
//extension AppleAuthManager: ASAuthorizationControllerDelegate {
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            onCompletion?(.success(credential))
//        }
//    }
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        onCompletion?(.failure(error))
//    }
//}
//
//extension AppleAuthManager: ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        UIApplication.shared.connectedScenes
//            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
//            .first ?? UIWindow()
//    }
//}

import AuthenticationServices
import CryptoKit

final class AppleAuthManager: NSObject {
    
    // Completion now returns idToken + rawNonce + fullName
    var onCompletion: ((Result<(idToken: String, rawNonce: String, fullName: PersonNameComponents?), Error>) -> Void)?
    
    // Store the current raw nonce
    private var currentNonce: String?
    
    func signIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        // ✅ Generate nonce for Apple and store raw
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - Nonce helpers
    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed")
                }
                return random
            }
            
            randoms.forEach {
                if remainingLength == 0 { return }
                if $0 < charset.count {
                    result.append(charset[Int($0)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleAuthManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleIDCredential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8),
              let rawNonce = currentNonce
        else {
            onCompletion?(.failure(NSError(domain: "AppleSignIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing ID token or nonce"])))
            return
        }
        
        let fullName = appleIDCredential.fullName
        
        // ✅ Return idToken + rawNonce + fullName for Firebase
        onCompletion?(.success((idToken: idTokenString, rawNonce: rawNonce, fullName: fullName)))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onCompletion?(.failure(error))
    }
}

// MARK: - Presentation
extension AppleAuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? UIWindow()
    }
}
