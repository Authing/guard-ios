//
//  GoSomewhereButton.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

open class GoSomewhereButton: Button {
    
    open var target: String? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        fontSize = 15
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let text = getText()
        setTitle(text, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self._onClick(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc private func _onClick(_ sender: UITapGestureRecognizer? = nil) {
        ALog.d(Self.self, "Going somewhere")
        onClick()
    }
    
    func onClick() {
        if let page = target {
            Util.openPage(self, page)
        } else {
            goNow()
        }
    }
    
    func getText() -> String {
        return ""
    }
    
    func goNow() {
        
    }
    
    public override func setAttribute(key: String, value: String) {
        super.setAttribute(key: key, value: value)
        if ("target" == key) {
            target = value
        }
    }
}
