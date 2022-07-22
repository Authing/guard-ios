//
//  FeedBackController.swift
//  Guard
//
//  Created by JnMars on 2022/7/7.
//

import Foundation

/// Cell Item
enum FeedBackItem {
    case phoneTitle
    case phoneContent
    case issuesTitle
    case issuesContent
    case issuesTips
    case issuesDesTitle
    case issuesDesContent
    case photoTitle
    case photoContent
    case errorMessage
    case feedBack

    func title() -> String? {
        switch self {
        case .phoneTitle:
            return "authing_feedback_contact".L
        case .issuesTitle:
            return "authing_feedback_related".L
        case .issuesTips:
            return "authing_feedback_issuetip".L
        case .issuesDesTitle:
            return "authing_feedback_description".L
        case .photoTitle:
            return "authing_feedback_screenshot".L
        default:
            return nil
        }
    }
    
    func height() -> CGFloat {
        switch self {
        case .phoneTitle, .issuesDesTitle, .photoTitle:
            return 54
        case .issuesTitle:
            return 39
        case .phoneContent:
            return 52
        case .issuesContent:
            return 48
        case .issuesTips:
            return 94
        case .issuesDesContent:
            return 100
        case .photoContent:
            return (UIScreen.main.bounds.width - 15) / 4 * 2 + 5
        case .errorMessage:
            return 15
        case .feedBack:
            return 48
        }
    }
}


class FeedBackController: AuthViewController {

    @IBOutlet var tableView: UITableView!
    
    private var items: [FeedBackItem] = [.phoneTitle,
                                         .phoneContent,
                                         .errorMessage,
                                         .issuesTitle,
                                         .issuesContent,
                                         .issuesTips,
                                         .issuesDesTitle,
                                         .issuesDesContent,
                                         .photoTitle,
                                         .photoContent,
                                         .feedBack]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "authing_feedback_title".L
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
}

extension FeedBackController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        switch items[indexPath.row] {
        case .phoneTitle, .issuesTitle, .issuesDesTitle, .photoTitle, .issuesTips:
            let label = UILabel.init(frame: CGRect(x: 24, y: 15, width: Const.SCREEN_WIDTH - 48, height: items[indexPath.row].height() - 15))
            label.font = UIFont.systemFont(ofSize: 16)
            cell.contentView.addSubview(label)
            if items[indexPath.row] == .phoneTitle {
                
                let attributedString1 = NSMutableAttributedString(string: items[indexPath.row].title() ?? "", attributes:[NSAttributedString.Key.foregroundColor : UIColor.black])
                let attributedString2 = NSMutableAttributedString(string:" *", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 232/255, green: 53/255, blue: 62/255, alpha: 1)])
                 
                attributedString1.append(attributedString2)
                label.attributedText = attributedString1
                
            } else if items[indexPath.row] == .issuesTips {
                
                label.frame = CGRect(x: 24, y: 24, width: Const.SCREEN_WIDTH - 48, height: 70)
                label.textColor = Const.Color_Text_Default_Gray

                label.numberOfLines = 0
                
                let  paraph =  NSMutableParagraphStyle ()
                paraph.lineSpacing = 5
                let  attributes = [NSAttributedString.Key.font : UIFont .systemFont(ofSize: 14),
                                    NSAttributedString.Key.paragraphStyle : paraph]
                label.attributedText =  NSAttributedString(string: items[indexPath.row].title() ?? "", attributes: attributes)
                
            } else if items[indexPath.row] == .issuesTitle {

                label.frame = CGRect(x: 24, y: 0 , width: Const.SCREEN_WIDTH - 48, height: 39)
                label.text = items[indexPath.row].title()
                
            } else {
                label.text = items[indexPath.row].title()
            }
            break
        case .phoneContent:
            let at = AccountTextField.init(frame: CGRect(x: 24, y: 0, width: Const.SCREEN_WIDTH - 48, height: 48))
            at.placeholder = "authing_input_phone_or_email".L
            at.hintColor = Const.Color_Text_Default_Gray
            cell.contentView.addSubview(at)
            break
        case .issuesContent:
            let picker = FeedBackIssuePicker.init(frame: CGRect(x: 24, y: 0, width: Const.SCREEN_WIDTH - 48, height: 48))
            cell.contentView.addSubview(picker)
            break
        case .issuesDesContent:
            let des = DescribeTextView.init(frame: CGRect(x: 24, y: 0, width: Const.SCREEN_WIDTH - 48, height: 100))
            cell.contentView.addSubview(des)
            break
        case .photoContent:
            let picker = ImagePickerView.init(frame: CGRect(x: 24, y: 0, width: Const.SCREEN_WIDTH - 48, height: FeedBackItem.photoContent.height()))
            cell.contentView.addSubview(picker)
            break
        case .errorMessage:
            let error = ErrorLabel.init(frame: CGRect(x: 24, y: 0, width: Const.SCREEN_WIDTH - 48, height: 15))
            cell.contentView.addSubview(error)
            break
        case .feedBack:
            let button = FeedBackButton.init(frame: CGRect(x: 24, y: 0, width: Const.SCREEN_WIDTH - 48, height: 48))
            cell.contentView.addSubview(button)
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items[indexPath.row].height()
    }
}
