import SwiftUI
import Firebase

struct PaywallView: View {
    
    @Binding var navigateToPaywallView: Bool
    @State var toast: Toast? = nil
    @State private var productId = Products.premiumPlan
    @EnvironmentObject var iap: IAPHandler
    @Binding var isBack: Bool
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                Image("logo")
                    .resizable()
                    .frame(width: 178, height: 48)
                
                Spacer()
            }
            .padding(.top, 60)
            
            VStack(spacing: 20) {
                
                Text("Keep nhōru available")
                    .appText(size: 24, weight: .medium, textColor: Color("#4A4740"))
                
                VStack(spacing: 5) {
                    Text("Your free trial has ended.")
                        .appText(size: 17, textColor: Color("#6B675F"))
                    
                    Text("$1.99/month")
                        .appText(size: 18, textColor: Color("#6B675F"))
                    
                    Text("Cancel anytime")
                        .appText(size: 17, textColor: Color("#6B675F"))
                }
                .lineSpacing(6) // approximates line-height: 1.6
                .multilineTextAlignment(.leading)
                
                AppButton(title: "Continue with nhōru", isEnabled: true) {
                    buyPlan(by: productId)
                }
                .padding(.horizontal, 50)
                .padding(.top, 50)
                
                Button(action: {
                    // Restore purchase action
                    toast = Toast(
                        type: .success,
                        title: "Subscription Restored",
                        message: "Subscription is successfully restored."
                    )
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2.0) {
                        isBack = true
                        navigateToPaywallView = false
                    }
                }) {
                    Text("Restore purchase")
                        .appText(family: .nunito, size: 14, textColor: Color("#3D3B38"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            
            VStack {
                Spacer()
                
                Text("Subscription renews automatically at $1.99/month until you cancel.")
                    .appText(size: 13, textColor: Color("#6B675F"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4) // approximates line-height: 1.6 for size 13
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
                
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
        .onAppear(perform: {
            LogActivities.shared.log(using: .onboardingView)
        })
        .appGradientBackground()
        .toastView(toast: $toast)
    }
    
    
    fileprivate func buyPlan(by productIdentifier: String) {
        IAPHandler.shared.performActionOnPurchasedEvent() { state in
            if state == .purchased {
                isBack = true
                navigateToPaywallView = false
            } else if state == .purchasing || state == .failed {
//                toast = Toast(
//                    type: .success,
//                    title: "Upgrading to Premium",
//                    message: state.message()
//                )
                
                isBack = true
                navigateToPaywallView = false
            }
        }
        
        Task {
            guard let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController else { return }
            await iap.purchase(productID: productIdentifier, presentingIn: rootVC)
        }
    }
}
