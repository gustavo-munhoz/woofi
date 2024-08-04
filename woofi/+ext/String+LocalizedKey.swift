//
//  String+LocalizedKey.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 19/07/24.
//

import Foundation

extension String {
    
    enum LocalizedKey {
        
        fileprivate var key: String {
            switch self {
            case .editPetVCDeleteAlertTitle:
                return "editPetVCDeleteAlertTitle"
                
            case .editPetVCDeleteAlertMessage:
                return "editPetVCDeleteAlertMessage"
                
            case .petListVCDeleteAlertTitle:
                return "petListVCDeleteAlertTitle"
                
            case .petListVCDeleteAlertMessage:
                return "petListVCDeleteAlertMessage"
                
            case .notificationMessageWalkTitle:
                return "notificationMessageWalkTitle"
                
            case .notificationMessageWalkBody:
                return "notificationMessageWalkBody"
                
            case .notificationMessageFeedTitle:
                return "notificationMessageFeedTitle"
            
            case .notificationMessageFeedBody:
                return "notificationMessageFeedBody"
                
            case .notificationMessageBathTitle:
                return "notificationMessageBathTitle"
            
            case .notificationMessageBathBody:
                return "notificationMessageBathBody"
                
            case .notificationMessageBrushTitle:
                return "notificationMessageBrushBody"
                
            case .notificationMessageBrushBody:
                return "notificationMessageBrushBody"
                
            case .notificationMessageVetTitle:
                return "notificationMessageVetTitle"
                
            case .notificationMessageVetBody:
                return "notificationMessageVetBody"
                
            case ._continue:
                return "continue"
                
            default:
                return String(describing: self)
            }
        }
        
        fileprivate var values: [CVarArg] {
            switch self {
            case .editPetVCDeleteAlertTitle(let petName),
                    .petListVCDeleteAlertTitle(let petName),
                    .notificationMessageWalkTitle(let petName),
                    .notificationMessageFeedTitle(let petName),
                    .notificationMessageBathTitle(let petName),
                    .notificationMessageBrushTitle(let petName),
                    .notificationMessageVetTitle(let petName):
                
                return [petName]
                
            case .editPetVCDeleteAlertMessage(let petName), .petListVCDeleteAlertMessage(let petName):
                return [petName, petName]
                
            case .notificationMessageWalkBody(let username, let petName),
                    .notificationMessageFeedBody(let username, let petName),
                    .notificationMessageBathBody(let username, let petName),
                    .notificationMessageBrushBody(let username, let petName),
                    .notificationMessageVetBody(let username, let petName):
                return [username, petName]
                
            default:
                return []
            }
        }
        
        // MARK: - Generics
        case ok
        case cancel
        case delete
        case _continue
        case photosAccessDeniedTitle
        case photosAccessDeniedMessage
        case placeholderUsername
        case placeholderBio
        
        // MARK: - TaskType
        case taskTypeWalk
        case taskTypeFeed
        case taskTypeBrush
        case taskTypeBath
        case taskTypeVet
        
        // MARK: - Tasks
        case taskDailyMorningWalk
        case taskDailyAfternoonWalk
        case taskDailyEveningWalk
        case taskDailyMorningMeal
        case taskDailyEveningMeal
        case taskWeeklyBrush
        case taskMonthlyBathFirst
        case taskMonthlyBathSecond
        case taskMonthlyVet
        
        // MARK: - EditPetView
        case editPetViewChangePictureButton
        case editPetViewPictureStackTitle
        case editPetViewPetNameStackTitle
        case editPetViewBreedStackTitle
        case editPetViewAgeStackTitle
        case editPetViewDeleteButton
        
        // MARK: - EditPetViewController
        case editPetVCNavigationItemTitle
        case editPetVCDeleteAlertTitle(petName: String)
        case editPetVCDeleteAlertMessage(petName: String)
        
        // MARK: - AddPetView
        case addPetViewTitle
        case addPetViewName
        case addPetViewBreed
        case addPetViewAge
        case addPetViewCreateButton
        
        // MARK: - PetView
        case petViewLargeTitle
        
