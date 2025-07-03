
import UIKit

class FooterProfileCell: UITableViewCell {

    @IBOutlet weak var LogOutView: UIView!
    @IBOutlet weak var LogOutTitleLabel: UILabel!
    @IBOutlet weak var LogOutIconImg: UIImageView!
    @IBOutlet weak var LogOutBtn: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        LogOutTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "logout") ?? "Log out")"
        LogOutTitleLabel.textColor = UIColor(named: "Title_Header")
        LogOutTitleLabel.font = UIFont(name: APP_FONT, size: 16.0)
        
        LogOutBtn.setTitle("", for: .normal)
        LogOutBtn.backgroundColor = .clear
        
        let attributes = [
            NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 14.0),
            NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")
        ]
        let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "version") ?? "Version") "  , attributes: attributes as [NSAttributedString.Key : Any])
        let attributes2 = [
            NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 14.0),
            NSAttributedString.Key.foregroundColor: Theme.Button_BG
        ]
        let appShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let appBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let attributedString2 = NSMutableAttributedString(string: "\(appShortVersion ?? "")", attributes: attributes2 as [NSAttributedString.Key : Any])
        
        attributedString.append(attributedString2)
        
        
        versionLabel.attributedText = attributedString
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
