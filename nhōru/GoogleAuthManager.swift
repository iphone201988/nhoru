import FirebaseAuth
import GoogleSignIn
import UIKit

func signInWithGoogle(rootVC: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
    
    GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
        if let error = error {
            SharedMethods.debugLog("Google Sign-In error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        guard
            let user = result?.user,
            let idToken = user.idToken?.tokenString
        else {
            completion(.failure(NSError(domain: "GoogleSignIn",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Missing Google tokens"])))
            return
        }
        
        let accessToken = user.accessToken.tokenString
        
        SharedMethods.debugLog("Google email: \(user.profile?.email ?? "")")
        SharedMethods.debugLog("Google name: \(user.profile?.name ?? "")")
        SharedMethods.debugLog("ID Token: \(idToken)")
        SharedMethods.debugLog("Access Token: \(accessToken)")
        
        FirebaseManager.shared.signInWithGoogle(idToken: idToken, accessToken: accessToken) { result in
            switch result {
            case .success(let firebaseUser):
                SharedMethods.debugLog("Firebase Google Sign-In Success: \(firebaseUser.uid)")
                completion(.success(firebaseUser))
            case .failure(let firebaseError):
                SharedMethods.debugLog("Firebase Google Sign-In error: \(firebaseError.localizedDescription)")
                completion(.failure(firebaseError))
            }
        }
    }
}
