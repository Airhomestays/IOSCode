
import UIKit

protocol AirbnbOccupantFilterControllerDelegate {
    func occupantFilterController(_ occupantFilterController: AirbnbOccupantFilterController, didSaveAdult adult: Int, children: Int, infant: Int, pet: Bool, guestBase: Int, infantLimit: Int, petLimit: Int, visitorLimit: Int)
}

class AirbnbOccupantFilterController: UIViewController {
    
    var delegate: AirbnbOccupantFilterControllerDelegate?
    
    var isFrom = ""
    
    var adultCount: Int?
    var additionalGuestCount: Int?
    var infantCountt: Int?
    var isFromInafnt: Bool?
    
    var petCountt: Int?
    var isFromPet: Bool?
    
    var visitorCountt: Int?
    var isFromVisitor: Bool?
    
    var isFromAdditionalGuest: Bool?
    var childrenCount: Int?
    var infantCount: Int?
    var hasPet: Bool?
    
    var humanCount: Int {
        return (adultCount ?? 0) + (childrenCount ?? 0)
    }
    var maxHumanCount: Int {
        if(Utility.shared.isfromcheckingPage)
        {
        return Utility.shared.maximum_Count_for_booking - humanCount
        }
        else{
        return  Utility.shared.maximum_guest_count - humanCount
        }
    }
    
    var maxVisitorCount: Int = (Utility.shared.maximum_Count_for_Visitor)
    var maxPettCount: Int = (Utility.shared.maximum_Count_for_Pet)
    var maxInfantCount: Int = (Utility.shared.maximum_Count_for_Inafant)
    var maxAdditionalGuestCount: Int = (Utility.shared.maximum_Count_for_additionalGuests)
    
    
    lazy var adultCounter: AirbnbCounter = {
        let view = AirbnbCounter()
        view.translatesAutoresizingMaskIntoConstraints = false
        if isFromAdditionalGuest == true {
            view.minCount = 0
            view.fieldID = "additionalGuests"
            view.maxCount = self.maxAdditionalGuestCount
            view.caption = "Additional Guests"
        } else if isFromInafnt == true {
            view.minCount = 0
            view.fieldID = "infants"
            view.maxCount = self.maxInfantCount
            view.caption = "Infants"
        } else if isFromPet == true {
            view.minCount = 0
            view.fieldID = "pet"
            view.maxCount = self.maxPettCount
            view.caption = "Pets"
        } else if isFromVisitor == true {
            view.minCount = 0
            view.fieldID = "visitor"
            view.maxCount = self.maxVisitorCount
            view.caption = "Visitor"
        } else {
            view.minCount = 1
            view.fieldID = "adult"
            view.maxCount = self.maxHumanCount
            view.caption = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
        }
        
        view.delegate = self
        
        
       
            

        return view
    }()
    
   
    var infantCounter: AirbnbCounter = {
        let view = AirbnbCounter()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.caption = "Infants"
        view.subCaption = "2 & under"
        view.maxCount = 5
        view.minCount = 0
        return view
    }()
    
    var petSwitch: AirbnbSwitch = {
        let view = AirbnbSwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.caption = "Pet"
        return view
    }()
    
