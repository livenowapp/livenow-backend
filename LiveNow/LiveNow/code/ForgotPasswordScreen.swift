//
//  ForgotPasswordScreen.swift
//  LiveNow
//
//  Created by Maja on 20. 5. 2026.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordScreen: View {
    @ObservedObject var authVM: AuthViewModel
    let orange: Color

    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isSending = false

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.055, 24)
            let topPadding = min(geo.size.height * 0.025, 18)

            VStack(spacing: 0) {

                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(.black.opacity(0.75))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("Reset password")
                        .font(.system(size: 24, weight: .bold))

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {

                        Spacer().frame(height: 26)

                        Text("Enter your email and we’ll send you a password reset link.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)

                        VStack(alignment: .leading, spacing: 10) {

                            Text("Email")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)

                            TextField("Enter your email", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .font(.system(size: 16))
                                .padding()
                                .background(Color.white.opacity(0.75))
                                .cornerRadius(16)
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }

                        if let successMessage {
                            Text(successMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                        }

                        Button(action: {
                            sendReset()
                        }) {

                            Group {
                                if isSending {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Send reset link")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(orange)
                            .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                        .disabled(isSending)

                        Spacer().frame(height: 24)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 24)
                }
            }
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private func sendReset() {

        errorMessage = nil
        successMessage = nil
        isSending = true

        authVM.resetPassword(email: email) { error in

            isSending = false

            if let error {
                errorMessage = error
            } else {
                successMessage = "Password reset email sent."
            }
        }
    }
}
