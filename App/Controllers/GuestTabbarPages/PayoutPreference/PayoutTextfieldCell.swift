
import UIKit

class PayoutTextfieldCell: UITableViewCell {
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var imgDownArrow: UIImageView!
    @IBOutlet var lblHeader: UILabel!
    @IBOutlet weak var payoutTF: CustomUITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 5.0
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        lblHeader.font = UIFont(name: APP_FONT, size: 14)
        payoutTF.font = UIFont(name: APP_FONT, size: 14)
        
        payoutTF.textColor =  UIColor(named: "Title_Header")
        
        lblHeader.textColor = UIColor(named: "Title_Header")
        
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        payoutTF.leftView = paddingView
        payoutTF.leftViewMode = .always
        
        
        if(Utility.shared.isRTLLanguage()) {
            payoutTF.textAlignment = .right
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
