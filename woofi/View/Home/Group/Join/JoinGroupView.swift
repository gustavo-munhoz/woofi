import UIKit
import SnapKit

class JoinGroupView: UIView, UITextFieldDelegate {

    // TODO: Localize texts
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Join Group"
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        
        let customFd = fd.addingAttributes([
            .traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold
            ]
        ])
        
        label.font = UIFont(descriptor: customFd, size: .zero)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .primary
        return label
    }()
    
    let tutorialLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter the code you received to join the group."
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .primary
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var textFields: [UITextField] = []

    let joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join group", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 12
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupTextFields()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupTextFields()
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        
        addSubview(titleLabel)
        addSubview(tutorialLabel)
        addSubview(stackView)
        addSubview(joinButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(24)
            make.left.right.equalToSuperview().inset(24)
        }
        
        tutorialLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.left.right.equalTo(titleLabel)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(tutorialLabel.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(75)
            make.height.equalTo(44)
        }
        
        joinButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(24)
            make.left.right.equalTo(tutorialLabel)
        }
    }
    
    private func setupTextFields() {
        for _ in 0..<6 {
            let textField = UITextField()
            textField.textAlignment = .center
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.borderStyle = .none
            textField.textColor = .primary
            textField.autocapitalizationType = .allCharacters
            textField.delegate = self
            
            let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
            
            let customFd = fd.addingAttributes([
                .traits: [
                    UIFontDescriptor.TraitKey.weight: UIFont.Weight.ultraLight,
                ]
            ])
            
            textField.font = UIFont(descriptor: customFd, size: .zero)
            
            let underline = UIView()
            underline.backgroundColor = .primary.withAlphaComponent(0.6)
            underline.translatesAutoresizingMaskIntoConstraints = false
            textField.addSubview(underline)
            underline.snp.makeConstraints { make in
                make.height.equalTo(2)
                make.left.right.equalTo(textField)
                make.bottom.equalTo(textField).offset(8)
            }
            
            stackView.addArrangedSubview(textField)
            textFields.append(textField)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newLength = text.count + string.count - range.length
        
        if newLength > 1 {
            return false
        }
        
        if !string.isEmpty {
            textField.text = string
            
            if let nextField = textFields.first(where: { $0.text?.isEmpty ?? true }) {
                nextField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
            
            return false
            
        } else {
            textField.text = ""
            
            if let previousFieldIndex = textFields.firstIndex(of: textField), previousFieldIndex > 0 {
                let previousField = textFields[previousFieldIndex - 1]
                previousField.becomeFirstResponder()
            }
            
            return false
        }
    }
}
