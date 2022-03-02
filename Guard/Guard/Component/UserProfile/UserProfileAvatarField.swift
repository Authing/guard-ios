//
//  UserProfileAvatarField.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/1.
//

import UIKit

open class UserProfileAvatarField: UserProfileField {
    
    let imageSize = CGFloat(40)
    
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
        addSubview(imageView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let w = imageSize
        imageView.frame = CGRect(x: frame.width - w - MARGIN_X, y: (frame.height - imageSize) / 2, width: w, height: imageSize)
    }
    
    override func setField(_ field: String) {
        super.setField(field)
        if let photo = Authing.getCurrentUser()?.raw?[field] as? String {
            if let url = URL(string: photo) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async() { [weak self] in
                            self?.imageView.image = UIImage(data: data)
                        }
                    }
                }
            }
        }
        self.layoutSubviews()
    }
}
