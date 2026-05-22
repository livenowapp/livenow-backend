//
//  ContactUs.swift
//  LiveNow
//
//  Created by Maja on 16. 5. 2026.
//

import SwiftUI

//MARK: - CONTACT US

struct ContactScreen: View {
    let orange: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding = min(geo.size.width * 0.055, 24)
            let topPadding = min(geo.size.height * 0.025, 18)

            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.black.opacity(0.75))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("Contact us")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text("We’d love to hear from you.")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.top, 24)

                        Text("Send us feedback, questions, or anything that could help improve LiveNow.")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)

                        Button(action: {
                            if let url = URL(string: "mailto:livenowapp@outlook.com") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(orange)

                                Text("livenowapp@outlook.com")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(orange)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.75))
                            .cornerRadius(18)
                        }
                        .buttonStyle(.plain)

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
}
