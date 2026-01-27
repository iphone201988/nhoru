import SwiftUI

struct TypingTextSequence: View {
    let introLines: [String]
    let speed: Double
    var pauseBetweenLines: Double = 2.0
    var onSequenceComplete: (() -> Void)? = nil
    
    @State private var visibleLines: [String] = []
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            ForEach(visibleLines.indices, id: \.self) { index in
                TypingText(
                    fullText: visibleLines[index],
                    speed: speed,
                    startImmediately: index == visibleLines.count - 1,
                    pauseBeforeStart: index == 0 ? 0 : pauseBetweenLines,
                    onComplete: {
                        if currentIndex < introLines.count - 1 {
                            currentIndex += 1
                            visibleLines.append(introLines[currentIndex])
                        } else {
                            onSequenceComplete?()
                        }
                    }
                )
            }
        }
        .onAppear {
            if !introLines.isEmpty {
                visibleLines = [introLines[0]]
            }
        }
    }
}

struct TypingText: View {
    let fullText: String
    let speed: Double
    var startImmediately: Bool = false
    var pauseBeforeStart: Double = 0
    var onComplete: (() -> Void)? = nil
    
    @State private var displayedText = ""
    @State private var index = 0
    @State private var hasStarted = false
    
    var body: some View {
        Text(displayedText)
            .appText(size: 17, textColor: .color4A4740)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                if startImmediately && !hasStarted {
                    hasStarted = true
                    startTyping()
                }
            }
            .onChange(of: startImmediately) { newValue, oldValue in
                if newValue && !hasStarted {
                    hasStarted = true
                    startTyping()
                }
            }
    }
    
    private func startTyping() {
        if pauseBeforeStart > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + pauseBeforeStart) {
                typeNextCharacter()
            }
        } else {
            typeNextCharacter()
        }
    }
    
    private func typeNextCharacter() {
        guard index < fullText.count
        else {
            onComplete?()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + speed) {
            let char = fullText[fullText.index(fullText.startIndex, offsetBy: index)]
            displayedText.append(char)
            index += 1
            typeNextCharacter()
        }
    }
}
