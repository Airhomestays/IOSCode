
import UIKit

class tripscancellCell: UITableViewCell {

    @IBOutlet var lineView: UILabel!
    @IBOutlet weak var travellingwithLabel: UILabel!
    @IBOutlet weak var stayingLabel: UILabel!
    @IBOutlet weak var startinLabel: UILabel!
    @IBOutlet weak var travellingLabel: UILabel!
    @IBOutlet weak var nightsLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
      
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        startinLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"startin"))!)"
        stayingLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"stayingfor"))!)"
        travellingwithLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"travellingwith"))!)"
        
        
        startinLabel.textColor = UIColor(named: "Title_Header")
        stayingLabel.textColor = UIColor(named: "Title_Header")
        travellingwithLabel.textColor = UIColor(named: "Title_Header")
        
        startinLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
         stayingLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
         startLabel.font = UIFont(name: APP_FONT, size: 14)
         nightsLabel.font = UIFont(name: APP_FONT, size: 14)
         travellingwithLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        
        startLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        nightsLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        travellingLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        
         travellingLabel.font = UIFont(name: APP_FONT, size: 14)
        if(Utility.shared.isRTLLanguage()) {
            stayingLabel.textAlignment = .right

            nightsLabel.textAlignment = .right
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
