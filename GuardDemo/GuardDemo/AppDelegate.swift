//
//  AppDelegate.swift
//  GuardDemo
//
//  Created by Lance Mao on 2021/11/23.
//

import UIKit
import Guard
import Wechat
import OneAuth
import AppAuth
import WeCom
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var window:UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        WechatLogin.registerApp(appId:"wx1cddb15e280c0f67", universalLink: "https://developer-beta.authing.cn/app/")
        WeCom.registerApp(appId: "wwauth803c38cb89ac1d57000002", corpId: "ww803c38cb89ac1d57", agentId: "1000002")
        OneAuth.bizId =  "74ae90bd84f74b69a88b578bbbbcdcfd"
        Authing.start("60caaf41df670b771fd08937");

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
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

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Authing.NotifyName.notify_wechat.rawValue), object: userActivity)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return WeCom.handleOpenURL(url: url)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
}

