
import UIKit
import SwiftMessages

class paymethodCell: UITableViewCell {

    @IBOutlet var lineview: UILabel!
    @IBOutlet var imgSelect: UIImageView!
    @IBOutlet var lblSelect: UILabel!
    @IBOutlet var typeImage: UIImageView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var processLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var paypalLabel: UILabel!
    
    @IBOutlet var selectBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        paypalLabel.textColor =  UIColor(named: "Title_Header")
        lblSelect.textColor = Theme.PRIMARY_COLOR
        
        currencyLabel.textColor =  UIColor(named: "searchPlaces_TextColor")
        processLabel.textColor =  UIColor(named: "searchPlaces_TextColor")
        feeLabel.textColor =  UIColor(named: "searchPlaces_TextColor")

        containerView.layer.borderColor = UIColor(named: "Review_Page_Line_Color")?.cgColor
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 5.0
        containerView.layer.masksToBounds = true
        
        if(Utility.shared.isRTLLanguage()) {
                   imgSelect.performRTLTransform()
               }
        lineview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        feeLabel.font = UIFont(name: APP_FONT, size: 12)
        processLabel.font = UIFont(name: APP_FONT, size: 12)
        currencyLabel.font = UIFont(name: APP_FONT, size: 12)
        paypalLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        lblSelect.font = UIFont(name: APP_FONT, size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
