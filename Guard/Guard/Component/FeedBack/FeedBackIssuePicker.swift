//
//  FeedBackIssuePicker.swift
//  Guard
//
//  Created by JnMars on 2022/7/7.
//

import Foundation

open class FeedBackIssuePicker: TextFieldLayout {
    
    public var items = ["authing_cannot_get_verify_code".L,
                 "authing_cannot_login".L,
                 "authing_cannot_register".L,
                 "authing_lost_account".L,
                 "authing_cannot_reset_password".L,
                 "authing_account_is_locked".L,
                 "authing_other".L]
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        self.text = items.first
        textColor = Const.Color_Text_Gray
        
        let pullDownImageView = UIImageView.init(image: UIImage.init(named: "authing_pull", in: Bundle(for: Self.self), compatibleWith: nil))
        pullDownImageView.contentMode = .scaleAspectFit
        pullDownImageView.frame = CGRect(x: self.frame.width - 35, y: self.frame.height / 2 - 7.5, width: 15, height: 15)
        self.addSubview(pullDownImageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {

        let otherBtns: [String] = items
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "authing_cancel".L, style: .cancel, handler:{ (action) -> Void in
            
        })
        alertController.addAction(cancelAction)
        for (_, value) in (otherBtns.enumerated()) {
            let otherAction = UIAlertAction(title: value, style: .`default`, handler: { (action) in
                self.text = action.title
            })
            alertController.addAction(otherAction)
        }
        self.viewController?.present(alertController, animated: true, completion: nil)
    }
}
