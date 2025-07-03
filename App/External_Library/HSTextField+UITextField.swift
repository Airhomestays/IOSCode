
import Foundation
import UIKit

extension UITextField{

public func config(color:UIColor,size:CGFloat, align:NSTextAlignment,placeHolder:String){
    self.textColor = color
    self.textAlignment = align
   
    }

    func cornerRoundRadius() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
    }

    func cornerMiniumRadius() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }

    func setBorder() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }

    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text)
    }
  
    func setLeftPadding(){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPadding(){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
  

    func isEmpty() -> Bool {
        if  (self.text! == "") || (self.text! == "NULL") || (self.text! == "(null)")  || (self.text! == "<null>") || (self.text! == "Json Error") || (self.text! == "0") || (self.text!.isEmpty) ||  self.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }
}
