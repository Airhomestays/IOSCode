

import UIKit

class BookingTotalCell: UITableViewCell {

    @IBOutlet weak var gstLine: UILabel!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet var lineView1: UILabel!
    @IBOutlet var lineView: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        totalTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"total"))!)"

        gstLine.textColor = UIColor(named: "Title_Header")
        totalTitleLabel.textColor = UIColor(named: "Title_Header")
        totalTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        totalTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        totalPriceLabel.textColor = UIColor(named: "Title_Header")
        totalPriceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        totalPriceLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        lineView1.backgroundColor = UIColor(named: "Review_Page_Line_Color")

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
