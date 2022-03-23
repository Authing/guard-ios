//
//  PrivacyConfirmBox.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/24.
//

import UIKit

open class PrivacyConfirmBox: UIView, UITextViewDelegate {
    
    let size = 15.0
    
    let imageUnchecked = UIImage(named: "authing_checkbox_unchecked", in: Bundle(for: PrivacyConfirmBox.self), compatibleWith: nil)
    let imageChecked = UIImage(named: "authing_checkbox_checked", in: Bundle(for: PrivacyConfirmBox.self), compatibleWith: nil)
    let checkBox: UIButton = UIButton()
    let checkBoxImageView: UIImageView = UIImageView()
    let label: UITextView = UITextView()
    
    public var isChecked: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        isHidden = true
        addSubview(checkBoxImageView)
        addSubview(checkBox)
        addSubview(label)
        
        checkBoxImageView.image = imageUnchecked
        checkBoxImageView.translatesAutoresizingMaskIntoConstraints = false
        checkBoxImageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        checkBoxImageView.heightAnchor.constraint(equalToConstant: size).isActive = true
        checkBoxImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        checkBoxImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        
        checkBox.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        checkBox.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkBox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        checkBox.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        checkBox.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        label.delegate = self
        label.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        DispatchQueue.main.async() {
            Util.getConfig(self) { config in
                self._setup(config)
            }
        }
    }
    
    private func _setup(_ config: Config?) {
        let regBtn = Util.findView(self, viewClass: RegisterButton.self)
        let loginBtn = Util.findView(self, viewClass: LoginButton.self)
        
        var loc: Int = 0
        if (regBtn != nil) {
            loc = 1
        } else if (loginBtn != nil) {
            loc = 2
        }
        
        var shouldShow = false
        let lang = Util.getLangHeader()
        if let agreements = config?.agreements {
            for agreement in agreements {
                if (lang == agreement["lang"] as? String) {
                    let availableAt = agreement["availableAt"] as? Int
                    if (availableAt == nil) {
                        continue
                    }
                    if (availableAt! == 2 || (loc == 1 && availableAt! == 0) || (loc == 2 && availableAt! == 1)) {
                        if let title = agreement["title"] as? String {
                            let t = "<meta charset=\"utf-8\">\n" + title
                            let data = t.data(using: .utf8)!
                            let attributedString = try? NSAttributedString(
                                data: data,
                                options: [.documentType: NSAttributedString.DocumentType.html],
                                documentAttributes: nil)
                            self.label.attributedText = attributedString
                            shouldShow = true
                        }
                        break
                    }
                }
            }
        }
        
        if (shouldShow) {
            isHidden = false
        } else {
            constraints.forEach { constraint in
                if (constraint.firstAttribute == .height) {
                    self.heightAnchor.constraint(equalToConstant: 0).isActive = true
                }
            }
        }
    }
    
    @objc private func onClick(sender: UIButton) {
        isChecked = !isChecked
        if (isChecked) {
            checkBoxImageView.image = imageChecked
        } else {
            checkBoxImageView.image = imageUnchecked
        }
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        label.selectedTextRange = nil
    }
}
