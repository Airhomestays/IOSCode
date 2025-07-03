

import UIKit

class RentpaymentReceiptCell: UITableViewCell {

    @IBOutlet var paymentRTLLabel: UILabel!
    @IBOutlet weak var payemntdescriptionLabel: UILabel!
    @IBOutlet weak var paymentreceiveLAbel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var paymentDateLabel: UILabel!
    
    @IBOutlet var lineView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (!Utility.shared.host_isfrom_hostRecipt) {
            payemntdescriptionLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"payment_accept_info"))!)"
        } else {
            payemntdescriptionLabel.text = "1. Airhomestays is obligated to deduct 1% of the gross earnings of hosts who are residents of India, and remit these funds to the Indian tax authorities, per section 194-O of the Indian Income-Tax Act. /n2. If the Indian host has not provided their PAN to Airhomestays, we are required to withhold tax at the rate of 5%. Please note, any funds that have already been withheld and remitted to tax authorities are unable to be returned by Airhomestays. /n3. Service fee includes gst on our commission."
        }
        
        
        paymentreceiveLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"paymentreceive"))!)"
       
        
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
          
        
        paymentreceiveLAbel.textColor = UIColor(named: "Title_Header")
        paymentreceiveLAbel.font = UIFont(name: APP_FONT, size: 12.0)
        paymentreceiveLAbel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        totalLabel.textColor = UIColor(named: "Title_Header")
        totalLabel.font = UIFont(name: APP_FONT, size: 12.0)
        totalLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        
        paymentRTLLabel.textColor = UIColor(named: "Title_Header")
        paymentRTLLabel.font = UIFont(name: APP_FONT, size: 12.0)
   
        paymentDateLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        paymentDateLabel.font = UIFont(name: APP_FONT, size: 12.0)
        paymentDateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        
        payemntdescriptionLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        payemntdescriptionLabel.font = UIFont(name: APP_FONT, size: 12.0)
        payemntdescriptionLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
