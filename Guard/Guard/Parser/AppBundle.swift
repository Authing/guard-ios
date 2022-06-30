//
//  Bundle.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/22.
//

open class AppBundle {
    open var appId: String?
    open var rootDir: URL?
    open var name: String?
    open var versionCode: Int = 1
    open var versionName: String?
    open var indexView: UIView?
    open var mainColor: String?
    
    public init() {
    }
}
