
import UIKit


protocol AirbnbCounterDelegate {
    func counter(_ counter: AirbnbCounter, didUpdate count: Int)
}

class AirbnbCounter: UIView {
    
    var delegate: AirbnbCounterDelegate?
    var fieldID: String?
    
    var maxCount: Int? {
        didSet {
            updateMaxMinCount()
        }
    }
    var minCount: Int?{
        didSet {
            updateMaxMinCount()
        }
    }
    
    var firstLayout: Bool = true
    var count: Int = 0 {
        didSet {
            countLabel.text = "\(count)"
            
            updateMaxMinCount()
            
            if let del = delegate {
                del.counter(self, didUpdate: count)
            }
        }
    }
    

    var caption: String? {
        didSet {
            captionLabel.text = caption
        }
    }
    
    var subCaption: String? {
        didSet {
            subCaptionLabel.text = subCaption
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        
        count = minCount ?? 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var captionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: APP_FONT_MEDIUM, size: 18)

        view.textColor = UIColor(named: "Title_Header")
        return view
    }()
    
    var subCaptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: APP_FONT, size: 15)
 
        view.textColor = UIColor(named: "Title_Header")
        return view
    }()
    
    lazy var decrementButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "substract", in: Bundle(for: AirbnbOccupantFilter.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
         button.tintColor = Theme.PRIMARY_COLOR
        button.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        button.addTarget(self, action: #selector(AirbnbCounter.handleDecrement), for: .touchUpInside)
        button.adjustsImageWhenHighlighted = false

        button.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = button.frame.size.width / 2
        return button
    }()
    
    lazy var countLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.font = UIFont(name: APP_FONT, size: 22)
        view.textColor = UIColor(named: "Title_Header")
        view.textAlignment = .center
        view.text = "\(self.count)"
        return view
    }()
    
    var incrementButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "add", in: Bundle(for: AirbnbOccupantFilter.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = Theme.PRIMARY_COLOR
        button.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        button.addTarget(self, action: #selector(AirbnbCounter.handleIncrement), for: .touchUpInside)
        button.adjustsImageWhenHighlighted = false

        button.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = button.frame.size.width / 2
        return button
    }()
    
    func setupViews() {
        
        addSubview(incrementButton)
        if Utility.shared.isRTLLanguage(){
            incrementButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            incrementButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = false
        }else{
            incrementButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            incrementButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = false
        }
        incrementButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
        incrementButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        incrementButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        addSubview(countLabel)
        if Utility.shared.isRTLLanguage(){
            countLabel.leftAnchor.constraint(equalTo: incrementButton.rightAnchor).isActive = true
            countLabel.rightAnchor.constraint(equalTo: incrementButton.leftAnchor).isActive = false
        }else{
            countLabel.rightAnchor.constraint(equalTo: incrementButton.leftAnchor).isActive = true
            countLabel.leftAnchor.constraint(equalTo: incrementButton.rightAnchor).isActive = false
        }
        countLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        countLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        countLabel.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        addSubview(decrementButton)
        if Utility.shared.isRTLLanguage(){
            decrementButton.rightAnchor.constraint(equalTo: countLabel.leftAnchor).isActive = false
            decrementButton.leftAnchor.constraint(equalTo: countLabel.rightAnchor).isActive = true
        }else{
            decrementButton.rightAnchor.constraint(equalTo: countLabel.leftAnchor).isActive = true
            decrementButton.leftAnchor.constraint(equalTo: countLabel.rightAnchor).isActive = false
        }
        decrementButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
        decrementButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        decrementButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        addSubview(captionLabel)
        if Utility.shared.isRTLLanguage(){

            captionLabel.leftAnchor.constraint(equalTo: decrementButton.rightAnchor).isActive = true
            

            captionLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }else{
            captionLabel.rightAnchor.constraint(equalTo: decrementButton.leftAnchor).isActive = true

            captionLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true

        }
        captionLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        captionLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 2/3).isActive = true
        
        
        addSubview(subCaptionLabel)
        if Utility.shared.isRTLLanguage(){

            subCaptionLabel.leftAnchor.constraint(equalTo: decrementButton.rightAnchor).isActive = true
 
            subCaptionLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }else{
            subCaptionLabel.rightAnchor.constraint(equalTo: decrementButton.leftAnchor).isActive = true

            subCaptionLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true

        }
        subCaptionLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor).isActive = true
        subCaptionLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/3).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        decrementButton.layer.cornerRadius = decrementButton.frame.size.width / 2
        incrementButton.layer.cornerRadius = incrementButton.frame.size.width / 2

    }
    
    @objc func handleDecrement() {
        count -= 1
    }
    
    @objc func handleIncrement() {
        count += 1
    }
    
    func updateMaxMinCount() {
        if minCount != nil, count <= minCount! {
            decrementButton.isEnabled = false
            decrementButton.alpha = 0.5
        } else {
            decrementButton.isEnabled = true
            decrementButton.alpha = 1
        }
        
        if maxCount != nil, count >= maxCount! {
            incrementButton.isEnabled = false
            incrementButton.alpha = 0.5
        } else {
            incrementButton.isEnabled = true
            incrementButton.alpha = 1
        }

    }
}
