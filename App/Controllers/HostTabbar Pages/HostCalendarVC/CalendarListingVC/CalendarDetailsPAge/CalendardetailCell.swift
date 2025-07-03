
import UIKit

class CalendardetailCell: UITableViewCell {
    
    @IBOutlet var lineView: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var AvailableLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        priceLabel.textColor = Theme.PRIMARY_COLOR
        dateLabel.font = UIFont(name: APP_FONT, size: 14)
        priceLabel.font = UIFont(name: APP_FONT, size: 16)
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        dateLabel.textColor = UIColor(named: "searchPlaces_TextColor")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
