import Foundation
import FirebaseAuth

final class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private init() {}
    
    func signInWithGoogle(idToken: String,
                          accessToken: String,
                          completion: @escaping (Result<User, Error>) -> Void) {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    func signInWithApple(idToken: String,
                         rawNonce: String?,
                         fullName: PersonNameComponents?,
                         completion: @escaping (Result<User, Error>) -> Void) {
        
        // Create Firebase credential for Apple
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: rawNonce,
            fullName: fullName
        )
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    func signInWithEmailLink(email: String,
                             link: String,
                             completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, link: link) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    func sendMagicLink(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://nhoru-40537.web.app")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier ?? "")
        UserDefaults.standard.set(email, forKey: "magicLinkEmail")
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
            if let error = error {
                SharedMethods.debugLog("Daily Quota: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
