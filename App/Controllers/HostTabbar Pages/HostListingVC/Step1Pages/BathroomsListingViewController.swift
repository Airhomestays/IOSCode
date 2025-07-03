
import UIKit
import Lottie

class BathroomsListingViewController: BaseHostTableviewController {
    

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var offlineUIView: UIView!
    @IBOutlet weak var saveAndExit: UIButton!
    @IBOutlet weak var retryButn: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var bathroomsArr = [Float]()
    var bathroomsCount = Float()
    var bathroomTypeArr = [String]()
    var bathroomTypeLbl = String()
    var inputListView = UIView()
    var pickerView = UIPickerView()
    var lottieView1: LottieAnimationView!
    var bathroomJSONValue = Float()
    
    @IBOutlet weak var stepTitleheightConstaraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstaraint: NSLayoutConstraint!

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
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "How_many_bath") ?? "How many bathrooms?")"
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func setUpUI() {
        saveAndExit.isHidden = true
        if(Utility.shared.step1_inactivestatus == "inactive" || Utility.shared.step1_inactivestatus == "") {
            saveAndExit.isHidden = true
        } else {
            saveAndExit.isHidden = false
        }
        offlineUIView.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIView, nextButton: nextBtn)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "save")as! String)", for: .normal)
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
        
        setBathroomsCount()
        setBathroomType()
        
        tableView.reloadData()
    }
    
    func setBathroomsCount() {
        var incrVal = 1.0
        let bathrooms = Utility.shared.getListSettingsArray.bathrooms?.listSettings != nil ? (Utility.shared.getListSettingsArray.bathrooms?.listSettings![0]?.endValue)! : 0
        let valcount = bathrooms + bathrooms - 1
        for i in 0..<valcount {
            bathroomsArr.insert(Float(incrVal) , at: i)
            incrVal = (incrVal + 0.5)
        }
        
        if Utility.shared.step1ValuesInfo.keys.contains("bathrooms") {
            if let bedRoomsCountValues = (Utility.shared.step1ValuesInfo["bathrooms"]!) as? Double {
                bathroomsCount = Float(bedRoomsCountValues)
                bathroomJSONValue = Float(bedRoomsCountValues)
            }
        }else{
            bathroomsCount = bathroomsArr.first != nil ? bathroomsArr.first! : 0
            bathroomJSONValue = 1
            Utility.shared.step1ValuesInfo.updateValue(Double(bathroomJSONValue), forKey: "bathrooms")
        }
    }
    
    func setBathroomType() {
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
                if (Utility.shared.step1ValuesInfo["bathroomType"]! as? Int) == item?.id {
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
    
    override func registerCells() {
        tableView.register(UINib(nibName: "RoomsCell", bundle: nil), forCellReuseIdentifier: "RoomsCell")
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "textfieldcell")
    }
   
    override func addLottieViewAsSubview() {}
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIView.isHidden = true
        }
        
    }
    
    @IBAction func RedirectNextPage(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if(Double(bathroomJSONValue) < 1) {
                Utility.shared.step1ValuesInfo.updateValue(Double(1),forKey: "bathrooms")
            } else {
                Utility.shared.step1ValuesInfo.updateValue(Double(bathroomJSONValue),forKey: "bathrooms")
            }
            let location = AddressListingViewController()
            self.view.window?.backgroundColor = UIColor.white
            location.modalPresentationStyle = .fullScreen
            self.present(location, animated: false, completion: nil)
        } else {
            self.offlineViewShow()
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
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
    func lottieViewanimation() {
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
    @IBAction func saveandexit(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.lottieViewanimation()
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
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: "RoomsCell", for: indexPath) as? RoomsCell
                cell?.dashView.isHidden = false
                cell?.dashView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
                cell?.roomsTitleLabel.text = "\(1) \(Utility.shared.getLanguage()?.value(forKey: "bathroom")as! String)"
                cell?.countshowLabel.text = "1"
                if bathroomsCount > 1 {
                    let val = Double(bathroomsCount).clean
                    cell?.roomsTitleLabel.text = "\(val) \(Utility.shared.getLanguage()?.value(forKey: "bathrooms")as! String)"
                    cell?.countshowLabel.text = "\(val)"
                    bathroomJSONValue = Float(bathroomsCount)
                }else{
                    if(bathroomsCount != 0) {
                        cell?.roomsTitleLabel.text = "\(Int(bathroomsCount)) \(Utility.shared.getLanguage()?.value(forKey: "bathroom")as! String)"
                        cell?.countshowLabel.text = "\(Int(bathroomsCount))"
                        bathroomJSONValue = Float(bathroomsCount)
                    }
                }
                cell?.roomsTitleLabel.textColor = UIColor(named: "Title_Header")
                cell?.countshowLabel.textColor = UIColor(named: "Title_Header")
                
                cell?.roomsTitleLabel.font = UIFont(name:APP_FONT, size: 18.0)
                cell?.countValue = 1
                cell?.plusBtn.tag = indexPath.row
                cell?.minusBtn.tag = indexPath.row
                cell?.tag = indexPath.row + 100
                cell?.plusBtn.addTarget(self, action: #selector(self.plusBtnTapped(sender:)), for: .touchUpInside)
                cell?.minusBtn.addTarget(self, action: #selector(self.minusBtnTapped(sender:)), for: .touchUpInside)
                cell?.selectionStyle = .none
                cell?.plusBtn.layer.cornerRadius = (cell?.plusBtn.frame.size.width)!/2
                cell?.plusBtn.layer.borderWidth = 1.0
                cell?.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                cell?.minusBtn.layer.cornerRadius = (cell?.minusBtn.frame.size.width)!/2
                cell?.minusBtn.layer.borderWidth = 1.0
                cell?.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                return cell!
            } else {
                
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
                
                cell?.imgDownArrow.isHidden = false
                return cell!
                
            }
            
        }
        return UITableViewCell()
    }
    
    @objc func onClickedDownArrow(sender: UIButton){
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! TextFieldCell
        cell.txtField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            selectedTextfield = 1
            if !bathroomTypeLbl.isEmpty {
                let index = bathroomTypeArr.firstIndex(where: { (item) -> Bool in
                    item == bathroomTypeLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }
        pickerView.reloadAllComponents()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
 
    @objc func plusBtnTapped(sender : UIButton) {
        if let cell = view.viewWithTag(sender.tag + 100) as? RoomsCell {
            if bathroomsArr.count > 0 {
                if Float(cell.countshowLabel.text!)! >= bathroomsArr.last! && sender.tag == 0 {
                    cell.plusBtn.isEnabled = false
                    cell.plusBtn.isUserInteractionEnabled = false
                }else{
                    cell.countshowLabel.text = "\((Double(cell.countshowLabel.text!)! + 0.5))"
                    bathroomsCount = Float(cell.countshowLabel.text!)!
                    cell.plusBtn.isEnabled = true
                    cell.plusBtn.isUserInteractionEnabled = true
                    cell.minusBtn.isUserInteractionEnabled = true
                    cell.minusBtn.isEnabled = true
                    bathroomJSONValue = Float(cell.countshowLabel.text!)!
                    if (Double(cell.countshowLabel.text!)!) > 1.0 {
                        let array = cell.countshowLabel.text!.components(separatedBy: ".")
                        if array[1].contains("0") {
                            cell.roomsTitleLabel.text = "\(array[0]) \(Utility.shared.getLanguage()?.value(forKey: "bathrooms")as! String)"
                            cell.countshowLabel.text! = array[0]
                        }else{
                            cell.roomsTitleLabel.text = "\(cell.countshowLabel.text!) \(Utility.shared.getLanguage()?.value(forKey: "bathrooms")as! String)"
                        }
                    }else{
                        let array = cell.countshowLabel.text!.components(separatedBy: ".")
                        if array[1].contains("0") {
                            cell.roomsTitleLabel.text = "\(array[0]) \(Utility.shared.getLanguage()?.value(forKey: "bathroom")as! String)"
                            cell.countshowLabel.text! = array[0]
                        }else{
                            cell.roomsTitleLabel.text = "\(cell.countshowLabel.text!) \(Utility.shared.getLanguage()?.value(forKey: "bathroom")as! String)"
                        }
                    }
                }
            }
        }
    }
    
    @objc func minusBtnTapped(sender : UIButton) {
        if let cell = view.viewWithTag(sender.tag + 100) as? RoomsCell {
            if Float(cell.countshowLabel.text!)! <= bathroomsArr.first! && sender.tag == 0 {
                cell.minusBtn.isEnabled = false
                cell.minusBtn.isUserInteractionEnabled = false
            }else{
                
                cell.countshowLabel.text = "\((Double(cell.countshowLabel.text!)! - 0.5))"
                bathroomsCount = Float(cell.countshowLabel.text!)!
                cell.minusBtn.isEnabled = true
                cell.minusBtn.isUserInteractionEnabled = true
                cell.plusBtn.isEnabled = true
                cell.plusBtn.isUserInteractionEnabled = true
                bathroomJSONValue = Float(cell.countshowLabel.text!)!
                if (Double(cell.countshowLabel.text!)!) > 1.0 {
                    let array = cell.countshowLabel.text!.components(separatedBy: ".")
                    if array[1].contains("0") {
                        cell.roomsTitleLabel.text = "\(array[0]) \(Utility.shared.getLanguage()?.value(forKey: "bathrooms")as! String)"
                        cell.countshowLabel.text! = array[0]
                    }else{
                        cell.roomsTitleLabel.text = "\(cell.countshowLabel.text!) \(Utility.shared.getLanguage()?.value(forKey: "bathrooms")as! String)"
                    }
                } else{
                    
                    let array = cell.countshowLabel.text!.components(separatedBy: ".")
                    if array[1].contains("0") {
                        cell.roomsTitleLabel.text = "\(array[0]) \(Utility.shared.getLanguage()?.value(forKey: "bathroom")as! String)"
                        cell.countshowLabel.text! = array[0]
                    }else{
                        cell.roomsTitleLabel.text = "\(cell.countshowLabel.text!) \(Utility.shared.getLanguage()?.value(forKey: "bathroom")as! String)"
                    }
                }
            }
        }
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
        tableView.reloadData()
        view.endEditing(true)
    }
    
}

extension BathroomsListingViewController: stepsUpdateProtocol{
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
                //                guestListing.delegateGuestListing = self
                self.view.window?.backgroundColor = UIColor.white
                guestListing.modalPresentationStyle = .fullScreen
                self.present(guestListing, animated: false, completion: nil)
                break
            case 2:
                let bedsListing = BedsListingViewController()
                self.view.window?.backgroundColor = UIColor.white
                bedsListing.modalPresentationStyle = .fullScreen
                self.present(bedsListing, animated: false, completion: nil)
                break
            case 3:
                break
            case 4:
                let location = AddressListingViewController()
                self.view.window?.backgroundColor = UIColor.white
                // self.view.layer.add(dismissrightAnimation()!, forKey: kCATransition)
                location.modalPresentationStyle = .fullScreen
                self.present(location, animated: false, completion: nil)
                break
            case 5:
                let becomeHostObj = MapLocateVC()
                self.view.window?.backgroundColor = UIColor.white
                becomeHostObj.modalPresentationStyle = .fullScreen
                self.present(becomeHostObj, animated:false, completion: nil)
                break
            case 6:
                let nextpageObj = AmenitiesViewController()
                self.view.window?.backgroundColor = UIColor.white
                nextpageObj.modalPresentationStyle = .fullScreen
                self.present(nextpageObj, animated: false, completion: nil)
                break
            case 7:
                let amenities = SafeAmenitiesViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 8:
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
