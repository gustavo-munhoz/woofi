//
//  LocalizedString.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

struct LocalizedString {
    
    private init() {}
    
    struct LoginAndRegister {
        private init() {}
        
        static let emailInput = String(localized: "emailInput")
        static let usernameInput = String(localized: "usernameInput")
        static let passwordInput = String(localized: "passwordInput")
        static let loginButton = String(localized: "loginButton")
        static let registerButton = String(localized: "registerButton")
        
    }
    
    struct Group {
        private init() {}
        
        static let navbarTitle = String(localized: "group")
    }
    
    struct PetList {
        private init() {}
        
        static let navbarTitle = String(localized: "petList")
    }
    
    struct Pet {
        private init() {}
        
        static let largeTitleTasks = String(localized: "largeTitleTasks")
        
        static let dailyTasksTitle = String(localized: "taskSectionTitleDaily")
        static let weeklyTasksTitle = String(localized: "taskSectionTitleWeekly")
        static let monthlyTasksTitle = String(localized: "taskSectionTitleMonthly")
    }
    
    struct Tasks {
        private init() {}
        
        static func ofType(_ type: TaskType) -> String {
            switch type {
                case .walk:
                    return walk
                case .feed:
                    return feed
                case .bath:
                    return bath
                case .brush:
                    return brush
                case .vet:
                    return vet
            }
        }
        
        static let title = String(localized: "tasksTitle")
        
        static let walk = String(localized: "taskWalk")
        static let feed = String(localized: "taskFeed")
        static let bath = String(localized: "taskBath")
        static let brush = String(localized: "taskBrush")
        static let vet = String(localized: "taskVet")
    }
    
}
