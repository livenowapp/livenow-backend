//
//  AuthViewModel.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

final class AuthViewModel: ObservableObject {
    
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @Published var showSignup: Bool = false
    @Published var confirmPassword = ""
    @Published var currentNonce: String?
    @AppStorage("hasAuthenticatedBefore")
    var hasAuthenticatedBefore = false

    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)

        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)

            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce.")
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)

        return hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let nonce = currentNonce,
                let appleIDToken = appleIDCredential.identityToken,
                let idTokenString = String(data: appleIDToken, encoding: .utf8)
            else {
                errorMessage = "Apple Sign In failed."
                return
            }

            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )

            Auth.auth().signIn(with: credential) { result, error in
                DispatchQueue.main.async {
                    if let error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    self.isLoggedIn = true
                }
            }

        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    var displayName: String {
        Auth.auth().currentUser?.displayName ?? ""
    }
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signUp() {
        errorMessage = nil

        guard password == confirmPassword else {
                errorMessage = "Passwords don't match."
                return
            }

        isLoading = true

        Auth.auth().createUser(
            withEmail: email,
            password: password
        ) { result, error in
            
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

                        self.hasAuthenticatedBefore = true
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

                if let error = error as NSError? {
                    switch error.code {
                    case AuthErrorCode.wrongPassword.rawValue,
                         AuthErrorCode.invalidCredential.rawValue:
                        self.errorMessage = "Incorrect email or password."

                    case AuthErrorCode.invalidEmail.rawValue:
                        self.errorMessage = "Please enter a valid email."

                    case AuthErrorCode.userNotFound.rawValue:
                        self.errorMessage = "No account found with this email."

                    default:
                        self.errorMessage = "Something went wrong. Please try again."
                    }

                    return
                }
                
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
                
                self.hasAuthenticatedBefore = true
                self.isLoggedIn = true
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            showSignup = false
            name = ""
            email = ""
            password = ""
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateName(_ name: String, completion: @escaping (Bool) -> Void) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter your name."
            completion(false)
            return
        }

        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = trimmedName

        changeRequest?.commitChanges { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.name = trimmedName
                    self.objectWillChange.send()
                    completion(true)
                }
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (String?) -> Void) {

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            completion("Please enter your email.")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: trimmedEmail) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(error.localizedDescription)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func deleteAccount(completion: @escaping (String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion("No user found.")
            return
        }

        let uid = user.uid
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        let entriesRef = userRef.collection("entries")

        entriesRef.getDocuments { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(error.localizedDescription)
                }
                return
            }

            let batch = db.batch()

            snapshot?.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }

            batch.deleteDocument(userRef)

            batch.commit { error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(error.localizedDescription)
                    }
                    return
                }

                user.delete { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(error.localizedDescription)
                        } else {
                            self.isLoggedIn = false
                            self.name = ""
                            self.email = ""
                            self.password = ""
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}
