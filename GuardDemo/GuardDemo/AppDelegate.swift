//
//  AppDelegate.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/11/23.
//

import UIKit
import Guard
import OneAuth
import AppAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var currentAuthorizationFlow: OIDExternalUserAgentSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        OneAuth.bizId = "74ae90bd84f74b69a88b578bbbbcdcfd"
        Authing.setupWechat("wx1cddb15e280c0f67", universalLink: "https://developer-beta.authing.cn/")
        Authing.start(appid: "60caaf41df670b771fd08937");
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Authing.handleOpen(url: url)
        return true
    }
}

