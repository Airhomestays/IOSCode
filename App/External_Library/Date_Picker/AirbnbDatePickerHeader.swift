
import UIKit
import SwiftMessages

class AirbnbDatePickerHeader: UIView {
    
    var calendar = Calendar.current
    var dateDayNameFormat = DateFormatter()
    var dateMonthYearFormat = DateFormatter()
    var heightConst : NSLayoutConstraint?
    var topConst : NSLayoutConstraint?
    var leftConst : NSLayoutConstraint?
    
    var selectedStartDate: Date? {
        didSet {
            if let date = selectedStartDate {
               
                topConst?.constant = 35

                if Utility.shared.isRTLLanguage() {
                   endDayLabel.text = "\(dateDayNameFormat.string(from: date))"
                    endDateLabel.text = dateMonthYearFormat.string(from: date)
                } else {
                startDayLabel.text = "\(dateDayNameFormat.string(from: date))"
                    startDateLabel.text = dateMonthYearFormat.string(from: date) }
            } else {
               
                topConst?.constant = 25

                    if Utility.shared.isRTLLanguage() {
                        endDayLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkin"))!)"
                        endDateLabel.text = ""
                   
                    } else {
                startDayLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkin"))!)"
                        startDateLabel.text = "" }

            }
        }
    }
    var selectedEndDate: Date? {
        didSet {
            slashView.topAnchor.constraint(equalTo: topAnchor, constant: 55).isActive = true
            slashView.heightAnchor.constraint(equalToConstant: 85).isActive = true
           
            slashView.layoutIfNeeded()
            if let date = selectedEndDate {

                if Utility.shared.isRTLLanguage() {
                    startDayLabel.text = "\(dateDayNameFormat.string(from: date))"
                    startDateLabel.text = dateMonthYearFormat.string(from: date)
                } else {
                endDayLabel.text = "\(dateDayNameFormat.string(from: date))"
                    endDateLabel.text = dateMonthYearFormat.string(from: date) }
            } else {
             
                slashView.topAnchor.constraint(equalTo: topAnchor, constant: 35).isActive = true
                slashView.heightAnchor.constraint(equalToConstant: 65).isActive = true

                if Utility.shared.isRTLLanguage() {
                    startDayLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkout"))!)"
                    startDateLabel.text = ""
                } else {
                endDayLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkout"))!)"
                endDateLabel.text = ""
                    }
            }
        }

    }
    
    var startDayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

            label.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkin"))!)"

        label.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        label.textColor = UIColor(named: "Title_Header")
        
