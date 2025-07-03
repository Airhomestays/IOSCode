

import UIKit

class AgreetermsCell: UITableViewCell {

    @IBOutlet weak var agreeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        agreeLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        let fullString = "\((Utility.shared.getLanguage()?.value(forKey:"agreeterm"))!)"
      
        let coloredString = "\((Utility.shared.getLanguage()?.value(forKey:"houseRules"))!)"

       let rangeOfColoredString = (fullString as! NSString).range(of: coloredString)

        
        let attributedString = NSMutableAttributedString(string:fullString)
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR , NSAttributedString.Key.font: APP_FONT_SEMIBOLD],
                                range: rangeOfColoredString)
        agreeLabel.attributedText = attributedString
        
      
        
        agreeLabel.font = UIFont(name: APP_FONT, size: 14)
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
