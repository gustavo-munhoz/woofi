//
//  PetTaskInstanceCell.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import UIKit

class PetTaskInstanceCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PetTaskInstanceCell"
    
    weak var taskInstance: PetTaskInstance?
    
    private(set) lazy var completeToggleButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var taskIntanceTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.font = UIFont.preferredFont(forTextStyle: .callout)
        view.textColor = .primary
        
        return view
    }()
    
    private(set) lazy var userThatCompleted: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        if let italicFd = fd.withSymbolicTraits(.traitItalic) {
            let italicFont = UIFont(descriptor: italicFd, size: 0)
            view.font = UIFont(descriptor: italicFd, size: .zero)
        }
        
        return view
    }()
    
    private(set) lazy var stackView: UIStackView = {
        let spacer = UIView()
        
        spacer.isUserInteractionEnabled = false
        spacer.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        
        let view = UIStackView(arrangedSubviews: [completeToggleButton, taskIntanceTitle, userThatCompleted, spacer])
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGray5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.left.right.bottom.top.equalToSuperview()
        }
    }
    
    func setup(with taskInstance: PetTaskInstance) {
        taskIntanceTitle.text = taskInstance.label
        userThatCompleted.text = taskInstance.completedBy?.name ?? ""
        
        addSubviews()
        setupConstraints()
    }
}
