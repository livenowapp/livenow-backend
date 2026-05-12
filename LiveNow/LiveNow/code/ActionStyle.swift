//
//  ActionStyle.swift
//  LiveNow
//
//  Created by Maja on 9. 5. 2026.
//

import SwiftUI

struct ActionStyle {

    static func iconName(_ icon: String?) -> String {
        guard let icon else { return "sparkles" }
        
        let map: [String: String] = [
            
            // emoji
            "🌬": "action_breath",
            "🚶": "action_walk",
            "💬": "action_chat",
            "✍️": "action_pencil",
            "🌿": "action_leaf",
            "🎵": "action_music",
            "🛏": "action_sleep",
            "☀️": "action_sunlight",
            "✋": "action_handraised",
            "🧘": "action_meditation",

            // SF Symbols
            "wind": "action_breath",
            "figure.walk": "action_walk",
            "bubble.left.and.bubble.right": "action_chat",
            "pencil": "action_pencil",
            "leaf": "action_leaf",
            "music.note": "action_music",
            "bed.double": "action_sleep",
            "sun.max": "action_sunlight",
            "hand.raised": "action_handraised",
            "figure.mind.and.body": "action_meditation",

            // new format
            "action_breath": "action_breath",
            "action_walk": "action_walk",
            "action_chat": "action_chat",
            "action_pencil": "action_pencil",
            "action_leaf": "action_leaf",
            "action_music": "action_music",
            "action_sleep": "action_sleep",
            "action_sunlight": "action_sunlight",
            "action_handraised": "action_handraised",
            "action_meditation": "action_meditation"
        ]
        
        return map[icon] ?? "sparkles"
    }

    static func color(_ icon: String?) -> Color {
        switch iconName(icon) {

        case "action_breath":
            return .yellow.opacity(0.22)

        case "action_walk":
            return .orange.opacity(0.22)

        case "action_chat":
            return .teal.opacity(0.22)

        case "action_pencil":
            return .indigo.opacity(0.22)

        case "action_leaf":
            return .gray.opacity(0.05)

        case "action_music":
            return .purple.opacity(0.22)

        case "action_sleep":
            return .pink.opacity(0.22)

        case "action_sunlight":
            return .blue.opacity(0.22)

        case "action_handraised":
            return .red.opacity(0.22)
            
        case "action_meditation":
            return .green.opacity(0.22)
            
        case "action_nophone":
            return .gray.opacity(0.22)
            
        case "action_book":
            return .brown.opacity(0.22)
            
        default:
            return .gray.opacity(0.18)
        }
    }
}

struct MomentIconImage: View {
    
    let icon: String
    let size: CGFloat
    
    var body: some View {
        Group {
            
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
}
