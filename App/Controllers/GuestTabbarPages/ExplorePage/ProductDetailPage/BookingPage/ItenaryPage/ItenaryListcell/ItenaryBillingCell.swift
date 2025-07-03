
import UIKit

class ItenaryBillingCell: UITableViewCell {

   
    
    @IBOutlet var lineView: UILabel!
    @IBOutlet weak var viewReceiptBtn: UIButton!
    @IBOutlet weak var billingTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        billingTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"billing"))!)"
        billingTitleLabel.textColor = UIColor(named: "Title_Header")
        billingTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        billingTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        
        stayLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        stayLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        stayLabel.font = UIFont(name: APP_FONT, size: 13)
        
        priceLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        priceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        priceLabel.font = UIFont(name: APP_FONT, size: 13)
        
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
