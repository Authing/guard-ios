//
//  SDKUsageTask.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/3.
//

import UIKit

class SDKUsageTask {
    static func report() {
        DispatchQueue.global().async {
            let uuid: String = Util.getDeviceID()
            let modelIdentifier = UIDevice.modelIdentifier()
            let systemVersion = UIDevice.current.systemVersion
            if let escapedString = modelIdentifier.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                let urlString = "https://developer-beta.authing.cn/stats/sdk-trace/?appid=" + Authing.getAppId()
                + "&sdk=ios&version=" + Const.SDK_VERSION
                + "&ip=\(uuid)"
                + "&host=\(Authing.getHost())"
                + "&device=\(escapedString)"
                + "&os-version=\(systemVersion)"
                let url:URL! = URL(string: urlString)
                URLSession.shared.dataTask(with: url) { (objectData, response, error) in
                    guard error == nil else {
                        return
                    }
                }.resume()
            }
        }
    }
}
