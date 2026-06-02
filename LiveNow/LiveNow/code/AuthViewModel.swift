//
//  AuthViewModel.swift
//  LiveNow
//
//  Created by Maja on 24. 4. 2026.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

final class AuthViewModel: ObservableObject {
    
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @Published var showSignup: Bool = false
    
    var displayName: String {
        Auth.auth().currentUser?.displayName ?? ""
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
