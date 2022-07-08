//
//  FeedBackButton.swift
//  Guard
//
//  Created by JnMars on 2022/7/8.
//

import Foundation

open class FeedBackButton: PrimaryButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let loginText = "authing_submit".L
        self.setTitle(loginText, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        
        var account: String = ""
        var type: Int = 0
        var describe: String?
        var imageUrls: [String] = []
        if let issueType: FeedBackIssuePicker = Util.findView(self, viewClass: FeedBackIssuePicker.self) {
            type = issueType.selectType
        }
        if let at: AccountTextField = Util.findView(self, viewClass: AccountTextField.self) {
            if at.text != nil && at.text != ""{
                account = at.text ?? ""
            } else {
                Util.setError(self, "authing_feedback_error".L)
                return
            }
        }
        if let des: DescribeTextView = Util.findView(self, viewClass: DescribeTextView.self) {
            describe = des.text
        }
        
        let dispatchGroup = DispatchGroup()
        let dispathcQueue = DispatchQueue.global()
        
        startLoading()

        if let picker: ImagePickerView = Util.findView(self, viewClass: ImagePickerView.self) {
                        
            for image in picker.items {
                dispatchGroup.enter()
                dispathcQueue.async{
                    AuthClient().uploadImage(image) { code, message in
                        dispatchGroup.leave()
                        if code == 200 {
                            imageUrls.append(message ?? "")
                        } else {
                            self.stopLoading()
                            Util.setError(self, message)
                        }
                    }
                }
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            AuthClient().feedBack(contact: account, type: type, description: describe ?? "", images: imageUrls) { code, message in
                self.stopLoading()
                if code == 200 {
                    DispatchQueue.main.async() {
                        self.viewController?.navigationController?.popViewController(animated: true)
                    }
                } else {
                    Util.setError(self, message)
                }
            }
        }
    }
}
