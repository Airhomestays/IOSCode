
import UIKit
import SwiftMessages

class PaymentFooterCell: UITableViewCell {
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var lineview: UILabel!
    
    @IBOutlet var countryBtn: UIButton!
    @IBOutlet var txtFiled: CustomUITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = containerView.frame.size.height / 2
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
        
        containerView.backgroundColor = UIColor(named: "colorController")
        txtFiled.attributedPlaceholder = NSAttributedString(
            string: "Placeholder Text",
            attributes: [NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR]
        )
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
