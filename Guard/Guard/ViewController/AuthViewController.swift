//
//  AuthViewController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

open class AuthViewController: UIViewController {
    
//    public var authFlow: AuthFlow? = AuthFlow()
    
    public var authFlow: AuthFlow? = AuthFlow(){
        didSet {
            setupUI()
        }
    }
    
    public var hideNavigationBar: Bool = false
    open override func viewDidLoad() {
        super.viewDidLoad()
                                                     
        let backButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        backButton.setImage( UIImage(named: "authing_back", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
        
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // make navigation bar clear
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        // tap anywhere to dismiss keyboard
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(hideNavigationBar, animated: true)
//        let backImage = UIImage(named: "authing_back", in: Bundle(for: Self.self), compatibleWith: nil)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(onBack))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // make navigation bar clear
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        if Util.isGettingConfig(self.view) {
            let load = LoadingView.startAnimation()
            Util.getConfig(self.view) { config in
                LoadingView.stopAnimation(loadingView: load)
            }
        }
        
        let tf: AccountTextField? = Util.findView(view, viewClass: AccountTextField.self)
        if (tf != nil) {
            tf?.syncData()
        }
        
    }
    
    private func setupUI() {
        
        if let logo: AppLogo = Util.findView(view, viewClass: AppLogo.self),
           let title: AppName = Util.findView(view, viewClass: AppName.self) {
            if let mode = self.authFlow?.UIConfig?.contentMode, mode != .left{
                self.view.constraints.forEach({ constraint in
                    if (constraint.firstAttribute == .leading && constraint.firstItem as? UIView == logo) {
                        self.view.removeConstraint(constraint)
                    }
                    if (constraint.firstAttribute == .leading && constraint.firstItem as? UIView == title) {
                        self.view.removeConstraint(constraint)
                    }
                })
                if mode == .center {
                    logo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                    title.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                    title.textAlign = 1
                } else if mode == .right {
                    logo.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -24).isActive = true
                    title.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
                    title.textAlign = 2
                }
            }
        }
    }

    @IBAction func onCloseClick(_ sender: UIButton, forEvent event: UIEvent) {
        
        if (self.nibName == "AuthingLogin" ||
            self.nibName == "AuthingRegister") &&
            Authing.getCurrentUser()?.mfaToken != nil {
            Authing.saveUser(nil)
        }
        
        if authFlow?.transition == .Present {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func onBack(sender: UIButton) {
        
        if (self.nibName == "AuthingMFAPhone1" ||
            self.nibName == "AuthingMFAEmail1" ||
            self.nibName == "AuthingMFAOTP1" ||
            self.isKind(of: MFAFaceViewController.self)) &&
            self.authFlow?.mfaFromViewControllerName != "BindingMfaViewController" {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
