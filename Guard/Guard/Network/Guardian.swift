//
//  Guardian.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/3.
//

import UIKit

public class Guardian {
    
    public static func get(_ endPoint: String, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        request(endPoint: endPoint, method: "GET", body: nil, completion: completion)
    }
    
    public static func post(_ endPoint: String, _ body: NSDictionary?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {        request(endPoint: endPoint, method: "POST", body: body, completion: completion)
    }
    
    public static func delete(_ endPoint: String, _ body: NSDictionary? = nil, completion: @escaping (Int, String?, NSDictionary?) -> Void) {        request(endPoint: endPoint, method: "DELETE", body: body, completion: completion)
    }
    
    private static func request(endPoint: String, method: String, body: NSDictionary?, completion: @escaping (Int, String?, NSDictionary?) -> Void) {
        Authing.getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))\(endPoint)";
                request(config: config, urlString: urlString, method: method, body: body, completion: completion)
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())", nil)
            }
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
        if let currentUser = Authing.getCurrentUser() {
            if let token = currentUser.idToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else if let mfaToken = currentUser.mfaToken {
                request.addValue("Bearer \(mfaToken)", forHTTPHeaderField: "Authorization")
            }
        }
        request.timeoutInterval = 60
        request.addValue(Authing.getAppId(), forHTTPHeaderField: "x-authing-app-id")
        request.addValue("guard-ios", forHTTPHeaderField: "x-authing-request-from")
        request.addValue(Const.SDK_VERSION, forHTTPHeaderField: "x-authing-sdk-version")
        request.addValue(Util.getLangHeader(), forHTTPHeaderField: "x-authing-lang")
        
        request.httpShouldHandleCookies = false
        
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
                let httpResponse = response as? HTTPURLResponse
                let statusCode: Int = (httpResponse?.statusCode)!
                
                // some API e.g. getCustomUserData returns json array
                if (statusCode == 200 || statusCode == 201) {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSArray {
                        let res: NSDictionary = ["result": jsonArray]
                        completion(200, "", res)
                        return
                    }
                }
                
                guard let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary else {
                    print("data is not json when requesting \(urlString)")
                    completion(500, "only accept json data", nil)
                    return
                }
                
                guard statusCode == 200 || statusCode == 201 else {
                    print("Guardian request network error. Status code:\(statusCode.description). url:\(urlString)")
                    let message: String? = json["message"] as? String
                    completion(statusCode, message ?? "Network Error", json)
                    return
                }
                
                if (json["code"] as? Int == nil) {
                    completion(200, nil, json)
                } else {
                    let code: Int = json["code"] as! Int
                    let message: String? = json["message"] as? String
                    let jsonData: NSDictionary? = json["data"] as? NSDictionary
                    if (jsonData == nil) {
                        let result = json["data"]
                        if (result == nil) {
                            completion(code, message, nil)
                        } else {
                            completion(code, message, ["data": result!])
                        }
                    } else {
                        completion(code, message, jsonData)
                    }
                }
            } catch {
                print("parsing json error when requesting \(urlString)")
                completion(500, urlString, nil)
            }
        }.resume()
    }
    
    public static func uploadImage(_ image: UIImage, completion: @escaping (Int, String?) -> Void) {
        Authing.getConfig { config in
            if (config != nil) {
                let urlString: String = "\(Authing.getSchema())://\(Util.getHost(config!))/api/v2/upload?folder=photos";
                _uploadImage(urlString, image, completion: completion)
            } else {
                completion(500, "Cannot get config. app id:\(Authing.getAppId())")
            }
        }
    }
    
    private static func _uploadImage(_ urlString: String, _ image: UIImage, completion: @escaping (Int, String?) -> Void) {
        let url = URL(string: urlString)
        let boundary = UUID().uuidString
        let session = URLSession.shared
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"aPhone\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            guard error == nil else {
                completion(500, "network error \(url!)")
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
            guard jsonData != nil else {
                completion(500, "response not json \(url!)")
                return
            }
            
            guard let json = jsonData as? [String: Any] else {
                completion(500, "illegal json \(url!)")
                return
            }
            
            guard let code = json["code"] as? Int else {
                completion(500, "no response code \(url!)")
                return
            }
            
            guard code == 200 else {
                completion(code, json["message"] as? String)
                return
            }
            
            guard let data = json["data"] as? NSDictionary else {
                completion(500, "no response data \(url!)")
                return
            }
            
            if let u = data["url"] as? String {
                completion(200, u)
            } else {
                completion(500, "response data has no url field \(url!)")
                return
            }
        }).resume()
    }
}
