//
//  ChangePasword.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 16. 5. 2026.
//

import SwiftUI
import FirebaseAuth

// MARK: - CHANGE PASSWORD

struct ChangePasswordScreen: View {
    @ObservedObject var authVM: AuthViewModel
    let orange: Color

    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var isVerified = false
    @State private var isVerifying = false
    @State private var isSavingPassword = false
    @State private var passwordUpdated = false

    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.055, 24)
            let topPadding = min(geo.size.height * 0.025, 18)

            VStack(spacing: 0) {
                header(horizontalPadding: horizontalPadding, topPadding: topPadding)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if passwordUpdated {
                            Text("Password updated.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                                .padding(.top, 28)
                        } else {
                            if !isVerified {
                                currentPasswordSection
                            }

                            if isVerified {
                                newPasswordSection
                            }
                        }

                        Spacer().frame(height: 24)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 28)
                }
            }
        }
        .background(
            Color(red: 0.97, green: 0.96, blue: 0.94)
                .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
    }

    private func header(horizontalPadding: CGFloat, topPadding: CGFloat) -> some View {
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

            Text("Change password")
                .font(.system(size: 24, weight: .bold))

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
    }

    private var currentPasswordSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Current password")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                SecureField("Enter current password", text: $currentPassword)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(16)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
            }

            Button(action: {
                verifyCurrentPassword()
            }) {
                buttonContent(
                    title: "Continue",
                    isLoading: isVerifying
                )
            }
            .buttonStyle(.plain)
            .disabled(isVerifying)
        }
    }

    private var newPasswordSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("New password")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                SecureField("Enter new password", text: $newPassword)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(16)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Confirm password")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                SecureField("Confirm new password", text: $confirmPassword)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(16)
            }

            Button(action: {
                updatePassword()
            }) {
                buttonContent(
                    title: "Save new password",
                    isLoading: isSavingPassword
                )
            }
            .buttonStyle(.plain)
            .disabled(isSavingPassword)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
            }
        }
    }

    private func buttonContent(title: String, isLoading: Bool) -> some View {
        Group {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(orange)
        .cornerRadius(16)
    }

    private func updatePassword() {
        errorMessage = nil
        successMessage = nil
        isSavingPassword = true

        guard !newPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a new password."
            isSavingPassword = false
            return
        }

        guard newPassword.count >= 6 else {
            errorMessage = "Password should be at least 6 characters."
            isSavingPassword = false
            return
        }

        guard newPassword != currentPassword else {
            errorMessage = "New password must be different from your current password."
            isSavingPassword = false
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
            isSavingPassword = false
            return
        }

        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
            DispatchQueue.main.async {
                self.isSavingPassword = false

                if let error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.passwordUpdated = true
                    self.successMessage = "Password updated."

                    self.newPassword = ""
                    self.confirmPassword = ""
                    self.currentPassword = ""

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func verifyCurrentPassword() {
        errorMessage = nil
        isVerifying = true

        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            errorMessage = "Unable to verify user."
            isVerifying = false
            return
        }

        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: currentPassword
        )

        user.reauthenticate(with: credential) { _, error in
            DispatchQueue.main.async {
                self.isVerifying = false

                if let error {
                    self.errorMessage = "Password is incorrect."
                } else {
                    self.isVerified = true
                    self.errorMessage = nil
                }
            }
        }
    }
}
