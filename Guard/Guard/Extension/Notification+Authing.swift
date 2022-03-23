//
//  Notification+Authing.swift
//  social
//
//  Created by JnMars on 2022/3/22.
//

import Foundation

extension NotificationCenter {
    class func addObserver(_ observer: Any, selector aSelector: Selector, name aName: Guard.NotifyName, object anObject: Any?) {
        let name = Notification.Name.init(aName.rawValue)
        NotificationCenter.default.addObserver(observer, selector: aSelector, name: name, object: anObject)
    }
    
    class func post(name aName: Guard.NotifyName, object anObject: Any?) {
        let name = Notification.Name.init(aName.rawValue)
        NotificationCenter.default.post(name: name, object: anObject)
    }
    
    class func post(name aName: Guard.NotifyName, object anObject: Any?, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        let name = Notification.Name.init(aName.rawValue)
        NotificationCenter.default.post(name: name, object: anObject, userInfo: aUserInfo)
    }
}
