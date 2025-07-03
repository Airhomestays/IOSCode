

import UIKit
import Lottie

class TripLengthViewController: BaseHostTableviewController {
    
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressVew: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var saveAndExit: UIButton!
    @IBOutlet weak var offlineUIView: UIView!
    
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var futureDateLbl = String()
    var cancellationLbl = String()
    var cancel_id = Int()
    var futureDatesArr = [String]()
    var futures_Date_Array_without_String = [String]()
    var future_array = [String]()
    var staticArray = [String]()
    var inputPickerView = UIView()
    var pickerView = UIPickerView()
    
    var maxStay = ""
    var maxStayList = [[String: Any]]()
    var maxStayLimit = Int()
    var maxStayStart = Int()
    var minStayStart = Int()
    var minStay = ""
    var minStayList = [[String : Any]]()
    var minStayLimit = Int()
    var lottieView1: LottieAnimationView!
    
    var selectedAmenityIdList = [Int]()
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBookingStatus()
        
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
        
        self.titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"discountdesc"))!)"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressVew.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveAndExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
        saveAndExit.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveAndExit.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
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
        progressViewWidth.constant = ((self.view.frame.width/8) * CGFloat((self.stepsTitleView.selectedViewIndex + 1)))
    }
    
    override func setUpUI() {
        offlineUIView.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIView, nextButton: nextBtn)
        tableView.isHidden = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        if(Utility.shared.step3_Edit) {
            self.saveAndExit.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleHeightConstraint.constant = 50
            self.stepTitleTopConstraint.constant = 5
        } else{
            self.saveAndExit.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleHeightConstraint.constant = 0
            self.stepTitleTopConstraint.constant = 0
        }
        
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
    
    override func setdropdown() {
        inputPickerView.frame = CGRect(x: 0, y: FULLHEIGHT-200, width: FULLWIDTH, height: 200)
        pickerView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 200)
        inputPickerView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.tintColor = Theme.PRIMARY_COLOR
        pickerView.backgroundColor = UIColor(named: "colorController")
        pickerView.reloadAllComponents()
    }
    
    override func setDropdownList() {
        let minNights = (Utility.shared.getListSettingsArray.minNight?.listSettings!)!
        let maxNights = (Utility.shared.getListSettingsArray.maxNight?.listSettings!)!
        if((minNights[0]?.endValue!) != nil) {
            minStayLimit = (minNights[0]?.endValue!)!
        }
        
        if((maxNights[0]?.endValue!) != nil) {
            maxStayLimit = (maxNights[0]?.endValue!)!
        }
        
        minStayStart = minNights[0]?.startValue ?? 0
        maxStayStart = maxNights[0]?.startValue ?? 0
        minStay = "\(Utility.shared.step3ValuesInfo["minNight"] != nil ? Utility.shared.step3ValuesInfo["minNight"]! : minStayStart)"
        maxStay = "\(Utility.shared.step3ValuesInfo["maxNight"] != nil ? Utility.shared.step3ValuesInfo["maxNight"]! : maxStayStart)"
        
        Utility.shared.step3ValuesInfo.updateValue(Int(minStay)!, forKey: "minNight")
        Utility.shared.step3ValuesInfo.updateValue(Int(maxStay)!, forKey: "maxNight")
        tableView.reloadData()
    }
    
    override func registerCells() {
        tableView.register(UINib(nibName: "RoomsCell", bundle: nil), forCellReuseIdentifier: "RoomsCell")
        tableView.register(UINib(nibName: "DiscountTextFieldCell", bundle: nil), forCellReuseIdentifier: "discounttextfieldcell")
        tableView.register(UINib(nibName: "SingleTextFieldCell", bundle: nil), forCellReuseIdentifier: "singletextfieldcell")
    }
    
    override func addLottieViewAsSubview() {
        self.view.addSubview(self.lottieView)
    }
    
    @IBAction func RedirectNextPage(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if(Int(minStay) != nil && Int(maxStay) != nil) {
                let minNight : Int = Int(minStay)!
                let maxNight : Int = Int(maxStay)!
                if (maxNight != 0 && minNight > maxNight) {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"minimumnights"))!)")
                    return
                }
                let amenities = IncreaseEarningViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
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
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if(Utility.shared.step3_Edit) {
                let StepTwoObj = HouseRulesViewController()
                self.view.window?.backgroundColor = UIColor.white
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
            }
            else{
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
    
    func lottieViewanimation() {
        saveAndExit.setTitle("", for:.normal)
        lottieView1 = LottieAnimationView.init(name: "animation")
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:((self.saveAndExit.frame.size.width/2)-50), y:0, width:100, height:self.saveAndExit.frame.size.height)
        self.saveAndExit.addSubview(self.lottieView1)
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
    @IBAction func saveandexitAction(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.lottieViewanimation()
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.selectedRules, forKey: "houseRules")
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.createId, forKey: "id")
            super.updateStep3ListingAPICall{ (success) -> Void in
                if success {
                    saveAndExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                    
                    self.lottieView1.isHidden = true
                }
            }
        } else {
            self.offlineviewShow()
        }
    }
    
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (selectedTextfield == 0) {
            return futureDatesArr.count
        }else {
            return staticArray.count
        }
    }
    
    override func pickerView( _ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var titleData = ""
        if (selectedTextfield == 0) {
            titleData = futureDatesArr[row]
        }else {
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
        }else if selectedTextfield == 1 {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 1) {
            return "\((Utility.shared.getLanguage()?.value(forKey:"triplength"))!)"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 1) {
            return 50
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x:24, y: 10, width: FULLWIDTH-40, height:40))
        headerLabel.font =  UIFont(name: APP_FONT_MEDIUM, size:16)
        headerLabel.addCharacterSpacing()
        headerLabel.textColor =  UIColor(named: "Title_Header")
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        headerLabel.numberOfLines = 0
        let headerView = UIView(frame: CGRect(x:24, y: 0, width: tableView.bounds.size.width - 20, height: 25))
        headerView.backgroundColor = UIColor.clear
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 1) {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomsCell", for: indexPath) as? RoomsCell
            cell?.dashView.isHidden = false
            cell?.dashView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
            if indexPath.row == 0 {
                cell?.roomsTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"ministay"))!)"
                cell?.countshowLabel.text = minStay
                if minStay == String(minStayStart){
                    cell?.minusBtn.isEnabled = false
                    cell?.minusBtn.alpha = 0.5
                    cell?.minusBtn.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5)
                    cell?.minusBtn.isUserInteractionEnabled = false
                } else {
                    cell?.minusBtn.isEnabled = true
                    cell?.minusBtn.alpha = 1
                    cell?.minusBtn.borderColor = Theme.PRIMARY_COLOR
                    cell?.minusBtn.isUserInteractionEnabled = true
                }
                cell?.countValue = 1
                cell?.plusBtn.tag = indexPath.row
                cell?.minusBtn.tag = indexPath.row
                cell?.tag = indexPath.row + 100
            }else {
                cell?.roomsTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"maxistay"))!)"
                cell?.countshowLabel.text = maxStay
                
                if maxStay == String(maxStayStart) {
                    cell?.minusBtn.isEnabled = false
                    cell?.minusBtn.alpha = 0.5
                    cell?.minusBtn.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5)
                    cell?.minusBtn.isUserInteractionEnabled = false
                } else {
                    cell?.minusBtn.isEnabled = true
                    cell?.minusBtn.alpha = 1
                    cell?.minusBtn.borderColor = Theme.PRIMARY_COLOR
                    cell?.minusBtn.isUserInteractionEnabled = true
                }
                cell?.countValue = 1
                cell?.plusBtn.tag = indexPath.row
                cell?.minusBtn.tag = indexPath.row
                cell?.tag = indexPath.row + 100
            }
            cell?.plusBtn.addTarget(self, action: #selector(plusButtonTapped(_:)), for: .touchUpInside)
            cell?.minusBtn.addTarget(self, action: #selector(self.minusBtnTapped(sender:)), for: .touchUpInside)
            cell?.plusBtn.layer.cornerRadius = (cell?.plusBtn.frame.size.width)!/2
            cell?.plusBtn.layer.borderWidth = 1.0
            cell?.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell?.minusBtn.layer.cornerRadius = (cell?.minusBtn.frame.size.width)!/2
            cell?.minusBtn.layer.borderWidth = 1.0
            cell?.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell?.selectionStyle = .none
            if Utility.shared.isRTLLanguage(){
                cell?.roomsTitleLabel.textAlignment = .right
            } else {
                cell?.roomsTitleLabel.textAlignment = .left
            }
            cell?.roomsTitleLabel.textColor  =  UIColor(named: "Title_Header")
            cell?.dashView.isHidden = true
            return cell!
        }
        
        if(indexPath.section == 0) {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "discounttextfieldcell", for: indexPath) as? DiscountTextFieldCell
            if indexPath.row == 0 {
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"bookingpreference"))!)"
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                cell?.txtField.text = futureDateLbl
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: futureDateLbl,
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                cell?.selectionStyle = .none
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
                cell?.txtField.inputAccessoryView = toolBar
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputView = pickerView
                let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
                cell?.txtField.leftView = paddingView
                cell?.txtField.leftViewMode = .always
                cell?.txtField.tag = 0
                cell?.txtField.delegate = self
                cell?.txtField.textColor = UIColor(named: "Title_Header")
                cell?.txtField.tintColor = .clear
                cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
                
            }
            
            cell?.imgDownArrow.isHidden = false
            cell?.stepnumberLbl.isHidden = true
            cell?.stepnumberLbl.text = ""
            cell?.stepNumberLblTopConstraint.constant = 0
            cell?.linebottomconstant.constant = 0
            cell?.linetopconstant.constant = 0
            return cell!
        }
        return UITableViewCell()
    }
    
    @objc func onClickedDownArrow(sender: UIButton){
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! DiscountTextFieldCell
        cell.txtField.becomeFirstResponder()
    }
    
    @objc func plusButtonTapped(_ sender: UIButton) {
        var limit = Int()
        if sender.tag == 0 {
            limit = minStayLimit
        } else {
            limit = maxStayLimit
        }
        if let cell = view.viewWithTag(sender.tag + 100) as? RoomsCell {
            if Int(cell.countshowLabel.text!)! >= limit && (sender.tag == 0 || sender.tag == 1) {
                cell.plusBtn.isEnabled = false
                cell.plusBtn.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5)
                cell.plusBtn.isUserInteractionEnabled = false
            } else {
                cell.countshowLabel.text = "\(Int(cell.countshowLabel.text!)! + 1)"
                if sender.tag == 0 {
                    Utility.shared.step3ValuesInfo.updateValue(Int(cell.countshowLabel.text!)!, forKey: "minNight")
                    minStay = "\(Utility.shared.step3ValuesInfo["minNight"]!)"
                } else if sender.tag == 1{
                    Utility.shared.step3ValuesInfo.updateValue(Int(cell.countshowLabel.text!)!, forKey: "maxNight")
                    maxStay = "\(Utility.shared.step3ValuesInfo["maxNight"]!)"
                }
                cell.plusBtn.isEnabled = true
                cell.plusBtn.borderColor = Theme.PRIMARY_COLOR
                cell.plusBtn.isUserInteractionEnabled = true
            }
            cell.minusBtn.isEnabled = true
            cell.minusBtn.alpha = 1
            cell.minusBtn.borderColor = Theme.PRIMARY_COLOR
            cell.minusBtn.isUserInteractionEnabled = true
        }
    }
    
    @objc func minusBtnTapped(sender : UIButton) {
        var limit = Int()
        if sender.tag == 0 {
            limit = minStayStart
        } else {
            limit = maxStayStart
        }
        
        if let cell = view.viewWithTag(sender.tag + 100) as? RoomsCell {
            cell.countshowLabel.text = "\(Int(cell.countshowLabel.text!)! - 1)"
            if sender.tag == 0 {
                Utility.shared.step3ValuesInfo.updateValue(Int(cell.countshowLabel.text!)!, forKey: "minNight")
                minStay = "\(Utility.shared.step3ValuesInfo["minNight"]!)"
            } else if sender.tag == 1{
                Utility.shared.step3ValuesInfo.updateValue(Int(cell.countshowLabel.text!)!, forKey: "maxNight")
                maxStay = "\(Utility.shared.step3ValuesInfo["maxNight"]!)"
            }
            if Int(cell.countshowLabel.text!)! <= limit && (sender.tag == 0) {
                cell.minusBtn.isEnabled = false
                cell.minusBtn.alpha = 0.5
                cell.minusBtn.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5)
                cell.minusBtn.isUserInteractionEnabled = false
            } else if(sender.tag == 1 && Int(cell.countshowLabel.text!)! <= limit) {
                cell.minusBtn.isEnabled = false
                cell.minusBtn.alpha = 0.5
                cell.minusBtn.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5)
                cell.minusBtn.isUserInteractionEnabled = false
            } else {
                cell.minusBtn.isEnabled = true
                cell.minusBtn.alpha = 1
                cell.minusBtn.borderColor = Theme.PRIMARY_COLOR
                cell.minusBtn.isUserInteractionEnabled = true
            }
            cell.plusBtn.isEnabled = true
            
            cell.plusBtn.borderColor = Theme.PRIMARY_COLOR
            cell.plusBtn.isUserInteractionEnabled = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1) {
            if(indexPath.row == 0) {
                if !futureDateLbl.isEmpty {
                    let index = futureDatesArr.firstIndex(where: { (item) -> Bool in
                        item == futureDateLbl
                    })
                    pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
                }
            }
        }
        pickerView.reloadAllComponents()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0) {
            return UITableView.automaticDimension
        }
        return 65
    }
}


extension TripLengthViewController: stepsUpdateProtocol{
    func selectedPage(step: Int, selectedPageIndex: Int) {
        if step == 3{
            switch selectedPageIndex{
            case 6:
                let StepTwoObj = ReviewGuestViewController()
                self.view.window?.backgroundColor = UIColor.white
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
                break
            case 0:
                let becomeHost = HouseRulesViewController()
                self.view.window?.backgroundColor = UIColor.white
                becomeHost.modalPresentationStyle = .fullScreen
                self.present(becomeHost, animated:false, completion: nil)
                break
            case 1:
                let becomeHost = NoticeArrivalViewController()
                self.view.window?.backgroundColor = UIColor.white
                becomeHost.modalPresentationStyle = .fullScreen
                self.present(becomeHost, animated:false, completion: nil)
                break
            case 4:
                
                break
            case 2:
                
                let amenities = BasePriceViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 3:
                let amenities = DiscountViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
                
            case 5:
                let amenities = IncreaseEarningViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 7:
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
