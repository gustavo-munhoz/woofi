//
//  AuthError.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 23/07/24.
//

import Foundation
import FirebaseAuth

enum AuthError: Error, Equatable {
    case userAlreadyExists
    case userNotFound
    case wrongPassword
    case weakPassword
    case invalidEmail
    case unknownError(String)
    
    static func ==(lhs: AuthError, rhs: AuthError) -> Bool {
        switch (lhs, rhs) {
        case (.userAlreadyExists, .userAlreadyExists),             
             (.userNotFound, .userNotFound),
             (.weakPassword, .weakPassword),
             (.invalidEmail, .invalidEmail):
            return true
        case (.unknownError(let lhsMessage), .unknownError(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
    
    init(error: NSError) {
        let errorCode = AuthErrorCode(_nsError: error).code
            switch errorCode {
            case .emailAlreadyInUse:
                self = .userAlreadyExists
            case .wrongPassword:
                self = .wrongPassword
            case .userNotFound:
                self = .userNotFound
            case .weakPassword:
                self = .weakPassword
            case .invalidEmail:
                self = .invalidEmail
            default:
                self = .unknownError(error.localizedDescription)
        }
    }
    
    var errorTitle: String {
        switch self {
        case .userAlreadyExists:
            return .localized(for: .errorEmailTakenTitle)
        case .userNotFound, .wrongPassword:
            return .localized(for: .errorUserNotFoundOrIncorrectPasswordTitle)
        case .weakPassword:
            return .localized(for: .errorWeakPasswordTitle)
        case .invalidEmail:
            return .localized(for: .errorInvalidEmailTitle)
        case .unknownError(let string):
            return .localized(for: .errorUnknownTitle)
        }
    }
    
    var errorMessage: String {
        switch self {
        case .userAlreadyExists:
            return .localized(for: .errorEmailTakenMessage)
        case .userNotFound, .wrongPassword:
            return .localized(for: .errorUserNotFoundOrIncorrectPasswordMessage)
        case .weakPassword:
            return .localized(for: .errorWeakPasswordMessage)
        case .invalidEmail:
            return .localized(for: .errorInvalidEmailMessage)
        case .unknownError(let message):
            return .localized(for: .errorUnknownMessage)
        }
    }       
}

