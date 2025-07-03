

import UIKit

protocol ReservationTextviewCellDelegate: class {
    func didChangeText(text: String?, cell: ReservationCancelCell)
    func textendEditing(text:String?, cell:ReservationCancelCell)
}
class ReservationCancelCell: UITableViewCell,UITextViewDelegate {
    weak var delegate: ReservationTextviewCellDelegate?
    @IBOutlet weak var checkTxtView: UITextView!
    
    @IBOutlet var lineview1: UILabel!
    
    @IBOutlet var userImgButton: UIButton!
    
    
    
    @IBOutlet var lineview2: UILabel!
    @IBOutlet var missedEarningsTop: NSLayoutConstraint!
    @IBOutlet var missedEarningsHeight: NSLayoutConstraint!
    @IBOutlet var viewMissedEarnings: UIView!
    @IBOutlet var refundHeightConstant: NSLayoutConstraint!
    @IBOutlet var refundableheightConstant: NSLayoutConstraint!
    @IBOutlet var nonRefundableImage: UIImageView!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var bottomContainer: UIView!
    @IBOutlet var descriptionCancellationPolicy: UILabel!
    
     @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet var refundContainer: UIView!
    @IBOutlet var lblCancellationPolicy: UILabel!
    
    @IBOutlet weak var reservationcancelTitleLabel: UILabel!
    @IBOutlet weak var nonrefundableLabel: UILabel!
    @IBOutlet weak var hostnightLabel: UILabel!
    @IBOutlet weak var missedearningsLabel: UILabel!
    @IBOutlet weak var inLabel: UILabel!
    @IBOutlet weak var aboveCostLAbel: UILabel!
    @IBOutlet weak var cancelReservationBtn: UIButton!
    @IBOutlet weak var keepReservationBtn: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var priceLAbel: UILabel!
    @IBOutlet weak var Listimage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
   
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var NonRefundHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var NonRefundPriceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var HostnightHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var totalLabelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var NonRefundTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var PriceLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var HostNightTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var TotalLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var lblGuest: UILabel!
    
    @IBOutlet weak var missedEarningTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var missedEarningHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
           reservationcancelTitleLabel.text =   "\((Utility.shared.getLanguage()?.value(forKey:"reserveCancel"))!)"
        lblCancellationPolicy.text = "\((Utility.shared.getLanguage()?.value(forKey:"cancellations"))!)"
           missedearningsLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"missedearnings"))!)"
        
        lineview1.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        lineview2.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        
        lblGuest.textColor = UIColor(named: "Title_Header")
        dateLabel.textColor = UIColor(named: "Title_Header")
        checkTxtView.textColor = UIColor(named: "Title_Header")
        lblCancellationPolicy.textColor = UIColor(named: "Title_Header")
        
        bottomContainer.backgroundColor = UIColor(named: "colorController")
        cancelReservationBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"cancelreservation"))!)", for: .normal)
          nonrefundableLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nonrefundable"))!)"
        inLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"refundable"))!)"
        
        
           aboveCostLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"refundcost"))!)"
        dateLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"canceltellme"))!)"
      
        
        
        aboveCostLAbel.textColor = UIColor(named: "searchPlaces_TextColor")
        
         reservationcancelTitleLabel.textColor = UIColor(named: "searchPlaces_TextColor")
         hostnightLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        
        nonrefundableLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        priceLAbel.textColor = UIColor(named: "searchPlaces_TextColor")
        inLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        missedearningsLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        totalLabel.textColor = UIColor(named: "searchPlaces_TextColor")
         cancelReservationBtn.backgroundColor = Theme.SECONDARY_COLOR
        nameLabel.font = UIFont(name: APP_FONT, size: 14)
        lblGuest.font = UIFont(name: APP_FONT_SEMIBOLD, size: 14)
        
        lblCancellationPolicy.font = UIFont(name: APP_FONT_SEMIBOLD, size: 14)
        descriptionCancellationPolicy.font = UIFont(name: APP_FONT, size: 14)
        
         dateLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 14)
         nonrefundableLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
         missedearningsLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
         inLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
         priceLAbel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
         totalLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        aboveCostLAbel.font = UIFont(name: APP_FONT, size: 14)
        
         reservationcancelTitleLabel.font = UIFont(name: APP_FONT, size: 14)
         hostnightLabel.font = UIFont(name: APP_FONT, size: 14)
        
        keepReservationBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        cancelReservationBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        
        cancelReservationBtn.layer.cornerRadius = (cancelReservationBtn.frame.size.height / 2)
        cancelReservationBtn.layer.masksToBounds = true
        if(Utility.shared.isRTLLanguage()) {
            priceLAbel.textAlignment = .left
            totalLabel.textAlignment = .left
        }
        checkTxtView.font = UIFont(name: APP_FONT, size: 12)
        checkTxtView.delegate = self
        checkTxtView.isEditable = true
        checkTxtView.isScrollEnabled = true
      
        placeholderLabel.font = checkTxtView.font
        placeholderLabel.numberOfLines = 0
        placeholderLabel.sizeToFit()

        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !checkTxtView.text.isEmpty
        placeholderLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        
        let shadowSize2 : CGFloat = 3.0
        let shadowPath1 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                    y: -shadowSize2 / 2,
                                                    width: self.bottomContainer.frame.size.width + shadowSize2,
                                                    height: self.bottomContainer.frame.size.height + shadowSize2))
        
        self.bottomContainer.layer.masksToBounds = false
               self.bottomContainer.layer.shadowColor = Theme.TextLightColor.cgColor
               self.bottomContainer.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
               self.bottomContainer.layer.shadowOpacity = 0.3
               self.bottomContainer.layer.shadowPath = shadowPath1.cgPath
        
        
    }

    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        delegate?.didChangeText(text: textView.text, cell: self)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textendEditing(text: textView.text, cell: self)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    override func layoutSubviews() {
        refundContainer.halfroundedCorners(corners:[.topLeft, .bottomRight] , radius: 15)
        viewMissedEarnings.halfroundedCorners(corners:[.topLeft, .bottomRight], radius: 15)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