        // MARK: - PetViewController
        case petVCDailyTitle
        case petVCWeeklyTitle
        case petVCMonthlyTitle
        
        // MARK: - PetListView
        case petListViewEmptyText
        
        // MARK: - PetListViewController
        case petListVCContextMenuEdit
        case petListVCContextMenuDelete
        case petListVCDeleteAlertTitle(petName: String)
        case petListVCDeleteAlertMessage(petName: String)
        
        // MARK: - JoinGroupView
        case joinGroupViewTitle
        case joinGroupViewTutorial
        case joinGroupViewButton
        
        // MARK: - JoinGroupViewController
        case joinGroupVCInvalidCodeTitle
        case joinGroupVCInvalidCodeMessage
        
        // MARK: - InviteView
        case inviteViewTitle
        case inviteViewTutorial
        case inviteViewShareButton
        
        // MARK: - InviteViewController
        case inviteVCMessage(code: String)
        
        // MARK: - GroupViewController
        case groupVCAlertTitle
        case groupVCAlertMessage
        case groupVCInviteActionTitle
        case groupVCJoinActionTitle
        case groupVCLeaveActionTitle
        case groupVCLeaveWarningTitle
        case groupVCLeaveWarningMessage
        case groupVCLeaveWarningConfirm
        
        // MARK: - GroupView
        case groupViewEmptyText
        
        // MARK: - HomeViewController
        case homeVCGroupNavbarTitle
        case homeVCPetsNavbarTitle
        case homeVCProfileNavbarTitle
        
        // MARK: - ProfileSetupView
        case profileSetupViewChangePictureButton
        case profileSetupViewPictureStackTitle
        case profileSetupViewUsernameStackTitle
        case profileSetupViewBioStackTitle
        
        // MARK: - ProfileSetupViewController
        case profileSetupVCNavigationTitle
        
        // MARK: - EditProfileView
        case editProfileViewChangePictureButton
        case editProfileViewPictureStackTitle
        case editProfileViewUsernameStackTitle
        case editProfileViewBioStackTitle
        case editProfileSignOut
        
        // MARK: - UserView
        case userViewStatsLabel
        
        // MARK: - LoginView
        case loginViewWelcomeBack
        case loginViewSeparator
        case loginViewSigningIn
        case loginViewRegisterLabel
        case loginViewRegisterButton
        case authEmailInputLabel
        case authPasswordInputLabel
        case authUsernameInputLabel
        case authLoginButtonTitle
        case authRegisterButtonTitle
        
        case loginViewSignInWithGoogle
        case loginViewSignInWithApple
        case registerViewSignUpWithGoogle
        case registerViewSignUpWithApple
        
        // MARK: - LoginViewController
        case loginVCNavTitle
        
        // MARK: - RegisterView
        case registerViewWelcome
        case registerViewSignUpButton
        case registerViewSigningUp
        
        // MARK: - RegisterViewController Alerts
        case errorEmailTakenTitle
        case errorEmailTakenMessage
        case errorUserNotFoundOrIncorrectPasswordTitle
        case errorUserNotFoundOrIncorrectPasswordMessage
        case errorWeakPasswordTitle
        case errorWeakPasswordMessage
        case errorInvalidEmailTitle
        case errorInvalidEmailMessage
        case errorUnknownTitle
        case errorUnknownMessage
        
        // MARK: - Notifications
        case notificationMessageWalkTitle(petName: String)
        case notificationMessageWalkBody(username: String, petName: String)
        case notificationMessageFeedTitle(petName: String)
        case notificationMessageFeedBody(username: String, petName: String)
        case notificationMessageBathTitle(petName: String)
        case notificationMessageBathBody(username: String, petName: String)
        case notificationMessageBrushTitle(petName: String)
        case notificationMessageBrushBody(username: String, petName: String)
        case notificationMessageVetTitle(petName: String)
        case notificationMessageVetBody(username: String, petName: String)
    }
    
    static func localized(for key: LocalizedKey) -> String {
        String(format: NSLocalizedString(key.key, comment: ""), arguments: key.values)
    }
}
