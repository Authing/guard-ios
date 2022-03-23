//
//  UserInfoCompleteContainer.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/17.
//

import UIKit

open class UserInfoCompleteContainer: UIView {
    
    private let ITEM_TOP_SPACE: CGFloat = 16
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        Util.getConfig(self) { config in
            let missingFields: Array<NSDictionary> = AuthFlow.missingField(config: config, userInfo: Guard.getCurrentUser())
            if ((config?.completeFieldsPlace?.contains("login")) != nil && missingFields.count > 0) {
                let height = CGFloat(missingFields.count - 1) * self.ITEM_TOP_SPACE + self.getHeight(missingFields)
                self.constraints.first(where: {
                    $0.firstAttribute == .height
                })?.constant = height
            }
        }
        
        DispatchQueue.main.async() {
            self._setup()
        }
    }
    
    private func getHeight(_ missingFields: Array<NSDictionary>) -> CGFloat {
        var height: CGFloat = 0
        for f in missingFields {
            let form = getForm(f["inputType"] as? String)
            height += form.getHeight()
        }
        return height
    }
    
    private func getForm(_ inputType : String?) -> UserInfoCompleteFieldForm {
        if ("email" == inputType) {
            return UserInfoCompleteFieldEmail()
        } else if ("phone" == inputType) {
            return UserInfoCompleteFieldPhone()
        } else if ("select" == inputType) {
            return UserInfoCompleteFieldFormSelect()
        } else if ("datetime" == inputType) {
            return UserInfoCompleteFieldFormDateTime()
        } else {
            return UserInfoCompleteFieldFormText()
        }
    }
    
    private func _setup() {
        let vc: AuthViewController? = viewController
        if (vc == nil) {
            return
        }
        
        let missingFields: Array<NSDictionary>? = vc?.authFlow?.data[AuthFlow.KEY_EXTENDED_FIELDS] as? Array<NSDictionary>
        var i = 0, last: UIView? = nil
        let count = missingFields?.count ?? 0
        while (i < count) {
            let missingField: NSDictionary = missingFields![i]
            let form: UserInfoCompleteFieldForm = getForm(missingField["inputType"] as? String)
            form.setFormData(missingField)
            
            addSubview(form)
            
            form.translatesAutoresizingMaskIntoConstraints = false
            form.heightAnchor.constraint(equalToConstant: form.getHeight()).isActive = true
            form.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
            form.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
            if (i == 0) {
                form.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            } else {
                form.topAnchor.constraint(equalTo: last!.bottomAnchor, constant: ITEM_TOP_SPACE).isActive = true
            }
            
            last = form
            i += 1
        }

        if let scrollView: UIScrollView = Util.findView(self, viewClass: UIScrollView.self) {
            let contentView: UIView = scrollView.subviews[0]
            var lastH: CGFloat = 0
            var lastY: CGFloat = 0
            for sub: UIView in contentView.subviews {
                if (sub.frame.origin.y > lastY) {
                    lastY = sub.frame.origin.y
                    lastH = sub.frame.height
                }
            }
            contentView.frame = CGRect(x: contentView.frame.origin.x, y: contentView.frame.origin.y, width: contentView.frame.width, height: lastY + lastH)
            contentView.constraints.first(where: {
                $0.firstAttribute == .height
            })?.constant = lastY + lastH
            
            scrollView.contentSize = CGSize(width:contentView.frame.size.width, height: lastY + lastH + 32)
        }
    }
}
