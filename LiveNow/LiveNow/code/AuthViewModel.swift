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
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    
    func signUp() {
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            self.isLoggedIn = true
        }
    }
    
    func login() {
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            self.isLoggedIn = true
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
