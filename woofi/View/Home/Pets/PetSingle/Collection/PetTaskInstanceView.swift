//
//  PetTaskInstanceView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/05/24.
//

import UIKit
import SnapKit
import os


class PetTaskInstanceView: UIView {
    
    private var notificationTimer: Timer?
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PetTaskInstanceView")
    
    var taskInstance: PetTaskInstance? {
        didSet {
            titleLabel.text = taskInstance?.label
            updateCompletionImage()
        }
    }
    
    var pet: Pet?
    var taskGroup: PetTaskGroup?
    var frequency: TaskFrequency?
    
    private(set) lazy var completionImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "circle"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .iconGreen
        
        return view
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .primary
        
        return view
    }()
    
    private(set) lazy var completedByLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.textColor = .primary.withAlphaComponent(0.6)
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withSymbolicTraits(.traitItalic)!
        view.font = UIFont(descriptor: fd, size: .zero)
        
        return view
    }()
    
    private(set) lazy var textsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            titleLabel,
            completedByLabel,
            SpacerView(axis: .horizontal)
        ])
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(completionImage)
        addSubview(textsStackView)
    }
    
    private func setupConstraints() {
        completionImage.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.height.equalTo(28)
            make.width.equalTo(28)
        }
        
        textsStackView.snp.makeConstraints { make in
            make.left.equalTo(completionImage.snp.right).offset(10)
            make.right.centerY.equalToSuperview()
            make.height.equalTo(completionImage)
        }                
    }
    
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleTap() {
        guard let taskInstance = taskInstance else { return }
        
        taskInstance.completed.toggle()
        taskInstance.completedByUserWithID = taskInstance.completed ? Session.shared.currentUser?.id : nil
        
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
            let imageName = taskInstance.completed ? "checkmark.circle.fill" : "circle"
            
            self.setCompletedImage(name: imageName)
            
            if let user = Session.shared.currentUser {
                self.completedByLabel.text = taskInstance.completed ? user.username : nil
            }
        }, completion: { _ in
            self.updateTaskInstanceInFirestore()
            
            self.notificationTimer?.invalidate()
            
            if taskInstance.completed {                
                self.notificationTimer = Timer.scheduledTimer(
                    timeInterval: 5.0,
                    target: self,
                    selector: #selector(self.sendNotification),
                    userInfo: nil,
                    repeats: false
                )
            }
        })
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.3) {
                self.alpha = 0.5
            }
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1.0
                self.handleTap()
            }
        default:
            break
        }
    }
    
    private func updateCompletionImage() {
//        guard let taskInstance = taskInstance else {
//            logger.log(level: .fault, "Task Instance is not set.")
//            return
//        }
        Task {
            let username = await loadCompletedByUser()
            if let user = username {
                self.completedByLabel.text = user
                setCompletedImage(name: "checkmark.circle.fill")
                return
            }
//            
//            let imageName = taskInstance.completed ? "checkmark.circle.fill" : "circle"
//            
//            setCompletedImage(name: imageName)
//            
//            if let user = Session.shared.currentUser,
//               taskInstance.completedByUserWithID == user.id  {
//                completedByLabel.text = taskInstance.completed ? user.username : nil
//            }
        }
    }
    
    private func setCompletedImage(name: String) {
        if let image = UIImage(systemName: name) {
            if #available(iOS 17.0, *) {
                completionImage.setSymbolImage(image, contentTransition: .replace)
            } else {
                completionImage.image = image
            }
        }
    }
    
    private func loadCompletedByUser() async -> String? {
//        Task {
            do {
                if let taskInstance = taskInstance, let id = taskInstance.completedByUserWithID {
                    
                    let userData = try await FirestoreService.shared.fetchUserData(userId: id)
                    let username = userData[FirestoreKeys.Users.username] as? String
                    
                    return username // self.completedByLabel.text = username
                } else {
                    return nil
//                        self.completedByLabel.text = ""
                }
            } catch {
                return nil
            }
//        }
    }
    
    private func updateTaskInstanceInFirestore() {
        guard let petID = pet?.id,
              let frequency = frequency,
              let taskGroup = taskGroup,
              let taskInstance = taskInstance else { return }
        
        FirestoreService.shared.updateTaskInstance(
            petID: petID,
            frequency: frequency,
            petTaskGroup: taskGroup,
            taskInstance: taskInstance
        ) { error in
            if let error = error {
                print("Failed to update task instance: \(error)")
            } else {
                print("Successfully updated task instance")
            }
        }
    }
    
    @objc private func sendNotification() {
        guard let taskInstance = taskInstance,
              taskInstance.completed,
              let taskType = taskGroup?.task,
              let petName = pet?.name,
              let user = Session.shared.currentUser
        else { return }
        
        let userID = user.id
        let groupID = user.groupID
        
        print("Requesting notification for: \n-groupID: \(groupID)\n-userID: \(userID)\n-taskType: \(taskType)\n-petName: \(petName)")
        
        NotificationService.shared.sendTaskCompletedNotification(
            toGroupID: groupID,
            byUserID: userID,
            taskType: taskType,
            petName: petName
        )
        
        increaseUserStat(for: taskType)
    }
    
    private func increaseUserStat(for taskType: TaskType) {
        guard let user = Session.shared.currentUser else { return }
        
        user.stats = user.stats.map { stat in
            if stat.task == taskType {
                stat.value += 1
            }
            return stat
        }
        user.publishSelf()
        
        Task {
            do {
                try await FirestoreService.shared.updateUserStats(for: user)
            } catch {
                print("Error updating user stats: \(error.localizedDescription)")
            }
        }
    }
}
