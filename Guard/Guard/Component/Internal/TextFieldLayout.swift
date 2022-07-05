//
//  TextFieldLayout.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

open class TextFieldLayout: BaseInput, UITextFieldDelegate {
    
    let border = TextFieldBorder()
    let imageView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.delegate = self
        backgroundColor = Const.Color_BG_Text_Box
        layer.borderWidth = 1
        layer.cornerRadius = 4
        autocapitalizationType = .none
        layer.borderColor = Const.Color_BG_Text_Box.cgColor
//        addSubview(border)
        
        let itemWidth: CGFloat = frame.height/3
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: frame.height/3 + 8, height: frame.height))
    
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 8, y: (frame.height - itemWidth)/2, width: itemWidth, height: itemWidth)
        paddingView.addSubview(imageView)
        
        leftView = paddingView
        leftViewMode = .never
        clearButtonMode = .whileEditing
        font = UIFont.systemFont(ofSize: 16)
    }
    
    public func updateIconImage(icon: UIImage) {
        imageView.image = icon
        leftViewMode = .always
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = CGRect(x: -2, y: -2, width: frame.width + 4, height: frame.height + 4)
        border.setNeedsDisplay()
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        border.setHighlight(true)
        layer.borderColor = Const.Color_Authing_Main.cgColor
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        border.setHighlight(false)
        layer.borderColor = Const.Color_BG_Text_Box.cgColor
    }
    
    public func setError(_ text: String?) {
        if let t = text, !Util.isNull(t) {
            layer.borderColor = Const.Color_Error.cgColor
        } else if isFirstResponder {
            layer.borderColor = Const.Color_Authing_Main.cgColor
        } else {
            layer.borderColor = Const.Color_BG_Text_Box.cgColor
        }
    }
}
