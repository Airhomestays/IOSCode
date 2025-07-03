
import UIKit
import Lottie
import SwiftMessages

class BookingWindowViewController: BaseHostTableviewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var saveandExitBtn: UIButton!
    @IBOutlet weak var offlineUIView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    
    var futureDateLbl = String()
    var cancellationLbl = String()
    var cancel_id = Int()
    var futureDatesArr = [String]()
    var futures_Date_Array_without_String = [String]()
    var future_array = [String]()
    var staticArray = [String]()
    var inputPickerView = UIView()
    var pickerView = UIPickerView()
    var lottieView1: LottieAnimationView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        tableView.backgroundColor =  UIColor(named: "colorController")
        bottomView.backgroundColor =  UIColor(named: "colorController")
        curvedView.backgroundColor = UIColor(named: "colorController")
        
        nextBtn.backgroundColor = Theme.Button_BG
        saveandExitBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = UIColor.white
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bookingwindow") ?? "Booking Window")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveandExitBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
        saveandExitBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveandExitBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
        self.stepsTitleView.whichStep = 3
        self.stepsTitleView.selectedViewIndex = 4
        self.stepsTitleView.delegateSteps = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
    }
    
    override func setUpUI() {
        offlineUIView.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIView, nextButton: nextBtn)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        self.tableView.isHidden = false
        if(Utility.shared.step3_Edit) {
            self.saveandExitBtn.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleHeightConstraint.constant = 50
            self.stepTitleTopConstraint.constant = 5
        } else {
            self.saveandExitBtn.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleHeightConstraint.constant = 0
            self.stepTitleTopConstraint.constant = 0
        }
    }
    
    override func setDropdownList() {
        self.setBookingStatus()
        self.setStaticArray()
        tableView.reloadData()
    }
    
    func setBookingStatus() {
        let listSettings = (Utility.shared.getListSettingsArray.maxDaysNotice?.listSettings!)!
        
        futureDatesArr = ["\((Utility.shared.getLanguage()?.value(forKey:"datesunavailable"))!)","3 \((Utility.shared.getLanguage()?.value(forKey:"monthsintofuture"))!)","6 \((Utility.shared.getLanguage()?.value(forKey:"monthsintofuture"))!)","9 \((Utility.shared.getLanguage()?.value(forKey:"monthsintofuture"))!)","12 \((Utility.shared.getLanguage()?.value(forKey:"monthsintofuture"))!)","\((Utility.shared.getLanguage()?.value(forKey:"Allfuturedates"))!)"]
        
        futures_Date_Array_without_String = ["unavailable","3months","6months","9months","12months","available"]
        future_array = ["Dates unavailable by default","3months into the future","6months into the future","9months into the future","12months into the future","All future dates"]
        
        if(Utility.shared.step3ValuesInfo["maxDaysNotice"] != nil && (("\(Utility.shared.step3ValuesInfo["maxDaysNotice"]!)") == "available")) {
            futureDateLbl = "\((Utility.shared.getLanguage()?.value(forKey:"Allfuturedates"))!)"
            Utility.shared.step3ValuesInfo.updateValue("available", forKey: "maxDaysNotice")
        }
        if(Utility.shared.step3ValuesInfo["maxDaysNotice"] != nil && ("\(Utility.shared.step3ValuesInfo["maxDaysNotice"]!)" == "unavailable")) {
            futureDateLbl = "\((Utility.shared.getLanguage()?.value(forKey:"datesunavailable"))!)"
            Utility.shared.step3ValuesInfo.updateValue("unavailable", forKey: "maxDaysNotice")
        }
        if(Utility.shared.step3ValuesInfo["maxDaysNotice"] != nil && (("\(Utility.shared.step3ValuesInfo["maxDaysNotice"]!)") != "available")) {
            if (Utility.shared.step3ValuesInfo["maxDaysNotice"]! as? String) == "unavailable" {
                futureDateLbl = "\((Utility.shared.getLanguage()?.value(forKey:"datesunavailable"))!)"
                
            }else{
                let index = futures_Date_Array_without_String.firstIndex(where: { (item) -> Bool in
                    item == "\(Utility.shared.step3ValuesInfo["maxDaysNotice"]!)"
                })
                futureDateLbl = futureDatesArr[index!]
            }
            Utility.shared.step3ValuesInfo.updateValue("\(Utility.shared.step3ValuesInfo["maxDaysNotice"]!)", forKey: "maxDaysNotice")
        } else {
            futureDateLbl = futureDatesArr.last!
            Utility.shared.step3ValuesInfo.updateValue("available", forKey: "maxDaysNotice")
        }
        
        if !futureDateLbl.isEmpty {
            let index = futureDatesArr.firstIndex(where: { (item) -> Bool in
                item == futureDateLbl
            })
            if index != nil {
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }
    }
    
    func setStaticArray() {
        staticArray.append("\((Utility.shared.getLanguage()?.value(forKey:"flexible"))!)")
        staticArray.append("\((Utility.shared.getLanguage()?.value(forKey:"moderate"))!)")
        staticArray.append("\((Utility.shared.getLanguage()?.value(forKey:"strict"))!)")
        if(Utility.shared.step3ValuesInfo["cancellationPolicy"] != nil) {
            if ((Utility.shared.step3ValuesInfo["cancellationPolicy"] as? Int)! == 1) {
                cancellationLbl = staticArray[0]
                cancel_id = 1
            } else if((Utility.shared.step3ValuesInfo["cancellationPolicy"] as? Int)! == 2) {
                cancellationLbl = staticArray[1]
                cancel_id = 2
            } else if((Utility.shared.step3ValuesInfo["cancellationPolicy"] as? Int)! == 3) {
                cancellationLbl = staticArray[2]
                cancel_id = 3
            }
        } else {
            cancellationLbl = staticArray.first!
            cancel_id = 1
        }
        pickerView.selectRow(cancel_id-1, inComponent: 0, animated: true)
        Utility.shared.step3ValuesInfo.updateValue(cancel_id, forKey: "cancellationPolicy")
        
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
        tableView.register(UINib(nibName: "SingleTextFieldCell", bundle: nil), forCellReuseIdentifier: "singletextfieldcell")
        
    }

    override func addLottieViewAsSubview() {
        self.view.addSubview(self.lottieView)
    }
    
    
    func lottieViewanimation() {
        saveandExitBtn.setTitle("", for:.normal)
        lottieView1 = LottieAnimationView.init(name: "animation")
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:((self.saveandExitBtn.frame.size.width/2)-50), y:0, width:100, height:self.saveandExitBtn.frame.size.height)
        self.saveandExitBtn.addSubview(self.lottieView1)
        self.view.bringSubviewToFront(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor.clear
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscrolling), userInfo: nil, repeats: true)
    }
    @objc func autoscrolling() {
        self.lottieView1.play()
    }
    func offlineviewShow() {
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
    
    @IBAction func RedirectNextPage(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            let guestListing = TripLengthViewController()
            guestListing.modalPresentationStyle = .fullScreen
            self.present(guestListing, animated: false, completion: nil)
        } else {
            self.offlineviewShow()
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if(Utility.shared.step3_Edit) {
                let StepTwoObj = HouseRulesViewController()
                self.view.window?.backgroundColor = UIColor.white
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            self.offlineviewShow()
        }
    }
    
    func goToBecomeHostVC(){
        let becomeHost = BecomeHostVC()
        becomeHost.listID = "\(Utility.shared.createId)"
        becomeHost.showListingStepsAPICall(listID:"\(Utility.shared.createId)")
        becomeHost.modalPresentationStyle = .fullScreen
        self.present(becomeHost, animated:false, completion: nil)
    }
    @IBAction func saveandExit(_ sender: Any) {
        
        if Utility().isConnectedToNetwork(){
            self.lottieViewanimation()
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.selectedRules, forKey: "houseRules")
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.createId, forKey: "id")
            super.updateStep3ListingAPICall{ (success) -> Void in
                if success {
                    saveandExitBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                    
                    self.lottieView1.isHidden = true
                }
            }
        } else {
            self.offlineviewShow()
        }
    }
    
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIView.isHidden = true
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textfieldcell", for: indexPath) as? TextFieldCell
            if indexPath.row == 0 {
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"bookingpreference"))!)"
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT, size:14)
                cell?.queryTitleLbl.textColor = UIColor(named: "searchPlaces_TextColor")
                cell?.txtField.text = futureDateLbl
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: futureDateLbl,
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                cell?.selectionStyle = .none
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputAccessoryView = toolBar
                cell?.txtField.inputView = pickerView
                cell?.txtField.tag = 0
                cell?.txtField.delegate = self
                cell?.txtField.textColor = UIColor(named: "Title_Header")
                cell?.txtField.tintColor = .clear
                cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
                
            } else if indexPath.row == 1 {
                cell?.selectionStyle = .none
                
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"cancellationPolicy"))!)"
                
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT, size:14)
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputAccessoryView = toolBar
                cell?.txtField.inputView = pickerView
                cell?.txtField.tintColor = .clear
                cell?.txtField.delegate = self
                cell?.txtField.textColor = UIColor(named: "Title_Header")
                cell?.txtField.text = cancellationLbl
                cell?.selectionStyle = .none
                cell?.txtField.tag = 1
                cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
            }
            cell?.imgDownArrow.isHidden = false
            cell?.stepnumberLbl.isHidden = true
            cell?.stepnumberLbl.text = ""
            cell?.stepNumberLblTopConstraint.constant = 0
            return cell!
        }
        return UITableViewCell()
    }
    
    @objc func onClickedDownArrow(sender: UIButton){
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! TextFieldCell
        cell.txtField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            if !futureDateLbl.isEmpty {
                let index = futureDatesArr.firstIndex(where: { (item) -> Bool in
                    item == futureDateLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        } else {
            if !cancellationLbl.isEmpty {
                let index = staticArray.firstIndex(where: { (item) -> Bool in
                    item == cancellationLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
            
        }
        pickerView.reloadAllComponents()
    }
    
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (selectedTextfield == 0) {
            return futureDatesArr.count
        } else {
            return staticArray.count
        }
    }
    
    override func pickerView( _ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var titleData = ""
        if (selectedTextfield == 0) {
            titleData = futureDatesArr[row]
        } else {
            titleData = staticArray[row]
        }
        
        let myTitle = NSAttributedString(string: titleData , attributes: [NSAttributedString.Key.font:UIFont(name: APP_FONT, size: 15.0)!,NSAttributedString.Key.foregroundColor:Theme.PRIMARY_COLOR])
        return myTitle
    }
    
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        if (selectedTextfield == 0) {
            futureDateLbl = futureDatesArr[row]
            pickerView.selectRow(row, inComponent: component, animated: true)
            Utility.shared.step3ValuesInfo.updateValue(futures_Date_Array_without_String[row], forKey:"maxDaysNotice")
        } else if selectedTextfield == 1 {
            cancellationLbl = staticArray[row]
            pickerView.selectRow(row, inComponent: component, animated: true)
            Utility.shared.step3ValuesInfo.updateValue(row+1, forKey: "cancellationPolicy")
            
        }
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextfield = textField.tag
        pickerView.reloadAllComponents()
        if(textField.tag == 0) {
            if !futureDateLbl.isEmpty {
                let index = futureDatesArr.firstIndex(where: { (item) -> Bool in
                    item == futureDateLbl
                })
                
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }
        
        if(textField.tag == 1) {
            if !cancellationLbl.isEmpty {
                let index = staticArray.firstIndex(where: { (item) -> Bool in
                    item == cancellationLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        tableView.reloadData()
        view.endEditing(true)
    }
}

extension BookingWindowViewController: stepsUpdateProtocol{
    func selectedPage(step: Int, selectedPageIndex: Int) {
        if step == 3{
            switch selectedPageIndex{
            case 0:
                let StepTwoObj = ReviewGuestViewController()
                self.view.window?.backgroundColor = UIColor.white
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
                break
            case 1:
                let becomeHost = HouseRulesViewController()
                self.view.window?.backgroundColor = UIColor.white
                becomeHost.modalPresentationStyle = .fullScreen
                self.present(becomeHost, animated:false, completion: nil)
                break
            case 2:
                let becomeHost = BookInstantViewController()
                self.view.window?.backgroundColor = UIColor.white
                becomeHost.modalPresentationStyle = .fullScreen
                self.present(becomeHost, animated:false, completion: nil)
                break
            case 3:
                let becomeHost = NoticeArrivalViewController()
                self.view.window?.backgroundColor = UIColor.white
                becomeHost.modalPresentationStyle = .fullScreen
                self.present(becomeHost, animated:false, completion: nil)
                break
            case 4:
                break
            case 5:
                let guestListing = TripLengthViewController()
                guestListing.modalPresentationStyle = .fullScreen
                self.present(guestListing, animated: false, completion: nil)
                break
            case 6:
                let amenities = BasePriceViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 7:
                let amenities = DiscountViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 8:
                let amenities = IncreaseEarningViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 9:
                let amenities = LawAndTaxViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            default:
                break
            }
        }
    }
}
