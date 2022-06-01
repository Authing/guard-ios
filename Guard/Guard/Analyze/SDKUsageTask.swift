//
//  SDKUsageTask.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/3.
//

import Foundation

class SDKUsageTask {
    static func report() {
        DispatchQueue.global().async {
            let uuid: String = Util.getDeviceID()
            let deviceName = UIDevice.modelName
            let systemVersion = UIDevice.current.systemVersion
            if let escapedString = deviceName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                let urlString = "https://developer-beta.authing.cn/stats/sdk-trace/?appid=" + Authing.getAppId()
                + "&sdk=ios&version=" + Const.SDK_VERSION
                + "&ip=\(uuid)"
                + "&device=\(escapedString)"
                + "&os-version=\(systemVersion)"
                let url:URL! = URL(string: urlString)
                URLSession.shared.dataTask(with: url) { (objectData, response, error) in
                    guard error == nil else {
                        ALog.w(SDKUsageTask.self, "network error:\(error!.localizedDescription)")
                        return
                    }
                }.resume()
            }
        }
    }
}
