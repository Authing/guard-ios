//
//  GraphValidateCodeTextField.swift
//  Guard
//
//  Created by JnMars on 2023/3/8.
//

import Foundation

open class GraphValidateCodeTextField: TextFieldLayout {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        Util.getConfig(self) { config in
            if config?.appRobotVerify == "always_enable" {

            }
            self.isHidden = config?.appRobotVerify == "always_enable" ? false : true
        }
        
        let sVerifyCode: String = "authing_please_input_graph_verify_code".L
        setHint("\(sVerifyCode)")
    }

}
