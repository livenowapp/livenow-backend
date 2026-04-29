//
//  AIService.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import Foundation


// MARK: - API

final class AIService {
    static let shared = AIService()

    // Če boš kasneje testiral na pravem telefonu, localhost ne bo delal.
    // Takrat se tukaj zamenja URL z IP naslovom tvojega računalnika ali deployed backend URL.
    private let endpoint = "http://127.0.0.1:3001/analyze"

    func analyzeThought(thought: String) async throws -> AIResponse {
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["thought": thought]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(AIResponse.self, from: data)
        return decoded
    }
}
