//
//  AuthViewController.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

open class AuthViewController: UIViewController {
    
    public var authFlow: AuthFlow? = AuthFlow()
    public var isPresent = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)

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
        
        navigationController?.setNavigationBarHidden(false, animated: true)
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

    @IBAction func onCloseClick(_ sender: UIButton, forEvent event: UIEvent) {
        if isPresent == true {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func onBack(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
