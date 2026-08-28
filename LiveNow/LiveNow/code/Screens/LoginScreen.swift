//
//  LoginScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
//

import SwiftUI
import AuthenticationServices

// MARK: - AUTH FIELD STYLE

struct AuthTextFieldBackground: View {
    let isFocused: Bool
    let orange: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color.white.opacity(0.82))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isFocused ? orange.opacity(0.45) : Color.black.opacity(0.05),
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
    }
}

// MARK: - LOGIN

struct LoginScreen: View {
    @ObservedObject var authVM: AuthViewModel
    let orange: Color

    @ScaledMetric private var logoSize: CGFloat = 36
    @ScaledMetric private var subtitleSize: CGFloat = 15
    @ScaledMetric private var fieldTextSize: CGFloat = 16
    @ScaledMetric private var buttonTextSize: CGFloat = 17
    
    @FocusState private var focusedField: Field?
    @State private var showForgotPassword = false
    @State private var inputReady = false

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

                    Text("Start saving your moments.")
                        .font(.system(size: subtitleSize))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 12) {
                        TextField("email", text: $authVM.email)
                            .font(.system(size: fieldTextSize))
                            .foregroundColor(.black.opacity(0.82))
                            .tint(orange)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                AuthTextFieldBackground(
                                    isFocused: focusedField == .email,
                                    orange: orange
                                )
                            )

                        PasswordField(
                            title: "password",
                            text: $authVM.password,
                            orange: orange,
                            isFocused: focusedField == .password,
                            fontSize: fieldTextSize,
                            contentType: .password
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .onSubmit {
                            if canSubmit {
                                authVM.login()
                            }
                        }
                        
                        Button(action: {
                            showForgotPassword = true
                        }) {
                            Text("Forgot password?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(orange)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 6)
                    }
                    .padding(.top, 18)
                    .allowsHitTesting(inputReady)

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

                    SignInWithAppleButton(.signIn) { request in
                        let nonce = authVM.randomNonceString()
                        authVM.currentNonce = nonce

                        request.requestedScopes = [.fullName, .email]
                        request.nonce = authVM.sha256(nonce)
                        
                    } onCompletion: { result in
                        authVM.handleAppleSignIn(result: result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .cornerRadius(14)
                    .disabled(authVM.isLoading)
                    .opacity(authVM.isLoading ? 0.55 : 1)
                    
                    Spacer().frame(height: 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, horizontalPadding)
                .frame(minHeight: geo.size.height)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .background(
            Color(
                red: 0.97,
                green: 0.96,
                blue: 0.94
            )
            .ignoresSafeArea()
        )
        .onAppear {
            focusedField = nil
            inputReady = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                inputReady = true
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordScreen(
                authVM: authVM,
                orange: orange
            )
        }
    }
}

// MARK: - SIGNUP

struct SignupScreen: View {
    @ObservedObject var authVM: AuthViewModel
    let orange: Color
    
    private let privacyURL = URL(
        string: "https://www.livenowapp.net/privacy"
    )!

    private let termsURL = URL(
        string: "https://www.livenowapp.net/terms"
    )!
    
    private var termsAndPrivacyText: AttributedString {
        let markdown = """
        I confirm that I am at least 16 years old and agree to the [Terms of Use](\(termsURL.absoluteString)) and [Privacy Policy](\(privacyURL.absoluteString)).
        """

        return (try? AttributedString(markdown: markdown))
            ?? AttributedString(
                "I confirm that I am at least 16 years old and agree to the Terms of Use and Privacy Policy."
            )
    }

    @ScaledMetric private var titleSize: CGFloat = 34
    @ScaledMetric private var subtitleSize: CGFloat = 15
    @ScaledMetric private var fieldTextSize: CGFloat = 16
    @ScaledMetric private var buttonTextSize: CGFloat = 17

    @FocusState private var focusedField: Field?

    enum Field {
        case name
        case email
        case password
        case confirmPassword
    }
    
    private var canSubmit: Bool {
        !authVM.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !authVM.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !authVM.password.isEmpty &&
        !authVM.confirmPassword.isEmpty &&
        authVM.acceptedAgeAndTerms &&
        !authVM.isLoading
    }

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(max(geo.size.width * 0.065, 20), 28)
            let topSpacing = min(max(geo.size.height * 0.045, 28), 60)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer().frame(height: topSpacing)

                    Text("Create account")
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundColor(.black)

                    Text("Sign up to save your progress.")
                        .font(.system(size: subtitleSize))
                        .foregroundColor(.gray)

                    VStack(spacing: 12) {
                        TextField("name", text: $authVM.name)
                            .font(.system(size: fieldTextSize))
                            .foregroundColor(.black.opacity(0.82))
                            .tint(orange)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .email
                            }
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                AuthTextFieldBackground(
                                    isFocused: focusedField == .name,
                                    orange: orange
                                )
                            )

                        TextField("email", text: $authVM.email)
                            .font(.system(size: fieldTextSize))
                            .foregroundColor(.black.opacity(0.82))
                            .tint(orange)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                AuthTextFieldBackground(
                                    isFocused: focusedField == .email,
                                    orange: orange
                                )
                            )

                        PasswordField(
                            title: "password",
                            text: $authVM.password,
                            orange: orange,
                            isFocused: focusedField == .password,
                            fontSize: fieldTextSize,
                            contentType: .newPassword
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .confirmPassword
                        }
                        
                        PasswordField(
                            title: "confirm password",
                            text: $authVM.confirmPassword,
                            orange: orange,
                            isFocused: focusedField == .confirmPassword,
                            fontSize: fieldTextSize,
                            contentType: .newPassword
                        )
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.done)
                        .onSubmit {
                            if canSubmit {
                                authVM.signUp()
                            }
                        }
                    }
                    .padding(.top, 18)
                    
                    HStack(alignment: .top, spacing: 12) {

                        Button {
                            withAnimation(.easeInOut(duration: 0.16)) {
                                authVM.acceptedAgeAndTerms.toggle()
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        authVM.acceptedAgeAndTerms
                                            ? orange
                                            : Color.white.opacity(0.82)
                                    )
                                    .frame(width: 24, height: 24)

                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        authVM.acceptedAgeAndTerms
                                            ? orange
                                            : Color.black.opacity(0.14),
                                        lineWidth: 1
                                    )
                                    .frame(width: 24, height: 24)

                                if authVM.acceptedAgeAndTerms {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        Text(termsAndPrivacyText)
                            .font(.system(size: 13))
                            .foregroundColor(.black.opacity(0.68))
                            .tint(orange)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                    
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
                    .scaleEffect(authVM.isLoading ? 0.98 : 1)
                    .animation(.easeInOut(duration: 0.15), value: authVM.isLoading)
                    .buttonStyle(.plain)
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1 : 0.55)
                    
                    Button(action: {
                        authVM.acceptedAgeAndTerms = false
                        authVM.showSignup = false
                    }) {
                        Text("already have an account? log in")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(orange)
                    }
                    .buttonStyle(.plain)
                    
                    SignInWithAppleButton(.signUp) { request in
                        let nonce = authVM.randomNonceString()
                        authVM.currentNonce = nonce

                        request.requestedScopes = [.fullName, .email]
                        request.nonce = authVM.sha256(nonce)

                    } onCompletion: { result in
                        guard authVM.acceptedAgeAndTerms else {
                            authVM.errorMessage =
                                "Please confirm that you are at least 16 years old and agree to the Terms of Use and Privacy Policy."
                            return
                        }

                        authVM.handleAppleSignIn(result: result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .cornerRadius(14)
                    .disabled(!authVM.acceptedAgeAndTerms || authVM.isLoading)
                    .opacity(authVM.acceptedAgeAndTerms ? 1 : 0.55)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, horizontalPadding)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geo.size.height)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
    }
}
