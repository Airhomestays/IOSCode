
import UIKit

class SingleTextFieldCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: CustomUITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.font = UIFont(name: APP_FONT, size: 18)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
