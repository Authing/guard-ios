//
//  TextFieldLayout.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/24.
//

open class TextFieldLayout: BaseInput, UITextFieldDelegate {
    
    let border = TextFieldBorder()
    let imageView = UIImageView()
    let paddingView = UIView()
    
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
        self.borderStyle = .none

        hintColor = Const.Color_Text_Default_Gray
        backgroundColor = Const.Color_BG_Text_Box
        layer.borderColor = Const.Color_BG_Text_Box.cgColor
        layer.borderWidth = 0
        layer.cornerRadius = 4
        autocapitalizationType = .none
//        addSubview(border)
            
        imageView.contentMode = .scaleAspectFit
        paddingView.addSubview(imageView)
        
        leftView = paddingView
        leftViewMode = .never
        clearButtonMode = .whileEditing
//        font = UIFont.systemFont(ofSize: 16)
    }
    
    public func updateIconImage(icon: UIImage) {
        imageView.image = icon
        leftViewMode = .always
        self.layoutSubviews()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = CGRect(x: -2, y: -2, width: frame.width + 4, height: frame.height + 4)
        let itemWidth: CGFloat = frame.height/3
        paddingView.frame = CGRect(x: 0, y: 0, width: itemWidth + 20, height: frame.height)
        imageView.frame = CGRect(x: 12, y: (frame.height - itemWidth)/2, width: itemWidth, height: itemWidth)
        border.setNeedsDisplay()
        
        tintClearImage()
    }

    private func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let _ = button.image(for: .highlighted) {
                    let image = UIImage(named: "authing_clear_button", in: Bundle(for: Self.self), compatibleWith: nil)
                    button.setImage(image, for: .normal)
                    button.setImage(image, for: .highlighted)
                }
            }
        }
    }

    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: self.frame.width - self.frame.height, y: 0, width: self.frame.height, height: self.frame.height)
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        border.setHighlight(true)
        layer.borderColor = Const.Color_Authing_Main.cgColor
        layer.borderWidth = 1
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        border.setHighlight(false)
        layer.borderColor = Const.Color_BG_Text_Box.cgColor
        layer.borderWidth = 0
    }
    
    public func setError(_ text: String?) {
        if let t = text, !Util.isNull(t) {
            layer.borderColor = Const.Color_Error.cgColor
            layer.borderWidth = 1
        } else if isFirstResponder {
            layer.borderColor = Const.Color_Authing_Main.cgColor
            layer.borderWidth = 1
        } else {
            layer.borderColor = Const.Color_BG_Text_Box.cgColor
            layer.borderWidth = 0
        }
    }
}
