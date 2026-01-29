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
    @Published var isNewlyLogged: Bool = false
    
    static let shared = AuthManager()
    
    init() {
        self.isLogged = UserDefaults.standard.bool(forKey: "isLogged")
    }
    
    func login(uid: String, uname: String, event: EventLogs) {
        isLogged = true
        isNewlyLogged = true
        UserDefaults.standard.set(true, forKey: "isLogged")
        UserDefaults.standard.set(uid, forKey: "uid")
        UserDefaults.standard.set(uname, forKey: "uname")
        LogActivities.shared.log(using: event)
    }
    
    func logout() {
        do {
            try FirebaseManager.shared.signOut()
            isLogged = false
            isNewlyLogged = false
            UserDefaults.standard.set(false, forKey: "isLogged")
            UserDefaults.standard.removeObject(forKey: "uid")
            UserDefaults.standard.removeObject(forKey: "uname")
            LogActivities.shared.log(using: .logout)
        }
        catch(let error) {
            SharedMethods.debugLog(error.localizedDescription)
        }
    }
}
