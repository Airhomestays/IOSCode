
import UIKit

class AirbnbDatePickerMonthHeader: BaseCell {

    var monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "Title_Header")
        
        label.font = UIFont(name: APP_FONT_SEMIBOLD, size: 18.0)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(monthLabel)
        
        monthLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        monthLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        monthLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        monthLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
