
import UIKit
import SwiftMessages

class CompletedCell: UITableViewCell {
    @IBOutlet weak var completeView: UIView!
    
    @IBOutlet var linelbl1: UILabel!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet weak var nextimage: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var listingprogressLabel: UILabel!
    
    @IBOutlet var lineLabel: UILabel!
    @IBOutlet var bottomConstant: NSLayoutConstraint!
    @IBOutlet var heightConstant: NSLayoutConstraint!
    @IBOutlet var submitLabel: UILabel!
    
    @IBOutlet var verificationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var previewBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        linelbl1.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        submitLabel.isHidden = true
        if(IS_IPHONE_XR || IS_IPHONE_PLUS)
        {
            self.completeView.frame.size.width = FULLWIDTH - 40
        }
        else if IS_IPHONE_5
        {
            self.completeView.frame.size.width = FULLWIDTH - 40
        }
        progressBarView.transform = progressBarView.transform.scaledBy(x: 1, y:2)
        completeView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.completeView.cornerRadius = 15.0
        self.completeView.layer.masksToBounds = true
        
        self.listImage.cornerRadius = 15.0
        self.listImage.layer.masksToBounds = true

        self.listImage.layer.masksToBounds = true
        self.publishBtn.layer.cornerRadius = 16
        self.publishBtn.layer.masksToBounds = true
    
        self.previewBtn.layer.cornerRadius = 4.0
        self.previewBtn.layer.masksToBounds = true
        
        self.editBtn.layer.cornerRadius =  self.editBtn.frame.size.height/2
        self.editBtn.layer.masksToBounds = true
        self.editBtn.layer.borderColor = UIColor.clear.cgColor
        self.editBtn.layer.borderWidth = 1
        
        
        
        self.nextimage.image = self.nextimage.image?.withRenderingMode(.alwaysTemplate)
        self.nextimage.tintColor =  UIColor(named: "Title_Header")
        previewBtn.setTitle(" \((Utility.shared.getLanguage()?.value(forKey:"more"))!) ", for:.normal)
        progressBarView.progressTintColor = Theme.PRIMARY_COLOR
        publishBtn.backgroundColor = Theme.Button_BG
        previewBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        publishBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        
        editBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        submitLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        verificationLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 13)
        submitLabel.textColor = UIColor.clear
        editBtn.setTitleColor(Theme.Button_BG, for: .normal)
        previewBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 13)
        titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        updateDateLabel.font = UIFont(name: APP_FONT, size: 13)
        listingprogressLabel.font = UIFont(name: APP_FONT, size: 13)
        
        titleLabel.textColor = UIColor(named: "Title_Header")
        updateDateLabel.textColor = UIColor(named: "Title_Header")
        listingprogressLabel.textColor = UIColor(named: "Title_Header")
        if Utility.shared.isRTLLanguage() {
            nextimage.performRTLTransform()
            
        }
        
    }
    
    override func layoutSubviews() {
        self.submitLabel.layer.cornerRadius =  self.submitLabel.frame.size.height/2
        self.submitLabel.layer.masksToBounds = true
        self.submitLabel.layer.borderColor = UIColor.clear.cgColor
        self.submitLabel.layer.borderWidth = 1
        
        self.editBtn.layer.cornerRadius =  self.editBtn.frame.size.height/2
        self.editBtn.layer.masksToBounds = true
        self.editBtn.layer.borderColor = Theme.Button_BG.cgColor
        self.editBtn.layer.borderWidth = 1
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
