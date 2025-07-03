
import UIKit
import Lottie

protocol GuestListingViewControllerDelegate {
    func toatalguests(guest:String)
}

class GuestListingViewController: BaseHostTableviewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var offlineUIview: UIView!
    @IBOutlet weak var saveAndExit: UIButton!
    @IBOutlet weak var retryButn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    var lottieView1: LottieAnimationView!
    
    var personCapacityArray = [Int]()
    var personCapacityValue = Int()
    var bedRoomCapacity = [Int]()
    var bedRoomCount = Int()
    var bedRoomMinCount = Int()
    var bedMinCount = Int()
    var guestMinCount = Int()
    
    var bedCapacity = [Int]()
    var bedCount = Int()
    var bathroomsArr = [Float]()
    var bathroomsCount = Float()
    var bathroomTypeArr = [String]()
    var bathroomTypeLbl = String()
    var inputListView = UIView()
    var pickerView = UIPickerView()
    var bathroomJSONValue = Float()
    var delegateGuestListing:GuestListingViewControllerDelegate!
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleheightConstaraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstaraint: NSLayoutConstraint!
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        tableView.backgroundColor =  UIColor(named: "colorController")
        bottomView.backgroundColor =  UIColor(named: "colorController")
        curvedView.backgroundColor = UIColor(named: "colorController")
        
        nextBtn.backgroundColor = Theme.Button_BG
        saveAndExit.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = UIColor.white
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "guest_stay") ?? "How many guests can stay?")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        saveAndExit.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"SaveExit") ?? "Save & Exit")", for:.normal)
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryButn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveAndExit.setTitleColor(Theme.PRIMARY_COLOR, for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryButn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveAndExit.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        saveAndExit.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryButn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
        self.stepsTitleView.whichStep = 1
        self.stepsTitleView.selectedViewIndex = 1
        self.stepsTitleView.delegateSteps = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
        progressViewWidth.constant = ((self.view.frame.width/7) * CGFloat((self.stepsTitleView.selectedViewIndex + 1)))
    }
    
    override func setUpUI() {
        if(Utility.shared.step1_inactivestatus == "inactive" || Utility.shared.step1_inactivestatus == "") {
            saveAndExit.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleheightConstaraint.constant = 0
            self.stepTitleTopConstaraint.constant = 0
        } else {
            saveAndExit.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleheightConstaraint.constant = 50
            self.stepTitleTopConstaraint.constant = 5
        }
        offlineUIview.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIview, nextButton: nextBtn)
        tableView.isHidden = false
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "next"))!)", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        lottieView1 = LottieAnimationView.init(name: "animation")
        
    }
    
    override func setdropdown() {
        inputListView.frame = CGRect(x: 0, y: FULLHEIGHT-200, width: FULLWIDTH, height: 200)
        pickerView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 200)
        inputListView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.tintColor = Theme.PRIMARY_COLOR
        pickerView.backgroundColor = UIColor(named: "colorController")
        pickerView.reloadAllComponents()
    }
    
    override func setDropdownList() {
        
        setPersonCapacity()
        setBedRoomsCount()
        setBedsCount()
        setBathroomsCount()
        setBathroomType()
        tableView.reloadData()
    }
    
    
    func setBathroomsCount() {
        let bathrooms = Utility.shared.getListSettingsArray.bathrooms?.listSettings != nil ? (Utility.shared.getListSettingsArray.bathrooms?.listSettings![0]?.endValue)! : 0
        
        let MinCount = Utility.shared.getListSettingsArray.bathrooms?.listSettings != nil ? (Utility.shared.getListSettingsArray.bathrooms?.listSettings![0]?.startValue)! : 0
        let valcount = bathrooms + 1
        var index = 0
        var incrVal = Float(MinCount)
        for i in 0..<valcount {
            bathroomsArr.insert(incrVal, at: i)
            incrVal = (incrVal + 1)
        }
        
        if Utility.shared.step1ValuesInfo.keys.contains("bathrooms") {
            if let bedRoomsCountValues = (Utility.shared.step1ValuesInfo["bathrooms"]!) as? Double {
                bathroomsCount = Float(bedRoomsCountValues)
                bathroomJSONValue = Float(bedRoomsCountValues)
            }
        }else{
            bathroomsCount = bathroomsArr.first != nil ? bathroomsArr.first! : 0
            bathroomJSONValue = bathroomsCount
            Utility.shared.step1ValuesInfo.updateValue(Double(bathroomsCount), forKey: "bathrooms")
        }
    }
    
    func setBathroomType()
    {
        let typeListSettings = (Utility.shared.getListSettingsArray.bathroomType?.listSettings!)!
        for item in typeListSettings {
            bathroomTypeArr.append((item?.itemName)!)
        }
        bathroomTypeLbl = bathroomTypeArr.first != nil ? bathroomTypeArr.first! : ""
        if !Utility.shared.step1ValuesInfo.keys.contains("bathroomType") {
            bathroomTypeLbl = bathroomTypeArr.first != nil ? bathroomTypeArr.first! : ""
            pickerView.selectRow(0, inComponent: 0, animated: true)
            
            Utility.shared.step1ValuesInfo.updateValue(((Utility.shared.getListSettingsArray.bathroomType?.listSettings!.count)! > 0 ? ((Utility.shared.getListSettingsArray.bathroomType?.listSettings!.first??.id!)!) : 0), forKey: "bathroomType")
        }else{
            _ = typeListSettings.filter({ (item) -> Bool in
                if (Utility.shared.step1ValuesInfo["bathroomType"]! as? Int) == item?.id
                {
                    bathroomTypeLbl = (item?.itemName!)!
                    return true
                }else{
                    return false
                }
            })
            if !bathroomTypeLbl.isEmpty {
                let index = bathroomTypeArr.firstIndex(where: { (item) -> Bool in
                    item == bathroomTypeLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            } else {
                bathroomTypeLbl = bathroomTypeArr.first != nil ? bathroomTypeArr.first! : ""
                pickerView.selectRow(0, inComponent: 0, animated: true)
                Utility.shared.step1ValuesInfo.updateValue(((Utility.shared.getListSettingsArray.bathroomType?.listSettings!.count)! > 0 ? ((Utility.shared.getListSettingsArray.bathroomType?.listSettings!.first??.id!)!) : 0), forKey: "bathroomType")
            }
        }
    }
    
    
    override func setPersonCapacity() {
        var incrVal = 1
        let personcapacity = (Utility.shared.getListSettingsArray.personCapacity?.listSettings![0]?.endValue)!
        
        let personMinCount = (Utility.shared.getListSettingsArray.personCapacity?.listSettings![0]?.startValue)!
        for i in 0..<personcapacity {
            personCapacityArray.insert(incrVal , at: i)
            incrVal = (incrVal + 1)
        }
        if !Utility.shared.step1ValuesInfo.keys.contains("personCapacity") {
            personCapacityValue = personMinCount
            guestMinCount  =  personMinCount
            Utility.shared.step1ValuesInfo.updateValue(personMinCount, forKey: "personCapacity")
        }else {
            personCapacityValue = Utility.shared.step1ValuesInfo["personCapacity"] as! Int
        }
    }
    
    func setBedRoomsCount() {
        var bedroomincrVal = 1
        let bedroomCapacityCount = (Utility.shared.getListSettingsArray.bedrooms?.listSettings![0]?.endValue)!
        let bedroomCapacityminCount = (Utility.shared.getListSettingsArray.bedrooms?.listSettings![0]?.startValue)!
        for i in 0..<bedroomCapacityCount {
            bedRoomCapacity.insert(bedroomincrVal , at: i)
            bedroomincrVal = (bedroomincrVal + 1)
        }
        bedRoomMinCount = bedroomCapacityminCount
        if !Utility.shared.step1ValuesInfo.keys.contains("bedrooms") {
            bedRoomCount = bedroomCapacityminCount
            
            Utility.shared.step1ValuesInfo.updateValue(bedroomCapacityminCount, forKey: "bedrooms")
        }else {
            if let count = Utility.shared.step1ValuesInfo["bedrooms"]! as? Int
            {
                bedRoomCount = count
            }else if let bedRmCount = Utility.shared.step1ValuesInfo["bedrooms"] as? String{
                bedRoomCount = Int(bedRmCount)!
            }
        }
    }
    
    func setBedsCount() {
        var bedincrVal = 1
        let bedCapacityCount = (Utility.shared.getListSettingsArray.beds?.listSettings![0]?.endValue)!
        let bedCapacityminCount = (Utility.shared.getListSettingsArray.beds?.listSettings![0]?.startValue)!
        for i in 0..<bedCapacityCount {
            bedCapacity.insert(bedincrVal , at: i)
            bedincrVal = (bedincrVal + 1)
        }
        bedMinCount = bedCapacityminCount
        if !Utility.shared.step1ValuesInfo.keys.contains("beds") {
            bedCount = bedCapacityminCount
            
            Utility.shared.step1ValuesInfo.updateValue(bedCount, forKey: "bedrooms")
            Utility.shared.step1ValuesInfo.updateValue(bedCapacityminCount, forKey: "beds")
        }else {
            bedCount = Utility.shared.step1ValuesInfo["beds"] as! Int
        }
    }
    
    override func registerCells() {
        tableView.register(UINib(nibName: "RoomsCell", bundle: nil), forCellReuseIdentifier: "RoomsCell")
        tableView.register(UINib(nibName: "GuestListingNew", bundle: nil), forCellReuseIdentifier: "GuestListingNew")
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "textfieldcell")
    }
    
    override func addLottieViewAsSubview() {}
    
    func lottieViewanimation() {
        saveAndExit.setTitle("", for:.normal)
        lottieView1 = LottieAnimationView.init(name: "animation")
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:((self.saveAndExit.frame.size.width/2)-50), y:0, width:100, height:self.saveAndExit.frame.size.height)
        self.saveAndExit.addSubview(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor.clear
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll() {
        self.lottieView1.play()
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIview.isHidden = true
        }
    }
    @IBAction func RedirectNextPage(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            let bedsCount = Utility.shared.step1ValuesInfo["beds"] as? Int
            if(bedsCount != nil) {
                if(Utility.shared.bedcount>bedsCount!) {
                    self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey: "bed_count_exceed")as! String)")
                    return
                }
            }
            
            if(Double(bathroomJSONValue) < 1) {
                Utility.shared.step1ValuesInfo.updateValue(Double(1),forKey: "bathrooms")
            } else{
                Utility.shared.step1ValuesInfo.updateValue(Double(bathroomJSONValue),forKey: "bathrooms")
            }
            let location = AddressListingViewController()
            self.view.window?.backgroundColor = UIColor.white
            location.modalPresentationStyle = .fullScreen
            self.present(location, animated: false, completion: nil)
        } else {
            self.offlineUIview.isHidden = false
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: self.offlineUIview.frame.size.width + shadowSize2,
                                                        height: self.offlineUIview.frame.size.height + shadowSize2))
            
            self.offlineUIview.layer.masksToBounds = false
            self.offlineUIview.layer.shadowColor = Theme.TextLightColor.cgColor
            self.offlineUIview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.offlineUIview.layer.shadowOpacity = 0.3
            self.offlineUIview.layer.shadowPath = shadowPath2.cgPath
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineUIview.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
            }else{
                offlineUIview.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        delegateGuestListing?.toatalguests(guest:"\(Utility.shared.step1ValuesInfo["personCapacity"]!)")
        Utility.shared.step1ValuesInfo.updateValue(Double(bathroomJSONValue),forKey: "bathrooms")
        if(Utility.shared.step1_inactivestatus == "inactive" || Utility.shared.step1_inactivestatus == "") {
            self.dismiss(animated: true, completion: nil)
        }else{
            let StepOne = PlaceListingViewController()
            StepOne.modalPresentationStyle = .fullScreen
            self.present(StepOne, animated:false, completion: nil)
        }
    }
    func goToBecomeHost(){
        let becomeHost = BecomeHostVC()
        becomeHost.listID = "\(Utility.shared.createId)"
        becomeHost.showListingStepsAPICall(listID:"\(Utility.shared.createId)")
        becomeHost.modalPresentationStyle = .fullScreen
        self.present(becomeHost, animated:false, completion: nil)
    }
    
    @IBAction func saveAndExit(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.lottieViewanimation()
            let bedsCount = Utility.shared.step1ValuesInfo["beds"] as? Int
            if(bedsCount != nil) {
                if(Utility.shared.bedcount>bedsCount!) {
                    self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey: "bed_count_exceed")as! String)")
                    return
                }
            }
            if(Double(bathroomJSONValue) < 1) {
                Utility.shared.step1ValuesInfo.updateValue(Double(1),forKey: "bathrooms")
            } else {
                Utility.shared.step1ValuesInfo.updateValue(Double(bathroomJSONValue),forKey: "bathrooms")
            }
            super.updateListingAPICall{ (success) -> Void in
                if success {
                    saveAndExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                    
                    self.lottieView1.isHidden = true
                }
            }
        } else {
            self.offlineUIview.isHidden = false
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: self.offlineUIview.frame.size.width + shadowSize2,
                                                        height: self.offlineUIview.frame.size.height + shadowSize2))
            
            self.offlineUIview.layer.masksToBounds = false
            self.offlineUIview.layer.shadowColor = Theme.TextLightColor.cgColor
            self.offlineUIview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.offlineUIview.layer.shadowOpacity = 0.3
            self.offlineUIview.layer.shadowPath = shadowPath2.cgPath
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineUIview.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
            }else{
                offlineUIview.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "RoomsCell", for: indexPath) as? RoomsCell
            cell?.dashView.isHidden = false
            cell?.dashView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
            if indexPath.row == 0 {
                if personCapacityValue > 1 {
                    cell?.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "total_guests") ?? "Total guests")"
                }else{
                    cell?.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "total_guest") ?? "Total guest")"
                }
                cell?.countshowLabel.text = "\(personCapacityValue)"
                
                if cell?.countshowLabel.text == String((Utility.shared.getListSettingsArray.personCapacity?.listSettings![0]?.startValue)!){
                    cell?.minusBtn.isEnabled = false
                    cell?.minusBtn.alpha = 0.5
                    cell?.minusBtn.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5)
                    cell?.minusBtn.isUserInteractionEnabled = false
                }
                cell?.roomsTitleLabel.textColor =  UIColor(named: "Title_Header")
                cell?.countValue = 1
                cell?.plusBtn.tag = indexPath.row
                cell?.minusBtn.tag = indexPath.row
                cell?.tag = indexPath.row + 100
                cell?.plusBtn.addTarget(self, action: #selector(self.plusBtnTapped), for: .touchUpInside)
                cell?.minusBtn.addTarget(self, action: #selector(self.minusBtnTapped), for: .touchUpInside)
            }else if indexPath.row == 1 {
                if bedRoomCount > 1{
                    cell?.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bedroom_guests") ?? "")"
                }else{
                    cell?.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bedroom_guest") ?? "")"
                }
                cell?.countshowLabel.text = "\(bedRoomCount)"
                
                if cell?.countshowLabel.text == String((Utility.shared.getListSettingsArray.bedrooms?.listSettings![0]?.startValue)!){
                    cell?.minusBtn.isEnabled = false
                    cell?.minusBtn.alpha = 0.5
                    cell?.minusBtn.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5)
                    cell?.minusBtn.isUserInteractionEnabled = false
                }
                cell?.roomsTitleLabel.textColor =  UIColor(named: "Title_Header")
                cell?.countValue = 1
                cell?.plusBtn.tag = indexPath.row
                cell?.minusBtn.tag = indexPath.row
                cell?.tag = indexPath.row + 100
                cell?.plusBtn.addTarget(self, action: #selector(self.plusBtnTapped), for: .touchUpInside)
                cell?.minusBtn.addTarget(self, action: #selector(self.minusBtnTapped), for: .touchUpInside)
            }else if indexPath.row == 2 {
                if bedCount > 1{
                    cell?.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bed_guests") ?? "Bed for guests")"
                }else{
                    cell?.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bed_guest") ?? "Bed for guest")"
                }
                cell?.roomsTitleLabel.textColor =  UIColor(named: "Title_Header")
                cell?.countshowLabel.text = "\(bedCount)"
                
                if cell?.countshowLabel.text == String((Utility.shared.getListSettingsArray.beds?.listSettings![0]?.startValue)!){
                    cell?.minusBtn.isEnabled = false
                    cell?.minusBtn.alpha = 0.5
                    cell?.minusBtn.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5)
                    cell?.minusBtn.isUserInteractionEnabled = false
                }
                cell?.countValue = 1
                cell?.plusBtn.tag = indexPath.row
                cell?.minusBtn.tag = indexPath.row
                cell?.tag = indexPath.row + 100
                cell?.plusBtn.addTarget(self, action: #selector(self.plusBtnTapped), for: .touchUpInside)
                cell?.minusBtn.addTarget(self, action: #selector(self.minusBtnTapped), for: .touchUpInside)
                cell?.dashView.isHidden = true
            } else if (indexPath.row == 3) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GuestListingNew", for: indexPath) as? GuestListingNew
                cell?.borderView.layer.cornerRadius = 5
                cell?.borderView.layer.masksToBounds = true
                cell?.borderView.borderWidth = 1.0
                cell?.borderView.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
                cell?.btn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
                cell?.selectionStyle = .none
                cell?.btn.addTarget(self, action: #selector(onClickedDownArrow), for: .touchUpInside)
                return cell!
            }
            if indexPath.row == 4 {
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: "RoomsCell", for: indexPath) as? RoomsCell
                cell?.dashView.isHidden = false
                cell?.dashView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
                cell?.dashView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
                cell?.roomsTitleLabel.text = "\(1) \(Utility.shared.getLanguage()?.value(forKey: "bathroom")as! String)"
                cell?.countshowLabel.text = "1"
                
                cell?.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bathrooms")as! String)"
                if bathroomsCount > 1 {
                    let val = Double(bathroomsCount).clean
                    cell?.countshowLabel.text = "\(val)"
                    bathroomJSONValue = Float(bathroomsCount)
                }else{
                    if(bathroomsCount != 0) {
                        cell?.countshowLabel.text = "\(Int(bathroomsCount))"
                        bathroomJSONValue = Float(bathroomsCount)
                    }
                }
                cell?.roomsTitleLabel.textColor = UIColor(named: "Title_Header")
                cell?.countshowLabel.textColor = UIColor(named: "Title_Header")
                
                if cell?.countshowLabel.text == String((Utility.shared.getListSettingsArray.bathrooms?.listSettings![0]?.startValue)!){
                    cell?.minusBtn.isEnabled = false
                    cell?.minusBtn.alpha = 0.5
                    cell?.minusBtn.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5)
                    cell?.minusBtn.isUserInteractionEnabled = false
                }
                
                cell?.roomsTitleLabel.font = UIFont(name:APP_FONT_MEDIUM, size: 14.0)
                cell?.countValue = 1
                cell?.plusBtn.tag = indexPath.row
                cell?.minusBtn.tag = indexPath.row
                cell?.tag = indexPath.row + 1000
                cell?.plusBtn.addTarget(self, action: #selector(self.plusBtnTappedbed(sender:)), for: .touchUpInside)
                cell?.minusBtn.addTarget(self, action: #selector(self.minusBtnTappedbed(sender:)), for: .touchUpInside)
                cell?.selectionStyle = .none
                cell?.plusBtn.layer.cornerRadius = (cell?.plusBtn.frame.size.width)!/2
                cell?.plusBtn.layer.borderWidth = 1.0
                cell?.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                cell?.minusBtn.layer.cornerRadius = (cell?.minusBtn.frame.size.width)!/2
                cell?.minusBtn.layer.borderWidth = 1.0
                cell?.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                cell?.dashView.isHidden = true
                return cell!
            } else if(indexPath.row == 5) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "textfieldcell", for: indexPath) as? TextFieldCell
                cell?.txtField.tintColor = UIColor.clear
                cell?.queryTitleLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "Place_kind")as! String)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: bathroomTypeLbl,
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                cell?.selectionStyle = .none
                cell?.tag = indexPath.row + 200
                cell?.stepnumberLbl.isHidden = true
                cell?.selectionStyle = .none
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputAccessoryView = toolBar
                cell?.txtField.inputView = inputListView
                cell?.txtField.tag = 1
                cell?.txtField.delegate = self
                cell?.queryTitleLbl.isHidden = true
                cell?.stepOneHeight.constant = 0
                cell?.stepOneBottom.constant = 0
                cell?.stepNumberLblTopConstraint.constant = 0
                cell?.imgDownArrow.isHidden = false
                return cell!
            }
            
            cell?.plusBtn.layer.cornerRadius = (cell?.plusBtn.frame.size.width)!/2
            cell?.plusBtn.layer.borderWidth = 1.0
            cell?.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell?.minusBtn.layer.cornerRadius = (cell?.minusBtn.frame.size.width)!/2
            cell?.minusBtn.layer.borderWidth = 1.0
            cell?.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell?.selectionStyle = .none
            
            cell?.countshowLabel.textColor = UIColor(named: "Title_Header")
            return cell!
        }
        return UITableViewCell()
    }
    
    @objc func onClickedDownArrows(sender: UIButton){
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! TextFieldCell
        cell.txtField.becomeFirstResponder()
    }
    
    @objc func onClickedDownArrow(sender: UIButton){
        let bedsListing = BedsListingViewController()
        self.view.window?.backgroundColor = UIColor.white
        bedsListing.modalPresentationStyle = .currentContext
        self.present(bedsListing, animated: false, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            selectedTextfield = 1
            if !bathroomTypeLbl.isEmpty {
                let index = bathroomTypeArr.firstIndex(where: { (item) -> Bool in
                    item == bathroomTypeLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }
        
        if(indexPath.row == 3) {
            let bedsListing = BedsListingViewController()
            self.view.window?.backgroundColor = UIColor.white
            bedsListing.modalPresentationStyle = .currentContext
            self.present(bedsListing, animated: false, completion: nil)
            
        }
        pickerView.reloadAllComponents()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectedTextfield == 1 {
            return bathroomTypeArr.count
        } else {
            return 0
        }
    }
    
    override func pickerView( _ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var titleData = ""
        if selectedTextfield == 1 {
            titleData = bathroomTypeArr[row]
        }
        
        let myTitle = NSAttributedString(string: titleData , attributes: [NSAttributedString.Key.font:UIFont(name:APP_FONT, size: 15.0)!,NSAttributedString.Key.foregroundColor:Theme.PRIMARY_COLOR])
        return myTitle
    }
    
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        if selectedTextfield == 1 {
            bathroomTypeLbl = bathroomTypeArr[row]
        }
        pickerView.selectRow(row, inComponent: component, animated: true)
        Utility.shared.step1ValuesInfo.updateValue((Utility.shared.getListSettingsArray.bathroomType?.listSettings![row]!.id!)!, forKey: "bathroomType")
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextfield = textField.tag
        if !bathroomTypeLbl.isEmpty {
            let index = bathroomTypeArr.firstIndex(where: { (item) -> Bool in
                item == bathroomTypeLbl
            })
            pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
        }
        pickerView.reloadAllComponents()
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            let indexPaths = IndexPath(item: 5, section: 0)
            tableView.reloadRows(at:[indexPaths] , with: .none)
        } else {
            tableView.reloadData()
        }
        view.endEditing(true)
    }
    
    
    @objc func plusBtnTappedbed(sender : UIButton) {
        if let cell = view.viewWithTag(sender.tag + 1000) as? RoomsCell {
            if bathroomsArr.count > 0 {
                if Int(Float(cell.countshowLabel.text!)!) >= bathroomsArr.count - 1 {
                    cell.plusBtn.isEnabled = false
                    cell.plusBtn.isUserInteractionEnabled = false
                    cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5).cgColor
                } else {
                    cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                    cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                    bathroomsCount = Float(cell.countshowLabel.text!)!
                    cell.plusBtn.isEnabled = true
                    cell.plusBtn.isUserInteractionEnabled = true
                    cell.minusBtn.isUserInteractionEnabled = true
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1.0
                    bathroomJSONValue = Float(cell.countshowLabel.text!)!
                    let text = "\((Double(cell.countshowLabel.text!)! + 0.5).clean)"
                    cell.countshowLabel.text = text
                    if (Double(cell.countshowLabel.text!)!) > 1.0 {
                        let array = cell.countshowLabel.text!.components(separatedBy: ".")
                        cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bathrooms")as! String)"
                    } else {
                        let array = cell.countshowLabel.text!.components(separatedBy: ".")
                        cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bathrooms")as! String)"
                    }
                }
            }
        }
    }
    
    @objc func minusBtnTappedbed(sender : UIButton) {
        if let cell = view.viewWithTag(sender.tag + 1000) as? RoomsCell {
            cell.countshowLabel.text = "\((Double(cell.countshowLabel.text!)! - 0.5).clean)"
            bathroomsCount = Float(cell.countshowLabel.text!)!
            
            bathroomJSONValue = Float(cell.countshowLabel.text!)!
            if (Double(cell.countshowLabel.text!)!) > 1.0 {
                let array = cell.countshowLabel.text!.components(separatedBy: ".")
                cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bathrooms")as! String)"
            }else{
                
                let array = cell.countshowLabel.text!.components(separatedBy: ".")
                cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bathrooms")as! String)"
            }
            if Float(cell.countshowLabel.text!)! <= bathroomsArr.first!{
                cell.minusBtn.isEnabled = false
                cell.minusBtn.alpha = 0.5
                cell.minusBtn.isUserInteractionEnabled = false
                cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5).cgColor
            }else{
                cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                
                cell.minusBtn.isEnabled = true
                cell.minusBtn.alpha = 1
                cell.minusBtn.isUserInteractionEnabled = true
                cell.plusBtn.isEnabled = true
                cell.plusBtn.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc func plusBtnTapped(sender : UIButton) {
        if let cell = view.viewWithTag(sender.tag + 100) as? RoomsCell {
            if Int(cell.countshowLabel.text!)! >= personCapacityArray.count && sender.tag == 0 {
                if(lottieView.isHidden) {
                    cell.plusBtn.isEnabled = false
                    cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5).cgColor
                    cell.plusBtn.isUserInteractionEnabled = false
                }
            }else if Int(cell.countshowLabel.text!)! >= bedRoomCapacity.count && sender.tag == 1 {
                if(lottieView.isHidden) {
                    cell.plusBtn.isEnabled = false
                    cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5).cgColor
                    cell.plusBtn.isUserInteractionEnabled = false
                }
            }else if Int(cell.countshowLabel.text!)! >= bedCapacity.count && sender.tag == 2
            {
                if(lottieView.isHidden)
                {
                    cell.plusBtn.isEnabled = false
                    cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5).cgColor
                    cell.plusBtn.isUserInteractionEnabled = false
                }
            }else {
                cell.countshowLabel.text = "\(Int(cell.countshowLabel.text!)! + 1)"
                if sender.tag == 0 {
                    Utility.shared.step1ValuesInfo.updateValue(Int(cell.countshowLabel.text!)!, forKey: "personCapacity")
                }else if sender.tag == 1 {
                    Utility.shared.step1ValuesInfo.updateValue(Int(cell.countshowLabel.text!)!, forKey: "bedrooms")
                }else if sender.tag == 2{
                    Utility.shared.step1ValuesInfo.updateValue(Int(cell.countshowLabel.text!)!, forKey: "beds")
                }
                cell.plusBtn.isEnabled = true
                
                cell.plusBtn.isUserInteractionEnabled = true
            }
            
            if(sender.tag == 0) {
                if Int(cell.countshowLabel.text ?? "0") ?? 0 > 1{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "total_guests") ?? "Total guests")"
                }else{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "total_guest") ?? "Total guest")"
                }
            }
            if(sender.tag == 1) {
                if Int(cell.countshowLabel.text ?? "0") ?? 0 > 1{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bedroom_guests") ?? "Bedroom for guest")"
                }else{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bedroom_guest") ?? "Bedroom for guests")"
                }
            }
            if(sender.tag == 2) {
                if Int(cell.countshowLabel.text ?? "0") ?? 0 > 1{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bed_guests") ?? "Bed for guests")"
                }else{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bed_guest") ?? "Bed for guest")"
                }
            }
            cell.minusBtn.isEnabled = true
            cell.minusBtn.alpha = 1
            cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell.minusBtn.isUserInteractionEnabled = true
        }
    }
    
    @objc func minusBtnTapped(sender : UIButton) {
        if let cell = view.viewWithTag(sender.tag + 100) as? RoomsCell {
            cell.countshowLabel.text = "\(Int(cell.countshowLabel.text!)! - 1)"
            if Int(cell.countshowLabel.text!)! <= personCapacityValue && sender.tag == 0 {
                cell.minusBtn.isEnabled = false
                cell.minusBtn.alpha = 0.5
                cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5).cgColor
                cell.minusBtn.isUserInteractionEnabled = false
            }else if Int(cell.countshowLabel.text!)! <= bedRoomMinCount && sender.tag == 1 {
                cell.minusBtn.isEnabled = false
                cell.minusBtn.alpha = 0.5
                cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5).cgColor
                cell.minusBtn.isUserInteractionEnabled = false
            }else if Int(cell.countshowLabel.text!)! <= bedMinCount && sender.tag == 2 {
                cell.minusBtn.isEnabled = false
                cell.minusBtn.alpha = 0.5
                cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5).cgColor
                cell.minusBtn.isUserInteractionEnabled = false
            }else{
                if sender.tag == 0 {
                    Utility.shared.step1ValuesInfo.updateValue(Int(cell.countshowLabel.text!)!, forKey: "personCapacity")
                }else if sender.tag == 1 {
                    Utility.shared.step1ValuesInfo.updateValue(Int(cell.countshowLabel.text!)!, forKey: "bedrooms")
                }else if sender.tag == 2{
                    Utility.shared.step1ValuesInfo.updateValue(Int(cell.countshowLabel.text!)!, forKey: "beds")
                }
                cell.minusBtn.isEnabled = true
                cell.minusBtn.alpha = 1
                cell.minusBtn.isUserInteractionEnabled = true
            }
            if(sender.tag == 0) {
                if Int(cell.countshowLabel.text ?? "0") ?? 0 > 1{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "total_guests") ?? "Total guests")"
                }else{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "total_guest") ?? "Total guest")"
                }
            }
            if(sender.tag == 1) {
                if Int(cell.countshowLabel.text ?? "0") ?? 0 > 1{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bedroom_guests") ?? "Bedroom for guest")"
                }else{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bedroom_guest") ?? "Bedroom for guests")"
                }
            }
            if(sender.tag == 2) {
                if Int(cell.countshowLabel.text ?? "0") ?? 0 > 1{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bed_guests") ?? "Bed for guests")"
                }else{
                    cell.roomsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bed_guest") ?? "Bed for guest")"
                }
            }
            cell.plusBtn.isEnabled = true
            cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell.plusBtn.isUserInteractionEnabled = true
        }
    }
}

