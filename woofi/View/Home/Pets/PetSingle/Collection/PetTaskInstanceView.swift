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
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PetTaskInstanceView")    
    
    weak var taskInstance: PetTaskInstance? {
        didSet {
            titleLabel.text = taskInstance?.label
            completionImage.image = (taskInstance?.completed ?? false) ?
            UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
            
            Task {
                do {
                    if let taskInstance = taskInstance, let id = taskInstance.completedByUserWithID {
                        let userData = try await FirestoreService.shared.fetchUserData(userId: id)
                        let username = userData[FirestoreKeys.Users.username] as? String
                        DispatchQueue.main.async {
                            self.completedByLabel.text = username ?? ""
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.completedByLabel.text = ""
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.completedByLabel.text = "Error"
                    }
                }
            }
        }
    }
    
    private(set) lazy var completionImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "circle"))
        view.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        UIView.transition(with: self,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            self.updateCompletionImage()
            
        }, completion: nil)
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
        guard let taskInstance = taskInstance else { 
            logger.log(level: .fault, "Task Instance is not set.")
            return
        }
        
        let imageName = taskInstance.completed == true ? "checkmark.circle.fill" : "circle"
        
        if let image = UIImage(systemName: imageName) {
            if #available(iOS 17.0, *) {
                completionImage.setSymbolImage(image, contentTransition: .replace)
            } else {
                completionImage.image = image
            }
        }
        
        completedByLabel.text = taskInstance.completed ? Session.shared.currentUser?.username : nil
    }
}
