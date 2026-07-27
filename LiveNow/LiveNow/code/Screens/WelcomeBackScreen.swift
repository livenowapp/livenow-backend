//
//  WelcomeBackScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 28. 6. 2026.
//

import SwiftUI

struct WelcomeBackScreen: View {

    let name: String
    let orange: Color
    let lightOrange: Color

    var body: some View {
        GeometryReader { geo in

            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let widthScale = min(max(screenWidth / 393, 0.88), 1.16)
            let heightScale = min(max(screenHeight / 852, 0.88), 1.12)
            let scale = min(widthScale, heightScale)

            let logoSize = min(max(screenWidth * 0.34, 135), 180)

            let titleSize = min(max(42 * scale, 34), 52)
            let subtitleSize = min(max(18 * scale, 15), 22)

            VStack {

                Spacer()

                Image("LogoCircle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSize)

                Spacer()
                    .frame(height: min(max(screenHeight * 0.05, 36), 52))

                Text(greeting)
                    .font(.system(size: titleSize, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("One small reset can change your day.")
                    .font(.system(size: subtitleSize))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                
                /*Text(message)
                    .font(.system(size: subtitleSize))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)*/

                Spacer()
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
        .background(
            Color(red: 0.97, green: 0.96, blue: 0.94)
                .ignoresSafeArea()
        )
    }

    private var greeting: String {

        if name.isEmpty {
            return timeGreeting
        }

        return "\(timeGreeting),\n\(name)"
    }

    private var timeGreeting: String {

        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {

        case 5..<12:
            return "Good morning"

        case 12..<18:
            return "Welcome back"

        default:
            return "Good evening"
        }
    }

    
    
   /* private var message: String {

        let messages = [
            "One small reset can change your day.",
            "Take a deep breath. You're exactly where you need to be.",
            "You don't have to solve everything today.",
            "Your mind deserves a moment of peace.",
            "Let's make today a little lighter.",
            "A calmer mind starts with one small step.",
            "You are stronger than your thoughts.",
            "Progress comes from small resets.",
            "Slow down. You've got this.",
            "Today is a good day to think a little less.",
            "Choose peace over overthinking.",
            "One mindful moment is enough to begin.",
            "Welcome back to yourself.",
            "Less overthinking. More living.",
            "You don't need all the answers right now.",
            "A clear mind changes everything.",
            "Let's quiet the noise together.",
            "Your next reset is only one tap away.",
            "Every reset is a step forward.",
            "Today is another chance to live in the present."
        ]

        return messages.randomElement()!
    }*/
}
