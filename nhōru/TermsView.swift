import SwiftUI

struct TermsPrivacyAgreeView: View {
    
    @State private var showTermsPrivacySheet = false
    
    var body: some View {
        HStack(spacing: 0) {
            Text("By continuing, you agree to our ")
                .appText(size: 13)
                .lineSpacing(1.6 * 13)
            
            Text("Terms and Privacy")
                .appText(family: .nunito, size: 13, weight: .medium)
                .onTapGesture {
                    showTermsPrivacySheet = true
                }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .padding(.top, 16)
        .sheet(isPresented: $showTermsPrivacySheet) {
            TermsPrivacySheet(
                url: URL(string: "https://nhoru.com/")!
            )
        }
    }
}

struct TermsPrivacyAndSupportEmailView: View {
    
    @State private var showTermsPrivacySheet = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 0) {
                Text("Terms and Privacy")
                    .appText(family: .nunito, size: 13, weight: .medium)
                    .onTapGesture {
                        showTermsPrivacySheet = true
                    }
                
                Text("   ·   ")
                    .appText(family: .nunito, size: 13, textColor: .color5A5654)
                
                Text(verbatim: "support@nhoru.com")
                    .appText(family: .nunito, size: 13, weight: .medium)
                    .onTapGesture {
                        if let url = URL(string: "mailto:support@nhoru.com") {
                            UIApplication.shared.open(url)
                        }
                    }
            }
            .lineSpacing(13 * 0.6)
            .padding(.bottom, 20)
            .sheet(isPresented: $showTermsPrivacySheet) {
                TermsPrivacySheet(
                    url: URL(string: "https://nhoru.com/")!
                )
            }
        }
    }
}
