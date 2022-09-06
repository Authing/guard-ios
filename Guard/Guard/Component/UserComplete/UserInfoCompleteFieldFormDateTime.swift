//
//  UserInfoCompleteFieldFormDateTime.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/22.
//

open class UserInfoCompleteFieldFormDateTime: UserInfoCompleteFieldForm {
    var textField: TextFieldLayout = TextFieldLayout()
    let datePickerView:UIDatePicker = UIDatePicker()
    
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
        
        addSubview(textField)
        
        datePickerView.datePickerMode = .date
        textField.inputView = datePickerView
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControl.Event.valueChanged)
        
        textField.tintColor = Const.Color_Authing_Main
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: sender.date)
        textField.text = "\(calendarDate.year!)/\(calendarDate.month!)/\(calendarDate.day!)"
    }
    
    public override func getHeight() -> CGFloat {
        return 26 + 44 + 8
    }
    
    public override func getValue() -> String? {
        return textField.text
    }
    
    public override func setFormData(_ data: NSDictionary) {
        super.setFormData(data)
    }
}
