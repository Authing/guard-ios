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
    private var receiveCallBack: ((Int, String?) -> Void)?

    public func setRetryCount(_ count: Int) {
        retryCount = count
    }
    
    public func initWebSocket(urlString: String, completion: @escaping (Int, String?) -> Void) {
        self.receiveCallBack = completion
        self.urlString = urlString
        self.webSocketConnect(urlString: urlString)
    }
    
    private func webSocketConnect(urlString: String) {
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
                    self.receiveCallBack?(200, text)
                case .data(let data):
                    ALog.d(AuthingWebsocketClient.self, "\(data)")
                    self.receiveCallBack?(200, "\(data)")
                @unknown default:
                    fatalError()
                }
            case .failure(let error):
                ALog.e(AuthingWebsocketClient.self, error)
                self.receiveCallBack?((error as NSError).code, (error as NSError).debugDescription)
            }
        }
        
        self.sendPing()
    }
    
    public func cancel() {
        self.webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    
    func sendPing() {
        self.webSocketTask.sendPing { (error) in
            if let error = error {
                ALog.w(AuthingWebsocketClient.self, "Sending PING failed: \(error)")
                self.webSocketTask = nil
                self.webSocketConnect(urlString: self.urlString)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.sendPing()
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
