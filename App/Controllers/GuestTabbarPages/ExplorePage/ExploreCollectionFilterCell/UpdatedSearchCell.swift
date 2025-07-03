

import UIKit
import ISPageControl
import FlexiblePageControl

class UpdatedSearchCell: UICollectionViewCell, ImageScrollerDelegate {
    func pageChanged(index: Int, indexpath: Int) {
        pageControllView.setCurrentPage(at:index, animated:true)
      
    }
    
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet var thunderTop: NSLayoutConstraint!
    @IBOutlet weak var imgScrollerView: ImageScroller!

    @IBOutlet var pageControllView: FlexiblePageControl!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var listTypeLabel: UILabel!
    @IBOutlet weak var listTitleLabel: UILabel!
    @IBOutlet weak var listPriceLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingCount: UILabel!
    @IBOutlet weak var ratingImgView: UIImageView!
    @IBOutlet weak var lightImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        

        
        self.imgScrollerView.delegate = self
        self.imgScrollerView.backgroundColor = UIColor.clear
        self.imgScrollerView.isAutoScrollEnabled = false
        self.imgScrollerView.scrollTimeInterval = 2.0
        self.imgScrollerView.scrollView.bounces = false
        
        listTypeLabel.font = UIFont(name:APP_FONT, size: 12)
        listTypeLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        ratingCount.font = UIFont(name: APP_FONT, size: 11)
        listTitleLabel.font = UIFont(name:APP_FONT_MEDIUM, size: 15)
        listPriceLabel.font = UIFont(name:APP_FONT_MEDIUM, size: 11)

        
        pageControllView.cornerRadius = 5
     
        pageControllView.pageIndicatorTintColor = UIColor(named: "Review_Page_Line_Color")!
        pageControllView.currentPageIndicatorTintColor = Theme.PRIMARY_COLOR
        
        self.likeBtn.layer.cornerRadius = 18
        self.likeBtn.clipsToBounds = true
        self.likeBtn.setTitle("", for: .normal)
        imgScrollerView.contentMode = .scaleAspectFit
        imgScrollerView.clipsToBounds = true
        
        
        self.listTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
      
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        self.imgScrollerView.layer.cornerRadius = 15
        self.imgScrollerView.layer.masksToBounds = true
        self.imgScrollerView.clipsToBounds = true
        if (Utility.shared.isRTLLanguage()){
        }
        
    }
}
