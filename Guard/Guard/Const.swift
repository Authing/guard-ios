//
//  Const.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/3.
//

typealias AuthCallback = (Int, String?, UserInfo?) -> Void

public class Const: NSObject {
    public static let SDK_VERSION: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.2.0"
    
    public static let Color_Authing_Main = UIColor(red: 0.224, green: 0.416, blue: 1, alpha: 1)
    public static let Color_Button_Pressed = UIColor(red: 0.039, green: 0.227, blue: 0.792, alpha: 1)
    public static let Color_Button_Disabled = UIColor(red: 0.573, green: 0.667, blue: 0.953, alpha: 1)
    public static let Color_Button_Gray = UIColor(red: 0.925, green: 0.941, blue: 0.945, alpha: 1)
    public static let Color_Text_Gray = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    public static let Color_Error = UIColor(red: 1, green: 0.31, blue: 0.31, alpha: 1)
    public static let Color_Asterisk = UIColor(red: 0.514, green: 0.094, blue: 0.153, alpha: 1)
    public static let Color_BG_Gray = UIColor(red: 0.937, green: 0.937, blue: 0.937, alpha: 1)
    public static let Color_Border_Gray = UIColor(red: 0.828, green: 0.856, blue: 0.888, alpha: 1)
    public static let Color_BG_Text_Box = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1)
    public static let Color_Text_Default_Gray = UIColor(red: 134.0/255.0, green: 144.0/255.0, blue: 156.0/255.0, alpha: 1.0)
    
    public static let ONEPX = 1 / UIScreen.main.scale
    
    public static let EC_MFA_REQUIRED = 1636;
    public static let EC_FIRST_TIME_LOGIN = 1639;
    
    public static let SCREEN_WIDTH = UIScreen.main.bounds.width
    public static let SCREEN_HEIGHT = UIScreen.main.bounds.height

}
