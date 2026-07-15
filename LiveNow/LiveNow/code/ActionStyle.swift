//
//  ActionStyle.swift
//  LiveNow
//
//  Created by Maja on 9. 5. 2026.
//

import SwiftUI

// MARK: - ACTION ICON STYLE

enum ActionIconStyle {
    static let size: CGFloat = 72
    static let previewSize: CGFloat = 48
    static let detailSize: CGFloat = 92
    static let imageScale: CGFloat = 0.82
}

// MARK: - ACTION STYLE

struct ActionStyle {

    private static let colorMap: [String: Color] = [
        "action_breath": .yellow.opacity(0.33),
        "action_walk": .orange.opacity(0.22),
        "action_chat": .indigo.opacity(0.22),
        "action_pencil": .teal.opacity(0.22),
        "action_leaf": .blue.opacity(0.11),
        "action_music": .cyan.opacity(0.22),
        "action_sleep": .pink.opacity(0.16),
        "action_sunlight": .blue.opacity(0.22),
        "action_handraised": .red.opacity(0.33),
        "action_meditation": .purple.opacity(0.11),
        "action_nophone": .gray.opacity(0.33),
        "action_book": .purple.opacity(0.16),
    ]

    static func iconName(_ icon: String?) -> String {
        icon ?? "sparkles"
    }

    static func color(_ icon: String?) -> Color {
        colorMap[icon ?? ""] ?? .gray.opacity(0.18)
    }
}

// MARK: - MOMENT ICON IMAGE

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
