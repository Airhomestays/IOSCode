
import Foundation
import UIKit

extension UIButton{
    public func config(color:UIColor,size:CGFloat,align:UIControl.ContentHorizontalAlignment,title:String){
        self.setTitleColor(color, for: .normal)
       
        self.contentHorizontalAlignment = align
      
    }
    func rotateImageViewofBtn() {
        self.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    func cornerRoundRadius() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
    }
    func cornerMiniumRadius() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    func setBorder(color:UIColor) {
        self.layer.borderWidth = 1
        self.layer.borderColor = color.cgColor
    }
    
    func floatingEffect() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.5;
    }
  
   func newEffect() {
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.init(width: 0.0, height: 2)
        self.layer.shadowRadius = 1.0;
        self.layer.shadowOpacity = 1;
    
    }
}
