//
//  EmailLabel.swift
//  Guard
//
//  Created by Lance Mao on 2022/1/12.
//

open class EmailLabel: UILabel {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        DispatchQueue.main.async() {
            if let email = Util.getEmail(self) {
                self.text = email
            }
        }
    }
}
