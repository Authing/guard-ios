//
//  UserInfoCompleteFieldFormDateTime.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/22.
//

import UIKit

open class UserInfoCompleteFieldFormDateTime: UserInfoCompleteFieldForm {
    var textField: UITextField = UITextField()
    let datePickerView:UIDatePicker = UIDatePicker()
    
    override init(frame: CGRect) {
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
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControl.Event.valueChanged)
        
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2).isActive = true
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: sender.date)
        textField.text = "\(calendarDate.year!)/\(calendarDate.month!)/\(calendarDate.day!)"
    }
    
    public override func getHeight() -> CGFloat {
        return 26 + 44 + 2
    }
    
    public override func getValue() -> String? {
        return textField.text
    }
    
    public override func setFormData(_ data: NSDictionary) {
        super.setFormData(data)
    }
}
