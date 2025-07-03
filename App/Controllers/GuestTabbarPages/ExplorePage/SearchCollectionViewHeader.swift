
import UIKit

class SearchCollectionViewHeader: UICollectionReusableView {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var onoffSwitch: UISwitch!
    
    @IBOutlet weak var contentVw: UIView!
    @IBOutlet weak var containerVw: UIView!
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if Utility.shared.selectedstartDate_filter.isEmpty {
            onoffSwitch.isOn = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"display_tot_pro")) ?? "Display total price")"
        subtitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"include_fees_taxs")) ?? "Includes all fees, before taxs")"
        titleLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        subtitleLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        if(Utility.shared.isRTLLanguage()) {
            onoffSwitch.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        if Utility.shared.isRTLLanguage() {
            onoffSwitch.semanticContentAttribute = .forceRightToLeft
        } else {
            onoffSwitch.semanticContentAttribute = .forceLeftToRight
        }
        [contentVw, containerVw].forEach { views in
            views?.backgroundColor = .appColor()
        }
        
        if Utility.shared.getAppTheme() == "dark" {
            contentVw.layer.borderColor = Theme.past_bg.cgColor
            contentVw.layer.borderWidth = 1
        } else {
            contentVw.layer.borderColor = Theme.past_bg.cgColor
            contentVw.layer.borderWidth = 1
        }

      
        
        onoffSwitch.onTintColor = Theme.PRIMARY_COLOR
        onoffSwitch.tintColor = UIColor(named: "Button_Grey_Color")
    }
}
