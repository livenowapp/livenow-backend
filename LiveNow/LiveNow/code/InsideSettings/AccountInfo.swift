//
//  AccountScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 16. 5. 2026.
//

import SwiftUI
import FirebaseAuth

// MARK: - ACCOUNT SCREEN

struct AccountInfoScreen: View {
    @ObservedObject var authVM: AuthViewModel
    let orange: Color

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var savedMessage: String? = nil

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
                            .font(.system(size: 20))
                            .foregroundColor(.black.opacity(0.75))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("Account info")
                        .font(.system(size: 24, weight: .bold))

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        VStack(spacing: 16) {
                            Circle()
                                .fill(orange.opacity(0.14))
                                .frame(width: 92, height: 92)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 38))
                                        .foregroundColor(orange)
                                )

                            Text(name.isEmpty ? "Your name" : name)
                                .font(.system(size: 28, weight: .bold))
                        }
                        .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Name")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)

                            TextField("Enter your name", text: $name)
                                .font(.system(size: 16))
                                .padding()
                                .autocorrectionDisabled()
                                .background(Color.white.opacity(0.75))
                                .cornerRadius(16)
                            
                            if let errorMessage = authVM.errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Email")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)

                            Text(Auth.auth().currentUser?.email ?? "")
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.8))
                                .autocorrectionDisabled()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.white.opacity(0.75))
                                .cornerRadius(16)
                        }

                        Button(action: {
                            savedMessage = nil
                            authVM.errorMessage = nil

                            authVM.updateName(name) { success in
                                if success {
                                    authVM.errorMessage = nil
                                    savedMessage = "Saved"
                                } else {
                                    savedMessage = nil
                                }
                            }
                        }) {
                            Text("Save changes")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(orange)
                                .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                        
                        if let savedMessage {
                            Text(savedMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                        }

                        Spacer().frame(height: 24)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 24)
                }
            }
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
        .onAppear {
            name = authVM.displayName
        }
        .navigationBarBackButtonHidden(true)
    }
}
