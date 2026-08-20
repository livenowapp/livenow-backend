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

    var body: some View {
        SecureField(title, text: $text)
            .textContentType(contentType)
            .font(.system(size: fontSize))
            .foregroundColor(.black.opacity(0.82))
            .tint(orange)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
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
