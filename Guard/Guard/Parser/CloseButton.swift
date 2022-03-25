//
//  CloseButton.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/23.
//

import UIKit

public class CloseButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        frame = CGRect(x: 20, y: 44, width: 30, height: 30)
        let image = UIImage(named: "authing_close", in: Bundle(for: Self.self), compatibleWith: nil)
        setBackgroundImage(image, for: .normal)
        self.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
    }
    
    @objc private func onClick(sender: UIButton) {
        authViewController?.dismiss(animated: true, completion: nil)
    }
}
