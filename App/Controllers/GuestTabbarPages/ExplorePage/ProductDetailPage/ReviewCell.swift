

import UIKit
import  Cosmos
class ReviewCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var readallBtn: UIButton!

    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var verifyLabel: UILabel!
    @IBOutlet weak var reviewRateView: CosmosView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        verifyLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"verifyrentall"))!)"
        reviewTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"review"))!)"
        
        reviewRateView.settings.filledColor = Theme.PRIMARY_COLOR
        reviewRateView.settings.filledBorderColor = Theme.PRIMARY_COLOR
        profileImg.layer.cornerRadius = profileImg.layer.frame.size.width/2
        profileImg.layer.masksToBounds = true
        readallBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
     
                    reviewTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 19)
         verifyLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
         reviewCountLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        reviewLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        reviewDateLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        
        reviewRateView.semanticContentAttribute = Utility.shared.isRTLLanguage() ? .forceRightToLeft : .forceLeftToRight
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
