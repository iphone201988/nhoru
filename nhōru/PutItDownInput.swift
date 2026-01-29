import SwiftUI

struct PutItDownInput: View {
    @Binding var text: String
    @Binding var keyboardHeight: CGFloat
    @Binding var maxCharacters: Int
    @FocusState.Binding var isFocused: Bool
    @EnvironmentObject var serviceManager: AIServiceManager
    var onSend: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            TextField("Put it down here...", text: $text, axis: .vertical)
                .appText(size: 17, textColor: .color4A4740)
                .padding(12)
                .padding(.bottom, 36)
                .frame(height: 150, alignment: .topLeading)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            (isFocused || (keyboardHeight == 0 && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                            ? Color.gray.opacity(0.6)
                            : Color.clear,
                            lineWidth: 1.5
                        )
                )
                .cornerRadius(12)
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    if newValue.count > maxCharacters {
                        text = String(newValue.prefix(maxCharacters))
                    }
                }

            Button {
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                onSend()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(10)
                    //.background(Color.black.opacity(text.isEmpty ? 0.3 : 0.8))
                    .background(
                        Color.black.opacity(
                            text.isEmpty || !AIServiceManager.shared.isInternetAvailable ? 0.3 : 0.8
                        )
                    )
                    .clipShape(Circle())
            }
            .padding(8)
            //.disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .disabled(
                text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || !serviceManager.isInternetAvailable
            )
            .isHidden(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}
