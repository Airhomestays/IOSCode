
import UIKit

class DiscountTextFieldCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet var linebottomconstant: NSLayoutConstraint!
    @IBOutlet var linetopconstant: NSLayoutConstraint!
    @IBOutlet weak var stepnumberLbl: UILabel!
    @IBOutlet weak var queryTitleLbl: UILabel!
    @IBOutlet weak var txtField: CustomDiscountTextField!
    @IBOutlet var stepOneHeight: NSLayoutConstraint!
    
    @IBOutlet var lblPercentage: UILabel!
    
    @IBOutlet var imgDownArrow: UIImageView!
    @IBOutlet var stepOneBottom: NSLayoutConstraint!
    @IBOutlet var lineLabel: UIView!
    @IBOutlet weak var stepNumberLblTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stepnumberLbl.text = Utility.shared.getLanguage()?.value(forKey: "step1") as? String
        stepnumberLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        
        queryTitleLbl.font = UIFont(name: APP_FONT, size: 14)
        queryTitleLbl.textColor = UIColor(named: "searchPlaces_TextColor")
        queryTitleLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        
        txtField.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        txtField.textColor = UIColor(named: "Title_Header")
        
        txtField.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        txtField.layer.borderWidth = 1.0
        txtField.layer.cornerRadius = 5.0
        txtField.layer.masksToBounds = true
        
        txtField.tintColor = UIColor(named: "Title_Header")
        
        
        txtField.semanticContentAttribute = (Utility.shared.isRTLLanguage()) ? .forceRightToLeft : .forceLeftToRight
        
        txtField.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
