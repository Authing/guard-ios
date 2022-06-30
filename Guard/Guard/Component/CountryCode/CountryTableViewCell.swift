//
//  CountryCodeViewController.swift
//  Guard
//
//  Created by JnMars on 2022/3/26.
//

class CountryTableViewCell: UITableViewCell {
    
    let itemHeight: CGFloat = 50
    
    private lazy var emoji: UILabel = {
        var label = UILabel.init(frame: CGRect(x: 20, y: 0, width: itemHeight, height: itemHeight))
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        return label
    }()
    
    private lazy var countryName: UILabel = {
        var label = UILabel.init(frame: CGRect(x: itemHeight, y: 0, width: itemHeight * 3, height: itemHeight))
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()

    private lazy var phoneCode: UILabel = {
        var label = UILabel.init(frame: CGRect(x: UIScreen.main.bounds.width - itemHeight - 20, y: 5, width: itemHeight, height: itemHeight))
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.lightGray
        label.textAlignment = .right
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    func setupUI() {
        self.contentView.addSubview(emoji)
        self.contentView.addSubview(countryName)
        self.contentView.addSubview(phoneCode)
    }
    
    func setContent(model: CountryItemModel) {
        countryName.text = Util.getLangHeader() == "zh-CN" ? model.cn : model.en
        if let code = model.code {
            phoneCode.text = "+\(code)"
        }
        emoji.text = model.emoji
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
