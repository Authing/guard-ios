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
                container.isHidden = false

                if let errorLabel = Util.findView(container, viewClass: ErrorLabel.self) as? ErrorLabel{
                    updateErrorLabelConstraints(label: errorLabel, container: container)
                }
                
                if let extendFieldTextField = Util.findView(self, viewClass: ExtendFieldTextField.self) as? ExtendFieldTextField,
                   let field = self.extendField,
                   let text = self.fieldText {
                    extendFieldTextField.setExtendField(field, text)
                }
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
