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
    @Published var isLoggedIn: Bool = false
    @Published var showSignup: Bool = false
    @Published var confirmPassword = ""
    @Published var acceptedAgeAndTerms = false
    @Published var currentNonce: String?
    @Published var needsAppleTermsAcceptance = false

    @Published var needsEmailVerification: Bool = false
    @Published var verificationMessage: String? = nil
    @Published var isCheckingAuthentication: Bool = true
    
    @AppStorage("hasAuthenticatedBefore")
    var hasAuthenticatedBefore = false
    
    var usesEmailPassword: Bool {
        Auth.auth().currentUser?.providerData.contains {
            $0.providerID == "password"
        } ?? false
    }

    var usesAppleSignIn: Bool {
        Auth.auth().currentUser?.providerData.contains {
            $0.providerID == "apple.com"
        } ?? false
    }
    
    private func appleTermsPendingKey(for uid: String) -> String {
        "appleTermsPending_\(uid)"
    }

    private func setAppleTermsPending(
        _ pending: Bool,
        for uid: String
    ) {
        UserDefaults.standard.set(
            pending,
            forKey: appleTermsPendingKey(for: uid)
        )
    }

    private func isAppleTermsPending(for uid: String) -> Bool {
        UserDefaults.standard.bool(
            forKey: appleTermsPendingKey(for: uid)
        )
    }
    
    init() {
        checkAuthenticationState()
    }
    
    func checkAuthenticationState() {

        guard let user = Auth.auth().currentUser else {
            isLoggedIn = false
            needsEmailVerification = false
            isCheckingAuthentication = false
            return
        }

        user.reload { [weak self] error in
            DispatchQueue.main.async {

                guard let self = self else { return }

                defer {
                    self.isCheckingAuthentication = false
                }

                if let nsError = error as NSError?,
                   nsError.domain == AuthErrorDomain,
                   nsError.code == AuthErrorCode.userNotFound.rawValue {

                    try? Auth.auth().signOut()

                    self.isLoggedIn = false
                    self.needsEmailVerification = false
                    self.verificationMessage = nil
                    self.errorMessage = nil
                    return
                }

                guard error == nil,
                      let refreshedUser = Auth.auth().currentUser else {

                    try? Auth.auth().signOut()

                    self.isLoggedIn = false
                    self.needsEmailVerification = false
                    return
                }

                let usesEmailPassword = refreshedUser.providerData.contains {
                    $0.providerID == "password"
                }

                if usesEmailPassword && !refreshedUser.isEmailVerified {

                    try? Auth.auth().signOut()

                    self.isLoggedIn = false
                    self.needsEmailVerification = false
                    self.verificationMessage = nil
                    self.errorMessage = nil
                    return
                }

                let usesApple = refreshedUser.providerData.contains {
                    $0.providerID == "apple.com"
                }

                if usesApple &&
                    self.isAppleTermsPending(for: refreshedUser.uid) {

                    self.acceptedAgeAndTerms = false
                    self.needsAppleTermsAcceptance = true
                    self.needsEmailVerification = false
                    self.isLoggedIn = false

                    return
                }

                self.needsAppleTermsAcceptance = false
                self.isLoggedIn = true
                self.needsEmailVerification = false
            }
        }
    }

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

    func handleAppleSignIn(
        result: Result<ASAuthorization, Error>
    ) {
        switch result {

        case .success(let authorization):

            guard
                let appleIDCredential =
                    authorization.credential as? ASAuthorizationAppleIDCredential,
                let nonce = currentNonce,
                let appleIDToken = appleIDCredential.identityToken,
                let idTokenString = String(
                    data: appleIDToken,
                    encoding: .utf8
                )
            else {
                errorMessage = "Apple Sign In failed."
                return
            }

            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )

            isLoading = true
            errorMessage = nil

            Auth.auth().signIn(with: credential) { result, error in

                DispatchQueue.main.async {

                    self.isLoading = false
                    self.currentNonce = nil

                    if let error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    guard let result else {
                        self.errorMessage =
                            "Apple Sign In failed. Please try again."
                        return
                    }

                    self.needsEmailVerification = false
                    self.errorMessage = nil

                    let isNewUser =
                        result.additionalUserInfo?.isNewUser ?? false

                    if isNewUser {

                        self.setAppleTermsPending(
                            true,
                            for: result.user.uid
                        )

                        self.acceptedAgeAndTerms = false
                        self.needsAppleTermsAcceptance = true
                        self.needsEmailVerification = false
                        self.errorMessage = nil
                        self.isLoggedIn = false

                    } else {

                        let hasPendingTerms =
                            self.isAppleTermsPending(
                                for: result.user.uid
                            )

                        if hasPendingTerms {

                            self.acceptedAgeAndTerms = false
                            self.needsAppleTermsAcceptance = true
                            self.needsEmailVerification = false
                            self.errorMessage = nil
                            self.isLoggedIn = false

                        } else {

                            self.hasAuthenticatedBefore = true
                            self.needsAppleTermsAcceptance = false
                            self.needsEmailVerification = false
                            self.errorMessage = nil
                            self.isLoggedIn = true
                        }
                    }
                }
            }

        case .failure(let error):

            isLoading = false
            currentNonce = nil

            if let authorizationError =
                error as? ASAuthorizationError,
               authorizationError.code == .canceled {
                return
            }

            errorMessage = error.localizedDescription
        }
    }
    
    func completeAppleSignUp() {

        guard let user = Auth.auth().currentUser else {
            needsAppleTermsAcceptance = false
            acceptedAgeAndTerms = false
            errorMessage =
                "Apple Sign In failed. Please try again."
            return
        }

        guard acceptedAgeAndTerms else {
            errorMessage =
                "Please confirm that you are at least 16 years old and agree to the Terms of Use and Privacy Policy."
            return
        }

        setAppleTermsPending(
            false,
            for: user.uid
        )

        hasAuthenticatedBefore = true
        needsAppleTermsAcceptance = false
        needsEmailVerification = false
        errorMessage = nil
        isLoggedIn = true
    }
    
    var displayName: String {
        Auth.auth().currentUser?.displayName ?? ""
    }
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signUp() {
        errorMessage = nil
        verificationMessage = nil

        guard acceptedAgeAndTerms else {
            errorMessage =
                "Please confirm that you are at least 16 years old and agree to the Terms of Use and Privacy Policy."
            return
        }
        
        let trimmedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let trimmedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter your name."
            return
        }

        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords don't match."
            return
        }

        isLoading = true

        Auth.auth().createUser(
            withEmail: trimmedEmail,
            password: password
        ) { result, error in

            DispatchQueue.main.async {
                if let error = error as NSError? {
                    self.isLoading = false

                    switch error.code {
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        self.errorMessage =
                            "An account with this email already exists."

                    case AuthErrorCode.invalidEmail.rawValue:
                        self.errorMessage =
                            "Please enter a valid email."

                    case AuthErrorCode.weakPassword.rawValue:
                        self.errorMessage =
                            "Password should be at least 6 characters."

                    default:
                        self.errorMessage = error.localizedDescription
                    }

                    return
                }

                guard let user = result?.user else {
                    self.isLoading = false
                    self.errorMessage =
                        "Account could not be created."
                    return
                }

                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = trimmedName

                changeRequest.commitChanges { profileError in
                    DispatchQueue.main.async {
                        if let profileError {
                            self.isLoading = false
                            self.errorMessage =
                                profileError.localizedDescription
                            return
                        }

                        Auth.auth().useAppLanguage()

                        user.sendEmailVerification { verificationError in
                            DispatchQueue.main.async {
                                self.isLoading = false

                                if let verificationError {
                                    self.errorMessage =
                                        verificationError.localizedDescription
                                    return
                                }

                                UIApplication.shared.sendAction(
                                    #selector(UIResponder.resignFirstResponder),
                                    to: nil,
                                    from: nil,
                                    for: nil
                                )

                                self.hasAuthenticatedBefore = true
                                self.needsEmailVerification = true
                                self.isLoggedIn = false

                                self.verificationMessage =
                                    "We sent a verification link to \(trimmedEmail)."
                            }
                        }
                    }
                }
            }
        }
    }
    
    func login() {
        errorMessage = nil
        verificationMessage = nil

        let trimmedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }

        isLoading = true

        Auth.auth().signIn(
            withEmail: trimmedEmail,
            password: password
        ) { result, error in

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
                        self.errorMessage =
                            "Something went wrong. Please try again."
                    }

                    return
                }

                guard let user = result?.user else {
                    self.errorMessage =
                        "Something went wrong. Please try again."
                    return
                }

                guard user.isEmailVerified else {
                    self.isLoggedIn = false
                    self.needsEmailVerification = true
                    self.errorMessage =
                        "Please verify your email before continuing."
                    return
                }

                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )

                self.hasAuthenticatedBefore = true
                self.needsEmailVerification = false
                self.isLoggedIn = true
            }
        }
    }
    
    func checkEmailVerification() {
        errorMessage = nil
        verificationMessage = nil

        guard let user = Auth.auth().currentUser else {
            isLoggedIn = false
            needsEmailVerification = false
            errorMessage = "Please sign in again."
            return
        }

        isLoading = true

        user.reload { error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let refreshedUser = Auth.auth().currentUser else {
                    self.errorMessage = "Please sign in again."
                    return
                }

                if refreshedUser.isEmailVerified {
                    self.hasAuthenticatedBefore = true
                    self.needsEmailVerification = false
                    self.isLoggedIn = true
                } else {
                    self.needsEmailVerification = true
                    self.isLoggedIn = false
                    self.errorMessage =
                        "Your email hasn't been verified yet."
                }
            }
        }
    }
    
    func resendVerificationEmail() {
        errorMessage = nil
        verificationMessage = nil

        guard let user = Auth.auth().currentUser else {
            errorMessage = "Please sign in again."
            return
        }

        guard !user.isEmailVerified else {
            needsEmailVerification = false
            isLoggedIn = true
            return
        }

        isLoading = true

        Auth.auth().useAppLanguage()

        user.sendEmailVerification { error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                self.verificationMessage =
                    "A new verification email has been sent."
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()

            isLoggedIn = false
            needsEmailVerification = false
            verificationMessage = nil
            
            showSignup = false
            name = ""
            email = ""
            password = ""
            confirmPassword = ""
            acceptedAgeAndTerms = false
            errorMessage = nil

            Task {
                await NotificationScheduler()
                    .removeAllLiveNowNotifications()
            }

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
    
    func deleteAccount(
        completion: @escaping (String?) -> Void
    ) {
        guard let user = Auth.auth().currentUser else {
            completion("No user found.")
            return
        }

        deleteUserDataAndAccount(
            user: user,
            completion: completion
        )
    }

    func deleteAppleAccount(
        authorization: ASAuthorization,
        nonce: String,
        completion: @escaping (String?) -> Void
    ) {
        guard
            let user = Auth.auth().currentUser,
            let appleCredential =
                authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = appleCredential.identityToken,
            let idTokenString = String(
                data: identityToken,
                encoding: .utf8
            ),
            let authorizationCode = appleCredential.authorizationCode,
            let authCodeString = String(
                data: authorizationCode,
                encoding: .utf8
            )
        else {
            completion("Unable to verify your Apple account.")
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleCredential.fullName
        )

        user.reauthenticate(with: credential) { _, error in
            if let error {
                DispatchQueue.main.async {
                    completion(error.localizedDescription)
                }
                return
            }

            Task {
                do {
                    try await Auth.auth().revokeToken(
                        withAuthorizationCode: authCodeString
                    )

                    await MainActor.run {
                        self.deleteUserDataAndAccount(
                            user: user,
                            completion: completion
                        )
                    }
                } catch {
                    await MainActor.run {
                        completion(error.localizedDescription)
                    }
                }
            }
        }
    }

    private func deleteUserDataAndAccount(
        user: User,
        completion: @escaping (String?) -> Void
    ) {
        let uid = user.uid
        let db = Firestore.firestore()

        let userRef = db
            .collection("users")
            .document(uid)

        let entriesRef = userRef
            .collection("entries")

        let rateLimitsRef = db
            .collection("rateLimits")

        Task {
            do {
                // 1. Poiščemo vse resete uporabnika.
                let entriesSnapshot =
                    try await entriesRef.getDocuments()

                // 2. Poiščemo vse rateLimits dokumente uporabnika.
                // Ne zanašamo se na document ID, ampak na uid field.
                let rateLimitsSnapshot =
                    try await rateLimitsRef
                        .whereField("uid", isEqualTo: uid)
                        .getDocuments()

                let batch = db.batch()

                // 3. Izbrišemo vse entries.
                for document in entriesSnapshot.documents {
                    batch.deleteDocument(document.reference)
                }

                // 4. Izbrišemo vse rateLimits zapise tega uporabnika.
                for document in rateLimitsSnapshot.documents {
                    batch.deleteDocument(document.reference)
                }

                // 5. Izbrišemo users/{uid}.
                // S tem izgine tudi personalization,
                // ker je field znotraj tega dokumenta.
                batch.deleteDocument(userRef)

                // 6. Firestore cleanup.
                try await batch.commit()

                #if DEBUG
                print("ACCOUNT DELETE: Firestore data deleted")
                print(
                    "ACCOUNT DELETE: rateLimits deleted:",
                    rateLimitsSnapshot.documents.count
                )
                #endif

                // 7. Nato izbrišemo Firebase Authentication account.
                user.delete { error in
                    DispatchQueue.main.async {

                        if let error {
                            #if DEBUG
                            print(
                                "ACCOUNT DELETE AUTH ERROR:",
                                error.localizedDescription
                            )
                            #endif

                            completion(error.localizedDescription)
                            return
                        }

                        // Odstranimo še lokalni Apple terms podatek,
                        // če je šlo za Apple account.
                        UserDefaults.standard.removeObject(
                            forKey: self.appleTermsPendingKey(
                                for: uid
                            )
                        )

                        #if DEBUG
                        print("ACCOUNT DELETE: Auth user deleted")
                        print("ACCOUNT DELETE COMPLETE:", uid)
                        #endif

                        self.finishAccountDeletion()
                        completion(nil)
                    }
                }

            } catch {
                await MainActor.run {
                    #if DEBUG
                    print(
                        "ACCOUNT DELETE FIRESTORE ERROR:",
                        error.localizedDescription
                    )
                    #endif

                    completion(error.localizedDescription)
                }
            }
        }
    }

    private func finishAccountDeletion() {
        isLoggedIn = false
        needsEmailVerification = false
        verificationMessage = nil
        showSignup = false

        name = ""
        email = ""
        password = ""
        confirmPassword = ""
        acceptedAgeAndTerms = false
        errorMessage = nil
        currentNonce = nil

        Task {
            await NotificationScheduler()
                .removeAllLiveNowNotifications()
        }
    }
}
