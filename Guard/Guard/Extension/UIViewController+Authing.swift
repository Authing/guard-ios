//
//  UIViewController+Authing.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/25.
//

extension UIViewController {
    public func canPerformSegue(withIdentifier id: String) -> Bool {
        guard let segues = self.value(forKey: "storyboardSegueTemplates") as? [NSObject] else { return false }
        return segues.first { $0.value(forKey: "identifier") as? String == id } != nil
    }
}
