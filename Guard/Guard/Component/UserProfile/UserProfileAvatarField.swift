//
//  UserProfileAvatarField.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/1.
//

import UIKit

open class UserProfileAvatarField: UserProfileField, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let imageSize = CGFloat(40)
    
    let imageView = UIImageView()
    let loading = UIActivityIndicatorView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        imageView.layer.cornerRadius = 6.0
        imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.addSubview(loading)
        loading.startAnimating()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let w = imageSize
        imageView.frame = CGRect(x: frame.width - w - MARGIN_X, y: (frame.height - imageSize) / 2, width: w, height: imageSize)
        loading.frame = CGRect(x: 0, y: 0, width: w, height: imageSize)
    }
    
    override func setField(_ field: String) {
        super.setField(field)
        
        defer {
            loading.stopAnimating()
            self.layoutSubviews()
        }
        
        guard let user = userInfo, let uid = user.userId else {
            return
        }
        
        if let image = CacheManager.getImage(uid) {
            self.imageView.image = image
        }
        
        if let photo = user.photo,
           let url = URL(string: photo) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async() { [weak self] in
                        if let image = UIImage(data: data) {
                            self?.imageView.image = image
                            CacheManager.putImage(uid, image)
                        }
                    }
                }
            }
        } else {
            imageView.image = UIImage(named: "authing_default_user_avatar", in: Bundle(for: Self.self), compatibleWith: nil)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.authViewController?.present(picker, animated: true, completion: nil)
        } else {
            print("read photo library error")
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            loading.startAnimating()
            Util.getAuthClient(self).uploadAvatar(image: image) { code, message, userInfo in
                DispatchQueue.main.async() { [weak self] in
                    self?.loading.stopAnimating()
                    if (code == 200) {
                        self?.imageView.image = image
                    }
                }
            }
        } else {
            print("pick image error")
        }
        
        picker.dismiss(animated: true, completion:nil)
    }
}
