import UIKit

class ReservationUpcomingHostCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var receiptBtn: UIButton!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var addressLAbel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var approvedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        approvedLabel.layer.cornerRadius = 6.0
        approvedLabel.layer.masksToBounds = true
        messageBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"message"))!)", for:.normal)
        approveBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"approve"))!)", for:.normal)
        declineBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"decline"))!)", for:.normal)
        receiptBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"receipt"))!)", for:.normal)
        cancelBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)", for:.normal)
        
        messageBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        approveBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        declineBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        receiptBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        cancelBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        titleBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        titleBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 17)
        approveBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 16)
        declineBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 16)
        receiptBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 16)
        cancelBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 16)
        messageBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 16)
        streetLabel.font = UIFont(name: APP_FONT, size: 15)
        addressLAbel.font = UIFont(name: APP_FONT, size: 15)
        approvedLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
        nameLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 19)
        dateLabel.font = UIFont(name: APP_FONT, size: 16)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
