//
//  UserProfileTextField.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/28.
//

open class UserProfileTextField: UserProfileField {
    
    let HEIGHT = CGFloat(52)
    let labelValue: UILabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        labelValue.textColor = Util.getLabelColor()
        addSubview(labelValue)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let w = labelValue.intrinsicContentSize.width
        labelValue.frame = CGRect(x: frame.width - w - MARGIN_X, y: 0, width: w, height: HEIGHT)
    }
    
    override func setField(_ field: String) {
        super.setField(field)
        let undefined = NSLocalizedString("authing_undefined", bundle: Bundle(for: Self.self), comment: "")
        labelValue.text = userInfo?.raw?[field] as? String ?? undefined
        self.layoutSubviews()
    }
}
