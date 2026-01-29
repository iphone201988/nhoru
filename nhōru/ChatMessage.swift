import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct Message: Codable {
    let id: String?
    let text: String?
    let isUser: Bool?
}

struct OpenAIResponse: Codable {
    let choices: [Message]?
}
