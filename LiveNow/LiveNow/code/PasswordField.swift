//
//  PasswordField.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 18. 7. 2026.
//

import SwiftUI

struct PasswordField: View {
    let title: String
    @Binding var text: String
    let orange: Color
    let isFocused: Bool
    let fontSize: CGFloat
    let contentType: UITextContentType

    @State private var isPasswordVisible = false

    var body: some View {
        HStack(spacing: 10) {
            Group {
                if isPasswordVisible {
                    TextField(title, text: $text)
                        .textContentType(contentType)
                } else {
                    SecureField(title, text: $text)
                        .textContentType(contentType)
                }
            }
            .font(.system(size: fontSize))
            .foregroundColor(.black.opacity(0.82))
            .tint(orange)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(
                    systemName: isPasswordVisible
                        ? "eye.slash"
                        : "eye"
                )
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray.opacity(0.75))
                .frame(width: 32, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                isPasswordVisible
                    ? "Hide password"
                    : "Show password"
            )
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(
            AuthTextFieldBackground(
                isFocused: isFocused,
                orange: orange
            )
        )
    }
}
