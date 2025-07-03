import UIKit

class FeebackHeaderCell: UITableViewCell {

    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"howwedo") ?? "How are we doing?")"
        titleLabel.textColor = UIColor(named: "Title_Header")
        titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 16)
        
        descLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"feedDesc") ?? "We're always working to improve the RentALL experience, so we'd love to hear what's working and how we can do better.")"
        descLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        descLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        descLabel.font = UIFont(name: APP_FONT, size: 14)
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
