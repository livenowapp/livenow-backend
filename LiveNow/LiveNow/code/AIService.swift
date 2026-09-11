//
//  AIService.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
//

import Foundation
import FirebaseAuth

private struct BackendErrorResponse: Decodable {
    let error: BackendErrorBody
}

private struct BackendErrorBody: Decodable {
    let code: String?
    let message: String
    let requestId: String?
}

// MARK: - API

final class AIService {
    static let shared = AIService()

    private let endpoint = "https://livenow-backend.onrender.com/analyze"

    private init() {}

    func analyzeThought(thought: String) async throws -> AIResponse {
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }

        guard let currentUser = Auth.auth().currentUser else {
            throw AIServiceError.userNotSignedIn
        }

        let idToken = try await currentUser.getIDToken()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "Bearer \(idToken)",
            forHTTPHeaderField: "Authorization"
        )

        let body = [
            "thought": thought
        ]

        request.httpBody = try JSONSerialization.data(
            withJSONObject: body
        )

        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                let backendError =
                    try? JSONDecoder().decode(
                        BackendErrorResponse.self,
                        from: data
                    )

                let message =
                    backendError?.error.message
                    ?? "Something went wrong. Please try again."

                #if DEBUG
                print("AI BACKEND STATUS:", httpResponse.statusCode)
                print("AI BACKEND MESSAGE:", message)
                #endif

                switch httpResponse.statusCode {
                case 401:
                    throw AIServiceError.unauthorized

                case 429:
                    throw AIServiceError.rateLimited

                default:
                    throw AIServiceError.serverError(
                        message: message
                    )
                }
            }

            return try JSONDecoder().decode(
                AIResponse.self,
                from: data
            )

        } catch {
            throw error
        }
    }
}

// MARK: - ERRORS

enum AIServiceError: LocalizedError {
    case userNotSignedIn
    case unauthorized
    case rateLimited
    case serverError(message: String)

    var errorDescription: String? {
        switch self {
        case .userNotSignedIn:
            return "You need to sign in before using LiveNow AI."

        case .unauthorized:
            return "Your session has expired. Please sign in again."

        case .rateLimited:
            return "You’ve made too many requests. Please try again shortly."

        case let .serverError(message):
            return message
        }
    }
}
