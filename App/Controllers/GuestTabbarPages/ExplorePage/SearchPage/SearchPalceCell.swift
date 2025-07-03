

import UIKit
import SwiftMessages

class SearchPalceCell: UITableViewCell {
    @IBOutlet var iconImage: UIImageView!
    
    @IBOutlet var lineView: UIView!
    @IBOutlet var locationLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
       
    }
    func configCell(locationDict:NSDictionary) {
        
        locationLbl.text = locationDict.value(forKey: "address_full") as? String
        locationLbl.font = UIFont(name: APP_FONT, size:14)
        locationLbl.textColor = UIColor(named: "searchPlaces_TextColor")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
