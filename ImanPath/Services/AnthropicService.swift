//
//  AnthropicService.swift
//  ImanPath
//
//  Coach API client via Supabase Edge Function
//

import Foundation

// MARK: - Response Types

struct CoachResponse: Codable {
    let reply: String
    let citations: [String]
    let suggestedAction: String?

    init(reply: String, citations: [String] = [], suggestedAction: String? = nil) {
        self.reply = reply
        self.citations = citations
        self.suggestedAction = suggestedAction
    }
}

struct EdgeFunctionMessage: Codable {
    let role: String
    let content: String
}

// MARK: - Errors

enum CoachError: LocalizedError {
    case missingConfig
    case networkError(Error)
    case invalidResponse
    case rateLimited
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingConfig:
            return "Supabase configuration not found"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimited:
            return "Rate limit exceeded. Please try again later."
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}

// MARK: - Service

class AnthropicService {
    // Supabase Edge Function URL
    private let edgeFunctionURL = URL(string: "https://vhrrlsadqppjnoxtkccn.supabase.co/functions/v1/coach")!

    // Supabase anon key - public by design (RLS protects data, not this key)
    // Same pattern as Firebase public API keys
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZocnJsc2FkcXBwam5veHRrY2NuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxNDU3ODUsImV4cCI6MjA4MzcyMTc4NX0.-il0QDBmYSrW-ruVHNue9zDEA9B1kOv6W0pSgRggfD0"

    // MARK: - Public API (Streaming)

    /// Send a message and stream the response chunk by chunk
    func sendMessageStreaming(
        userMessage: String,
        conversationHistory: [ChatMessage],
        dataPack: String,
        onChunk: @escaping (String) -> Void
    ) async throws {
        // Build messages array for conversation history
        var messages: [[String: String]] = []

        let recentHistory = conversationHistory.suffix(10)
        for msg in recentHistory {
            messages.append([
                "role": msg.sender == .user ? "user" : "assistant",
                "content": msg.content
            ])
        }

        // Build request body with streaming enabled
        let requestBody: [String: Any] = [
            "userMessage": userMessage,
            "messages": messages,
            "dataPack": dataPack,
            "stream": true
        ]

        // Create request
        var request = URLRequest(url: edgeFunctionURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Make streaming request
        let (bytes, response) = try await URLSession.shared.bytes(for: request)

        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CoachError.invalidResponse
        }

        if httpResponse.statusCode == 429 {
            throw CoachError.rateLimited
        }

        guard httpResponse.statusCode == 200 else {
            throw CoachError.apiError("Status \(httpResponse.statusCode)")
        }

        // Parse SSE stream
        for try await line in bytes.lines {
            // SSE format: "data: {...}"
            guard line.hasPrefix("data: ") else { continue }

            let jsonString = String(line.dropFirst(6))

            // Skip [DONE] or empty
            guard jsonString != "[DONE]", !jsonString.isEmpty else { continue }

            // Parse JSON
            guard let data = jsonString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                continue
            }

            // Extract text delta from content_block_delta event
            if let type = json["type"] as? String,
               type == "content_block_delta",
               let delta = json["delta"] as? [String: Any],
               let text = delta["text"] as? String {
                onChunk(text)
            }
        }
    }

    // MARK: - Public API (Non-Streaming - Legacy)

    /// Send a message to Coach via Supabase Edge Function (non-streaming)
    func sendMessage(
        userMessage: String,
        conversationHistory: [ChatMessage],
        dataPack: String
    ) async throws -> CoachResponse {
        // Build messages array for conversation history
        var messages: [[String: String]] = []

        let recentHistory = conversationHistory.suffix(10)
        for msg in recentHistory {
            messages.append([
                "role": msg.sender == .user ? "user" : "assistant",
                "content": msg.content
            ])
        }

        // Build request body
        let requestBody: [String: Any] = [
            "userMessage": userMessage,
            "messages": messages,
            "dataPack": dataPack
        ]

        // Create request
        var request = URLRequest(url: edgeFunctionURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Send request
        let (data, response) = try await URLSession.shared.data(for: request)

        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CoachError.invalidResponse
        }

        if httpResponse.statusCode == 429 {
            throw CoachError.rateLimited
        }

        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorJson["message"] as? String {
                throw CoachError.apiError(errorMessage)
            }
            throw CoachError.apiError("Status \(httpResponse.statusCode)")
        }

        // Parse response
        do {
            // Try full CoachResponse first (legacy)
            if let response = try? JSONDecoder().decode(CoachResponse.self, from: data) {
                return response
            }
            // Try simple reply format
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let reply = json["reply"] as? String {
                return CoachResponse(reply: reply)
            }
            throw CoachError.invalidResponse
        } catch {
            throw CoachError.invalidResponse
        }
    }
}

// MARK: - Preview/Testing Support

#if DEBUG
extension AnthropicService {
    /// Create a mock response for previews and testing
    static func mockResponse(
        reply: String = "I understand you're struggling. Your recent check-in shows your mood has been low. Remember, you've made it through tough moments before. Try the breathing exercise now - it helped you on Jan 8.",
        citations: [String] = [],
        suggestedAction: String? = "breathing"
    ) -> CoachResponse {
        CoachResponse(
            reply: reply,
            citations: citations,
            suggestedAction: suggestedAction
        )
    }
}
#endif
