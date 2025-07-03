

import UIKit
import SwiftMessages

protocol AirbnbDatePickerFooterDelegate {
    func didSave()
}

class AirbnbDatePickerFooter: UIView {
    
    var delegate: AirbnbDatePickerFooterDelegate?
    var isSaveEnabled: Bool? {
        didSet {
            if let enabled = isSaveEnabled, enabled {
            } else {
            }
        }
    }
    
    lazy var minimumbookLabel: UILabel = {
        let label = UILabel()
            
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        if(Utility.shared.minimumstay != 0)
        {

            if Utility.shared.minimumstay > 1{
                label.text = "\((Utility.shared.getLanguage()?.value(forKey:"nightrequire"))!) \(Utility.shared.minimumstay) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
            }else{
                label.text = "\((Utility.shared.getLanguage()?.value(forKey:"nightrequire"))!) \(Utility.shared.minimumstay) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
            }
        }
        else{
         label.text = ""
        }
        label.font = UIFont(name: APP_FONT, size: 14.0)
        label.textColor = UIColor(named: "Title_Header")
        
        label.numberOfLines = 4
        return label
    }()
    
    lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = Theme.Button_BG
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"save"))!)", for: .normal)
        btn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 18.0)
        btn.addTarget(self, action: #selector(AirbnbDatePickerFooter.handleSave), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = Theme.PRIMARY_DARK_COLOR
        
        saveButton.layer.cornerRadius = 25
        saveButton.clipsToBounds = true
            if(Utility.shared.isfromcheckingPage)
                   {
                    if Utility.shared.isRTLLanguage()
                    {
                   addSubview(saveButton)
                       if(IS_IPHONE_XR || IS_IPHONE_PLUS)
                       {
                   saveButton.centerXAnchor.constraint(equalTo: centerXAnchor,constant:-150).isActive = true
                       }
                       else
                       {
                         saveButton.centerXAnchor.constraint(equalTo: centerXAnchor,constant:-140).isActive = true
                       }
                   saveButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                   saveButton.heightAnchor.constraint(equalTo: heightAnchor, constant: -50).isActive = true
                   saveButton.widthAnchor.constraint(equalTo: widthAnchor, constant:-320).isActive = true
                   minimumbookLabel.layer.cornerRadius = minimumbookLabel.frame.size.width/2
                   minimumbookLabel.layer.masksToBounds = true
                   addSubview(minimumbookLabel)
                   
                   minimumbookLabel.centerXAnchor.constraint(equalTo: centerXAnchor,constant: 80).isActive = true
                   minimumbookLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                   minimumbookLabel.heightAnchor.constraint(equalTo: heightAnchor, constant: -50).isActive = true
                   minimumbookLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -160).isActive = true
                    }
                    else{
                        addSubview(minimumbookLabel)
                                   if(IS_IPHONE_XR || IS_IPHONE_PLUS)
                                   {
                                       minimumbookLabel.centerXAnchor.constraint(equalTo: centerXAnchor,constant:-60).isActive = true
                                   }
                                   else
                                   {
                                       minimumbookLabel.centerXAnchor.constraint(equalTo: centerXAnchor,constant:-55).isActive = true
                                   }
                               minimumbookLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                               minimumbookLabel.heightAnchor.constraint(equalTo: heightAnchor, constant: -10).isActive = true
                               minimumbookLabel.widthAnchor.constraint(equalTo: widthAnchor, constant:-128).isActive = true
                               minimumbookLabel.layer.cornerRadius = minimumbookLabel.frame.size.width/2
                               minimumbookLabel.layer.masksToBounds = true
                               addSubview(saveButton)
                               
                               saveButton.centerXAnchor.constraint(equalTo: centerXAnchor,constant: 143).isActive = true
                               saveButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                               saveButton.heightAnchor.constraint(equalTo: heightAnchor, constant: -50).isActive = true
                               saveButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -300).isActive = true
                    }
                   }
                   else{
                       addSubview(saveButton)
                       
                       saveButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                       saveButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                       saveButton.heightAnchor.constraint(equalTo: heightAnchor, constant: -50).isActive = true
                       saveButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -30).isActive = true
                   }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleSave() {
        if let del = delegate {
            del.didSave()
        }
    }
}
