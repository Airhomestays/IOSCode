

import UIKit

class ItenarycheckCell: UITableViewCell {
    @IBOutlet weak var checkouttimeLabel: UILabel!
    @IBOutlet weak var outcheckLabel: UILabel!
    
    
    @IBOutlet var lineview: UILabel!
    @IBOutlet weak var arrowImgView: UIImageView!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var checkinTimeLabel: UILabel!
    @IBOutlet weak var checkinLabel: UILabel!
    @IBOutlet weak var checkoutLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        if Utility.shared.isRTLLanguage()
        {
            checkLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkout"))!)"
            outcheckLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkin"))!)"
        }
        else
        {
            checkLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkin"))!)"
            outcheckLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkout"))!)"
        }
       
        lineview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        checkLabel.textColor = UIColor(named: "Title_Header")
        checkLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        checkLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        outcheckLabel.textColor = UIColor(named: "Title_Header")
        outcheckLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        outcheckLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        checkinLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        checkinLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        checkinLabel.font = UIFont(name: APP_FONT, size: 13.0)
        
        checkoutLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        checkoutLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        checkoutLabel.font = UIFont(name: APP_FONT, size: 13.0)
        
        
        checkinTimeLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        checkinTimeLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        checkinTimeLabel.font = UIFont(name: APP_FONT, size: 13.0)
        
        checkouttimeLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        checkouttimeLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        checkouttimeLabel.font = UIFont(name: APP_FONT, size: 13.0)
        
        if Utility.shared.isRTLLanguage(){
            arrowImgView.performRTLTransform()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
