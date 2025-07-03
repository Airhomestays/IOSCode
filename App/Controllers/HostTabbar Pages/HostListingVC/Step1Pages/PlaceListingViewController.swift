
import UIKit
import Lottie
import SwiftMessages
import Apollo

protocol PlaceListingViewControllerDelegate {
    func total_guest_change(guestcount:String)
    func guestroom_detail(roomdetail:String)
}

class PlaceListingViewController: BaseHostTableviewController,GuestListingViewControllerDelegate {
    func toatalguests(guest: String) {
        total_guest_count = guest
    }
    
    var mobile = ""
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var offlineUIView: UIView!
    @IBOutlet weak var saveAndExit: UIButton!
    @IBOutlet weak var retryButn: UIButton!
    
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    var houseLabel = String()
    var roomTypeLbl = String()
    var buildingSizeLbl = String()
    var personalType = String()
    var houseTypeArray = [String]()
    var roomTypeArray = [String]()
    var buildingSizeArray = [String]()
    var staticArray = [String]()
    var inputPickerView = UIView()
    var pickerView = UIPickerView()
    var lottieView1: LottieAnimationView!
    var total_guest_count = String()
    var buildidArray = [String]()
    
    var delegatePlaceListing:PlaceListingViewControllerDelegate!
    
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleheightConstaraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    
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
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "Ready_Host") ?? "Hi! Lets get you ready to become a host.")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        self.stepsTitleView.whichStep = 1
        self.stepsTitleView.selectedViewIndex = 0
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
            self.stepTitleTopConstraint.constant = 0
        } else {
            saveAndExit.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleheightConstaraint.constant = 50
            self.stepTitleTopConstraint.constant = 5
        }
        offlineUIView.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIView, nextButton: nextBtn)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "next")as! String)", for: .normal)
        nextBtn.setTitleColor(UIColor.white, for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        self.tableView.isHidden = false
        lottieView1 = LottieAnimationView.init(name: "animation")
        saveAndExit.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"SaveExit") ?? "Save & Exit")", for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryButn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryButn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveAndExit.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        saveAndExit.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryButn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
    }
    
    override func setDropdownList() {
        if Utility.shared.step1ValuesInfo["mobile"] != nil {
            mobile = (Utility.shared.step1ValuesInfo["mobile"] as? String)!
        }
        setHouseType()
        setRoomType()
        setbuildingSize()
        setResidenceType()
        tableView.reloadData()
    }
    
    func setHouseType() {
        let listSettings = (Utility.shared.getListSettingsArray.houseType?.listSettings!)!
        for item in listSettings {
            houseTypeArray.append((item?.itemName)!)
        }
        if !Utility.shared.step1ValuesInfo.keys.contains("houseType") {
            houseLabel = houseTypeArray.first != nil ? houseTypeArray.first! : ""
            pickerView.selectRow(0, inComponent: 0, animated: true)
            Utility.shared.step1ValuesInfo.updateValue(listSettings.count > 0 ? ((listSettings[0]?.id)!) : 0, forKey: "houseType")
        }else {
            _ = listSettings.filter({ (item) -> Bool in
                if (Utility.shared.step1ValuesInfo["houseType"]! as? Int) == item?.id {
                    houseLabel = (item?.itemName!)!
                    return true
                }else{
                    return false
                }
            })
            if !houseLabel.isEmpty {
                let index = houseTypeArray.firstIndex(where: { (item) -> Bool in
                    item == houseLabel
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            } else {
                houseLabel = houseTypeArray.first != nil ? houseTypeArray.first! : ""
                pickerView.selectRow(0, inComponent: 0, animated: true)
                
                Utility.shared.step1ValuesInfo.updateValue(listSettings.count > 0 ? ((listSettings[0]?.id)!) : 0, forKey: "houseType")
            }
        }
    }
    
    override func setRoomType() {
        let roomTypeListSettings = (Utility.shared.getListSettingsArray.roomType?.listSettings!)!
        for item in roomTypeListSettings {
            roomTypeArray.append((item?.itemName)!)
        }
        if !Utility.shared.step1ValuesInfo.keys.contains("roomType") {
            roomTypeLbl = roomTypeArray.first != nil ? roomTypeArray.first! : ""
            pickerView.selectRow(0, inComponent: 0, animated: true)
            Utility.shared.step1ValuesInfo.updateValue(roomTypeListSettings.count > 0 ? (roomTypeListSettings[0]?.id)! : 0, forKey: "roomType")
        }else {
            for item in roomTypeListSettings{
                if let type = (Utility.shared.step1ValuesInfo["roomType"]! as? Int) {
                    if type == item?.id {
                        roomTypeLbl = (item?.itemName!)!
                    }
                }
            }
            if !roomTypeLbl.isEmpty {
                let index = roomTypeArray.firstIndex(where: { (item) -> Bool in
                    item == roomTypeLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            } else {
                roomTypeLbl = roomTypeArray.first != nil ? roomTypeArray.first! : ""
                pickerView.selectRow(0, inComponent: 0, animated: true)
                Utility.shared.step1ValuesInfo.updateValue(roomTypeListSettings.count > 0 ? (roomTypeListSettings[0]?.id)! : 0, forKey: "roomType")
            }
        }
    }
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIView.isHidden = true
        }
    }
    
    func setbuildingSize() {
        let buildingSizeListings = (Utility.shared.getListSettingsArray.buildingSize?.listSettings!)!
        for item in buildingSizeListings {
            buildingSizeArray.append((item?.itemName)!)
            buildidArray.append("\((item?.id)!)")
        }
        if !Utility.shared.step1ValuesInfo.keys.contains("buildingSize"){
            buildingSizeLbl = buildingSizeArray.first != nil ? buildingSizeArray.first! : ""
            Utility.shared.step1ValuesInfo.updateValue(buildidArray.count > 0 ? buildidArray[0] : 0 , forKey: "buildingSize")
            pickerView.selectRow(0, inComponent: 0, animated: true)
        }else {
            for item in buildingSizeListings{
                let build = "\(Utility.shared.step1ValuesInfo["buildingSize"]!)"
                if (item?.id == Int(build)!) {
                    buildingSizeLbl = (item?.itemName!)!
                }
            }
            if !buildingSizeLbl.isEmpty {
                let index = buildingSizeArray.firstIndex(where: { (item) -> Bool in
                    item == buildingSizeLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            } else {
                buildingSizeLbl = buildingSizeArray.first != nil ? buildingSizeArray.first! : ""
                Utility.shared.step1ValuesInfo.updateValue(buildidArray.count > 0 ? buildidArray[0] : 0 , forKey: "buildingSize")
                pickerView.selectRow(0, inComponent: 0, animated: true)
            }
        }
    }
    
    func setResidenceType() {
        staticArray.append("Yes")
        staticArray.append("No")
        if !Utility.shared.step1ValuesInfo.keys.contains("residenceType") {
            personalType = staticArray.first!
            pickerView.selectRow(0, inComponent: 0, animated: true)
            Utility.shared.step1ValuesInfo.updateValue("1", forKey: "residenceType")
        } else {
            personalType = (Utility.shared.step1ValuesInfo["residenceType"]! as? String) == "1" ? "Yes" : "No"
            if personalType == "Yes"
            {
                pickerView.selectRow(0, inComponent: 0, animated: true)
                Utility.shared.step1ValuesInfo.updateValue("1", forKey: "residenceType")
            }else if personalType == "No"
            {
                pickerView.selectRow(1, inComponent: 0, animated: true)
                Utility.shared.step1ValuesInfo.updateValue("0", forKey: "residenceType")
            }
        }
    }
    
    override func setdropdown() {
        inputPickerView.frame = CGRect(x: 0, y: FULLHEIGHT-200, width: FULLWIDTH, height: 200)
        pickerView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 200)
        inputPickerView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.tintColor = Theme.PRIMARY_COLOR
        pickerView.backgroundColor = UIColor(named: "colorController")
        pickerView.reloadAllComponents()
    }
    
    override func registerCells() {
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "textfieldcell")
        tableView.register(UINib(nibName: "TipCell", bundle: nil), forCellReuseIdentifier: "TipCell")
    }
    
    override func addLottieViewAsSubview() {}

    
    @IBAction func RedirectNextPage(_ sender: Any) {
        if self.mobile.isEmpty{
            self.view.makeToast("Please enter mobile number")
            return
        }
        if Utility().isConnectedToNetwork(){
            let guestListing = GuestListingViewController()
            guestListing.delegateGuestListing = self
            self.view.window?.backgroundColor = UIColor.white
            guestListing.modalPresentationStyle = .fullScreen
            self.present(guestListing, animated: false, completion: nil)
        } else {
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
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        delegatePlaceListing?.guestroom_detail(roomdetail:"\(Utility.shared.step1ValuesInfo["roomType"]!)")
        delegatePlaceListing?.total_guest_change(guestcount:total_guest_count)
        if(Utility.shared.step1_inactivestatus == "inactive" || Utility.shared.step1_inactivestatus == "")
        {
            self.dismiss(animated: true, completion: nil)
        }else{
            self.goToBecomeHost()
        }
        
    }
    
    func goToBecomeHost(){
        let becomeHost = BecomeHostVC()
        becomeHost.listID = "\(Utility.shared.createId)"
        becomeHost.showListingStepsAPICall(listID:"\(Utility.shared.createId)")
        becomeHost.modalPresentationStyle = .fullScreen
        self.present(becomeHost, animated:false, completion: nil)
    }
    
    func lottieanimation() {
        saveAndExit.setTitle("", for:.normal)
        lottieView1 = LottieAnimationView.init(name: "animation")
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:((self.saveAndExit.frame.size.width/2)-50), y:0, width:100, height:self.saveAndExit.frame.size.height)
        self.saveAndExit.addSubview(self.lottieView1)
        self.view.bringSubviewToFront(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor.clear
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll() {
        self.lottieView1.play()
    }
    
    
    @IBAction func saveAndExitAction(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.lottieanimation()
            super.updateListingAPICall{ (success) -> Void in
                if success {
                    saveAndExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                    
                    self.lottieView1.isHidden = true
                }
            }
        } else {
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
        return 5 + 1 //Mobile Number
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "textfieldcell", for: indexPath) as? TextFieldCell
            
            cell?.stepNumberLblTopConstraint.constant = 0
            cell?.linebottomconstant.constant = 0
            cell?.linetopconstant.constant = 0
            if indexPath.row == 0 {
                cell?.queryTitleLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "property_type")as! String)"
                
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: houseLabel,
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                cell?.txtField.tintColor = UIColor.clear
                cell?.txtField.tag = 0
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
                cell?.txtField.font = UIFont(name: APP_FONT, size: 14)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                
                
            } else if indexPath.row == 1 {
                cell?.queryTitleLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "What_guest_have")as! String)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: roomTypeLbl,
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                cell?.txtField.tag = 1
                cell?.txtField.tintColor = UIColor.clear
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
                cell?.txtField.font = UIFont(name: APP_FONT, size: 14)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                
            } else if indexPath.row == 2 {
                cell?.queryTitleLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "Rooms_in_property")as! String)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: buildingSizeLbl,
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                cell?.txtField.tag = 2
                cell?.txtField.tintColor = UIColor.clear
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
                cell?.txtField.font = UIFont(name: APP_FONT, size: 14)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                
            } else if indexPath.row == 3 {
                cell?.queryTitleLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "Personal_Home")as! String)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: personalType,
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                cell?.txtField.tag = 3
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
                cell?.txtField.font = UIFont(name: APP_FONT, size: 14)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                
            } else if indexPath.row == 4 {
                let cells = tableView
                    .dequeueReusableCell(withIdentifier: "TipCell", for: indexPath) as? TipCell
                cells?.tipText.text = "\(Utility.shared.getLanguage()?.value(forKey: "guest_personal_belongings")as! String)"
                cells?.selectionStyle = .none
                return cells!
            } else if indexPath.row == 5 {
                cell?.queryTitleLbl.text = "Mobile Number"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "Mobile Number",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                if Utility.shared.step1ValuesInfo.keys.contains("mobile"){
                    cell?.txtField.text = Utility.shared.step1ValuesInfo["mobile"] as? String
                    mobile = (cell?.txtField.text)!
                }else{
                    cell?.txtField.text = mobile.isEmpty ? "" : mobile
                }
                cell?.txtField.isUserInteractionEnabled = true
                cell?.txtField.tag = 5
                
            }
            cell?.txtField.tintColor = UIColor.clear
            cell?.txtField.textColor = UIColor(named: "Title_Header")
            cell?.stepnumberLbl.isHidden = true
            cell?.selectionStyle = .none
            let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
            cell?.txtField.inputAccessoryView = toolBar
            toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
            cell?.txtField.inputView = pickerView
            cell?.txtField.delegate = self
            cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
            
            cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
            cell?.txtField.font = UIFont(name: APP_FONT, size: 14)
            
            cell?.stepnumberLbl.text = ""
            cell?.stepNumberLblTopConstraint.constant = 0
            
            cell?.imgDownArrow.isHidden = false
            if indexPath.row == 5 {
                cell?.txtField.inputView = nil
                cell?.imgDownArrow.isHidden = true
            }
            return cell!
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            selectedTextfield = 0
            if !houseLabel.isEmpty {
                let index = houseTypeArray.firstIndex(where: { (item) -> Bool in
                    item == houseLabel
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        } else if indexPath.row == 1 {
            selectedTextfield = 1
            if !roomTypeLbl.isEmpty {
                let index = roomTypeArray.firstIndex(where: { (item) -> Bool in
                    item == roomTypeLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }else if indexPath.row == 2 {
            selectedTextfield = 2
            if !buildingSizeLbl.isEmpty {
                let index = buildingSizeArray.firstIndex(where: { (item) -> Bool in
                    item == buildingSizeLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        } else if indexPath.row == 3 {
            selectedTextfield = 3
            if personalType == "Yes" {
                pickerView.selectRow(0, inComponent: 0, animated: true)
            } else if personalType == "No" {
                pickerView.selectRow(1, inComponent: 0, animated: true)
            }
        }
        listValuePicker.reloadAllComponents()
    }

    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (selectedTextfield == 0) {
            return houseTypeArray.count
        }else if selectedTextfield == 1 {
            return roomTypeArray.count
        }else if selectedTextfield == 2 {
            return buildingSizeArray.count
        } else if selectedTextfield == 3{
            return staticArray.count
        }
        return 0
    }
    
    override func pickerView( _ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var titleData = ""
        
        if (selectedTextfield == 0) {
            if(houseTypeArray.count > row) {
                titleData = houseTypeArray[row]
            }
        }else if selectedTextfield == 1 {
            if(roomTypeArray.count > row) {
                titleData = roomTypeArray[row]
            }
        }else if selectedTextfield == 2 {
            if(buildingSizeArray.count > row) {
                titleData = buildingSizeArray[row]
            }
        }
        else if selectedTextfield == 3 {
            if(staticArray.count > row) {
                titleData = staticArray[row]
            }
        }
        
        let myTitle = NSAttributedString(string: titleData , attributes: [NSAttributedString.Key.font:UIFont(name: APP_FONT, size: 15.0)!,NSAttributedString.Key.foregroundColor:Theme.PRIMARY_COLOR])
        return myTitle
    }
    
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        if (selectedTextfield == 0) {
            houseLabel = houseTypeArray[row]
            pickerView.selectRow(row, inComponent: component, animated: true)
            Utility.shared.step1ValuesInfo.updateValue((Utility.shared.getListSettingsArray.houseType?.listSettings![row]?.id!)!, forKey: "houseType")
        } else if selectedTextfield == 1 {
            roomTypeLbl = roomTypeArray[row]
            pickerView.selectRow(row, inComponent: component, animated: true)
            Utility.shared.step1ValuesInfo.updateValue((Utility.shared.getListSettingsArray.roomType?.listSettings![row]?.id!)!, forKey: "roomType")
        }else if selectedTextfield == 2 {
            buildingSizeLbl = buildingSizeArray[row]
            pickerView.selectRow(row, inComponent: component, animated: true)
            Utility.shared.step1ValuesInfo.updateValue(buildidArray[row], forKey: "buildingSize")
        } else if selectedTextfield == 3{
            personalType = staticArray[row]
            pickerView.selectRow(row, inComponent: component, animated: true)
            Utility.shared.step1ValuesInfo.updateValue(personalType == "Yes" ? "1" : "0", forKey: "residenceType")
        }
    }
    
    @objc func onClickedDownArrow(sender: UIButton){
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! TextFieldCell
        cell.txtField.becomeFirstResponder()
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        
        selectedTextfield = textField.tag
        if selectedTextfield == 0 {
            if !houseLabel.isEmpty {
                let index = houseTypeArray.firstIndex(where: { (item) -> Bool in
                    item == houseLabel
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }else if selectedTextfield == 1 {
            if !roomTypeLbl.isEmpty {
                let index = roomTypeArray.firstIndex(where: { (item) -> Bool in
                    item == roomTypeLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }else if selectedTextfield == 2 {
            if !buildingSizeLbl.isEmpty {
                let index = buildingSizeArray.firstIndex(where: { (item) -> Bool in
                    item == buildingSizeLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }else if selectedTextfield == 3{
            if personalType == "Yes" {
                pickerView.selectRow(0, inComponent: 0, animated: true)
            }else if personalType == "No" {
                pickerView.selectRow(1, inComponent: 0, animated: true)
            }
        }
        pickerView.reloadAllComponents()
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 5 {
            let textValue = textField.text!.trimmingCharacters(in:.whitespaces)
            Utility.shared.step1ValuesInfo.updateValue(textValue, forKey: "mobile")
            mobile = textValue
        } else {
            tableView.reloadData()
            view.endEditing(true)
        }
        
    }
    
}

extension PlaceListingViewController: stepsUpdateProtocol{
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
                guestListing.delegateGuestListing = self
                self.view.window?.backgroundColor = UIColor.white
                guestListing.modalPresentationStyle = .fullScreen
                self.present(guestListing, animated: false, completion: nil)
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



public final class CreateListingMutationn: GraphQLMutation {
  public let operationDefinition =
    "mutation createListing($listId: Int, $roomType: String, $mobileNumber: String, $houseType: String, $residenceType: String, $bedrooms: String, $buildingSize: String, $bedType: String, $beds: Int, $personCapacity: Int, $bathrooms: Float, $bathroomType: String, $country: String, $street: String, $buildingName: String, $city: String, $state: String, $zipcode: String, $lat: Float, $lng: Float, $bedTypes: String, $isMapTouched: Boolean, $amenities: [Int], $safetyAmenities: [Int], $spaces: [Int]) {\n  createListing(listId: $listId, roomType: $roomType, mobileNumber: $mobileNumber, houseType: $houseType, residenceType: $residenceType, bedrooms: $bedrooms, buildingSize: $buildingSize, bedType: $bedType, beds: $beds, personCapacity: $personCapacity, bathrooms: $bathrooms, bathroomType: $bathroomType, country: $country, street: $street, buildingName: $buildingName, city: $city, state: $state, zipcode: $zipcode, lat: $lat, lng: $lng, bedTypes: $bedTypes, isMapTouched: $isMapTouched, amenities: $amenities, safetyAmenities: $safetyAmenities, spaces: $spaces) {\n    __typename\n    id\n    results {\n      __typename\n      roomType\n      mobileNumber\n      houseType\n      residenceType\n      bedrooms\n      buildingSize\n      bedType\n      beds\n      personCapacity\n      bathrooms\n      bathroomType\n      country\n      street\n      buildingName\n      city\n      state\n      zipcode\n      lat\n      lng\n      bedTypes\n      isMapTouched\n      amenities\n      safetyAmenities\n      spaces\n    }\n    status\n    errorMessage\n    actionType\n  }\n}"

  public var listId: Int?
  public var roomType: String?
  public var mobileNumber: String? // New parameter
  public var houseType: String?
  public var residenceType: String?
  public var bedrooms: String?
  public var buildingSize: String?
  public var bedType: String?
  public var beds: Int?
  public var personCapacity: Int?
  public var bathrooms: Double?
  public var bathroomType: String?
  public var country: String?
  public var street: String?
  public var buildingName: String?
  public var city: String?
  public var state: String?
  public var zipcode: String?
  public var lat: Double?
  public var lng: Double?
  public var bedTypes: String?
  public var isMapTouched: Bool?
  public var amenities: [Int?]?
  public var safetyAmenities: [Int?]?
  public var spaces: [Int?]?

  public init(listId: Int? = nil, roomType: String? = nil, mobileNumber: String? = nil, houseType: String? = nil, residenceType: String? = nil, bedrooms: String? = nil, buildingSize: String? = nil, bedType: String? = nil, beds: Int? = nil, personCapacity: Int? = nil, bathrooms: Double? = nil, bathroomType: String? = nil, country: String? = nil, street: String? = nil, buildingName: String? = nil, city: String? = nil, state: String? = nil, zipcode: String? = nil, lat: Double? = nil, lng: Double? = nil, bedTypes: String? = nil, isMapTouched: Bool? = nil, amenities: [Int?]? = nil, safetyAmenities: [Int?]? = nil, spaces: [Int?]? = nil) {
    self.listId = listId
    self.roomType = roomType
    self.mobileNumber = mobileNumber // New parameter
    self.houseType = houseType
    self.residenceType = residenceType
    self.bedrooms = bedrooms
    self.buildingSize = buildingSize
    self.bedType = bedType
    self.beds = beds
    self.personCapacity = personCapacity
    self.bathrooms = bathrooms
    self.bathroomType = bathroomType
    self.country = country
    self.street = street
    self.buildingName = buildingName
    self.city = city
    self.state = state
    self.zipcode = zipcode
    self.lat = lat
    self.lng = lng
    self.bedTypes = bedTypes
    self.isMapTouched = isMapTouched
    self.amenities = amenities
    self.safetyAmenities = safetyAmenities
    self.spaces = spaces
  }

  public var variables: GraphQLMap? {
    return ["listId": listId, "roomType": roomType, "mobileNumber": mobileNumber, "houseType": houseType, "residenceType": residenceType, "bedrooms": bedrooms, "buildingSize": buildingSize, "bedType": bedType, "beds": beds, "personCapacity": personCapacity, "bathrooms": bathrooms, "bathroomType": bathroomType, "country": country, "street": street, "buildingName": buildingName, "city": city, "state": state, "zipcode": zipcode, "lat": lat, "lng": lng, "bedTypes": bedTypes, "isMapTouched": isMapTouched, "amenities": amenities, "safetyAmenities": safetyAmenities, "spaces": spaces]
  }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes = ["Mutation"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("createListing", arguments: ["listId": GraphQLVariable("listId"), "roomType": GraphQLVariable("roomType"), "houseType": GraphQLVariable("houseType"), "residenceType": GraphQLVariable("residenceType"), "bedrooms": GraphQLVariable("bedrooms"), "buildingSize": GraphQLVariable("buildingSize"), "bedType": GraphQLVariable("bedType"), "beds": GraphQLVariable("beds"), "personCapacity": GraphQLVariable("personCapacity"), "bathrooms": GraphQLVariable("bathrooms"), "bathroomType": GraphQLVariable("bathroomType"), "country": GraphQLVariable("country"), "street": GraphQLVariable("street"), "buildingName": GraphQLVariable("buildingName"), "city": GraphQLVariable("city"), "state": GraphQLVariable("state"), "zipcode": GraphQLVariable("zipcode"), "lat": GraphQLVariable("lat"), "lng": GraphQLVariable("lng"), "bedTypes": GraphQLVariable("bedTypes"), "isMapTouched": GraphQLVariable("isMapTouched"), "amenities": GraphQLVariable("amenities"), "safetyAmenities": GraphQLVariable("safetyAmenities"), "spaces": GraphQLVariable("spaces")], type: .object(CreateListing.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(createListing: CreateListing? = nil) {
        self.init(unsafeResultMap: ["__typename": "Mutation", "createListing": createListing.flatMap { (value: CreateListing) -> ResultMap in value.resultMap }])
      }

      public var createListing: CreateListing? {
        get {
          return (resultMap["createListing"] as? ResultMap).flatMap { CreateListing(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "createListing")
        }
      }

      public struct CreateListing: GraphQLSelectionSet {
        public static let possibleTypes = ["ListingResponse"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(Int.self)),
          GraphQLField("results", type: .object(Result.selections)),
          GraphQLField("status", type: .scalar(Int.self)),
          GraphQLField("errorMessage", type: .scalar(String.self)),
          GraphQLField("actionType", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: Int? = nil, results: Result? = nil, status: Int? = nil, errorMessage: String? = nil, actionType: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "ListingResponse", "id": id, "results": results.flatMap { (value: Result) -> ResultMap in value.resultMap }, "status": status, "errorMessage": errorMessage, "actionType": actionType])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: Int? {
          get {
            return resultMap["id"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var results: Result? {
          get {
            return (resultMap["results"] as? ResultMap).flatMap { Result(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "results")
          }
        }

        public var status: Int? {
          get {
            return resultMap["status"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "status")
          }
        }

        public var errorMessage: String? {
          get {
            return resultMap["errorMessage"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "errorMessage")
          }
        }

        public var actionType: String? {
          get {
            return resultMap["actionType"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "actionType")
          }
        }

        public struct Result: GraphQLSelectionSet {
          public static let possibleTypes = ["CreateListing"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("roomType", type: .scalar(String.self)),
            GraphQLField("houseType", type: .scalar(String.self)),
            GraphQLField("residenceType", type: .scalar(String.self)),
            GraphQLField("bedrooms", type: .scalar(String.self)),
            GraphQLField("buildingSize", type: .scalar(String.self)),
            GraphQLField("bedType", type: .scalar(String.self)),
            GraphQLField("beds", type: .scalar(Int.self)),
            GraphQLField("personCapacity", type: .scalar(Int.self)),
            GraphQLField("bathrooms", type: .scalar(Double.self)),
            GraphQLField("bathroomType", type: .scalar(String.self)),
            GraphQLField("country", type: .scalar(String.self)),
            GraphQLField("street", type: .scalar(String.self)),
            GraphQLField("buildingName", type: .scalar(String.self)),
            GraphQLField("city", type: .scalar(String.self)),
            GraphQLField("state", type: .scalar(String.self)),
            GraphQLField("zipcode", type: .scalar(String.self)),
            GraphQLField("lat", type: .scalar(Double.self)),
            GraphQLField("lng", type: .scalar(Double.self)),
            GraphQLField("bedTypes", type: .scalar(String.self)),
            GraphQLField("isMapTouched", type: .scalar(Bool.self)),
            GraphQLField("amenities", type: .list(.scalar(Int.self))),
            GraphQLField("safetyAmenities", type: .list(.scalar(Int.self))),
            GraphQLField("spaces", type: .list(.scalar(Int.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(roomType: String? = nil, houseType: String? = nil, residenceType: String? = nil, bedrooms: String? = nil, buildingSize: String? = nil, bedType: String? = nil, beds: Int? = nil, personCapacity: Int? = nil, bathrooms: Double? = nil, bathroomType: String? = nil, country: String? = nil, street: String? = nil, buildingName: String? = nil, city: String? = nil, state: String? = nil, zipcode: String? = nil, lat: Double? = nil, lng: Double? = nil, bedTypes: String? = nil, isMapTouched: Bool? = nil, amenities: [Int?]? = nil, safetyAmenities: [Int?]? = nil, spaces: [Int?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "CreateListing", "roomType": roomType, "houseType": houseType, "residenceType": residenceType, "bedrooms": bedrooms, "buildingSize": buildingSize, "bedType": bedType, "beds": beds, "personCapacity": personCapacity, "bathrooms": bathrooms, "bathroomType": bathroomType, "country": country, "street": street, "buildingName": buildingName, "city": city, "state": state, "zipcode": zipcode, "lat": lat, "lng": lng, "bedTypes": bedTypes, "isMapTouched": isMapTouched, "amenities": amenities, "safetyAmenities": safetyAmenities, "spaces": spaces])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var roomType: String? {
            get {
              return resultMap["roomType"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "roomType")
            }
          }

          public var houseType: String? {
            get {
              return resultMap["houseType"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "houseType")
            }
          }

          public var residenceType: String? {
            get {
              return resultMap["residenceType"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "residenceType")
            }
          }

          public var bedrooms: String? {
            get {
              return resultMap["bedrooms"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bedrooms")
            }
          }

          public var buildingSize: String? {
            get {
              return resultMap["buildingSize"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "buildingSize")
            }
          }

          public var bedType: String? {
            get {
              return resultMap["bedType"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bedType")
            }
          }

          public var beds: Int? {
            get {
              return resultMap["beds"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "beds")
            }
          }

          public var personCapacity: Int? {
            get {
              return resultMap["personCapacity"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "personCapacity")
            }
          }

          public var bathrooms: Double? {
            get {
              return resultMap["bathrooms"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "bathrooms")
            }
          }

          public var bathroomType: String? {
            get {
              return resultMap["bathroomType"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bathroomType")
            }
          }

          public var country: String? {
            get {
              return resultMap["country"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "country")
            }
          }

          public var street: String? {
            get {
              return resultMap["street"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "street")
            }
          }

          public var buildingName: String? {
            get {
              return resultMap["buildingName"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "buildingName")
            }
          }

          public var city: String? {
            get {
              return resultMap["city"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "city")
            }
          }

          public var state: String? {
            get {
              return resultMap["state"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "state")
            }
          }

          public var zipcode: String? {
            get {
              return resultMap["zipcode"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "zipcode")
            }
          }

          public var lat: Double? {
            get {
              return resultMap["lat"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "lat")
            }
          }

          public var lng: Double? {
            get {
              return resultMap["lng"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "lng")
            }
          }

          public var bedTypes: String? {
            get {
              return resultMap["bedTypes"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bedTypes")
            }
          }

          public var isMapTouched: Bool? {
            get {
              return resultMap["isMapTouched"] as? Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "isMapTouched")
            }
          }

          public var amenities: [Int?]? {
            get {
              return resultMap["amenities"] as? [Int?]
            }
            set {
              resultMap.updateValue(newValue, forKey: "amenities")
            }
          }

          public var safetyAmenities: [Int?]? {
            get {
              return resultMap["safetyAmenities"] as? [Int?]
            }
            set {
              resultMap.updateValue(newValue, forKey: "safetyAmenities")
            }
          }

          public var spaces: [Int?]? {
            get {
              return resultMap["spaces"] as? [Int?]
            }
            set {
              resultMap.updateValue(newValue, forKey: "spaces")
            }
          }
        }
      }
    }
  }
