//
//  AuthingWebsocketClient.swift
//  Guard
//
//  Created by JnMars on 2023/2/27.
//

import Foundation

@available(iOS 13.0, *)

public class AuthingWebsocketClient: NSObject {
    private var webSocketTask: URLSessionWebSocketTask!
    private var urlString: String = ""
    private var retryCount: Int = 3
    private var retryTimes: Int = 0

    public func setRetryCount(_ count: Int) {
        retryCount = count
    }
    
    public func initWebSocket(urlString: String, completion: @escaping (String?) -> Void) {
        self.urlString = urlString
        guard let url = URL(string: urlString) else {
            ALog.e(AuthingWebsocketClient.self, "Error: can not create URL")
            return
        }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let request = URLRequest(url: url)
        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask.resume()
        
        webSocketTask.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    ALog.d(AuthingWebsocketClient.self, text)
                    completion(text)
                case .data(let data):
                    ALog.d(AuthingWebsocketClient.self, "\(data)")
                @unknown default:
                    fatalError()
                }
            case .failure(let error):
                ALog.e(AuthingWebsocketClient.self, error)
                completion(error.localizedDescription)
                self.retryTimes += 1
                self.reconnect(url: self.urlString, retryTimes: self.retryTimes)
            }
        }
    }
    
    public func reconnect(url: String, retryTimes: Int) {
        if retryTimes == retryCount {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.initWebSocket(urlString: url) { message in
            }
        }
    }
}

@available(iOS 13.0, *)
extension AuthingWebsocketClient: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession,
                           webSocketTask: URLSessionWebSocketTask,
                           didOpenWithProtocol protocol: String?) {
        ALog.d(AuthingWebsocketClient.self, "URLSessionWebSocketTask is connected")
    }
    public func urlSession(_ session: URLSession,
                           webSocketTask: URLSessionWebSocketTask,
                           didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                           reason: Data?) {
        let reasonString: String
        if let reason = reason, let string = String(data: reason, encoding: .utf8) {
            reasonString = string
        } else {
            reasonString = ""
        }
        ALog.e(AuthingWebsocketClient.self, "URLSessionWebSocketTask is closed: code=\(closeCode), reason=\(reasonString)")
    }
}
