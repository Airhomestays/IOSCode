
import UIKit

class AccommadationCell: UITableViewCell {
    
    @IBOutlet weak var accommodationhostLabel: UILabel!
    
    
    @IBOutlet var borderview: UIView!
    @IBOutlet weak var accomadationaddressLabel: UILabel!
    @IBOutlet weak var hostnameLabel: UILabel!
    @IBOutlet weak var addressLAbel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        accomadationaddressLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"accommadationaddress"))!)"
        
        accommodationhostLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"accommodationhost"))!)"
  
        accomadationaddressLabel.textColor = UIColor(named: "Title_Header")
        accomadationaddressLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        accomadationaddressLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        addressLAbel.textColor = UIColor(named: "searchPlaces_TextColor")
        addressLAbel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        addressLAbel.font = UIFont(name: APP_FONT, size: 12.0)
        
        accommodationhostLabel.textColor = UIColor(named: "Title_Header")
        accommodationhostLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        accommodationhostLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        hostnameLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        hostnameLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        hostnameLabel.font = UIFont(name: APP_FONT, size: 12.0)
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
