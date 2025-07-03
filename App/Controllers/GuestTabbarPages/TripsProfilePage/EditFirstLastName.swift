
import UIKit

class EditFirstLastName: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var txtField: CustomUITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = UIColor(named: "Title_Header")
        titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        txtField.textColor = UIColor(named: "searchPlaces_TextColor")
        txtField.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        txtField.font = UIFont(name: APP_FONT, size: 12.0)
        
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
         txtField.leftView = paddingView
         txtField.leftViewMode = .always
        
        txtField.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        txtField.layer.borderWidth  = 1.0
        txtField.layer.cornerRadius = 4.0
        txtField.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
