//
//  SampleListViewController.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/11/23.
//

import UIKit
import Guard

class SampleListViewController: UITableViewController {
    let from = ["Authing 登录", "手机号一键登录", "AppAuth"]
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
            AuthFlow.start { [weak self] userInfo in
                self?.goHome(userInfo: userInfo)
            }
        } else if indexPath.row == 1 {
            let vc = OneClickViewController(nibName: "OneClick", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 2 {
            let vc = AppAuthViewController(nibName: "AppAuth", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func goHome(userInfo: UserInfo?) {
        let vc: MainViewController = MainViewController(nibName: "Home", bundle: nil)
        vc.userInfo = userInfo
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
