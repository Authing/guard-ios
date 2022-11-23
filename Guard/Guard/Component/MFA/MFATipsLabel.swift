//
//  MFATipsLabel.swift
//  Guard
//
//  Created by mm on 2019/1/12.
//

import Foundation

class MFATipsLabel: Label {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let mfaPolicy = Authing.getCurrentUser()?.mfaPolicy?.first {
            if mfaPolicy == "SMS" {
                self.text = "authing_mfa_tips1".L
            } else if mfaPolicy == "EMAIL" {
                self.text = "authing_mfa_tips2".L
            } else if mfaPolicy == "OTP" {
                self.text = "authing_mfa_tips3".L
            } else if mfaPolicy == "FACE" {
                self.text = "authing_mfa_tips4".L
            }
        }
    }
}
