//
//  MethodTab.swift
//  Guard
//
//  Created by Lance Mao on 2022/5/31.
//

open class MethodTab: UIScrollView {
    
    let ITEM_WIDTH: CGFloat = 120.0
    let highlightHeight = 2.0
    
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
        var i: CGFloat = 0
        items.forEach { item in
            let frame = CGRect(x: i * ITEM_WIDTH, y: 0, width: ITEM_WIDTH, height: frame.height)
            item.frame = frame
            i += 1
        }
        contentSize = CGSize(width: CGFloat(items.count) * ITEM_WIDTH, height: frame.height)
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
            highlight.frame = CGRect(x: v.frame.origin.x, y: frame.height - highlightHeight, width: v.frame.width, height: highlightHeight)
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
        
        UIView.animate(withDuration: 0.3) {
            if let v = self.focusedItem() {
                self.highlight.frame = CGRect(x: v.frame.origin.x, y: self.frame.height - self.highlightHeight, width: v.frame.width, height: self.highlightHeight)
            }
        }
        setNeedsLayout()
    }

}
