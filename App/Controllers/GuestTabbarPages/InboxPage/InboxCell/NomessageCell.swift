
import UIKit

class NomessageCell: UITableViewCell {

    @IBOutlet weak var messagehostLabel: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        loginBtn.setBorder(color: Theme.PRIMARY_COLOR)
        loginBtn.layer.cornerRadius = 6.0
        loginBtn.layer.masksToBounds = true
        messagehostLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nomessage"))!)"
        loginBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"login_string"))!)", for:.normal)
        loginBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        messagehostLabel.font = UIFont(name: APP_FONT, size: 16)
        loginBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
