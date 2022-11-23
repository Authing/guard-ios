//
//  MFATableItem.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/10.
//

open class MFATableItem: UIView {
    
    enum MFAType: String {
        case phone = "SMS"
        case email = "EMAIL"
        case totp = "OTP"
        case face = "FACE"
    }
    
    let label = UILabel()
    let imageview = UIImageView()
    
    var mfaType: MFAType? {
        didSet {
            if (mfaType == .phone) {
                imageview.image = UIImage(named: "authing_mfa_phone", in: Bundle(for: Self.self), compatibleWith: nil)
            } else if (mfaType == .email) {
                imageview.image = UIImage(named: "authing_mfa_email", in: Bundle(for: Self.self), compatibleWith: nil)
            } else if (mfaType == .totp) {
                imageview.image = UIImage(named: "authing_mfa_otp", in: Bundle(for: Self.self), compatibleWith: nil)
            } else if (mfaType == .face) {
                imageview.image = UIImage(named: "authing_mfa_face", in: Bundle(for: Self.self), compatibleWith: nil)
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        
        addSubview(imageview)
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        imageview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        imageview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        imageview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        let vc = LoginButton.mfaHandle(view: self, mfaType: self.mfaType?.rawValue ?? "", needGuide: false)
        self.authViewController?.navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
}
