//
//  UserProfileContainer.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/28.
//

open class UserProfileContainer: UIScrollView {
    
    let MARGIN_X = CGFloat(20)
    let TEXT_HEIGHT = CGFloat(52)
    let NOT_LOGIN_AVATAR_LENGTH = CGFloat(64)
    let BUTTON_HEIGHT = CGFloat(44)
    
    var userInfo: UserInfo?
    var fieldsViews = Array<UserProfileField>()
    
    @IBInspectable var fields: String = "all" {
        didSet {
            refreshUI()
        }
    }
    
    public let logoutButton = LogoutButton()
    public let deleteAccountButton = DeleteAccountButton()
    
    let accountImageView = UIImageView()
    let notLoginTip = UILabel()
    let startLoginButton = PrimaryButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        refreshUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        refreshUI()
    }

    open func refreshUI() {
        for v in subviews {
            v.removeFromSuperview()
        }
        
        fieldsViews.removeAll()
        
        if userInfo == nil {
            userInfo = Authing.getCurrentUser()
        }
        
        if userInfo != nil {
            if ("all" == fields) {
                addAvatarField()
                addTextField("nickname")
                addTextField("name")
                addTextField("username")
                addTextField("phone")
                addTextField("email")
            }
            
            if logoutButton.onLogout == nil {
                logoutButton.onLogout = { code, message in
                    self.refreshUI()
                }
            }
            
            if deleteAccountButton.onDeleteAccount == nil {
                deleteAccountButton.onDeleteAccount = { code, message in
                    self.refreshUI()
                }
            }
            addSubview(logoutButton)
            addSubview(deleteAccountButton)
        } else {
            accountImageView.image = UIImage(named: "authing_account", in: Bundle(for: Self.self), compatibleWith: nil)// (named: "authing_account", bun)
            addSubview(accountImageView)
            
            notLoginTip.textColor = UIColor.darkGray
            notLoginTip.font = UIFont.systemFont(ofSize: 14)
            notLoginTip.text = NSLocalizedString("authing_not_login", bundle: Bundle(for: Self.self), comment: "")
            addSubview(notLoginTip)
            
            startLoginButton.setTitleColor(UIColor.white, for: .normal)
            startLoginButton.layer.cornerRadius = 4
            startLoginButton.layer.masksToBounds = true
            startLoginButton.setTitle(NSLocalizedString("authing_login", bundle: Bundle(for: Self.self), comment: ""), for: .normal)
            startLoginButton.addTarget(self, action:#selector(startLogin(sender:)), for: .touchUpInside)
            addSubview(startLoginButton)
        }
    }
    
    private func addAvatarField() {
        let field = UserProfileAvatarField()
        field.userInfo = userInfo
        addSubview(field)
        fieldsViews.append(field)
        field.field = "photo"
    }
    
    private func addTextField(_ field: String) {
        let uptf = UserProfileTextField()
        uptf.userInfo = userInfo
        addSubview(uptf)
        fieldsViews.append(uptf)
        uptf.field = field
    }
    
    open override func layoutSubviews() {
        if userInfo != nil {
            var y = 0.0
            for v in fieldsViews {
                v.frame = CGRect(x: 0, y: y, width: frame.width, height: TEXT_HEIGHT)
                y += v.frame.height
            }
            
            y += 4
            logoutButton.frame = CGRect(x: 0, y: y, width: frame.width, height: BUTTON_HEIGHT)
            
            y += 4 + BUTTON_HEIGHT
            deleteAccountButton.frame = CGRect(x: 0, y: y, width: frame.width, height: BUTTON_HEIGHT)
        } else {
            var y = 80.0
            accountImageView.frame = CGRect(x: (frame.width - NOT_LOGIN_AVATAR_LENGTH) / 2, y: y, width: NOT_LOGIN_AVATAR_LENGTH, height: NOT_LOGIN_AVATAR_LENGTH)
            
            y += NOT_LOGIN_AVATAR_LENGTH + 8
            let labelWidth = notLoginTip.intrinsicContentSize.width
            notLoginTip.frame = CGRect(x: (frame.width - labelWidth) / 2, y: y, width: labelWidth, height: BUTTON_HEIGHT)
            
            y += BUTTON_HEIGHT + 8
            let btnW = 128.0
            startLoginButton.frame = CGRect(x: (frame.width - btnW) / 2, y: y, width: btnW, height: BUTTON_HEIGHT)
        }
    }
    
    @objc private func startLogin(sender: UIButton) {
        AuthFlow().start { code, message, userInfo in
            self.refreshUI()
        }
    }
}
