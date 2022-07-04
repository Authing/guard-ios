//
//  MethodTab.swift
//  Guard
//
//  Created by Lance Mao on 2022/5/31.
//

open class MethodTab: UIScrollView {
    
    let itemPadding: CGFloat = 12.0
    let highlightHeight = 1.0
    
    var items = [MethodTabItem]()
    let underLine = UIView() // fixed grey
    let highlight = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup(frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(self.frame)
    }

    private func setup(_ frame: CGRect) {
        isUserInteractionEnabled = true
        showsHorizontalScrollIndicator = false
        
        Util.getConfig(self) { config in
            if let c = config {
                self.doSetup(c)
                
                self.setItemFrame()
                
                self.underLine.backgroundColor = UIColor(white: 0.8, alpha: 1)
                self.addSubview(self.underLine)
                
                self.highlight.backgroundColor = Const.Color_Authing_Main
                self.addSubview(self.highlight)
                
                for item in self.items {
                    let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onClick))
                    gesture.numberOfTapsRequired = 1
                    item.addGestureRecognizer(gesture)
                }
            }
        }
    }
    
    func doSetup(_ config: Config) {
        
    }
    
    private func setItemFrame() {
        var x: CGFloat = 0
        var i = 0
        items.forEach { item in
            let w = item.content.intrinsicContentSize.width
            if i == 0 {
                item.frame = CGRect(x: x, y: 0, width: w + itemPadding, height: frame.height)
                item.content.frame = CGRect(x: 0, y: 0, width: w, height: item.frame.height-2)
                x += w + itemPadding
            } else {
                item.frame = CGRect(x: x, y: 0, width: w + 2 * itemPadding, height: frame.height)
                item.content.frame = CGRect(x: itemPadding, y: 0, width: w, height: item.frame.height-2)
                x += w + 2 * itemPadding
            }
            i += 1
        }
        contentSize = CGSize(width: x, height: frame.height)
    }
    
    private func focusedItem() -> MethodTabItem? {
        for item in items {
            if item.isFocused() {
                return item
            }
        }
        return nil
    }
    
    open override func layoutSubviews() {
        if let v = focusedItem() {
            let x = v.content.frame.origin.x
            let w = v.content.frame.width
            highlight.frame = CGRect(x: v.frame.origin.x + x, y: frame.height - highlightHeight, width: w, height: highlightHeight)
        }
        
        let underLineHeight = 1 / UIScreen.main.scale
        underLine.frame = CGRect(x: 0, y: frame.height - underLineHeight, width: frame.width, height: underLineHeight)
    }
    
    @objc private func onClick(sender: UITapGestureRecognizer) {
        Util.setError(self, nil)
        var lastFocused: MethodTabItem?
        items.forEach { item in
            if (item.isFocused()) {
                lastFocused = item
            }
            item.loseFocus()
        }
        (sender.view as? MethodTabItem)?.gainFocus(lastFocused: lastFocused)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            if let v = self.focusedItem() {
                let x = v.content.frame.origin.x
                let w = v.content.frame.width
                self.highlight.frame = CGRect(x: v.frame.origin.x + x, y: self.frame.height - self.highlightHeight, width: w, height: self.highlightHeight)
            }
        }, completion: nil)
        
        setNeedsLayout()
    }

}
