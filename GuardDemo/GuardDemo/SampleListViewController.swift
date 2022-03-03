//
//  SampleListViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/11/23.
//

import UIKit
import Guard

class SampleListViewController: UITableViewController {
    let from = ["Authing 登录", "手机号一键登录", "MFA", "用户信息补全", "WebView", "AppAuth"]
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
        if indexPath.row == 0 {
            let authFlow = AuthFlow.start { [weak self] userInfo in
                self?.goHome(userInfo: userInfo)
            }
//            authFlow?.resetPasswordFirstTimeLoginXibName = "Test"
//            AuthFlow.showUserProfile()
        } else if indexPath.row == 1 {
            let vc = OneClickViewController(nibName: "OneClick", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 2 {
            Authing.start("61c173ada0e3aec651b1a1d1")
            AuthFlow.start { [weak self] userInfo in
                self?.goHome(userInfo: userInfo)
            }
        } else if indexPath.row == 3 {
            Authing.start("61ae0c9807451d6f30226bd4")
            AuthFlow.start { [weak self] userInfo in
                self?.goHome(userInfo: userInfo)
            }
        } else if indexPath.row == 4 {
            let vc = WebViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 5 {
            let vc = AppAuthViewController(nibName: "AppAuth", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func goHome(userInfo: UserInfo?) {
        let vc = MainViewController(nibName: "AuthingUserProfile", bundle: Bundle(for: UserProfileViewController.self))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
