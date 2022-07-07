//
//  UserInfoCompleteFieldFormSelect.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/22.
//

open class UserInfoCompleteFieldFormSelect: UserInfoCompleteFieldForm {
    var segment: UISegmentedControl = UISegmentedControl()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override func setup() {
        super.setup()
        
        addSubview(segment)
        
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.heightAnchor.constraint(equalToConstant: 44).isActive = true
        segment.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        segment.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        segment.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2).isActive = true
    }
    
    public override func getHeight() -> CGFloat {
        return 26 + 44 + 2
    }
    
    public override func getValue() -> String? {
        let index = segment.selectedSegmentIndex
        if (index == 0) {
            return "M"
        } else if (index == 1) {
            return "F"
        } else if (index == 2) {
            return "U"
        }
        return ""
    }
    
    public override func setFormData(_ data: NSDictionary) {
        super.setFormData(data)
        if ("gender" == data["name"] as? String) {
            let m = "authing_sex_male".L
            let f = "authing_sex_female".L
            let u = "authing_sex_unspecified".L
            segment.insertSegment(withTitle: u, at: 0, animated: false)
            segment.insertSegment(withTitle: f, at: 0, animated: false)
            segment.insertSegment(withTitle: m, at: 0, animated: false)
        }
    }
}
