import SwiftUI

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var sequenceFinished = false
    @State private var centerOpacity: Double = 0.0
    @State private var centerScale: CGFloat = 1.0 //0.96
    @State private var topOpacity: Double = 0.1
    @State private var topScale: CGFloat = 0.96
    @State private var isAnimationEffectDone: Bool = false
    @FocusState private var inputFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @EnvironmentObject var auth: AuthManager
    @State var toast: Toast? = nil
    @State private var productId = Products.premiumPlan
    @EnvironmentObject var iap: IAPHandler
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var serviceManager: AIServiceManager
    
    private let introLines = [
        "You're here.",
        "We can slow this down.",
        "Take one slow breath in...",
        "and let it out.",
        "When you're ready...",
        "Is anything weighing on you?"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                Image("logo")
                    .resizable()
                    .frame(width: 104, height: 28)
                    .opacity(topOpacity)
                    .scaleEffect(topScale)
                //.padding(.top, 8)
                
                HStack {
                    Spacer()
                    
                    Button {
                        buyPlan(by: productId)
                    } label: {
                        Image(systemName: iap.isSubscribed ? "crown.fill" : "crown")
                            .appText(family: .system, size: 18, weight: .medium, textColor: .yellow)
                            .opacity(0.8)
                    }
                    .disabled(iap.isSubscribed)
                    
                    Button {
                        auth.logout()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .appText(family: .system, size: 18, weight: .medium)
                            .opacity(0.8)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            Spacer()
            
            Image("logo")
                .resizable()
                .frame(width: 185, height: 50)
                .padding(.horizontal)
                .opacity(centerOpacity)
                .scaleEffect(centerScale)
            
            Spacer()
            
            if isAnimationEffectDone {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {
                            
                            TypingTextSequence(introLines: introLines, speed: 0.07) {
                                sequenceFinished = true
                            }
                            
                            ForEach(messages) { message in
                                HStack {
                                    if message.isUser {
                                        Text(message.text)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(12)
                                        Spacer()
                                    } else {
                                        Text(message.text)
                                            .padding()
                                            .background(Color.gray.opacity(0.15))
                                            .cornerRadius(12)
                                        Spacer()
                                    }
                                }
                            }
                            
                            Color.clear
                                .frame(height: 1)
                                .id("BOTTOM")
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 80)
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .scrollDismissesKeyboard(.never)
                    .onChange(of: messages.count) { _, _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: inputFocused) { _, focused in
                        if focused {
                            scrollToBottom(proxy: proxy, delay: 0.3)
                        } else {
                            scrollToBottom(proxy: proxy, delay: 0.2)
                        }
                    }
                }
            }

            if sequenceFinished {
                VStack(spacing: 6) {
              
                        Text(session.helperText)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 10)
                            .isHidden(session.helperText.isEmpty, remove: session.helperText.isEmpty)
                   
                        Text(session.systemMessage)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 10)
                            .isHidden(session.systemMessage.isEmpty, remove: session.systemMessage.isEmpty)
                   
                    PutItDownInput(
                        text: $inputText,
                        keyboardHeight: $keyboardHeight,
                        maxCharacters: $session.maxCharactersPerSubmission,
                        isFocused: $inputFocused) {
                            sendMessage()
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .disabled(session.isInputDisabled)
                        .onChange(of: inputText) { oldValue, newValue in
                            session.validateCharacters(newValue.count)
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            inputFocused = false
        }
        .onAppear {
            startAnimation()
            LogActivities.shared.log(using: .chatView)
            if auth.isNewlyLogged {
                toast = Toast(
                    type: .success,
                    title: "Welcome into nhōru",
                    message: "Logged In."
                )
            }

            Task { await iap.refreshSubscriptionStatus() }
        }
        .onChange(of: serviceManager.isInternetAvailable, { oldValue, newValue in
            if newValue {
                toast = Toast(type: .success, title: "nhōru", message: "Back Online")
            } else {
                toast = Toast(type: .error, title: "nhōru", message: "No Internet")
            }
        })
        .appGradientBackground()
        .toastView(toast: $toast)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, delay: TimeInterval = 0.1) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo("BOTTOM", anchor: .bottom)
            }
        }
    }
    
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }
            withAnimation {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation {
                keyboardHeight = 0
            }
        }
    }
    
    private func sendMessage() {
        if session.canSubmit {
            addNewMessage()
        }
        session.registerSubmission()
    }
    
    private func addNewMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        messages.append(ChatMessage(text: inputText, isUser: true))
        inputText = ""
        LogActivities.shared.log(using: .sendMessage)
        AIServiceManager.shared.sendMessage(inputText) { result in
            switch result {
            case .success(let reply):
                messages.append(ChatMessage(text: reply, isUser: true))
                
            case .failure:
                // Message already handled by AppInterruptionHandler
                break
            }
        }
    }
    
    private func startAnimation() {
        
        centerOpacity = 0.0
        centerScale = 1.0//0.96
        topOpacity = 0.0
        topScale = 0.96
        
        withAnimation(.easeInOut(duration: 2.0)) {
            centerOpacity = 1.0
            centerScale = 1.0
        }
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
        //            withAnimation(.easeInOut(duration: 2.0)) {
        //                topOpacity = 0.5
        //                topScale = 1.0
        //                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        //                    isAnimationEffectDone = true
        //                }
        //            }
        //        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            
            withAnimation(.easeInOut(duration: 2.0)) {
                centerOpacity = 0.0
                centerScale = 1.0 //0.96
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.01)) {
                        topOpacity = 0.5
                        topScale = 1.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                            isAnimationEffectDone = true
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            //startAnimationLoop()
        }
    }
    
    fileprivate func buyPlan(by productIdentifier: String) {
        IAPHandler.shared.performActionOnPurchasedEvent() { state in
            if state == .purchased {
                
            } else if state == .purchasing || state == .failed {
                toast = Toast(
                    type: .success,
                    title: "Upgrading to Premium",
                    message: state.message()
                )
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
