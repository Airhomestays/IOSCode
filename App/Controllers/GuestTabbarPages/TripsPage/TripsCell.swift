

import UIKit
import SwiftMessages

class TripsCell: UITableViewCell {
    @IBOutlet var heightConstraints: NSLayoutConstraint!
    
    @IBOutlet var phoneNoHeight: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var listTitleLable: UILabel!
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var addressLAbel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var approvedLabel: UILabel!
    
    @IBOutlet var lineview: UILabel!
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var moreImgView: UIImageView!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var moreLabel: UILabel!
    
    
    @IBOutlet var dateTop: NSLayoutConstraint!
    @IBOutlet var btnEmail: UIButton!
    
    @IBOutlet var emailHeightConstant: NSLayoutConstraint!
    
    @IBOutlet var btnPhoneno: UIButton!
    
    @IBOutlet var phoneTop: NSLayoutConstraint!
    
    
    @IBOutlet var userImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImg.layer.cornerRadius = userImg.frame.size.height / 2
        userImg.layer.masksToBounds = true
        
        nameLabel.textColor = UIColor(named: "Title_Header")
        nameLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 15)
        nameLabel.backgroundColor = .clear
        
        
        lineview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        
        
        priceLabel.textColor = UIColor(named: "Title_Header")
        priceLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        priceLabel.backgroundColor = .clear
        
        moreLabel.textColor = Theme.PRIMARY_COLOR
        moreLabel.font = UIFont(name: APP_FONT, size: 12.0)
        moreLabel.backgroundColor = .clear
        moreLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"more"))!)"
        
        dateLabel.textColor = UIColor(named: "Title_Header")
        dateLabel.font = UIFont(name: APP_FONT, size: 12)
        dateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        dateLabel.backgroundColor = .clear
        
        listTitleLable.textColor = Theme.PRIMARY_COLOR
        listTitleLable.font = UIFont(name: APP_FONT, size: 14)
        listTitleLable.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        listTitleLable.backgroundColor = .clear
        
        titleBtn.setTitle("", for: .normal)
        titleBtn.backgroundColor = .clear
        
        addressLAbel.textColor = UIColor(named: "Title_Header")
        addressLAbel.font = UIFont(name: APP_FONT, size: 12)
        addressLAbel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        addressLAbel.backgroundColor = .clear
        
        
        approvedLabel.layer.cornerRadius = approvedLabel.frame.size.height/2
        approvedLabel.layer.masksToBounds = true
        approvedLabel.font = UIFont(name: APP_FONT, size: 12.0)
        approvedLabel.textColor = .white
        
        
        btnEmail.titleLabel?.font = UIFont(name: APP_FONT, size: 12)
        btnEmail.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        btnEmail.backgroundColor = .clear
        
        btnPhoneno.titleLabel?.font = UIFont(name: APP_FONT, size: 12)
        btnPhoneno.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        btnPhoneno.backgroundColor = .clear
        
        
        btnPhoneno.titleLabel?.textColor = Theme.PRIMARY_COLOR
        btnEmail.titleLabel?.textColor  = Theme.PRIMARY_COLOR
        
        btnEmail.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        btnPhoneno.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        
        moreBtn.setTitle("", for: .normal)
        moreBtn.backgroundColor = .clear
        
        bgView.backgroundColor = UIColor(named: "Button_Grey_Color")
        bgView.layer.cornerRadius = 4.0
        bgView.clipsToBounds = true
        
        moreView.backgroundColor = .clear
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
