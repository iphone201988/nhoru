import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

@main
struct nho_ruApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var auth = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if auth.isLogged {
                NavigationStack {
                    ChatView()
                }
                .environmentObject(auth)
            } else {
                NavigationStack {
                    OnboardingView()
                }
                .environmentObject(auth)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
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
