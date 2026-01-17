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

    // Supabase anon key - safe to include in app (RLS protects data)
    private var supabaseAnonKey: String? {
        loadSupabaseConfig()
    }

    private func loadSupabaseConfig() -> String? {
        // Load from Secrets.xcconfig
        let possiblePaths = [
            Bundle.main.bundlePath + "/../../Secrets.xcconfig",
            Bundle.main.resourcePath.map { $0 + "/Secrets.xcconfig" },
            "/Users/zak/Code/real-projects/ImanPath/Secrets.xcconfig"
        ].compactMap { $0 }

        for path in possiblePaths {
            if let contents = try? String(contentsOfFile: path, encoding: .utf8) {
                for line in contents.components(separatedBy: .newlines) {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasPrefix("SUPABASE_ANON_KEY") {
                        let parts = trimmed.components(separatedBy: "=")
                        if parts.count >= 2 {
                            return parts.dropFirst().joined(separator: "=").trimmingCharacters(in: .whitespaces)
                        }
                    }
                }
            }
        }
        return nil
    }

    // MARK: - Public API

    /// Send a message to Coach via Supabase Edge Function
    func sendMessage(
        userMessage: String,
        conversationHistory: [ChatMessage],
        dataPack: String
    ) async throws -> CoachResponse {
        guard let anonKey = supabaseAnonKey, !anonKey.isEmpty else {
            throw CoachError.missingConfig
        }

        // Build messages array for conversation history
        var messages: [[String: String]] = []

        let recentHistory = conversationHistory.suffix(10)
        for msg in recentHistory {
            messages.append([
                "role": msg.sender == .user ? "user" : "assistant",
                "content": msg.sender == .assistant ? wrapInJSON(msg) : msg.content
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
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
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
            if let errorBody = String(data: data, encoding: .utf8) {
                // Try to parse error message from response
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorJson["message"] as? String {
                    throw CoachError.apiError(errorMessage)
                }
                throw CoachError.apiError("Status \(httpResponse.statusCode): \(errorBody)")
            }
            throw CoachError.apiError("Status \(httpResponse.statusCode)")
        }

        // Parse response - Edge Function returns CoachResponse directly
        do {
            let response = try JSONDecoder().decode(CoachResponse.self, from: data)
            return response
        } catch {
            if let responseText = String(data: data, encoding: .utf8) {
                #if DEBUG
                print("⚠️ Failed to parse response: \(responseText)")
                #endif
            }
            throw CoachError.invalidResponse
        }
    }

    // MARK: - Private Helpers

    /// Wrap a previous assistant message in JSON format for context
    private func wrapInJSON(_ message: ChatMessage) -> String {
        let response = CoachResponse(
            reply: message.content,
            citations: message.citations,
            suggestedAction: message.suggestedAction
        )
        if let data = try? JSONEncoder().encode(response),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return """
        {"reply": "\(message.content.replacingOccurrences(of: "\"", with: "\\\""))", "citations": [], "suggestedAction": null}
        """
    }
}

// MARK: - Preview/Testing Support

#if DEBUG
extension AnthropicService {
    /// Create a mock response for previews and testing
    static func mockResponse(
        reply: String = "I understand you're struggling. Your recent check-in shows your mood has been low. Remember, you've made it through tough moments before. Try the breathing exercise now - it helped you on Jan 8.",
        citations: [String] = ["checkin:2026-01-10", "journal:abc12345"],
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
