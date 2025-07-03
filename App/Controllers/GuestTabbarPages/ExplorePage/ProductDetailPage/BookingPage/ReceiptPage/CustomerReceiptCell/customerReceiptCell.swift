
import UIKit

class customerReceiptCell: UITableViewCell {

    @IBOutlet weak var customerReceiptLabel: UILabel!
    @IBOutlet weak var confirmCodeLAbel: UILabel!
    @IBOutlet weak var receiptNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()

        dateLabel.textColor = UIColor(named: "Title_Header")
        dateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        dateLabel.font = UIFont(name: APP_FONT, size: 14.0)
        
        receiptNumberLabel.textColor = UIColor(named: "Title_Header")
        receiptNumberLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        receiptNumberLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
