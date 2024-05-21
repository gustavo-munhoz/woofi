//
//  PetView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 13/05/24.
//

import UIKit
import SnapKit

class PetView: UIView {
    
    weak var viewModel: PetViewModel? {
        didSet {
            dailyTasks.setup(withTaskGroup: viewModel!.pet.taskGroups.first(where:  {
                $0.frequency == .daily
            })!)
        }
    }
    
    private(set) lazy var petPicture: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "dog.circle"))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var largeTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.text = LocalizedString.Pet.largeTitleTasks
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        let boldFd = fd.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]])
        view.font = UIFont(descriptor: boldFd, size: .zero)
        view.textColor = .primary
        
        return view
    }()
    
    private(set) lazy var dailyTasksLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.text = LocalizedString.Pet.dailyTasksTitle
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let boldFd = fd.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]])
        view.font = UIFont(descriptor: boldFd, size: .zero)
        view.textColor = .primary
        
        return view
    }()
    
    private(set) lazy var dailyTasks: PetTaskGroupView = {
        let view = PetTaskGroupView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var weeklyTasksLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.text = LocalizedString.Pet.weeklyTasksTitle
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let boldFd = fd.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]])
        view.font = UIFont(descriptor: boldFd, size: .zero)
        view.textColor = .primary
        
        return view
    }()
    
    private(set) lazy var monthlyTasksLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.text = LocalizedString.Pet.monthlyTasksTitle
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let boldFd = fd.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]])
        view.font = UIFont(descriptor: boldFd, size: .zero)
        view.textColor = .primary
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        
        backgroundColor = .systemBackground
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        [
            petPicture,
            largeTitleLabel,
            dailyTasksLabel,
            dailyTasks,
            weeklyTasksLabel,
            monthlyTasksLabel
        ].forEach { v in
            addSubview(v)
        }
    }
    
    private func setupConstraints() {
        petPicture.snp.makeConstraints { make in
            make.top.centerX.equalTo(safeAreaLayoutGuide)
            make.width.height.equalTo(175)
        }
        
        largeTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(petPicture.snp.bottom).offset(16)
            make.height.equalTo(42)
        }
        
        dailyTasksLabel.snp.makeConstraints { make in
            make.left.right.equalTo(largeTitleLabel)
            make.top.equalTo(largeTitleLabel.snp.bottom).offset(16)
            make.height.equalTo(28)
        }
        
        dailyTasks.snp.makeConstraints { make in
            make.left.right.equalTo(dailyTasksLabel)
            make.top.equalTo(dailyTasksLabel.snp.bottom).offset(16)
            make.height.equalTo(160)
        }
        
        weeklyTasksLabel.snp.makeConstraints { make in
            make.left.right.height.equalTo(dailyTasksLabel)
            make.top.equalTo(dailyTasks.snp.bottom).offset(16)
        }
        
        monthlyTasksLabel.snp.makeConstraints { make in
            make.left.right.height.equalTo(weeklyTasksLabel)
            make.top.equalTo(weeklyTasksLabel.snp.bottom).offset(16)
        }
    }
}
