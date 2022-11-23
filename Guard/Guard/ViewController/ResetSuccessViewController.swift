//
//  ResetSuccessViewController.swift
//  Guard
//
//  Created by JnMars on 2022/7/12.
//

import Foundation

class ResetSuccessViewController: AuthViewController {

    @IBOutlet var countdownLabel: Label!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "authing_reset_password_success".L
        
        var seconds = 6
        let timer : DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: 1.0)
        timer.setEventHandler {
            seconds -= 1
            if seconds == 0 {
                timer.cancel()
                if let button: GoBackButton = Util.findView(self.view, viewClass: GoBackButton.self){
                    button.sendActions(for: .touchUpInside)
                }
            } else {
                self.countdownLabel.text = String(format: "authing_reset_goback_auto".L, seconds)
            }
        }
        timer.resume()
    }
}
