
import UIKit

class PayoutCell: UITableViewCell {
    
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet var lineview: UILabel!
    @IBOutlet var typeImage: UIImageView!
    @IBOutlet weak var defaultBtn: UIButton!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var payoutLAbel: UILabel!
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var verifyInfoicon:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        if(IS_IPHONE_XR || IS_IPHONE_X || IS_IPHONE_XS_MAX || IS_IPHONE_PLUS) {
            self.payView.frame.size.width = FULLWIDTH-40
        }
        payView.layer.cornerRadius = 4.0
        payView.layer.masksToBounds = true
        defaultBtn.layer.cornerRadius = 4.0
        defaultBtn.layer.masksToBounds = true
        
        self.payView.layer.cornerRadius = 5.0
        self.payView.layer.borderColor = UIColor(named: "Review_Page_Line_Color")?.cgColor
        self.payView.layer.borderWidth = 1.0
        self.payView.layer.masksToBounds = true
        lineview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        payoutLAbel.textColor = Theme.PRIMARY_COLOR
        
        
        self.payView.backgroundColor = UIColor(named: "Button_Grey_Color")
        
        detailLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        statusLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        currencyLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        
        self.defaultBtn.layer.borderWidth = 1.5
        self.defaultBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
        self.defaultBtn.layer.cornerRadius = self.defaultBtn.frame.size.height / 2
        self.defaultBtn.clipsToBounds = true
        
        self.deleteBtn.layer.borderWidth = 1.5
        self.deleteBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
        self.deleteBtn.layer.cornerRadius = self.deleteBtn.frame.size.height / 2
        self.deleteBtn.clipsToBounds = true
        self.deleteBtn.backgroundColor = Theme.PRIMARY_COLOR
        self.deleteBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"remove"))!)  ", for: .normal)
        
        
        
        defaultBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        deleteBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        payoutLAbel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        detailLabel.font = UIFont(name: APP_FONT, size: 13)
        statusLabel.font = UIFont(name: APP_FONT, size: 13)
        currencyLabel.font = UIFont(name: APP_FONT, size: 13)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
