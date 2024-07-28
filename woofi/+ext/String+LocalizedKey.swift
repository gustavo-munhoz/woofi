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
                
            case ._continue:
                return "continue"
                
            default:
                return String(describing: self)
            }
        }
        
        fileprivate var values: [CVarArg] {
            switch self {
            case .editPetVCDeleteAlertTitle(let petName), .petListVCDeleteAlertTitle(let petName):
                return [petName]
                
            case .editPetVCDeleteAlertMessage(let petName), .petListVCDeleteAlertMessage(let petName):
                return [petName, petName]
                
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
    }
    
    static func localized(for key: LocalizedKey) -> String {
        String(format: NSLocalizedString(key.key, comment: ""), arguments: key.values)
    }
}
