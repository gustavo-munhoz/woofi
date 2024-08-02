//
//  AuthenticationService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import Firebase
import FirebaseAuth
import GoogleSignIn
import UIKit
import AuthenticationServices
import CryptoKit

class AuthenticationService: NSObject, AuthenticationServiceProtocol {
    
    /// Singleton instance for global access
    static let shared = AuthenticationService()
    
    private var currentNonce: String?
    private var appleSignInCompletion: ((Result<String, Error>) -> Void)?
    
    private override init() {}
    
    /// Logs in a user using email and password
    func loginUser(withEmail email: String, password: String) async throws -> AuthDataResult {
        do {
            return try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw error
        }
    }
    
    /// Logs in a user with Google Auth.
    func loginUser(withGoogleForm viewController: UIViewController) async throws -> AuthDataResult {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { signInResult, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let signInResult = signInResult else {
                        continuation.resume(throwing: NSError(
                            domain: "dev.mnhz.woofy",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Google Sign-In failed."]
                        ))
                        return
                    }
                    
                    guard let idToken = signInResult.user.idToken?.tokenString else {
                        continuation.resume(throwing: NSError(
                            domain: "dev.mnhz.woofy",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Google Sign-In authentication failed"]
                        ))
                        return
                    }
                    
                    let credential = GoogleAuthProvider.credential(
                        withIDToken: idToken,
                        accessToken: signInResult.user.accessToken.tokenString
                    )
                    
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            
                        } else if let authResult = authResult {
                            continuation.resume(returning: authResult)
                        }
                    }
                }
            }
        }
    }
    
    func registerUser(withEmail email: String, password: String, additionalData: [String: Any]) async throws -> AuthDataResult {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
//            var userData = additionalData
//            userData[FirestoreKeys.Users.uid] = authResult.user.uid
//            userData[FirestoreKeys.Users.email] = authResult.user.email
//            
//            try await FirestoreService.shared.saveUserData(userId: authResult.user.uid, data: userData)
            return authResult
        } catch {
            throw error
        }
    }
    
    func signInWithApple(completion: @escaping (Result<String, Error>) -> Void) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        // Generate and save nonce
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        appleSignInCompletion = completion
    }
    
    // MARK: - Helper Functions
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding

extension AuthenticationService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    self.appleSignInCompletion?(.failure(error))
                    return
                }
                // User is signed in to Firebase with Apple.
                self.appleSignInCompletion?(.success(authResult?.user.uid ?? "null-id"))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.appleSignInCompletion?(.failure(error))
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if #available(iOS 15.0, *) {
            // Use the first window of the first connected scene
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }!
        } else {
            // Fallback on earlier versions
            return UIApplication.shared.windows.first { $0.isKeyWindow }!
        }
    }
}
