//
//  LoginMethodTabItem.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

public class LoginMethodTabItem: MethodTabItem {
    override public func focusGained() {
        let containers: Array<LoginContainer> = Util.findViews(self, viewClass: LoginContainer.self)
        containers.forEach { container in
            
            if container.type == self.type {
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
            
            if container.type == 1 && container.isHidden == false{

                Util.getConfig(self) { config in
                    if config?.appRobotVerify == "always_enable" {
                        container.constraints.forEach({ constraint in
                            if (constraint.firstAttribute == .height) {
                                container.removeConstraint(constraint)
                            }
                        })
                        container.heightAnchor.constraint(equalToConstant: 188).isActive = true
                    }
                }
            }
        }

        
        Util.getConfig(self) { config in
            
            if let loginButton: LoginButton = Util.findView(self, viewClass: LoginButton.self) as? LoginButton {
                let loginText = "authing_login".L
                
                //phone-code
                if self.type == 0 {
                    if (config?.verifyCodeValidRegisterMethods?.contains("phone-code") ?? false) &&
                        (config?.verifyCodeValidLoginMethods?.contains("phone-code") ?? false) {
                        loginButton.setTitle(self.getLoginButtonTitle(config: config), for: .normal)
                    } else {
                        loginButton.setTitle(loginText, for: .normal)
                    }
                } else if self.type == 1 {
                    //password
                    if config?.passwordValidRegisterMethods?.count != config?.passwordValidLoginMethods?.count {
                        loginButton.setTitle(loginText, for: .normal)
                    } else {
                        loginButton.setTitle(self.getLoginButtonTitle(config: config), for: .normal)
                    }
                            
                } else if self.type == 2 {
                    //email-code
                    if (config?.verifyCodeValidRegisterMethods?.contains("email-code") ?? false) &&
                        (config?.verifyCodeValidLoginMethods?.contains("email-code") ?? false) {
                        loginButton.setTitle(self.getLoginButtonTitle(config: config), for: .normal)
                    } else {
                        loginButton.setTitle(loginText, for: .normal)
                    }
                } else {
                    loginButton.setTitle(self.getLoginButtonTitle(config: config), for: .normal)
                }
            }
        }
    }
    
    private func getLoginButtonTitle(config: Config?) -> String {
        if config?.autoRegisterThenLoginHintInfo ?? false &&
            !(config?.registerDisabled == true ||
              config?.registerMethods == nil ||
              config?.registerMethods?.count == 0) {
            
            return "\("authing_login".L) / \("authing_register".L)"
        } else {
            return "authing_login".L
        }
    }
}
