

import UIKit

class AboutDynamicCell: UITableViewCell {
    
    @IBOutlet var lineview: UILabel!
    @IBOutlet var aboutHeaderLbl: UILabel!
    @IBOutlet var aboutLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        aboutHeaderLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
              aboutLabel.font = UIFont(name: APP_FONT, size: 15)
        aboutLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        lineview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        aboutHeaderLbl.text = "\(Utility.shared.getLanguage()?.value(forKey:"about") ?? "About")"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
