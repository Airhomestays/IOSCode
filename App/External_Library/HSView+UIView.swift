
import Foundation
import UIKit

extension UIView{
  
    func elevationEffect() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 0.2;

    }
    func cornerViewRadius() {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    func blurEffect() {
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.bounds
        self.addSubview(blurView)
    }
  
    func cornerViewMiniumRadius() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
   
    func removeCornerRadius() {
        self.layer.cornerRadius = 0.0
        self.layer.masksToBounds = false
        self.clipsToBounds =  false
    }
    func viewRadius(radius:CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
  
    func applyGradient()  {
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.frame.size
        gradientLayer.colors = Theme.LOGIN_GRADIENT_PRIMARY_COLOR
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let gradientLayer1:CAGradientLayer = CAGradientLayer()
        gradientLayer1.frame.size = self.frame.size
        gradientLayer1.colors = Theme.WHITE_COLOR
        gradientLayer1.startPoint = CGPoint(x: 0.0, y: 0.2)
        gradientLayer1.endPoint = CGPoint(x: 1.0, y: 0.5)
       self.layer.insertSublayer(gradientLayer, below: gradientLayer1)
      
    }
    
    func removeGrandient()  {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    func specificCornerRadius(radius:Int)  {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight , .topLeft, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath

        self.layer.mask = rectShape
    }
    
 
    func setViewBorder(color:UIColor) {
        self.cornerViewRadius()
        self.layer.borderWidth = 2
        self.layer.borderColor = color.cgColor
    }
    
}


