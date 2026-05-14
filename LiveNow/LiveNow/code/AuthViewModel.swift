//
//  AuthViewModel.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI
import Combine
import FirebaseAuth

final class AuthViewModel: ObservableObject {
    
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @Published var showSignup: Bool = false
    
    var displayName: String {
        Auth.auth().currentUser?.displayName ?? "friend"
    }
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signUp() {
        errorMessage = nil
        
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your name."
            return
        }

        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your password."
            return
        }
        
        isLoading = true

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error as NSError? {
                    switch error.code {
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        self.errorMessage = "An account with this email already exists."

                    case AuthErrorCode.invalidEmail.rawValue:
                        self.errorMessage = "Please enter a valid email."

                    case AuthErrorCode.weakPassword.rawValue:
                        self.errorMessage = "Password should be at least 6 characters."

                    default:
                        self.errorMessage = error.localizedDescription
                    }

                    return
                }

                let changeRequest = result?.user.createProfileChangeRequest()
                changeRequest?.displayName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)

                changeRequest?.commitChanges { profileError in
                    DispatchQueue.main.async {
                        if let profileError = profileError {
                            self.errorMessage = profileError.localizedDescription
                            return
                        }

                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )

                        self.isLoggedIn = true
                    }
                }
            }
        }
    }
    
    func login() {
        errorMessage = nil
        isLoading = true

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
                
                self.isLoggedIn = true
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            email = ""
            password = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