    lazy var dismissButton: UIBarButtonItem = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage(named: "left_arrow", in: Bundle(for: AirbnbOccupantFilter.self), compatibleWith: nil), for: .normal)
        btn.frame = CGRect(x: 20, y: 20, width: 36, height: 36)
        btn.backgroundColor = Theme.ButtonBack_BG
        btn.layer.cornerRadius = btn.frame.size.height/2
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(AirbnbOccupantFilterController.handleDismiss), for: .touchUpInside)
        let barBtn = UIBarButtonItem(customView: btn)
        return barBtn
    }()
    
    lazy var editGuestTitle: UIBarButtonItem = {
        let label = UILabel()
        label.textColor = UIColor(named: "Title_Header")
        label.font = UIFont(name: APP_FONT_SEMIBOLD, size: 18.0)
        if isFromAdditionalGuest == true {
            label.text = " Edit Additional Guests"
        } else if isFromInafnt == true {
            label.text = " Edit Infants"
        } else if isFromPet == true {
            label.text = " Edit Pets"
        } else if isFromVisitor == true {
            label.text = " Edit Visitor"
        } else {
            label.text = "\(Utility.shared.getLanguage()?.value(forKey: "Edit_guests") ?? "Edit guests")"
        }
        
        let barLabel = UIBarButtonItem(customView: label)
        return barLabel
    }()
    
    var footerSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        
        return view
    }()
    
    lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = Theme.Button_BG
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"save") ?? "Save")", for: .normal)
        
        btn.titleLabel?.font = UIFont(name: APP_FONT_SEMIBOLD, size: 18)
        btn.addTarget(self, action: #selector(AirbnbOccupantFilterController.handleSave), for: .touchUpInside)
        return btn
    }()
    
    convenience init(adultCount: Int?, childrenCount: Int?, infantCount: Int?, hasPet: Bool?, additionalGuestCount: Int?, isFromAdditionalGuest: Bool = false, isFromInafnt: Bool = false, infantCountt: Int?, isFromPet: Bool = false, petCountt: Int?, isFromVisitor: Bool = false, visitorCountt: Int?) {
        self.init()
        
        self.adultCount = adultCount
        self.childrenCount = childrenCount
        self.infantCount = infantCount
        self.hasPet = hasPet
        
        self.isFromVisitor = isFromVisitor
        self.isFromPet = isFromPet
        self.isFromInafnt = isFromInafnt
        self.isFromAdditionalGuest = isFromAdditionalGuest
        
        if isFromAdditionalGuest == true {
            self.additionalGuestCount = additionalGuestCount
            adultCounter.count = self.additionalGuestCount ?? 1
        } else if isFromInafnt == true {
            self.infantCountt = infantCountt
            adultCounter.count = self.infantCountt ?? 1
        } else if isFromPet == true {
            self.petCountt = petCountt
            adultCounter.count = self.petCountt ?? 1
        }  else if isFromVisitor == true {
            self.visitorCountt = visitorCountt
            adultCounter.count = self.petCountt ?? 1
        }else {
            adultCounter.count = self.adultCount ?? 1
        }
        
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupViews()
        saveButton.layer.cornerRadius = 25
        saveButton.layer.masksToBounds = true
    }
    
    func setupViews() {
        
      
        view.backgroundColor =  UIColor(named: "colorController")
        
        view.addSubview(adultCounter)
        
        adultCounter.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        adultCounter.heightAnchor.constraint(equalToConstant: 50).isActive = true
        adultCounter.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        adultCounter.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true



        setupFooterView()
        
    }
    
    
    func setupFooterView() {
        view.addSubview(saveButton)
        
        saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(footerSeparator)
        
        footerSeparator.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10).isActive = true
        footerSeparator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        footerSeparator.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        footerSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        self.navigationItem.setLeftBarButtonItems([dismissButton,editGuestTitle], animated: true)
    }
    
    @objc func handleDismiss() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSave() {
        
        if isFromAdditionalGuest == true {
            if let del = delegate {
                
                additionalGuestCount = adultCounter.count

                let guest = additionalGuestCount!
                
                let guests = [
                    "additionalGuests": "\(guest)"
                ]
                NotificationCenter.default.post(name: Notification.Name("AdditionalGuests"), object: nil, userInfo: guests as? [AnyHashable : Any])
                del.occupantFilterController(self, didSaveAdult: adultCount ?? 1, children: childrenCount ?? 0, infant: infantCount ?? 0, pet: hasPet ?? false, guestBase: additionalGuestCount ?? 0, infantLimit: 0, petLimit: 0, visitorLimit: 0)
                
                dismiss(animated: true, completion: nil)
            }
        } else if isFromInafnt == true {
            if let del = delegate {
                
                infantCountt = adultCounter.count

                let guest = infantCountt!
                
                let guests = [
                    "infantCountt": "\(guest)"
                ]
                NotificationCenter.default.post(name: Notification.Name("InfantCountt"), object: nil, userInfo: guests as? [AnyHashable : Any])
                del.occupantFilterController(self, didSaveAdult: adultCount ?? 1, children: childrenCount ?? 0, infant: infantCount ?? 0, pet: hasPet ?? false, guestBase: 0, infantLimit: infantCountt ?? 0, petLimit: 0, visitorLimit: 0)
                
                dismiss(animated: true, completion: nil)
            }
        } else if isFromPet == true {
            if let del = delegate {
                
                petCountt = adultCounter.count

                let guest = petCountt!
                
                let guests = [
                    "petCountt": "\(guest)"
                ]
                NotificationCenter.default.post(name: Notification.Name("PetCountt"), object: nil, userInfo: guests as? [AnyHashable : Any])
                del.occupantFilterController(self, didSaveAdult: adultCount ?? 1, children: childrenCount ?? 0, infant: infantCount ?? 0, pet: hasPet ?? false, guestBase: 0, infantLimit: 0, petLimit: petCountt ?? 0, visitorLimit: 0)
                
                dismiss(animated: true, completion: nil)
            }
        } else if isFromVisitor == true {
            if let del = delegate {
                
                visitorCountt = adultCounter.count

                let guest = visitorCountt!
                
                let guests = [
                    "visitorCountt": "\(guest)"
                ]
                NotificationCenter.default.post(name: Notification.Name("VisitorCountt"), object: nil, userInfo: guests as? [AnyHashable : Any])
                del.occupantFilterController(self, didSaveAdult: adultCount ?? 1, children: childrenCount ?? 0, infant: infantCount ?? 0, pet: hasPet ?? false, guestBase: 0, infantLimit: infantCountt ?? 0, petLimit: 0, visitorLimit: visitorCountt ?? 0)
                
                dismiss(animated: true, completion: nil)
            }
        } else {
            if let del = delegate {
                
                adultCount = adultCounter.count

                let guest = adultCount! + childrenCount!
                
                let guests = [
                    "guest": "\(guest)",
                    "children": "\(childrenCount!)",
                    "adults": "\(adultCount!)",
                    "infants": "\(infantCount!)"
                ]
                NotificationCenter.default.post(name: Notification.Name("Guest"), object: nil, userInfo: guests as? [AnyHashable : Any])
                del.occupantFilterController(self, didSaveAdult: adultCount ?? 1, children: childrenCount ?? 0, infant: infantCount ?? 0, pet: hasPet ?? false, guestBase: 0, infantLimit: 0, petLimit: 0, visitorLimit: 0)
                
                dismiss(animated: true, completion: nil)
            }
        }
        
    }
}