extension GuestListingViewController: stepsUpdateProtocol{
    func selectedPage(step: Int, selectedPageIndex: Int) {
        if step == 1{
            switch selectedPageIndex{
            case 0:
                let StepOne = PlaceListingViewController()
                StepOne.modalPresentationStyle = .fullScreen
                self.present(StepOne, animated:false, completion: nil)
                break
            case 1:
                break
            case 2:
                let location = AddressListingViewController()
                self.view.window?.backgroundColor = UIColor.white
                location.modalPresentationStyle = .fullScreen
                self.present(location, animated: false, completion: nil)
                break
            case 3:
                let becomeHostObj = MapLocateVC()
                self.view.window?.backgroundColor = UIColor.white
                becomeHostObj.modalPresentationStyle = .fullScreen
                self.present(becomeHostObj, animated:false, completion: nil)
                break
            case 4:
                let nextpageObj = AmenitiesViewController()
                self.view.window?.backgroundColor = UIColor.white
                nextpageObj.modalPresentationStyle = .fullScreen
                self.present(nextpageObj, animated: false, completion: nil)
                break
            case 5:
                let amenities = SafeAmenitiesViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 6:
                let spaces = SpaceListViewController()
                self.view.window?.backgroundColor = UIColor.white
                spaces.modalPresentationStyle = .fullScreen
                self.present(spaces, animated: false, completion: nil)
                break
            default:
                break
            }
        }
    }
}
