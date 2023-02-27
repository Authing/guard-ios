//
//  AuthingWebsocketClient.swift
//  Guard
//
//  Created by JnMars on 2023/2/27.
//

import Foundation

class AuthingWebsocketClient: WebSocketDelegate {
        
    public func initWebSocket(url: String, completion: @escaping (String?) -> Void) {
        var urlString: String = url
        var retryTimes: Int = 0
        if let url = URL.init(string: url) {
            let socket = WebSocket(request: URLRequest.init(url: url))
            socket.delegate = self
            socket.connect()
            socket.onEvent = { event in
                switch event {
                case .connected(let headers):
                    print("connected: \(headers)")
                    break
                case .disconnected(let reason, let code):
                    print("disconnected reason: \(reason), code: \(code)")
                    break
                case .text(let string):
                    completion(string)
                    break
                case .error(let error):
                    retryTimes += 1
                    self.reconnect(url: urlString, retryTimes: retryTimes)
                    print(error.debugDescription)
                    break
                default:
                    break
                }
            }
        }
    }
    
    public func reconnect(url: String, retryTimes: Int) {
        if retryTimes == 5 {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.initWebSocket(url: url) { message in
                print(message)
            }
        }
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        print(event)
        print(client)
    }
    
}
