//
//  MFABindSuccessViewController.swift
//  Guard
//
//  Created by mm on 2019/1/12.
//

import Foundation

public enum BindSuccessType {
    case otp
    case phone
    case email
    case face
    case webauthn
}

open class MFABindSuccessViewController: AuthViewController {
    
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var faceView: UIView!
    @IBOutlet var webAuthnView: UIView!
    @IBOutlet var webAuthnContent: UILabel!
    
    @IBOutlet weak var recoveryCodeLabel: UILabel!
    
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var loginButton: PrimaryButton!
    
    public var type: BindSuccessType = .otp
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Util.getGrayBackgroundColor()
        
        title = "authing_mfa_bind_result".L
        
        loginButton.textValue = self.authFlow?.mfaFromViewControllerName == "BindingMfaViewController" ? "authing_bind_goback".L : "authing_login".L
        
        if type == .otp {
            
            self.recoveryCodeLabel.text = self.authFlow?.mfaRecoveryCode
            self.successView.isHidden = true
            self.faceView.isHidden = true
            self.webAuthnView.isHidden = true
            
        } else if type == .face {
            
            self.successView.isHidden = true
            self.otpView.isHidden = true
            self.webAuthnView.isHidden = true

        } else if type == .webauthn {
            
            self.successView.isHidden = true
            self.otpView.isHidden = true
            self.faceView.isHidden = true
            self.webAuthnContent.text = String(format: "authing_webauthn_success".L, Authing.getCurrentUser()?.getDisplayName() ?? "")
        } else {
            
            title = type == .phone ? "authing_bind_phone".L : "authing_bind_email".L
            self.otpView.isHidden = true
            self.faceView.isHidden = true
            self.webAuthnView.isHidden = true

        }
        
        if self.authFlow?.mfaFromViewControllerName == "BindingMfaViewController" || self.type == .otp {
            self.countDownLabel.isHidden = true
        } else {
            var seconds = 4
            let timer : DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            timer.schedule(deadline: .now(), repeating: 1.0)
            timer.setEventHandler {
                seconds -= 1
                if seconds == 0 {
                    timer.cancel()
                    self.onBack(sender: UIButton())
                } else {
                    self.countDownLabel.text = String(format: "authing_reset_goback_auto".L, seconds)
                }
            }
            timer.resume()
        }

        
    }
    
    override func onBack(sender: UIButton) {
        if let flow = self.authFlow {
            flow.complete(200, "", Authing.getCurrentUser())
        }
    }
    
    @IBAction func copyButtonClick(_ sender: Any) {
        UIPasteboard.general.string = self.recoveryCodeLabel.text
        Toast.show(text: "复制成功")
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        if let flow = self.authFlow {
            flow.complete(200, "", Authing.getCurrentUser())
        }
    }
    @IBAction func webAuthnDoneButtonClick(_ sender: Any) {
        if let flow = self.authFlow {
            flow.complete(200, "", Authing.getCurrentUser())
        }
    }
}
