import Foundation
import Network
import SwiftUI

// MARK: - Errors
enum AIError: Error {
    case invalidURL
    case invalidResponse
    case emptyResponse
    case noInternet
}

@MainActor
final class AIServiceManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AIServiceManager()
    private init() {
        startNetworkMonitoring()
    }
    
    // MARK: - Network
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published private(set) var isInternetAvailable: Bool = true
    @Published private(set) var systemMessage: String? = nil
    
    // MARK: - AI Retry
    private var didRetryOnce = false
    
    // MARK: - OpenAI Config
    private let apiKey = "<OPENAI_API_KEY>"
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o-mini"
    
    let systemPrompt = """
    You are a calm, neutral, and supportive assistant. 
    - Always respond in 1–2 short sentences.
    - Never give advice or problem-solving instructions.
    - Never leave a silent response.
    - When the user ends the session, respond naturally in a context-appropriate way, not with fixed text.
    - Be consistent with the style of these intro lines:
      - "You're here."
      - "We can slow this down."
      - "Take one slow breath in..."
      - "and let it out."
      - "When you're ready..."
      - "Is anything weighing on you?"
    """
    
    // MARK: - Network Monitoring
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self else { return }
                
                if path.status == .satisfied {
                    self.isInternetAvailable = true
                    self.systemMessage = nil
                } else {
                    self.isInternetAvailable = false
                    self.systemMessage = "No internet connection"
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    // MARK: - Public Chat API
    func sendMessage(_ message: String,completion: @escaping (Result<String, Error>) -> Void) {
        
        guard isInternetAvailable else {
            completion(.failure(AIError.noInternet))
            return
        }
        
        Task {
            await handleAIFailure {
                await self.performRequest(message, completion: completion)
            }
        }
    }
    
    // MARK: - Retry Logic
    private func handleAIFailure(
        retryAction: @escaping () async -> Void
    ) async {
        
        if !didRetryOnce {
            didRetryOnce = true
            await retryAction()
        } else {
            systemMessage = "Something didn't go through. Please try again."
            didRetryOnce = false
        }
    }
    
    private func resetRetryState() {
        didRetryOnce = false
    }
    
    // MARK: - OpenAI Request
    private func performRequest(_ message: String, completion: @escaping (Result<String, Error>) -> Void) async {
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(AIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": message]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard
                let http = response as? HTTPURLResponse,
                (200...299).contains(http.statusCode)
            else {
                throw AIError.invalidResponse
            }
            
            let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let reply = decoded.choices?.first?.text else {
                throw AIError.emptyResponse
            }
            
            resetRetryState()
            completion(.success(reply))
            
        } catch(let error) {
            completion(.failure(error))
        }
    }
}
