//
//  SampleListViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/11/23.
//

import UIKit
import Guard

class SampleListViewController: UITableViewController {

    let from = ["Authing 登录",
                "手机号一键登录",
                "MFA",
                "用户信息补全",
                "WebView",
                "AppAuth",
                "OIDCClient",
                "HCML Parser"]

    let reuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return from.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)!
        cell.textLabel?.text = from[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch from[indexPath.row] {
        case "Authing 登录":
            AuthFlow("60caaf41df670b771fd08937").start { [weak self] code, message, userInfo in
                self?.goHome(userInfo: userInfo)
            }
            return
        case "手机号一键登录":
                let vc = OneClickViewController(nibName: "OneClick", bundle: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            return
        case "MFA":
                AuthFlow("61c173ada0e3aec651b1a1d1").start { [weak self] code, message, userInfo in
                    self?.goHome(userInfo: userInfo)
                }
            return
        case "用户信息补全":
            AuthFlow("61ae0c9807451d6f30226bd4").start { [weak self] code, message, userInfo in
                self?.goHome(userInfo: userInfo)
            }
            return
        case "WebView":
            let vc = WebViewController()
            vc.authFlow?.skipConsent = true
            self.navigationController?.pushViewController(vc, animated: true)
            return
        case "AppAuth":
            let vc = AppAuthViewController(nibName: "AppAuth", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
            return
        case "OIDCClient":
            let flow = AuthFlow("60caaf41df670b771fd08937")
            flow.authProtocol = .EOIDC
            flow.start()  { [weak self] code, message, userInfo in
                self?.goHome(userInfo: userInfo)
            }
            return
        case "HCML Parser":
            AuthFlow().startAppBundle("62345c87ffe7c884acbae53c") { [weak self] code, message, userInfo in
                self?.goHome(userInfo: userInfo)
            }                
            return
        default:
            return
        }
    }
    
    private func goHome(userInfo: UserInfo?) {
        let vc = MainViewController(nibName: "AuthingUserProfile", bundle: Bundle(for: UserProfileViewController.self))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
