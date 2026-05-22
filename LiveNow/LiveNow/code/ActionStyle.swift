//
//  ActionStyle.swift
//  LiveNow
//
//  Created by Maja on 9. 5. 2026.
//

import SwiftUI

struct ActionStyle {

    private static let colorMap: [String: Color] = [
        "action_breath": .yellow.opacity(0.33),
        "action_walk": .orange.opacity(0.22),
        "action_chat": .teal.opacity(0.22),
        "action_pencil": .indigo.opacity(0.33),
        "action_leaf": .blue.opacity(0.11),
        "action_music": .purple.opacity(0.22),
        "action_sleep": .pink.opacity(0.16),
        "action_sunlight": .blue.opacity(0.22),
        "action_handraised": .red.opacity(0.33),
        "action_meditation": .purple.opacity(0.11),
        "action_nophone": .gray.opacity(0.33),
        "action_book": .cyan.opacity(0.16),
        "action_coldshower": .mint.opacity(0.22)
    ]

    static func iconName(_ icon: String?) -> String {
        icon ?? "sparkles"
    }

    static func color(_ icon: String?) -> Color {
        colorMap[icon ?? ""] ?? .gray.opacity(0.18)
    }
}

struct MomentIconImage: View {

    let icon: String
    let size: CGFloat

    var body: some View {

        if icon == "sparkles" {

            Image(systemName: "sparkles")
                .font(.system(size: size * 0.42))
                .foregroundColor(.orange)

        } else {

            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
}
