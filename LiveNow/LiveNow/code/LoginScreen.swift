//
//  LoginScreen.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI

struct LoginScreen: View {
    @ObservedObject var authVM: AuthViewModel
    let orange: Color

    @ScaledMetric private var logoSize: CGFloat = 36
    @ScaledMetric private var subtitleSize: CGFloat = 15
    @ScaledMetric private var fieldTextSize: CGFloat = 16
    @ScaledMetric private var buttonTextSize: CGFloat = 17

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.065, 28)
            let topSpacing = min(geo.size.height * 0.08, 70)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer().frame(height: topSpacing)

                    Text("LiveNow")
                        .font(.system(size: logoSize, weight: .bold))
                        .foregroundColor(.black)
                        .minimumScaleFactor(0.85)

                    Text("Sign in to save your progress.")
                        .font(.system(size: subtitleSize))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 12) {
                        TextField("email", text: $authVM.email)
                            .font(.system(size: fieldTextSize))
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.75))
                            .cornerRadius(14)

                        SecureField("password", text: $authVM.password)
                            .font(.system(size: fieldTextSize))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.75))
                            .cornerRadius(14)
                    }
                    .padding(.top, 18)

                    if let error = authVM.errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button(action: {
                        authVM.login()
                    }) {
                        Text("log in")
                            .font(.system(size: buttonTextSize, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(orange)
                            .cornerRadius(16)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        authVM.signUp()
                    }) {
                        Text("create account")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(orange)
                    }
                    .buttonStyle(.plain)

                    Spacer().frame(height: 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, horizontalPadding)
                .frame(minHeight: geo.size.height)
            }
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
    }
}
