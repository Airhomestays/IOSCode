

import UIKit
import RangeSeekSlider

class PriceRangeCell: UITableViewCell {
    
    @IBOutlet var priceLabel: UILabel!
    
    @IBOutlet weak var priceshowLabel: UILabel!
    
    
    @IBOutlet var sliderView: RangeSeekSlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if  Utility.shared.isRTLLanguage() {
            UIView.animate(withDuration: 0.1) {
                self.sliderView.semanticContentAttribute = .forceRightToLeft
               
            }
        } else {
            self.sliderView.semanticContentAttribute = .forceLeftToRight
        }

        sliderView.colorBetweenHandles = Theme.PRIMARY_COLOR
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
