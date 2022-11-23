//
//  CountdownTimerManager.swift
//  Guard
//
//  Created by JnMars on 2022/5/16.
//


public class CountdownTimerManager: NSObject {
    
    @objc public static let shared = CountdownTimerManager()
    private override init() {}
    var counter: Int = 60
    var timer: Timer!
    var verfyButton: LoadingButton!
    var appDidEnterBackgroundDate: Date?
    
    func createCountdownTimer(button: LoadingButton) {
        self.verfyButton = button
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
        
    @objc func updateCounter() {
        if counter > 0 {
            counter -= 1
            self.verfyButton.isUserInteractionEnabled = false
            if self.verfyButton.authViewController?.nibName == "AuthingMFAEmail1" ||
                self.verfyButton.authViewController?.nibName == "AuthingMFAPhone1"{
                self.verfyButton.setTitle("authing_get_verify_code".L + "（\(counter)）", for: .normal)
                self.verfyButton.setTitleColor(UIColor.init(hex: "#86909C"), for: .normal)
            } else {
                self.verfyButton.setTitle("  \(counter)  ", for: .normal)
                self.verfyButton.setTitleColor(UIColor.init(red: 29/255.0, green: 33/255.0, blue: 41/255.0, alpha: 1), for: .normal)
            }
        } else {
            self.invalidate()
        }
    }
    
    func invalidate() {
        if timer != nil{
            timer.invalidate()
            timer = nil
            counter = 60
            self.verfyButton.isUserInteractionEnabled = true
//            let text: String = "authing_get_verify_code".L
            self.verfyButton.setTitle("authing_verify_resend".L, for: .normal)
            self.verfyButton.setTitleColor(self.verfyButton.loadingColor, for: .normal)

            NotificationCenter.default.removeObserver(self)
        }
    }
                                               
    @objc func applicationDidEnterBackground(_ notification: NotificationCenter) {
        appDidEnterBackgroundDate = Date()
    }

    @objc func applicationWillEnterForeground(_ notification: NotificationCenter) {
        guard let previousDate = appDidEnterBackgroundDate else { return }
        let calendar = Calendar.current
        let difference = calendar.dateComponents([.second], from: previousDate, to: Date())
        let seconds = difference.second!
        counter -= seconds
        self.updateCounter()
    }
}
