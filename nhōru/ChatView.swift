import SwiftUI

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var sequenceFinished = false
    @State private var centerOpacity: Double = 0.0
    @State private var centerScale: CGFloat = 0.96
    @State private var topOpacity: Double = 0.1
    @State private var topScale: CGFloat = 0.96
    @State private var isAnimationEffectDone: Bool = false
    
    private let introLines = [
        "You're here.",
        "We can slow this down.",
        "Take one slow breath in...",
        "and let it out.",
        "When you're ready...",
        "Is anything weighing on you?"
    ]
    
    var body: some View {
        VStack {
            
            Image("logo")
                .resizable()
                .frame(width: 104, height: 28)
                .padding(.bottom, 20)
                .opacity(topOpacity)
                .scaleEffect(topScale)
            
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
                    ScrollView {
                        VStack(spacing: 18) {
                            TypingTextSequence(
                                introLines: introLines,
                                speed: 0.05
                            ) {
                                sequenceFinished = true
                            }
                            
                            ForEach(messages) { message in
                                HStack {
                                    if message.isUser {
                                        Spacer()
                                        Text(message.text)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(12)
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
                        .padding(.horizontal, 24)
                    }
                    .onChange(of: messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo("BOTTOM", anchor: .bottom)
                        }
                    }
                }
            }
            
            if sequenceFinished {
                HStack {
                    TextField("Put it down here...", text: $inputText, axis: .vertical)
                        .appText(size: 18)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .onSubmit {
                            sendMessage()
                        }
                }
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: sequenceFinished)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            startAnimation()
        }
        
        .appGradientBackground()
    }
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        messages.append(ChatMessage(text: inputText, isUser: true))
        inputText = ""
    }
    
    private func startAnimation() {
        
        centerOpacity = 0.0
        centerScale = 0.96
        topOpacity = 0.0
        topScale = 0.96
        
        withAnimation(.easeInOut(duration: 2.0)) {
            centerOpacity = 1.0
            centerScale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeInOut(duration: 2.0)) {
                topOpacity = 1.0
                topScale = 1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isAnimationEffectDone = true
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            
            withAnimation(.easeInOut(duration: 2.0)) {
                centerOpacity = 0.0
                centerScale = 0.96
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            //startAnimationLoop()
        }
    }
}
