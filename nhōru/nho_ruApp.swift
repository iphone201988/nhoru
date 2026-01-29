import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

@main
struct nho_ruApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var auth = AuthManager()
    @StateObject private var iap = IAPHandler.shared
    @StateObject private var session = SessionManager.shared
    @StateObject private var aiService = AIServiceManager.shared
    
    init() {
        FirebaseApp.configure()
        Task { await IAPHandler.shared.fetchAvailableProducts() }
    }
    
    var body: some Scene {
        WindowGroup {
            if auth.isLogged {
                NavigationStack {
                    ChatView()
                }
                .environmentObject(auth)
                .environmentObject(iap)
                .environmentObject(session)
                .environmentObject(aiService)
                .onOpenURL { url in
                    handleMagicLink(url)
                }
            } else {
                NavigationStack {
                    OnboardingView()
                }
                .environmentObject(auth)
                .environmentObject(iap)
                .environmentObject(session)
                .environmentObject(aiService)
                .onOpenURL { url in
                    handleMagicLink(url)
                }
            }
        }
    }
    
    func handleMagicLink(_ url: URL) {
        let link = url.absoluteString
        guard Auth.auth().isSignIn(withEmailLink: link) else { return }
        let email = UserDefaults.standard.value(forKey: "magicLinkEmail") as? String
        Auth.auth().signIn(withEmail: email ?? "", link: link) { result, error in
            if let error {
                SharedMethods.debugLog("Magic link sign-in failed: \(error)")
                return
            }
            guard let user = result?.user else { return }
            SharedMethods.debugLog("UID: \(user.uid)")
            SharedMethods.debugLog("Email: \(user.email ?? "")")
            SharedMethods.debugLog("Name: \(user.displayName ?? "N/A")")
            auth.login(uid: user.uid, uname: user.displayName ?? "", event: .authViaEmail)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let incomingURL = userActivity.webpageURL else { return false }
        if Auth.auth().isSignIn(withEmailLink: incomingURL.absoluteString) {
            NotificationCenter.default.post(name: .didReceiveMagicLink, object: incomingURL)
            return true
        }
        return false
    }
}
