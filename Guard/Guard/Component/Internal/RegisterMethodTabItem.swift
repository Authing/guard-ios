//
//  RegisterMethodTabItem.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

public class RegisterMethodTabItem: MethodTabItem {
    override public func focusGained() {
        let containers: Array<RegisterContainer> = Util.findViews(self, viewClass: RegisterContainer.self)
        containers.forEach { container in
            if (container.type == self.type) {
                container.isHidden = false
                let errorLabel: ErrorLabel? = Util.findView(container, viewClass: ErrorLabel.self)
                if (errorLabel != nil) {
                    updateErrorLabelConstraints(label: errorLabel!, container: container)
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
}
