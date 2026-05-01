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

    // ✅ LIVE BACKEND
    private let endpoint = "https://livenow-backend.onrender.com/analyze"

    func analyzeThought(thought: String) async throws -> AIResponse {
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("livenow_app_secret_2026_private", forHTTPHeaderField: "x-app-secret")
        
        let body = ["thought": thought]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            // 🔍 Debug (zelo uporabno)
            print("Status:", http.statusCode)

            guard 200..<300 ~= http.statusCode else {
                let errorString = String(data: data, encoding: .utf8)
                print("Server error:", errorString ?? "")
                throw URLError(.badServerResponse)
            }

            let decoded = try JSONDecoder().decode(AIResponse.self, from: data)
            return decoded

        } catch {
            print("Network error:", error.localizedDescription)
            throw error
        }
    }
}
