//
//  SDKUsageTask.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/3.
//

import Foundation

class SDKUsageTask {
    static func report() {
        let uuid: String = Util.getDeviceID()
        let url:URL! = URL(string:"https://developer-beta.authing.cn/stats/sdk-trace/?appid=" + Authing.getAppId()
                           + "&sdk=ios&version=" + Const.SDK_VERSION
                           + "&ip=" + uuid)
        URLSession.shared.dataTask(with: url) { (objectData, response, error) in
            guard error == nil else {
                print("network error:\(error!.localizedDescription)")
                return
            }
        }.resume()
    }
}