        label.font = UIFont(name: APP_FONT_MEDIUM, size: 20)
        return label
    }()
    
    var startDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        if(Utility.shared.isfromcheckingPage)
        {
        label.text = ""
        }
        else{
            label.text = ""
        }
        label.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        label.textColor = UIColor(named: "Title_Header")
         
        label.font = UIFont(name: APP_FONT_MEDIUM, size: 20)
        return label
    }()
    
    var endDayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

            label.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkout"))!)"
        label.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        label.textColor = UIColor(named: "Title_Header")
        
        label.font = UIFont(name: APP_FONT_MEDIUM, size: 20)
        return label
    }()
    
    var endDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        if(Utility.shared.isfromcheckingPage)
        {
        label.text = ""
        }
        else{
            label.text = ""
        }
        label.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        label.textColor = UIColor(named: "Title_Header")
        
        label.font = UIFont(name: APP_FONT_MEDIUM, size: 20)
        return label
    }()
    
    var dayLabels: [UILabel] = {
        var days = ["S", "M", "T", "W", "T", "F", "S"]
        if Utility.shared.isRTLLanguage(){
            if (Utility.shared.getAppLanguageCode()! == "ar"){
                days = ["س","م", "تي", "دبليو", "تي", "يليها", "س"]
            } else if (Utility.shared.getAppLanguageCode()! == "he"){
                days = ["ס","ס","ס","פ","ט","אָ","ט"]
            }
          
        }
        var labels = [UILabel]()
        
        for (i, day) in days.enumerated() {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = day
            label.textAlignment = .center
            label.textColor = UIColor(named: "Title_Header")
            label.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
            labels.append(label)
        }
        
        return labels
    }()
    
    var slashView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var slashWidthConstraint: NSLayoutConstraint?
    var slash: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "Title_Header")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        dateDayNameFormat.dateFormat = "EEE"

        dateMonthYearFormat.dateFormat = "MMM d"

        setupStartDayLabel()
        setupStartDateLabel()
        
        setupEndDayLabel()
        setupEndDateLabel()
        
        setupSlashView()
        
        setupDayLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        slashWidthConstraint?.constant = sqrt(pow(slashView.frame.size.width, 2) + pow(slashView.frame.size.height, 2))
        slash.transform = CGAffineTransform(rotationAngle: -atan2(slashView.frame.size.height, slashView.frame.size.width))
    }

    
    func setupStartDayLabel() {
        addSubview(startDayLabel)
        
        startDayLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        startDayLabel.topAnchor.constraint(equalTo: topAnchor, constant: 45).isActive = true
        startDayLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        startDayLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
      
    }
    
    func setupStartDateLabel() {
        addSubview(startDateLabel)
        
        startDateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        startDateLabel.topAnchor.constraint(equalTo: startDayLabel.bottomAnchor).isActive = true
        startDateLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        startDateLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupEndDayLabel() {
        addSubview(endDayLabel)
        
        endDayLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        endDayLabel.topAnchor.constraint(equalTo: topAnchor, constant: 45).isActive = true
        endDayLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        endDayLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
      
    }
    
    func setupEndDateLabel() {
        addSubview(endDateLabel)
        
        endDateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        endDateLabel.topAnchor.constraint(equalTo: endDayLabel.bottomAnchor).isActive = true
        endDateLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        endDateLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupSlashView() {
        addSubview(slashView)
        
       
       topConst = slashView.topAnchor.constraint(equalTo: topAnchor, constant: 15)
        topConst?.isActive = true
        
        if Utility.shared.isRTLLanguage(){
            if IS_IPHONE_XR || IS_IPHONE_PLUS{
                
                leftConst = slashView.leftAnchor.constraint(equalTo: startDayLabel.rightAnchor, constant: 50)
                leftConst?.isActive = true
                heightConst = slashView.heightAnchor.constraint(equalToConstant: 50)
                heightConst?.isActive = true
                
            }else{
                leftConst = slashView.leftAnchor.constraint(equalTo: startDayLabel.rightAnchor, constant: 50)
                leftConst?.isActive = true
                heightConst = slashView.heightAnchor.constraint(equalToConstant: 50)
                heightConst?.isActive = true
            }
         
         
            slashView.rightAnchor.constraint(equalTo: endDayLabel.leftAnchor, constant: 50).isActive = true
        }else{
            if IS_IPHONE_XR || IS_IPHONE_PLUS{
                
                slashView.leftAnchor.constraint(equalTo: startDayLabel.rightAnchor, constant: 10).isActive = true
                heightConst = slashView.heightAnchor.constraint(equalToConstant: 65)
                heightConst?.isActive = true
                
            }else{
                slashView.leftAnchor.constraint(equalTo: startDayLabel.rightAnchor, constant: -30).isActive = true
                heightConst = slashView.heightAnchor.constraint(equalToConstant: 65)
                heightConst?.isActive = true
            }
         
       
            slashView.rightAnchor.constraint(equalTo: endDayLabel.leftAnchor, constant: -30).isActive = true
        }
        
        
        slashView.addSubview(slash)
        
        slash.centerXAnchor.constraint(equalTo: slashView.centerXAnchor).isActive = true
        slash.centerYAnchor.constraint(equalTo: slashView.centerYAnchor).isActive = true
        slash.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        slashWidthConstraint = slash.widthAnchor.constraint(equalToConstant: 0)
        slashWidthConstraint?.isActive = true
        
       
    }
    
    func setupDayLabels() {
        for (i, label) in dayLabels.enumerated() {
            label.backgroundColor =  UIColor(named: "becomeAHostStep_Color")
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: i == 0 ? leftAnchor : dayLabels[i - 1].rightAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 25).isActive = true
            label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/CGFloat(dayLabels.count)).isActive = true
        }
    }
}
