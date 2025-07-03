

import UIKit

class CancellationCell: UITableViewCell {
    @IBOutlet weak var checkLabel: UILabel!
    
    
    @IBOutlet var lineView: UILabel!
    
    @IBOutlet var lblExampleDescription: UILabel!
    @IBOutlet var lblExample: UILabel!
    @IBOutlet var lblCancellationPolicy: UILabel!
    @IBOutlet weak var availabilityImg: UIImageView!
    @IBOutlet weak var cancelTitleLabel: UILabel!
    @IBOutlet weak var checkoutLabel: UILabel!
    @IBOutlet weak var fullviewDetailBtn: UIButton!
    @IBOutlet weak var checkoutTimeLabel: UILabel!
    @IBOutlet weak var checkinTimeLabel: UILabel!
    @IBOutlet weak var flexibleLabel: UILabel!
    
    @IBOutlet var lblExampleDescription1: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        cancelTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"cancellationPolicy"))!)"

    
        cancelTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
        lblExample.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        lblCancellationPolicy.font = UIFont(name: APP_FONT, size: 14)
        lblExampleDescription.font = UIFont(name: APP_FONT, size: 14)
        lblExampleDescription1.font = UIFont(name: APP_FONT, size: 14)
        
        lblExample.textColor =  UIColor(named: "Title_Header")
        
        lblCancellationPolicy.textColor = UIColor(named: "searchPlaces_TextColor")
        lblExampleDescription.textColor = UIColor(named: "searchPlaces_TextColor")
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        cancelTitleLabel.textColor =  UIColor(named: "Title_Header")

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
