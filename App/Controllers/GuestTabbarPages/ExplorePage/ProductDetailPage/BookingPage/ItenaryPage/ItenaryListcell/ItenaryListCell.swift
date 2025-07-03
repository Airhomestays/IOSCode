
import UIKit
import SwiftMessages

class ItenaryListCell: UITableViewCell {

    @IBOutlet weak var reservationCodeLAbel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
                
        reservationCodeLAbel.textColor = UIColor(named: "Title_Header")
        reservationCodeLAbel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        reservationCodeLAbel.font = UIFont(name: APP_FONT, size: 14.0)
        
        locationLabel.textColor = UIColor(named: "Title_Header")
        locationLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        locationLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
