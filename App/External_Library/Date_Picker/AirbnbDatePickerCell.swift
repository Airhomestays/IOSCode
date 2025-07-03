
import UIKit
import SwiftMessages

class AirbnbDatePickerCell: BaseCell {
    
    var type: AirbnbDatePickerCellType! = []
    var isFromFilter = false
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: APP_FONT_MEDIUM, size: 12.0)
        label.textColor = UIColor(named: "Title_Header")
        return label
    }()
    
    var highlightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(dateLabel)
        
        dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        dateLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        addSubview(highlightView)
        
        highlightView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        highlightView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        highlightView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        highlightView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func configureCell() {
        dateLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size:14)
         if type.contains(.Selected) || type.contains(.SelectedStartDate) || type.contains(.SelectedEndDate) || type.contains(.InBetweenDate) {

                 dateLabel.layer.cornerRadius = 0
                 dateLabel.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                 dateLabel.layer.borderWidth = 1
                  dateLabel.layer.backgroundColor = Theme.PRIMARY_COLOR.cgColor
                 dateLabel.layer.mask = nil
                  dateLabel.textColor = UIColor.white

             if type.contains(.SelectedStartDate) && type.contains(.SelectedEndDate) {
                 let side = frame.size.width / 2
                 let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: Utility.shared.isRTLLanguage() ? [.topRight, .bottomRight] : [.topLeft, .bottomLeft, .topRight,.bottomRight], cornerRadii: CGSize(width: side, height: side))
                 let shape = CAShapeLayer()
                 shape.path = maskPath.cgPath
                 dateLabel.layer.mask = shape
                 }
               else if type.contains(.SelectedStartDate) {
                let side = frame.size.width / 2
                let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: Utility.shared.isRTLLanguage() ? [.topRight, .bottomRight] : [.topLeft, .bottomLeft], cornerRadii: CGSize(width: side, height: side))
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.height, y: frame.size.width), radius: 52, startAngle: 40, endAngle: 0, clockwise: false)
                let shape = CAShapeLayer()
                shape.path = maskPath.cgPath
                dateLabel.layer.mask = shape
            }else if type.contains(.SelectedEndDate) {
                let side = frame.size.width / 2
                let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: Utility.shared.isRTLLanguage() ? [.topLeft, .bottomLeft] : [.topRight, .bottomRight], cornerRadii: CGSize(width: side, height: side))
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: 0, y: frame.size.width), radius: 52, startAngle: 40, endAngle: 0, clockwise: false)
                let shape = CAShapeLayer()
                shape.path = maskPath.cgPath
                dateLabel.layer.mask = shape
                
            } else if !type.contains(.InBetweenDate) {
                dateLabel.layer.cornerRadius = dateLabel.frame.size.width / 2
                dateLabel.layer.masksToBounds = true
            }
             else {
                 if(dateLabel.text == "" || dateLabel.text == nil) {
                                  
                 dateLabel.layer.cornerRadius = 0
                                 dateLabel.layer.borderColor = UIColor.clear.cgColor
                                 dateLabel.layer.borderWidth = 1
                                 dateLabel.layer.backgroundColor = UIColor.clear.cgColor
                                 dateLabel.layer.mask = nil
                                  dateLabel.textColor = UIColor.white
                 }
             }
             
            
        }
        
       
        else if type.contains(.PastDate) {
            
            dateLabel.layer.cornerRadius = 0
            dateLabel.layer.borderColor = UIColor.clear.cgColor
            dateLabel.layer.borderWidth = 0
            dateLabel.layer.backgroundColor = UIColor.clear.cgColor
            dateLabel.layer.mask = nil
            dateLabel.textColor = UIColor.lightGray
            dateLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size:14)
            
            if type.contains(.Today) {
                if !isFromFilter {
                    
               
                    dateLabel.layer.cornerRadius = self.frame.size.width / 2
                    dateLabel.layer.borderColor = Theme.hostCalendarDay_Color.cgColor
                    dateLabel.layer.borderWidth = 1
                    dateLabel.layer.backgroundColor = UIColor.clear.cgColor
                    dateLabel.layer.mask = nil
                    dateLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size:14)
                    dateLabel.textColor = Theme.hostCalendarDay_Color
                    dateLabel.textAlignment = .center
                }
                
                
            }

        }  else if type.contains(.disableCheckInDate){
            dateLabel.layer.borderColor = UIColor.clear.cgColor
            dateLabel.layer.borderWidth = 0
            dateLabel.layer.backgroundColor = UIColor.clear.cgColor
            dateLabel.textColor =  UIColor(named: "Title_Header")!.withAlphaComponent(0.5)
            if type.contains(.Today) {
                if !isFromFilter {
                    
               
                    dateLabel.layer.cornerRadius = self.frame.size.width / 2
                    dateLabel.layer.borderColor = Theme.hostCalendarDay_Color.cgColor
                    dateLabel.layer.borderWidth = 1
                    dateLabel.layer.backgroundColor = UIColor.clear.cgColor
                    dateLabel.layer.mask = nil
                    dateLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size:14)
                    dateLabel.textColor = Theme.hostCalendarDay_Color
                    dateLabel.textAlignment = .center
                }
                
                
            }
        }
        
        else if type.contains(.Today) {
            if isFromFilter {
                dateLabel.layer.cornerRadius = self.frame.size.width / 2
                dateLabel.layer.borderColor = UIColor.clear.cgColor
                dateLabel.layer.borderWidth = 1
                dateLabel.layer.backgroundColor = UIColor.clear.cgColor
                dateLabel.layer.mask = nil
                dateLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size:14)
                dateLabel.textColor = UIColor(named: "Title_Header")
            }
            else {
                dateLabel.layer.cornerRadius = self.frame.size.width / 2
                dateLabel.layer.borderColor =  UIColor(named: "Title_Header")?.cgColor
                dateLabel.layer.borderWidth = 1
                dateLabel.layer.backgroundColor = UIColor.clear.cgColor
                dateLabel.layer.mask = nil
                dateLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size:14)
                dateLabel.textColor = UIColor(named: "Title_Header")
                
                if type.contains(.disableCheckInDate) || type.contains(.PastDate){
                    
                    if !isFromFilter {
                        
                   
                        dateLabel.layer.cornerRadius = self.frame.size.width / 2
                        dateLabel.layer.borderColor = Theme.hostCalendarDay_Color.cgColor
                        dateLabel.layer.borderWidth = 1
                        dateLabel.layer.backgroundColor = UIColor.clear.cgColor
                        dateLabel.layer.mask = nil
                        dateLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size:14)
                        dateLabel.textColor = Theme.hostCalendarDay_Color
                        dateLabel.textAlignment = .center
                    }
                }
            }
            
            
        }
        
        else {
            
            dateLabel.layer.cornerRadius = 0
            dateLabel.layer.borderColor = UIColor.clear.cgColor
            dateLabel.layer.borderWidth = 0
            dateLabel.layer.backgroundColor = UIColor.clear.cgColor
            dateLabel.layer.mask = nil
            dateLabel.textColor = UIColor(named: "Title_Header")
            if type.contains(.Today) {
                if !isFromFilter {
                    
               
                    dateLabel.layer.cornerRadius = self.frame.size.width / 2
                    dateLabel.layer.borderColor = Theme.hostCalendarDay_Color.cgColor
                    dateLabel.layer.borderWidth = 1
                    dateLabel.layer.backgroundColor = UIColor.clear.cgColor
                    dateLabel.layer.mask = nil
                    dateLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size:14)
                    dateLabel.textColor = Theme.hostCalendarDay_Color
                    dateLabel.textAlignment = .center
                }
                
                
            }

      
        }
        
        
        if type.contains(.Highlighted) {
            highlightView.backgroundColor = UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 0.6)
            highlightView.layer.cornerRadius = frame.size.width / 2
            Utility.shared.ContainsTodayDate = true
            
            
        } else {
            highlightView.backgroundColor = UIColor.clear
        
        }
    }
}

struct AirbnbDatePickerCellType: OptionSet {
    let rawValue: Int
    
    static let Date = AirbnbDatePickerCellType(rawValue: 1 << 0)
    static let Empty = AirbnbDatePickerCellType(rawValue: 1 << 1)
    static let PastDate = AirbnbDatePickerCellType(rawValue: 1 << 2)
    static let Today = AirbnbDatePickerCellType(rawValue: 1 << 3)
    static let Selected = AirbnbDatePickerCellType(rawValue: 1 << 4)
    static let SelectedStartDate = AirbnbDatePickerCellType(rawValue: 1 << 5)
    static let SelectedEndDate = AirbnbDatePickerCellType(rawValue: 1 << 6)
    static let InBetweenDate = AirbnbDatePickerCellType(rawValue: 1 << 7)
    static let Highlighted = AirbnbDatePickerCellType(rawValue: 1 << 8)
    
    static let disableCheckInDate = AirbnbDatePickerCellType(rawValue: 1 << 9)
}

