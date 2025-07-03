
import UIKit
import Lottie
class WhishlistCell: UICollectionViewCell {

    @IBOutlet weak var entireView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var whishImage: UIImageView!
    
    var lottieView1: LottieAnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont(name: APP_FONT, size: 14)
        titleLabel.textColor =  UIColor(named: "searchPlaces_TextColor")
        countLabel.font = UIFont(name: APP_FONT, size: 14)
        countLabel.textColor =  UIColor(named: "searchPlaces_TextColor")
        self.whishImage.layer.cornerRadius = 15
        self.whishImage.layer.masksToBounds = true
    }
    func lottieAnimationView(){
        lottieView1 = LottieAnimationView.init(name:"animation")
        lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:(self.whishImage.frame.size.width)/2-45, y:(self.whishImage.frame.size.height)/2-45, width:100, height:100)
        self.contentView.addSubview(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor.clear
        self.lottieView1.layer.cornerRadius = 6.0
        self.lottieView1.clipsToBounds = true
        self.likeImage.isHidden = true
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
       
    }
    @objc func autoscroll()
    {
        self.lottieView1.play()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
   

}
