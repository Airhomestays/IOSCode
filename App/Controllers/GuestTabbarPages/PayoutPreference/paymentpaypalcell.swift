

import UIKit

class paymentpaypalcell: UITableViewCell {

    @IBOutlet weak var paydescriptionLabel: UILabel!
    @IBOutlet weak var paypalLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       
        paydescriptionLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"paypaldescription"))!)"

        paydescriptionLabel.font = UIFont(name: APP_FONT, size: 14)
        paydescriptionLabel.textColor =   UIColor(named: "searchPlaces_TextColor")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
