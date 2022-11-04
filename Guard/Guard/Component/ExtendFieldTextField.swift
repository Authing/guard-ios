//
//  ExtendFieldTextField.swift
//  Guard
//
//  Created by JMars on 2021/12/24.
//

public class ExtendFieldTextField: AccountTextField {
    public var extendField: String?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func setup() {
        super.setup()
//        Util.getConfig(self) { config in
//            self.keyboardType = .default
//        }
    }
    
    public func setExtendField(_ field: String, _ text: String) {
        
        self.extendField = field
        let sInput: String = "authing_please_input".L
        self.setHint("\(sInput)\(text)")
    }
}
