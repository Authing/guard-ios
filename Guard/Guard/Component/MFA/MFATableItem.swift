//
//  MFATableItem.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/10.
//

open class MFATableItem: UIView {
    
    enum MFAType {
        case phone
        case email
        case totp
        case face
    }
    
    let label = UILabel()
    
    var mfaType: MFAType? {
        didSet {
            if (mfaType == .phone) {
                label.text = "authing_mfa_verify_phone".L
            } else if (mfaType == .email) {
                label.text = "authing_mfa_verify_email".L
            } else if (mfaType == .totp) {
                label.text = "authing_mfa_verify_code".L
            } else if (mfaType == .face) {
                label.text = "authing_mfa_verify_face".L
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor(white: 0.9, alpha: 1)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)

        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        var vc: AuthViewController? = nil

        if (mfaType == .phone) {
            if let phone = Authing.getCurrentUser()?.mfaPhone {
                vc = AuthViewController(nibName: "AuthingMFAPhone1", bundle: Bundle(for: Self.self))
                vc?.authFlow?.data.setValue(phone, forKey: AuthFlow.KEY_MFA_PHONE)
            } else {
                vc = AuthViewController(nibName: "AuthingMFAPhone0", bundle: Bundle(for: Self.self))
            }
        } else if (mfaType == .email) {
            if let email = Authing.getCurrentUser()?.mfaEmail {
                vc = AuthViewController(nibName: "AuthingMFAEmail1", bundle: Bundle(for: Self.self))
                vc?.authFlow?.data.setValue(email, forKey: AuthFlow.KEY_MFA_EMAIL)
            } else {
                vc = AuthViewController(nibName: "AuthingMFAEmail0", bundle: Bundle(for: Self.self))
            }
        } else if (mfaType == .totp) {
            vc = AuthViewController(nibName: "AuthingMFAOTP", bundle: Bundle(for: Self.self))
        } else if (mfaType == .face) {
            vc = MFAFaceViewController.init()
            vc?.authFlow = authViewController?.authFlow?.copy() as? AuthFlow
        }
        self.authViewController?.navigationController?.pushViewController(vc!, animated: true)
    }
}
