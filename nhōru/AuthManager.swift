import SwiftUI
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import GoogleSignIn

final class AuthManager: ObservableObject {

    @Published var isLogged: Bool
    
    @Published var user: User? // Firebase User
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    static let shared = AuthManager()
    
    init() {
        self.isLogged = UserDefaults.standard.bool(forKey: "isLogged")
    }
    
    func login() {
        isLogged = true
        UserDefaults.standard.set(true, forKey: "isLogged")
    }
    
    func logout() {
        do {
            try FirebaseManager.shared.signOut()
            isLogged = false
            UserDefaults.standard.set(false, forKey: "isLogged")
        }
        catch(let error) {
            SharedMethods.debugLog(error.localizedDescription)
        }
    }
}
