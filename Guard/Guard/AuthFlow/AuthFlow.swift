//
//  AuthFlow.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

import UIKit

public class AuthFlow {
    public static func start(nibName: String? = nil, authCompletion: AuthViewController.AuthCompletion? = nil) {
        var vc: AuthViewController? = nil
        if (nibName == nil) {
            let bundle = Bundle(for: Self.self)
            vc = AuthViewController(nibName: "AuthingLogin", bundle: bundle)
        } else {
            vc = AuthViewController(nibName: nibName, bundle: nil)
        }
        vc?.setAuthCompletion(authCompletion)
        
        vc!.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        UIApplication.topViewController()!.present(vc!, animated: true, completion: nil)
    }
}
