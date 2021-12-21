//
//  Guardian.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/3.
//

import Foundation

public class Guardian {
    
    public static func get(urlString: String, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        request(urlString: urlString, method: "GET", body: nil, completion: completion)
    }
    
    public static func post(urlString: String, body: NSDictionary?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        request(urlString: urlString, method: "POST", body: body, completion: completion)
    }
    
    private static func request(urlString: String, method: String, body: NSDictionary?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        Authing.getConfig { config in
            request(config: config, urlString: urlString, method: method, body: body, completion: completion)
        }
    }
    
    public static func request(config: Config?, urlString: String, method: String, body: NSDictionary?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        let url:URL! = URL(string:urlString)
        var request = URLRequest(url: url)
        request.httpMethod = method
        if (method == "POST") {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let httpBody = try? JSONSerialization.data(withJSONObject: body!, options: [])
            if (httpBody != nil) {
                request.httpBody = httpBody
            }
        }
        if (config != nil && config?.userPoolId != nil) {
            request.addValue((config?.userPoolId)!, forHTTPHeaderField: "x-authing-userpool-id")
        }
        request.addValue(Authing.getAppId(), forHTTPHeaderField: "x-authing-app-id")
        request.addValue("Guard@iOS@" + Const.SDK_VERSION, forHTTPHeaderField: "x-authing-request-from")
        request.addValue(Util.getLangHeader(), forHTTPHeaderField: "x-authing-lang")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Guardian request network error:\(error!.localizedDescription)")
                completion(500, error!.localizedDescription, nil)
                return
            }
            
            guard data != nil else {
                print("data is null when requesting \(urlString)")
                completion(500, "no data from server", nil)
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary else {
                    print("data is not json when requesting \(urlString)")
                    completion(500, "only accept json data", nil)
                    return
                }
                
                let httpResponse = response as? HTTPURLResponse
                let statusCode: Int = (httpResponse?.statusCode)!
                guard statusCode == 200 || statusCode == 201 else {
                    print("Guardian request network error. Status code:" + statusCode.description)
                    completion(statusCode, "Network Error", json)
                    return
                }
                
                if (json["code"] as? Int == nil) {
                    completion(200, nil, json)
                } else {
                    let code: Int = json["code"] as! Int
                    let message: String? = json["message"] as? String
                    let jsonData: NSDictionary? = json["data"] as? NSDictionary
                    completion(code, message, jsonData)
                }
            } catch {
                print("parsing json error when requesting \(urlString)")
                completion(500, urlString, nil)
            }
        }.resume()
    }
}
