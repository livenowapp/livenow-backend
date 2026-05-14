//
//  LoginScreen.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI

// MARK: - LOGIN

struct LoginScreen: View {
    @ObservedObject var authVM: AuthViewModel
    let orange: Color

    @ScaledMetric private var logoSize: CGFloat = 36
    @ScaledMetric private var subtitleSize: CGFloat = 15
    @ScaledMetric private var fieldTextSize: CGFloat = 16
    @ScaledMetric private var buttonTextSize: CGFloat = 17
    @FocusState private var focusedField: Field?

    enum Field {
        case email
        case password
    }
    private var canSubmit: Bool {
        !authVM.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !authVM.password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !authVM.isLoading
    }

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
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.75))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        focusedField == .email
                                        ? orange.opacity(0.45)
                                        : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )
                            .cornerRadius(14)

                        SecureField("password", text: $authVM.password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.done)
                            .onSubmit {
                                authVM.login()
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.75))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        focusedField == .password
                                        ? orange.opacity(0.45)
                                        : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )
                            .cornerRadius(14)
                    }
                    .padding(.top, 18)

                    if let error = authVM.errorMessage {
                        Text(error)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(12)
                    }

                    Button(action: {
                        authVM.login()
                    }) {
                        Text(authVM.isLoading ? "loading..." : "log in")
                            .font(.system(size: buttonTextSize, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(orange)
                            .cornerRadius(16)
                    }
                    .scaleEffect(authVM.isLoading ? 0.98 : 1)
                    .animation(.easeInOut(duration: 0.15), value: authVM.isLoading)
                    .buttonStyle(.plain)
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1 : 0.55)
                    
                    Button(action: {
                        authVM.showSignup = true
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
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
    }
}

// MARK: - SIGNUP
struct SignupScreen: View {
    @ObservedObject var authVM: AuthViewModel
    let orange: Color

    @ScaledMetric private var titleSize: CGFloat = 34
    @ScaledMetric private var subtitleSize: CGFloat = 15
    @ScaledMetric private var fieldTextSize: CGFloat = 16
    @ScaledMetric private var buttonTextSize: CGFloat = 17

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.065, 28)
            let topSpacing = min(geo.size.height * 0.07, 60)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer().frame(height: topSpacing)

                    Text("Create account")
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundColor(.black)

                    Text("Start saving your moments.")
                        .font(.system(size: subtitleSize))
                        .foregroundColor(.gray)

                    VStack(spacing: 12) {
                        TextField("name", text: $authVM.name)

                        TextField("email", text: $authVM.email)

                        SecureField("password", text: $authVM.password)
                    }
                    .font(.system(size: fieldTextSize))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.top, 18)
                    
                    if let error = authVM.errorMessage {
                        Text(error)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(12)
                    }

                    Button(action: {
                        authVM.signUp()
                    }) {
                        Text(authVM.isLoading ? "creating..." : "create account")
                            .font(.system(size: buttonTextSize, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(orange)
                            .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .disabled(authVM.isLoading)

                    Button(action: {
                        authVM.showSignup = false
                    }) {
                        Text("already have an account? log in")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(orange)
                    }
                    .buttonStyle(.plain)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, horizontalPadding)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geo.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
    }
}
