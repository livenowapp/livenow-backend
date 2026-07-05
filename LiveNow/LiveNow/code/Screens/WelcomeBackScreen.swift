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

                Text(message)
                    .font(.system(size: subtitleSize))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)

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

    private var message: String {

        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {

        case 5..<12:
            return "Let's start today with a calmer mind."

        case 12..<18:
            return "One small reset can change your day."

        default:
            return "Let's slow your mind down."
        }
    }
}