extension AirbnbOccupantFilterController: AirbnbCounterDelegate {
    func counter(_ counter: AirbnbCounter, didUpdate count: Int) {
        if counter.fieldID == adultCounter.fieldID {
            let view = AirbnbCounter()
            if isFromAdditionalGuest == true {
                additionalGuestCount = count
                updtaeAddGuestscaptionLabel()
                updateAdditinalGuestsMaxCount()
            } else if isFromInafnt == true {
                infantCountt = count
                updtaeInfantcaptionLabel()
                updateInfantsMaxCount()
            } else if isFromPet == true {
                petCountt = count
                updtaePettcaptionLabel()
                updatePetssMaxCount()
            } else if isFromVisitor == true {
                visitorCountt = count
                updtaePVisitorcaptionLabel()
                updateVisitorsMaxCount()
            } else {
                adultCount = count
                updtaecaptionLabel()
                updateHumanMaxCount()
            }
            
        }

    }
    
    
    func updateVisitorsMaxCount() {
        adultCounter.maxCount = maxVisitorCount
     
    }
    
    func updtaePVisitorcaptionLabel()
    {
        if(visitorCountt ?? 0 > 1){
            
            adultCounter.caption  = "Visitor"
        }
        else{
            adultCounter.caption = "Visitor"
        }
        
    }
    
    
    func updatePetssMaxCount() {
        adultCounter.maxCount = maxPettCount
     
    }
    
    func updtaePettcaptionLabel()
    {
        if(petCountt ?? 0 > 1){
            
            adultCounter.caption  = "Pets"
        }
        else{
            adultCounter.caption = "Pets"
        }
        
    }
    
    func updateInfantsMaxCount() {
        adultCounter.maxCount = maxInfantCount
     
    }
    
    func updtaeInfantcaptionLabel()
    {
        if(infantCountt ?? 0 > 1){
            
            adultCounter.caption  = "Infants"
        }
        else{
            adultCounter.caption = "Infants"
        }
        
    }
    
    func updateAdditinalGuestsMaxCount() {
        adultCounter.maxCount = maxAdditionalGuestCount
     
    }
    
    func updtaeAddGuestscaptionLabel()
    {
        if(additionalGuestCount ?? 0 > 1){
            
            adultCounter.caption  = "Additional Guests"
        }
        else{
            adultCounter.caption = "Additional Guests"
        }
        
    }
    
    func updateHumanMaxCount() {
        adultCounter.maxCount = maxHumanCount + (adultCount ?? 0)
     
    }
    func updtaecaptionLabel()
    {
        if(adultCount ?? 0 > 1){
            
            adultCounter.caption  = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
        }
        else{
            adultCounter.caption = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
        }
        
    }
}
