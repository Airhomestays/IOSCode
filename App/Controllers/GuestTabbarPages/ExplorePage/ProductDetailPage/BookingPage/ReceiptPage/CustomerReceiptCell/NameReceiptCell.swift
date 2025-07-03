

import UIKit

class NameReceiptCell: UITableViewCell {
    
    

    @IBOutlet var lineView: UIView!
    @IBOutlet weak var accomadationTitleLabel: UILabel!
    @IBOutlet weak var durationTitleLAbel: UILabel!
    @IBOutlet weak var travelLabel: UILabel!
    @IBOutlet weak var nameLAbel: UILabel!
    @IBOutlet weak var accomadationLabel: UILabel!
    @IBOutlet weak var durationLbel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var reservationCodeTitle: UILabel!
    @IBOutlet weak var reservationCodeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"name"))!)"
        travelLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"traveldestination"))!)"
        durationTitleLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"duration"))!)"
        accomadationTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"accommodationtype"))!)"

        nameLAbel.textColor = UIColor(named: "Title_Header")
        nameLAbel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        nameLAbel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        nameLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        nameLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        nameLabel.font = UIFont(name: APP_FONT, size: 12.0)
              
        travelLabel.textColor = UIColor(named: "Title_Header")
        travelLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        travelLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        destinationLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        destinationLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        destinationLabel.font = UIFont(name: APP_FONT, size: 12.0)
        
        durationTitleLAbel.textColor = UIColor(named: "Title_Header")
        durationTitleLAbel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        durationTitleLAbel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        durationLbel.textColor = UIColor(named: "searchPlaces_TextColor")
        durationLbel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        durationLbel.font = UIFont(name: APP_FONT, size: 12.0)
        
        accomadationTitleLabel.textColor = UIColor(named: "Title_Header")
        accomadationTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        accomadationTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        accomadationLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        accomadationLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        accomadationLabel.font = UIFont(name: APP_FONT, size: 12.0)
        
        reservationCodeTitle.textColor = UIColor(named: "Title_Header")
        reservationCodeTitle.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        reservationCodeTitle.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        reservationCodeLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        reservationCodeLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        reservationCodeLabel.font = UIFont(name: APP_FONT, size: 12.0)
        
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
