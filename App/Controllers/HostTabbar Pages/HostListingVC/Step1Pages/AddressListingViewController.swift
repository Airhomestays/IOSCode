
import UIKit
import MapKit
import Lottie
import IQKeyboardManagerSwift

class AddressListingViewController: BaseHostTableviewController, CountryDelegate {
    
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var offlineUIView: UIView!
    @IBOutlet weak var saveandExit: UIButton!
    @IBOutlet weak var retryButn: UIButton!
    
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    
    var countryPlaceHolder = ""
    var countryValue = ""
    var selectedCountryCode = ""
    var countryArr = [String]()
    var isSaveandExitEnabled = Bool()
    var address = ""
    var street = ""
    var buildingName = ""
    var city = ""
    var state = ""
    var pincode = ""
    var createResults = CreateListingMutationn.Data.CreateListing.Result()
    var lottieView1: LottieAnimationView!
    
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleheightConstaraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstaraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        tableView.backgroundColor =  UIColor(named: "colorController")
        bottomView.backgroundColor =  UIColor(named: "colorController")
        curvedView.backgroundColor = UIColor(named: "colorController")
        nextBtn.backgroundColor = Theme.Button_BG
        saveandExit.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = UIColor.white
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "Where_place") ?? "Where's your place located?")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        saveandExit.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"SaveExit") ?? "Save & Exit")", for:.normal)
        
        IQKeyboardManager.shared.enable = true
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryButn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveandExit.setTitleColor(Theme.PRIMARY_COLOR, for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryButn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveandExit.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        saveandExit.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryButn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
        self.stepsTitleView.whichStep = 1
        self.stepsTitleView.selectedViewIndex = 2
        self.stepsTitleView.delegateSteps = self
        
        progressViewWidth.constant = ((self.view.frame.width/7) * CGFloat((self.stepsTitleView.selectedViewIndex + 1)))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
        progressViewWidth.constant = ((self.view.frame.width/7) * CGFloat((self.stepsTitleView.selectedViewIndex + 1)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nextBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "next")as! String)", for:.normal)
    }
    
    override func setUpUI() {
        if(Utility.shared.step1_inactivestatus == "inactive" || Utility.shared.step1_inactivestatus == "")
        {
            saveandExit.isHidden = true
            isSaveandExitEnabled = false
            self.stepsTitleView.isHidden = true
            self.stepTitleheightConstaraint.constant = 0
            self.stepTitleTopConstaraint.constant = 0
        } else {
            saveandExit.isHidden = false
            isSaveandExitEnabled = true
            self.stepsTitleView.isHidden = false
            self.stepTitleheightConstaraint.constant = 50
            self.stepTitleTopConstaraint.constant = 5
        }
        offlineUIView.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIView, nextButton: nextBtn)
        tableView.isHidden = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        
        
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "next"))!)", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        lottieView1 = LottieAnimationView.init(name: "animation")
    }
    
    override func setDropdownList() {
        
        for country in Utility.shared.countrylist {
            countryArr.append(country.countryName!)
        }
        if countryArr.count > 0 {
            countryPlaceHolder = countryArr.first!
        }
        
        if Utility.shared.step1ValuesInfo["country"] != nil {
            address = Utility.shared.step1ValuesInfo["country"] as! String
            countryValue = Utility.shared.step1ValuesInfo["country"] as! String
        }
        if Utility.shared.step1ValuesInfo["street"] != nil {
            street = (Utility.shared.step1ValuesInfo["street"] as? String)!
        }
        if Utility.shared.step1ValuesInfo["city"] != nil {
            city = (Utility.shared.step1ValuesInfo["city"] as? String)!
        }
        if Utility.shared.step1ValuesInfo["state"] != nil {
            state = (Utility.shared.step1ValuesInfo["state"] as? String)!
        }
        if Utility.shared.step1ValuesInfo["zipcode"] != nil {
            address = address + "" + (Utility.shared.step1ValuesInfo["zipcode"] as! String)
            pincode = (Utility.shared.step1ValuesInfo["zipcode"] as? String)!
        }
        tableView.reloadData()
    }
    
    
    
    func offlineViewShow() {
        offlineUIView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.offlineUIView.isHidden = false
        let shadowSize2 : CGFloat = 3.0
        let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                    y: -shadowSize2 / 2,
                                                    width: self.offlineUIView.frame.size.width + shadowSize2,
                                                    height: self.offlineUIView.frame.size.height + shadowSize2))
        
        self.offlineUIView.layer.masksToBounds = false
        self.offlineUIView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.offlineUIView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.offlineUIView.layer.shadowOpacity = 0.3
        self.offlineUIView.layer.shadowPath = shadowPath2.cgPath
        if IS_IPHONE_X || IS_IPHONE_XR{
            offlineUIView.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
        }else{
            offlineUIView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
        }
    }
    
    func lottienextanimation() {
        nextBtn.setTitle("", for:.normal)
        lottieView1 = LottieAnimationView.init(name: "animation_white")
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:((self.nextBtn.frame.size.width/2)-50), y:0, width:100, height:self.nextBtn.frame.size.height)
        self.nextBtn.addSubview(self.lottieView1)
        self.view.bringSubviewToFront(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor.clear
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll1), userInfo: nil, repeats: true)
    }
    @objc func autoscroll1() {
        self.lottieView1.play()
    }
    func createListingAPICall() {
        nextBtn.isHidden = false
        
        if Utility.shared.isConnectedToNetwork() {
            let createlist = CreateListingMutationn(listId: nil,
                                                   roomType: "\(Utility.shared.step1ValuesInfo["roomType"] ?? "")",
                                                    mobileNumber: "\(Utility.shared.step1ValuesInfo["mobile"] ?? "")",
                                                   houseType: "\(Utility.shared.step1ValuesInfo["houseType"] ?? "")" ,
                                                   residenceType: "\(Utility.shared.step1ValuesInfo["residenceType"] ?? "")",
                                                   bedrooms: "\(Utility.shared.step1ValuesInfo["bedrooms"] ?? "")" ,
                                                   buildingSize: "\(Utility.shared.step1ValuesInfo["buildingSize"] ?? "")",
                                                   bedType: "\(Utility.shared.step1ValuesInfo["bedType"] ?? "")" ,
                                                   beds: Utility.shared.step1ValuesInfo["beds"] as? Int,
                                                   personCapacity: Utility.shared.step1ValuesInfo["personCapacity"] as? Int,
                                                   bathrooms:(Utility.shared.step1ValuesInfo["bathrooms"] as? Double),
                                                   bathroomType: "\(Utility.shared.step1ValuesInfo["bathroomType"] ?? "")",
                                                   country: "\(Utility.shared.step1ValuesInfo["country"] ?? "")",
                                                   street: "\(Utility.shared.step1ValuesInfo["street"] ?? "")",
                                                   buildingName: "\(Utility.shared.step1ValuesInfo["buildingName"] ?? "")",
                                                   city: "\(Utility.shared.step1ValuesInfo["city"] ?? "")",
                                                   state: "\(Utility.shared.step1ValuesInfo["state"] ?? "")",
                                                   zipcode: "\(Utility.shared.step1ValuesInfo["zipcode"] ?? "")",
                                                   lat: (Utility.shared.step1ValuesInfo["lat"] as! Double),
                                                   lng: (Utility.shared.step1ValuesInfo["lng"] as! Double),
                                                   bedTypes: "\(Utility.shared.step1ValuesInfo["bedTypes"] ?? "")" ,
                                                   isMapTouched: Utility.shared.step1ValuesInfo["isMapTouched"] as? Bool,
                                                   amenities: [] ,
                                                   safetyAmenities: [] ,
                                                   spaces: [])
            apollo_headerClient.perform(mutation: createlist){ (result,error) in
                
                if(result?.data?.createListing?.status == 200) {
                    
                    self.lottieView1.isHidden = true
                    self.nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "next"))!)", for:.normal)
                    self.createResults = (result?.data?.createListing?.results)!
                    Utility.shared.createId = (result?.data?.createListing?.id)!
                    self.manageListingSteps(listId: "\((result?.data?.createListing?.id)!)", currentStep: 1)
                }else {
                    self.lottieView1.isHidden = true
                    self.nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "next"))!)", for:.normal)
                }
            }
        }else {
            self.lottieView1.isHidden = true
            self.nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "next"))!)", for:.normal)
            super.lottieView.isHidden = true
            nextBtn.isHidden = true
            offlineUIView.isHidden = false
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: UIScreen.main.bounds.size.width + shadowSize2,
                                                        height: offlineUIView.frame.size.height + shadowSize2))
            
            offlineUIView.layer.masksToBounds = false
            offlineUIView.layer.shadowColor = Theme.TextLightColor.cgColor
            offlineUIView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            offlineUIView.layer.shadowOpacity = 0.3
            offlineUIView.layer.shadowPath = shadowPath2.cgPath
            if IS_IPHONE_X || IS_IPHONE_XR {
                offlineUIView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: UIScreen.main.bounds.size.width, height: 55)
            }else{
                offlineUIView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: UIScreen.main.bounds.size.width, height: 55)
            }
        }
        
    }
    
    func manageListingSteps(listId:String,currentStep:Int) {
        let manageListingStepsMutation = ManageListingStepsMutation(listId:listId, currentStep:currentStep)
        apollo_headerClient.perform(mutation: manageListingStepsMutation){ (result,error) in
            
            if(result?.data?.manageListingSteps?.status == 200) {
                self.lottieView1.isHidden = true
                let becomeHostObj = MapLocateVC()
                if(Utility.shared.isfrombecomehoststep1Edit)
                {
                    Utility.shared.step1_inactivestatus = "completed"
                }
                else
                {
                    Utility.shared.step1_inactivestatus = ((result?.data?.manageListingSteps?.results?.step3!)!)
                }
                self.view.window?.backgroundColor = UIColor.white
                becomeHostObj.modalPresentationStyle = .fullScreen
                self.present(becomeHostObj, animated:false, completion: nil)
            }
            else {
                self.view.makeToast(result?.data?.manageListingSteps?.errorMessage)
            }
        }
    }
    
    override func registerCells() {
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "textfieldcell")
    }
    
    func lottieViewanimation() {
        saveandExit.setTitle("", for:.normal)
        lottieView1 = LottieAnimationView.init(name: "animation")
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:((self.saveandExit.frame.size.width/2)-50), y:0, width:100, height:self.saveandExit.frame.size.height)
        self.saveandExit.addSubview(self.lottieView1)
        self.view.bringSubviewToFront(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor.clear
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll() {
        self.lottieView1.play()
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIView.isHidden = true
        }
    }
    func updateAddressVariable(){
        address = countryValue
        address = address + " " + pincode
    }
    @IBAction func RedirectNextPage(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if self.countryValue.isEmpty || self.street.isEmpty || self.city.isEmpty || self.state.isEmpty || self.pincode.isEmpty {
                if self.countryValue.isEmpty{
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "enter_country"))!)")
                    return
                }
                if self.street.isEmpty{
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "enter_street"))!)")
                    return
                }
                if self.city.isEmpty {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "entercity"))!)")
                    return
                }
                if self.state.isEmpty {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "enterstate"))!)")
                    return
                }
                if self.pincode.isEmpty {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "enterzipcode"))!)")
                    return
                }
            }else{
                updateAddressVariable()
                if(("\(Utility.shared.createId)" != "0") && ("\(Utility.shared.createId)" != "")) {
                    
                    self.lottienextanimation()
                    if(address != "") {
                        let geoCoder = CLGeocoder()
                        geoCoder.geocodeAddressString(address) { (placemarks, error) in
                            guard
                                let placemarks = placemarks,
                                let location = placemarks.first?.location else {
                                
                                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "wrong_location"))!)")
                                self.lottieView1.isHidden = true
                                self.nextBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "next")as! String)", for:.normal)
                                return
                            }
                            Utility.shared.step1ValuesInfo.updateValue(Double(location.coordinate.latitude), forKey: "lat")
                            Utility.shared.step1ValuesInfo.updateValue(Double(location.coordinate.longitude), forKey: "lng")
                            
                            DispatchQueue.main.async {
                                self.manageListingSteps(listId:"\(Utility.shared.createId)", currentStep: 1)
                            }
                            
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.manageListingSteps(listId:"\(Utility.shared.createId)", currentStep: 1)
                        }
                    }
                }else {
                    self.lottienextanimation()
                    let geoCoder = CLGeocoder()
                    geoCoder.geocodeAddressString(address) { (placemarks, error) in
                        guard
                            let placemarks = placemarks,
                            let location = placemarks.first?.location
                        else {
                            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "wrong_location"))!)")
                            self.lottieView1.isHidden = true
                            self.nextBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "next")as! String)", for:.normal)
                            return
                        }
                        Utility.shared.step1ValuesInfo.updateValue(Double(location.coordinate.latitude), forKey: "lat")
                        Utility.shared.step1ValuesInfo.updateValue(Double(location.coordinate.longitude), forKey: "lng")
                        Utility.shared.step1ValuesInfo.updateValue(true, forKey: "isMapTouched")
                        
                        DispatchQueue.main.async {
                            self.createListingAPICall()
                        }
                    }
                }
                
            }
        } else {
            self.offlineViewShow()
        }
        
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
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
    
    @IBAction func saveAndExitAction(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            updateAddressVariable()
            let geoCoder = CLGeocoder()
            
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "wrong_location"))!)")
                    self.lottieView1.isHidden = true
                    self.nextBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "next")as! String)", for:.normal)
                    return
                }
                Utility.shared.step1ValuesInfo.updateValue(Double(location.coordinate.latitude), forKey: "lat")
                Utility.shared.step1ValuesInfo.updateValue(Double(location.coordinate.longitude), forKey: "lng")
                Utility.shared.step1ValuesInfo.updateValue(true, forKey: "isMapTouched")
                self.lottieViewanimation()
                super.updateListingAPICall{ (success) -> Void in
                    if success {
                        self.saveandExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                        
                        self.lottieView1.isHidden = true
                    }
                }
            }
        } else {
            self.offlineViewShow()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "textfieldcell", for: indexPath) as? TextFieldCell
            cell?.stepnumberLbl.isHidden = true
            let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissPicker))
            cell?.txtField.inputAccessoryView = toolBar
            toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
            cell?.queryTitleLbl.font = UIFont(name:APP_FONT_MEDIUM, size: 14)
            cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
            cell?.txtField.font = UIFont(name: APP_FONT, size: 14)
            if indexPath.row == 5 {
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey: "country_OR_region"))!)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: countryPlaceHolder.isEmpty ? "Afghanistan" : countryPlaceHolder,
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                if Utility.shared.step1ValuesInfo.keys.contains("country"){
                    for i in 0..<Utility.shared.countrylist.count{
                        if Utility.shared.countrylist[i].countryCode == Utility.shared.step1ValuesInfo["country"] as? String {
                            cell?.txtField.text = Utility.shared.countrylist[i].countryName
                        }
                    }
                    countryValue = (cell?.txtField.text)!
                }
                cell?.txtField.isUserInteractionEnabled = false
                cell?.txtField.tag = 0
                
            }else if indexPath.row == 0 {
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey: "street"))!)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "\((Utility.shared.getLanguage()?.value(forKey: "street_placeholder"))!)",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                if Utility.shared.step1ValuesInfo.keys.contains("street"){
                    cell?.txtField.text = Utility.shared.step1ValuesInfo["street"] as? String
                    street = (cell?.txtField.text)!
                }else{
                    cell?.txtField.text = street.isEmpty ? "" : street
                }
                cell?.txtField.isUserInteractionEnabled = true
                cell?.txtField.tag = 1
                
            }else if indexPath.row == 1 {
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey: "Apt_suite_optional"))!)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "\((Utility.shared.getLanguage()?.value(forKey: "Apt_suite_placeholder"))!)",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                cell?.txtField.tag = 2
                if Utility.shared.step1ValuesInfo.keys.contains("buildingName"){
                    cell?.txtField.text = Utility.shared.step1ValuesInfo["buildingName"] as? String
                    buildingName = (cell?.txtField.text)!
                }else{
                    cell?.txtField.text = buildingName.isEmpty ? "" : buildingName
                }
                cell?.txtField.isUserInteractionEnabled = true
                
            }else if indexPath.row == 2 {
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey: "city"))!)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "\((Utility.shared.getLanguage()?.value(forKey: "city_placeholder"))!)",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                if Utility.shared.step1ValuesInfo.keys.contains("city"){
                    cell?.txtField.text = Utility.shared.step1ValuesInfo["city"] as? String
                    city = (cell?.txtField.text)!
                }else{
                    cell?.txtField.text = city.isEmpty ? "" : city
                }
                cell?.txtField.isUserInteractionEnabled = true
                cell?.txtField.tag = 3
                
            }else if indexPath.row == 3 {
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey: "state"))!)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "\((Utility.shared.getLanguage()?.value(forKey: "state_placeholder"))!)",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                if Utility.shared.step1ValuesInfo.keys.contains("state"){
                    cell?.txtField.text = Utility.shared.step1ValuesInfo["state"] as? String
                    state = (cell?.txtField.text)!
                } else{
                    cell?.txtField.text = state.isEmpty ? "" : state
                }
                cell?.txtField.isUserInteractionEnabled = true
                cell?.txtField.tag = 4
                
            }else if indexPath.row == 4 {
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey: "zip_OR_postal"))!)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "\((Utility.shared.getLanguage()?.value(forKey: "zip_Placeholder"))!)",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                if Utility.shared.step1ValuesInfo.keys.contains("zipcode"){
                    cell?.txtField.text = Utility.shared.step1ValuesInfo["zipcode"] as? String
                    pincode = cell?.txtField.text ?? ""
                }else{
                    cell?.txtField.text = pincode.isEmpty ? "" : pincode
                }
                cell?.txtField.isUserInteractionEnabled = true
                cell?.txtField.tag = 5
                
            }
            cell?.txtField.tintColor =  UIColor(named: "Title_Header")
            cell?.selectionStyle = .none
            cell?.txtField.delegate = self
            
            cell?.stepnumberLbl.text = ""
            cell?.stepNumberLblTopConstraint.constant = 0
            cell?.linebottomconstant.constant = 0
            cell?.linetopconstant.constant = 0
            
            return cell!
            
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            let countryListObj = CountrycodeVC()
            Utility.shared.isPhonenumberCountrycode = false
            countryListObj.titleForHeader = "\((Utility.shared.getLanguage()?.value(forKey: "selectcountry"))!)"
            countryListObj.delegate = self
            countryListObj.modalPresentationStyle = .fullScreen
            self.present(countryListObj, animated:false, completion: nil)
        }
    }
    
    func setSelectedCountry(selectedCountry: String, selectedcountryCode : String, selectdialcode: String) {
        countryValue = selectedCountry
        self.selectedCountryCode = selectedcountryCode
        Utility.shared.step1ValuesInfo.updateValue(selectedCountryCode, forKey: "country")
        self.tableView.reloadData()
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            let textValue = textField.text!.trimmingCharacters(in:.whitespaces)
            Utility.shared.step1ValuesInfo.updateValue(textValue, forKey: "street")
            street = textValue
        }
        if textField.tag == 2 {
            let textValue = textField.text!.trimmingCharacters(in:.whitespaces)
            Utility.shared.step1ValuesInfo.updateValue(textValue, forKey: "buildingName")
            buildingName = textValue
        }
        if textField.tag == 3 {
            let textValue = textField.text!.trimmingCharacters(in:.whitespaces)
            Utility.shared.step1ValuesInfo.updateValue(textValue, forKey: "city")
            city = textValue
        }
        if textField.tag == 4 {
            let textValue = textField.text!.trimmingCharacters(in:.whitespaces)
            Utility.shared.step1ValuesInfo.updateValue(textValue, forKey: "state")
            state = textValue
        }
        if textField.tag == 5 {
            let textValue = textField.text!.trimmingCharacters(in:.whitespaces)
            Utility.shared.step1ValuesInfo.updateValue(textValue, forKey: "zipcode")
            pincode = textValue.trimmingCharacters(in: .whitespacesAndNewlines)
            address = countryValue
            address = address + " " + textValue
        }
        
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
}

extension AddressListingViewController: stepsUpdateProtocol{
    func selectedPage(step: Int, selectedPageIndex: Int) {
        if step == 1{
            switch selectedPageIndex{
            case 0:
                let StepOne = PlaceListingViewController()
                StepOne.modalPresentationStyle = .fullScreen
                self.present(StepOne, animated:false, completion: nil)
                break
            case 1:
                let guestListing = GuestListingViewController()
                self.view.window?.backgroundColor = UIColor.white
                guestListing.modalPresentationStyle = .fullScreen
                self.present(guestListing, animated: false, completion: nil)
                break
            case 2:
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
