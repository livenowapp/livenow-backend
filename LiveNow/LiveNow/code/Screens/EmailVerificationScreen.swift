//
//  EmailVerificationScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 23. 7. 2026.
//

import SwiftUI

struct EmailVerificationScreen: View {

    @ObservedObject var authVM: AuthViewModel
    let orange: Color

    var body: some View {
        GeometryReader { geo in

            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let widthScale = min(max(screenWidth / 393, 0.88), 1.16)
            let heightScale = min(max(screenHeight / 852, 0.88), 1.12)
            let scale = min(widthScale, heightScale)

            let horizontalPadding = min(screenWidth * 0.07, 30)
            let topPadding = min(screenHeight * 0.04, 34)

            let iconSize = min(screenWidth * 0.24, 94 * scale)
            let iconImageSize = iconSize * 0.42

            let titleSize = min(max(screenWidth * 0.072, 26), 34)
            let bodySize = min(max(screenWidth * 0.043, 15), 17)
            let messageSize = min(max(screenWidth * 0.037, 13), 15)

            ZStack {
                Color(
                    red: 0.97,
                    green: 0.96,
                    blue: 0.94
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {

                    Spacer()
                        .frame(height: topPadding)

                    ZStack {
                        Circle()
                            .fill(orange.opacity(0.14))
                            .frame(width: iconSize, height: iconSize)

                        Image(systemName: "envelope.badge")
                            .font(.system(size: iconImageSize, weight: .semibold))
                            .foregroundColor(orange)
                    }

                    Spacer()
                        .frame(height: screenHeight * 0.04)

                    VStack(spacing: 12) {

                        Text("Verify your email")
                            .font(.system(size: titleSize, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)

                        Text("We sent a verification link to your email address. Open your inbox, tap the link, then come back here.")
                            .font(.system(size: bodySize))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, horizontalPadding)

                    Spacer()
                        .frame(height: screenHeight * 0.035)

                    if let verificationMessage = authVM.verificationMessage {

                        Text(verificationMessage)
                            .font(.system(size: messageSize, weight: .medium))
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.bottom, 8)
                    }

                    if let errorMessage = authVM.errorMessage {

                        Text(errorMessage)
                            .font(.system(size: messageSize, weight: .medium))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.bottom, 8)
                    }

                    Spacer()

                    VStack(spacing: 14) {

                        Button {
                            authVM.checkEmailVerification()
                        } label: {

                            ZStack {

                                RoundedRectangle(cornerRadius: 18)
                                    .fill(orange)
                                    .frame(height: 56)

                                if authVM.isLoading {

                                    ProgressView()
                                        .tint(.white)

                                } else {

                                    Text("I've verified my email")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(authVM.isLoading)

                        Button {
                            authVM.resendVerificationEmail()
                        } label: {

                            Text("Resend verification email")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(orange)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                        .disabled(authVM.isLoading)

                        Button {
                            authVM.logout()
                        } label: {

                            Text("Use a different email")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)

                    Spacer()
                        .frame(height: max(screenHeight * 0.05, 24))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
