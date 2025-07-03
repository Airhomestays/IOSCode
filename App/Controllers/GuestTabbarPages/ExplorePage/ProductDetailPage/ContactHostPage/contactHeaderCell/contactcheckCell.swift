
import UIKit

class contactcheckCell: UITableViewCell {

    @IBOutlet weak var visitorsValue: UILabel!
    @IBOutlet weak var editVisitorsGuests: UIButton!
    @IBOutlet weak var visitorsLabel: UILabel!
    @IBOutlet weak var visitorsView: UIView!
    
    @IBOutlet weak var petValue: UILabel!
    @IBOutlet weak var editPetGuests: UIButton!
    @IBOutlet weak var petLabel: UILabel!
    @IBOutlet weak var petView: UIView!
    
    @IBOutlet weak var infantValue: UILabel!
    @IBOutlet weak var editInfantGuests: UIButton!
    @IBOutlet weak var infantLabel: UILabel!
    @IBOutlet weak var infantView: UIView!
    
    @IBOutlet weak var additioNalArrow: UIImageView!
    @IBOutlet weak var additionalGuestsValue: UILabel!
    @IBOutlet weak var editAdditonalGuests: UIButton!
    @IBOutlet weak var additionalGuestsLabel: UILabel!
    @IBOutlet weak var additionalGuestsView: UIView!
    
    @IBOutlet var guestImg: UIImageView!
    @IBOutlet var checkinimg: UIImageView!
    @IBOutlet var guestCountsLabel: UILabel!
    
    @IBOutlet var checkinoutLabel: UILabel!
    @IBOutlet weak var checkguestLabel: UILabel!
    @IBOutlet weak var checkoutLabel: UILabel!
    @IBOutlet weak var checkinLabel: UILabel!
    @IBOutlet weak var guestLabel: UIButton!
    @IBOutlet weak var addDateinLabel: UIButton!
    @IBOutlet weak var addOutDateLabel: UIButton!
    
    @IBOutlet var lineView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkinLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkinn"))!) / \((Utility.shared.getLanguage()?.value(forKey:"checkoutt"))!)"

        checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
        
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
      
         addOutDateLabel.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
         guestLabel.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        addOutDateLabel.titleLabel?.font = UIFont(name: APP_FONT, size: 14)
       
          guestLabel.titleLabel?.font = UIFont(name: APP_FONT, size: 14)
          
        checkguestLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 14)
         checkinLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 14)
        
        checkinoutLabel.font = UIFont(name: APP_FONT, size: 14)
         guestCountsLabel.font = UIFont(name: APP_FONT, size: 14)
        
        guestLabel.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"edit"))!)  ", for: .normal)
        addOutDateLabel.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"edit"))!)  ", for: .normal)

        
        checkinLabel.textColor = UIColor(named: "Title_Header")
        
        checkguestLabel.textColor = UIColor(named: "Title_Header")

        
//        editAdditonalGuests.textColor = UIColor(named: "Title_Header")
//        editInfantGuests.textColor = UIColor(named: "Title_Header")
//        editPetGuests.textColor = UIColor(named: "Title_Header")
//        editVisitorsGuests.textColor = UIColor(named: "Title_Header")
        
        additionalGuestsLabel.textColor = UIColor(named: "Title_Header")
        infantLabel.textColor = UIColor(named: "Title_Header")
        petLabel.textColor = UIColor(named: "Title_Header")
        visitorsLabel.textColor = UIColor(named: "Title_Header")
        
        additionalGuestsValue.textColor = UIColor(named: "searchPlaces_TextColor")
        infantValue.textColor = UIColor(named: "searchPlaces_TextColor")
        petValue.textColor = UIColor(named: "searchPlaces_TextColor")
        visitorsValue.textColor = UIColor(named: "searchPlaces_TextColor")
        
        checkinoutLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        guestCountsLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        if(Utility.shared.isRTLLanguage()) {
            guestLabel.imageView?.performRTLTransform()
            checkinimg.performRTLTransform()
            guestImg.performRTLTransform()
            checkinLabel.textAlignment = .right
            checkguestLabel.textAlignment = .right
            guestLabel.imageEdgeInsets = UIEdgeInsets(top: 0, left:0, bottom: 0, right:56)
        }
       else{
           
         
      }
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
