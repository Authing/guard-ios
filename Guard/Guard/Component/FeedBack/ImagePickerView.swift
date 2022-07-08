//
//  ImagePickerView.swift
//  Guard
//
//  Created by JnMars on 2022/7/7.
//

import Foundation

open class ImagePickerView: UIView {
    
    public var items: [UIImage] = []
    var itemWidth: CGFloat = UIScreen.main.bounds.width - 15 / 4
    var collectionView: UICollectionView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }


    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
                
        itemWidth =  (self.frame.width - 15) / 4

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        
        collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 8, width: self.frame.width, height: itemWidth * 2 + 5), collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.addSubview(collectionView)
    }
    
    @objc func deleteImage(_ sender: UIButton) {
        if let idx = items.firstIndex (where: { (image) -> Bool in
            return image == items[sender.tag]
         }) {
            items.remove(at: idx)
            collectionView.reloadData()
         }
    }
}

//MARK: UICollectionViewDelegate & DataSource
extension ImagePickerView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        for item in cell.contentView.subviews {
            item.removeFromSuperview()
        }
        if indexPath.row == items.count{
            cell.contentView.backgroundColor = Const.Color_BG_Text_Box
            let add = UIImageView.init(image: UIImage.init(named: "authing_add", in: Bundle(for: Self.self), compatibleWith: nil))
            add.frame = CGRect(x: (itemWidth - 15) / 2, y: (itemWidth - 15) / 2, width: 15, height: 15)
            cell.contentView.addSubview(add)
        } else {
            let item = UIImageView.init(image: items[indexPath.row])
            item.frame = CGRect(x: 0, y: 0, width: itemWidth, height: itemWidth)
            cell.contentView.addSubview(item)
            
            let deleteButton = UIButton.init(frame: CGRect(x: itemWidth - 30, y: 0, width: 30, height: 30))
            deleteButton.setImage(UIImage.init(named: "authing_close", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
            deleteButton.tag = indexPath.row
            deleteButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
            cell.contentView.addSubview(deleteButton)
        }
        return cell

    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == items.count{
            self.selectPicture()
        }
    }

}

//MARK: ---------- ImagePicker ----------
extension ImagePickerView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func selectPicture(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerVC = UIImagePickerController()
            pickerVC.delegate = self
            
            pickerVC.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.viewController?.present(pickerVC, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else
        {
            return
        }

        items.append(image)
        collectionView.reloadData()

        picker.dismiss(animated: true, completion: nil)
    }

}
