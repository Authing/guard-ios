//
//  GraphValidateCodeTextField.swift
//  Guard
//
//  Created by JnMars on 2023/3/8.
//

import Foundation

open class GraphValidateCodeTextField: TextFieldLayout {
    
    private var needInput: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let sVerifyCode: String = "authing_please_input_graph_verify_code".L
        setHint("\(sVerifyCode)")
    }
    
    public func setNeedInput(need: Bool) {
        self.needInput = need
    }
    
    public func getNeedInput() -> Bool {
        return self.needInput
    }
    
}
