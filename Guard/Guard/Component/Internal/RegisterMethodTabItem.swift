//
//  RegisterMethodTabItem.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

public class RegisterMethodTabItem: MethodTabItem {
    
    var extendField: String?
    var fieldText: String?
    
    override public func focusGained() {
        let containers: Array<RegisterContainer> = Util.findViews(self, viewClass: RegisterContainer.self)
        containers.forEach { container in
            if (container.type == self.type) {
                if let privacyBox = Util.findHiddenView(self, viewClass: PrivacyConfirmBox.self) as? PrivacyConfirmBox{
                    privacyBox.superview?.constraints.forEach({ constraint in
                        if (constraint.firstAttribute == .top && constraint.firstItem as? UIView == privacyBox) {
                            privacyBox.superview?.removeConstraint(constraint)
                        }
                    })
                    privacyBox.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 16).isActive = true
                }
                    
                container.isHidden = false
                
            } else {
                container.isHidden = true
            }
            
        }
    }
    
    private func updateErrorLabelConstraints(label: ErrorLabel, container: RegisterContainer) {
        
        label.superview?.constraints.forEach({ constraint in
            if (constraint.firstAttribute == .top && constraint.firstItem as? UIView == label) {
                label.superview?.removeConstraint(constraint)
            }
        })
        label.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 8).isActive = true
    }
    
    public func setExtendField(_ extendField: String, _ fieldText: String) {
        self.extendField = extendField
        self.fieldText = fieldText
    }
    
}
