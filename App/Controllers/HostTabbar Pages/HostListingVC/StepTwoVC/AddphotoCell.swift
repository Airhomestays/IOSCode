

import UIKit
import Lottie

class AddphotoCell: UICollectionViewCell {
    
    @IBOutlet var leadingConstant: NSLayoutConstraint!
    
    @IBOutlet var checkimg: UIImageView!
    @IBOutlet weak var closebtn: UIButton!
    @IBOutlet weak var coverLabel: UILabel!
    @IBOutlet weak var addphotoimage: UIImageView!
    var lottieView: LottieAnimationView!
    
    @IBOutlet weak var coverbutton: UIButton!
    @IBOutlet weak var addNewPhotoView: UIView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var plusIconImg: UIImageView!
    @IBOutlet weak var addPhotoBtn: UIButton!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        lottieView = LottieAnimationView.init(name:"animation")
        self.coverLabel.layer.cornerRadius = coverLabel.frame.size.height/2
        self.coverLabel.layer.masksToBounds = true
        self.closebtn.layer.cornerRadius = closebtn.frame.size.height/2
        self.closebtn.layer.masksToBounds = true
        
        coverLabel.text = "   \((Utility.shared.getLanguage()?.value(forKey:"coverphoto"))!)   "
        coverLabel.font = UIFont(name: APP_FONT, size: 10)
        
        coverbutton.setTitle("", for: .normal)
        coverbutton.backgroundColor = .clear
        coverbutton.layer.cornerRadius = coverbutton.frame.size.height/2
        coverbutton.clipsToBounds = true
        
        addPhotoBtn.setTitle("", for: .normal)
        addPhotoBtn.backgroundColor = .clear
        
        addPhotoLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "addphotos") ?? "Add Photos")"
        addPhotoLabel.textColor = UIColor(named: "Title_Header")
        addPhotoLabel.font = UIFont(name: APP_FONT, size: 14.0)
        addPhotoLabel.textAlignment = .center
        addphotoimage.cornerRadius  = 10.0
        addphotoimage.layer.masksToBounds = true
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if Utility.shared.isRTLLanguage(){
        } else {
        }
    }
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:0, y:0, width:100, height:100)
        self.contentView.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll() {
        self.lottieView.play()
    }
    
    
}
