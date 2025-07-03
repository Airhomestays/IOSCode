
import UIKit

class nolistTripsCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nolistLabel: UILabel!
    @IBOutlet weak var contactSupportBtn: UIButton!
    
    @IBOutlet var lineView: UILabel!
    
    @IBOutlet weak var approvedLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var contactSupportLabel: UILabel!
    @IBOutlet weak var contactIconImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
                
        bgView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        bgView.layer.cornerRadius = 4.0
        bgView.clipsToBounds = true
        
        contactIconImg.tintColor = Theme.PRIMARY_COLOR
        approvedLabel.layer.cornerRadius = approvedLabel.frame.size.height/2
        approvedLabel.layer.masksToBounds = true
        approvedLabel.textColor = .white
        approvedLabel.font = UIFont(name: APP_FONT, size: 12.0)
        
        dateLabel.textColor = UIColor(named: "Title_Header")
        dateLabel.font = UIFont(name: APP_FONT, size: 12)
        dateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        dateLabel.backgroundColor = .clear
        
        nolistLabel.textColor = UIColor(named: "Title_Header")
        nolistLabel.font = UIFont(name: APP_FONT, size: 14)
        nolistLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        nolistLabel.backgroundColor = .clear
        
        contactSupportBtn.setTitle("", for: .normal)
        contactSupportBtn.backgroundColor = .clear
        
        contactView.backgroundColor = .clear
        
        
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        contactSupportLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "contactsupport") ?? "Contact support")"
        contactSupportLabel.textColor = Theme.PRIMARY_COLOR
        contactSupportLabel.font = UIFont(name: APP_FONT, size: 12.0)
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
