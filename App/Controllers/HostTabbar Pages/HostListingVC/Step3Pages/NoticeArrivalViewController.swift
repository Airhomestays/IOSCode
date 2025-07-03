
import UIKit
import Lottie
import SwiftMessages

class NoticeArrivalViewController: BaseHostTableviewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var offLineView: UIView!
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    @IBOutlet weak var retrBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var saveandExit: UIButton!
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    
    var lottieView1: LottieAnimationView!
    var bookingNoticeTimeLbl = String()
    var bookingNoticeIdArray = [String]()
    var fromTime = String()
    var toTime = String()
    var bookingNoticeTimeArr = [String]()
    var inputPickerView = UIView()
    var pickerView = UIPickerView()
    var cancellationLbl = String()
    var staticArray = [String]()
    var cancel_id = Int()
    var fromTimeArray = [String]()
    var toTimeArray = [String]()
    var fromoptionsArray = [String]()
    var tooptionsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offLineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.setStaticArray()
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
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "howmuchnotice") ?? "Advance notice and cancellation policy")"
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
        retrBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveandExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
        saveandExit.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retrBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveandExit.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retrBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
        self.stepsTitleView.whichStep = 3
        self.stepsTitleView.selectedViewIndex = 1
        self.stepsTitleView.delegateSteps = self
    }
    
    func setStaticArray() {
        staticArray.append("\((Utility.shared.getLanguage()?.value(forKey:"flexible"))!)")
        staticArray.append("\((Utility.shared.getLanguage()?.value(forKey:"moderate"))!)")
        staticArray.append("\((Utility.shared.getLanguage()?.value(forKey:"strict"))!)")
        if(Utility.shared.step3ValuesInfo["cancellationPolicy"] != nil) {
            if((Utility.shared.step3ValuesInfo["cancellationPolicy"] as? Int)! == 1) {
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
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
        progressViewWidth.constant = ((self.view.frame.width/8) * CGFloat((self.stepsTitleView.selectedViewIndex + 1)))
    }
    
    override func setUpUI() {
        offLineView.isHidden = true
        callListingSettingsAPI(oflineView: offLineView, nextButton: nextBtn)
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        self.tableView.isHidden = false
        if(Utility.shared.step3_Edit) {
            self.saveandExit.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleHeightConstraint.constant = 50
            self.stepTitleTopConstraint.constant = 5
        } else{
            self.saveandExit.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleHeightConstraint.constant = 0
            self.stepTitleTopConstraint.constant = 0
        }
        fromTimeArray = ["Flexible","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25"]
        toTimeArray = ["Flexible","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26"]
        fromoptionsArray = ["Flexible","8AM","9AM","10AM","11AM","12PM(noon)","1PM","2PM","3PM","4PM","5PM","6PM","7PM","8PM","9PM","10PM","11PM","12AM (mid night)","1AM (next day)"]
        tooptionsArray = ["Flexible","9AM","10AM","11AM","12PM(noon)","1PM","2PM","3PM","4PM","5PM","6PM","7PM","8PM","9PM","10PM","11PM","12AM (mid night)","1AM (next day)","2PM (next day)"]
    }
    
    override func setDropdownList() {
        let listSettings = (Utility.shared.getListSettingsArray.bookingNoticeTime?.listSettings!)!
        for item in listSettings {
            bookingNoticeTimeArr.append((item?.itemName)!)
            bookingNoticeIdArray.append("\((item?.id)!)")
        }
        
        if(Utility.shared.step3ValuesInfo["bookingNoticeTime"] != nil) {
            for i in listSettings {
                if("\((i?.id!)!)" == (Utility.shared.step3ValuesInfo["bookingNoticeTime"] as? String)!) {
                    bookingNoticeTimeLbl = (i?.itemName)!
                }
            }
        } else {
            bookingNoticeTimeLbl = bookingNoticeTimeArr.first!
        }
        
        if !bookingNoticeTimeLbl.isEmpty {
            let index = bookingNoticeTimeArr.firstIndex(where: { (item) -> Bool in
                item == bookingNoticeTimeLbl
            })
            pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
        }
        
        Utility.shared.step3ValuesInfo.updateValue(bookingNoticeIdArray[0], forKey: "bookingNoticeTime")
        
        if(Utility.shared.step3ValuesInfo["checkInStart"] != nil) {
            let index = fromTimeArray.firstIndex(where: { (item) -> Bool in
                item == "\(Utility.shared.step3ValuesInfo["checkInStart"]!)"
            })
            fromTime = fromoptionsArray[index != nil ? index! : 0]
        } else {
            fromTime = ""
            Utility.shared.step3ValuesInfo.updateValue("Flexible", forKey: "checkInStart")
        }
        if !fromTime.isEmpty {
            let index = fromoptionsArray.firstIndex(where: { (item) -> Bool in
                item == Utility.shared.step3ValuesInfo["checkInStart"] as! String
            })
            pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
        }
        tableView.reloadData()
        if(Utility.shared.step3ValuesInfo["checkInEnd"] != nil ) {
            let index = toTimeArray.firstIndex(where: { (item) -> Bool in
                item == "\(Utility.shared.step3ValuesInfo["checkInEnd"]!)"
            })
            toTime = tooptionsArray[index != nil ? index! : 0]
        } else {
            toTime = ""
            Utility.shared.step3ValuesInfo.updateValue("Flexible", forKey: "checkInEnd")
        }
        if !toTime.isEmpty {
            let index = tooptionsArray.firstIndex(where: { (item) -> Bool in
                item == toTime
            })
            pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
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
        tableView.register(UINib(nibName: "DiscountTextFieldCell", bundle: nil), forCellReuseIdentifier: "discounttextfieldcell")
        tableView.register(UINib(nibName: "TipCell", bundle: nil), forCellReuseIdentifier: "TipCell")
    }
    
    override func addLottieViewAsSubview() {
        self.view.addSubview(self.lottieView)
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offLineView.isHidden = true
        }
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
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscrolling), userInfo: nil, repeats: true)
    }
    @objc func autoscrolling() {
        self.lottieView1.play()
    }
    func offlineviewShow() {
        self.offLineView.isHidden = false
        let shadowSize2 : CGFloat = 3.0
        let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                    y: -shadowSize2 / 2,
                                                    width: self.offLineView.frame.size.width + shadowSize2,
                                                    height: self.offLineView.frame.size.height + shadowSize2))
        
        self.offLineView.layer.masksToBounds = false
        self.offLineView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.offLineView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.offLineView.layer.shadowOpacity = 0.3
        self.offLineView.layer.shadowPath = shadowPath2.cgPath
        if IS_IPHONE_X || IS_IPHONE_XR{
            offLineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
        }else{
            offLineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
        }
    }
    
    
    @IBAction func RedirectNextPage(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            if(toTime != "Flexible" && fromTime != "Flexible") && !(fromTime == "12PM" && toTime == "12AM") && !(fromTime == "12PM" && toTime == "1AM") && !(fromTime == "1PM" && toTime == "1AM") && !(fromTime == "12PM" && toTime == "2AM") && !(fromTime == "2PM" && toTime == "2AM") && (fromTime == "" || toTime == ""){
                self.view.makeToast( "Please select From and To Time");
            }
            if(fromTime == "" || toTime == ""){
                self.view.makeToast( "Please select From and To Time");
                return
            }
            
            if(toTime != "Flexible" && fromTime != "Flexible") && !(fromTime == "12PM" && toTime == "12AM") && !(fromTime == "12PM" && toTime == "1AM") && !(fromTime == "1PM" && toTime == "1AM") && !(fromTime == "12PM" && toTime == "2AM") && !(fromTime == "2PM" && toTime == "2AM") && (fromTime != nil && toTime != nil){
                let index = tooptionsArray.firstIndex(where: { (item) -> Bool in
                    item == toTime
                })
                let index1 = fromoptionsArray.firstIndex(where: { (item) -> Bool in
                    item == fromTime
                })
                if(index1 != nil && index != nil) {
                    let from:Int = Int(fromTimeArray[index1!])!
                    let to:Int = Int(toTimeArray[index!])!
                    
                    if(from >= to) {
                        self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"fromtimealert"))!)")
                    } else {
                        let guestListing = BasePriceViewController()
                        self.view.window?.backgroundColor = UIColor.white
                        guestListing.modalPresentationStyle = .fullScreen
                        self.present(guestListing, animated: false, completion: nil)
                    }
                }
            } else {
                let guestListing = BasePriceViewController()
                self.view.window?.backgroundColor = UIColor.white
                guestListing.modalPresentationStyle = .fullScreen
                self.present(guestListing, animated: false, completion: nil)
            }
        } else {
            self.offlineviewShow()
        }
    }
    
    @objc override func dismissgenderPicker(text:Int) {
        if selectedTextfield == 1 {
            if(fromTime == "") {
                fromTime = "Flexible"
            }
        }
        if selectedTextfield == 2 {
            if(toTime == "") {
                toTime = "Flexible"
            }
        }
        view.endEditing(true)
        
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
    
    @IBAction func saveandExitAction(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            self.lottieViewanimation()
            if(toTime != "Flexible" && fromTime != "Flexible") && !(fromTime == "12PM" && toTime == "12AM") && !(fromTime == "12PM" && toTime == "1AM") && !(fromTime == "1PM" && toTime == "1AM") && !(fromTime == "12PM" && toTime == "2AM") && !(fromTime == "2PM" && toTime == "2AM") && (fromTime != nil && toTime != nil) {
                let index = tooptionsArray.firstIndex(where: { (item) -> Bool in
                    item == toTime
                })
                let index1 = fromoptionsArray.firstIndex(where: { (item) -> Bool in
                    item == fromTime
                })
                let from:Int = Int(fromTimeArray[index1 != nil ? index! : 0])!
                let to:Int = Int(toTimeArray[index != nil ? index! : 0])!
                
                if(from >= to) {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"fromtimealert"))!)")
                } else {
                    self.lottieViewanimation()
                    super.updateStep3ListingAPICall{ (success) -> Void in
                        if success {
                            saveandExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                            
                            self.lottieView1.isHidden = true
                        }
                    }
                }
            } else {
                self.lottieViewanimation()
                super.updateStep3ListingAPICall{ (success) -> Void in
                    if success {
                        saveandExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                        
                        self.lottieView1.isHidden = true
                    }
                }
            }
        }
        else
        {
            self.offlineviewShow()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
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
        if section == 1{
            return 4
        }else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            if(indexPath.row == 3) {
                
                let cells = tableView
                    .dequeueReusableCell(withIdentifier: "TipCell", for: indexPath) as? TipCell
                cells?.selectionStyle = .none
                if(cancellationLbl == "Flexible") {
                    cells?.tipText.text = "\(Utility.shared.getLanguage()?.value(forKey: "FlexibleDescription")as! String)"
                } else if(cancellationLbl == "Moderate") {
                    cells?.tipText.text = "\(Utility.shared.getLanguage()?.value(forKey: "ModerateDescription1")as! String)"
                } else {
                    cells?.tipText.text = "\(Utility.shared.getLanguage()?.value(forKey: "StrictDescription1")as! String)"
                }
                
                return cells!
                
            } else if indexPath.row == 0 {
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: "discounttextfieldcell", for: indexPath) as? DiscountTextFieldCell
                
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"from"))!)"
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"whencanguest"))!)"
                cell?.stepnumberLbl.isHidden = true
                cell?.queryTitleLbl.isHidden = false
                cell?.stepNumberLblTopConstraint.constant = 15
                cell?.stepnumberLbl.font =  UIFont(name: APP_FONT_MEDIUM, size:16)
                cell?.queryTitleLbl.font =  UIFont(name: APP_FONT_MEDIUM, size:16)
                cell?.txtField.font =  UIFont(name: APP_FONT_MEDIUM, size:14)
                cell?.stepnumberLbl.textColor = UIColor(named: "Title_Header")
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                cell?.txtField.tintColor = UIColor.clear
                let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
                cell?.txtField.leftView = paddingView
                cell?.txtField.leftViewMode = .always
                if(fromTime == "") {
                    cell?.txtField.text =  "\((Utility.shared.getLanguage()?.value(forKey:"from"))!)"
                } else {
                    cell?.txtField.text = fromTime
                }
                cell?.txtField.tag = 1
                cell?.stepnumberLbl.textColor = UIColor(named: "Title_Header")
                
                cell?.stepOneBottom.constant = 0
                cell?.stepOneHeight.constant = 0
                cell?.linetopconstant.constant = 0
                cell?.linebottomconstant.constant = 0
                
                cell?.txtField.textColor = UIColor(named: "Title_Header")
                cell?.txtField.tintColor = UIColor.clear
                cell?.selectionStyle = .none
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                
                cell?.txtField.inputAccessoryView = toolBar
                cell?.txtField.inputView = pickerView
                cell?.txtField.delegate = self
                cell?.lineLabel.isHidden = true
                cell?.imgDownArrow.isHidden = false
                return cell!
                
            }else if indexPath.row == 1 {
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: "discounttextfieldcell", for: indexPath) as? DiscountTextFieldCell
                
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"to"))!)"
                cell?.stepnumberLbl.text = ""
                cell?.queryTitleLbl.isHidden = true
                cell?.stepnumberLbl.isHidden = true
                cell?.stepNumberLblTopConstraint.constant = 0
                let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
                cell?.txtField.leftView = paddingView
                cell?.txtField.leftViewMode = .always
                if(toTime == "") {
                    cell?.txtField.text = "\((Utility.shared.getLanguage()?.value(forKey:"to"))!)"
                } else {
                    cell?.txtField.text = toTime
                }
                cell?.txtField.tag = 2
                cell?.queryTitleLbl.font =  UIFont(name: APP_FONT, size:14)
                cell?.txtField.font =  UIFont(name: APP_FONT_MEDIUM, size:14)
                cell?.txtField.tintColor = UIColor.clear
                cell?.stepOneBottom.constant = 0
                cell?.stepOneHeight.constant = 0
                cell?.stepNumberLblTopConstraint.constant = 0
                cell?.linetopconstant.constant = 14
                cell?.linebottomconstant.constant = 14
                cell?.txtField.textColor = UIColor(named: "Title_Header")
                cell?.txtField.tintColor = UIColor.clear
                cell?.selectionStyle = .none
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputAccessoryView = toolBar
                cell?.txtField.inputView = pickerView
                cell?.txtField.delegate = self
                cell?.lineLabel.isHidden = true
                cell?.imgDownArrow.isHidden = false
                return cell!
            } else if indexPath.row == 2 {
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: "discounttextfieldcell", for: indexPath) as? DiscountTextFieldCell
                
                cell?.selectionStyle = .none
                
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"cancellationPolicy"))!)"
                
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputAccessoryView = toolBar
                cell?.txtField.inputView = pickerView
                cell?.txtField.tintColor = .clear
                let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
                cell?.txtField.leftView = paddingView
                cell?.txtField.leftViewMode = .always
                cell?.txtField.delegate = self
                cell?.txtField.textColor = UIColor(named: "Title_Header")
                cell?.txtField.text = cancellationLbl
                cell?.selectionStyle = .none
                cell?.txtField.tag = 3
                cell?.queryTitleLbl.isHidden = false
                cell?.stepnumberLbl.isHidden = true
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
                cell?.linetopconstant.constant = 0
                cell?.linebottomconstant.constant = 0
                cell?.stepOneHeight.constant = 0
                cell?.stepOneBottom.constant = 0
                
                cell?.txtField.textColor = UIColor(named: "Title_Header")
                cell?.txtField.tintColor = UIColor.clear
                cell?.selectionStyle = .none
                cell?.lineLabel.isHidden = true
                cell?.imgDownArrow.isHidden = false
                return cell!
            }
        }
        return UITableViewCell()
    }
    
    @objc func onClickedDownArrow(sender: UIButton){
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 1)) as! DiscountTextFieldCell
        cell.txtField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(selectedTextfield == 1) {
            let index = fromoptionsArray.firstIndex(where: { (item) -> Bool in
                item == Utility.shared.step3ValuesInfo["checkInStart"] as! String
            })
            pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
        }
        if(selectedTextfield == 2) {
            if(toTime == "12PM") {
                toTime = "12PM(noon)"
            }
            
            if(toTime == "12AM") {
                toTime = "12AM(mid night)"
            }
            
            if(toTime == "1AM") {
                toTime = "1AM(next day)"
                
            }
            if(toTime == "2AM" ) {
                toTime = "2AM(next day)"
            }
            if(toTime == "" ) {
                toTime = "Flexible"
            }
            let index = tooptionsArray.firstIndex(where: { (item) -> Bool in
                item == toTime
            })
            pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
        }
        
        if(indexPath.row == 4) {
            if !cancellationLbl.isEmpty {
                let index = staticArray.firstIndex(where: { (item) -> Bool in
                    item == cancellationLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }
        listValuePicker.reloadAllComponents()
    }
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (selectedTextfield == 0) {
            return bookingNoticeTimeArr.count
        } else if selectedTextfield == 1 {
            return fromoptionsArray.count
        } else if selectedTextfield == 2 {
            return tooptionsArray.count
        } else if selectedTextfield == 3 {
            return staticArray.count
        }
        return 0
    }
    
    override func pickerView( _ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var titleData = ""
        if (selectedTextfield == 0) {
            titleData = bookingNoticeTimeArr[row]
        }else if selectedTextfield == 1 {
            titleData = fromoptionsArray[row]
        }else if selectedTextfield ==  2 {
            titleData = tooptionsArray[row]
        } else if selectedTextfield == 3 {
            titleData = staticArray[row]
        }
        let myTitle = NSAttributedString(string: titleData , attributes: [NSAttributedString.Key.font:UIFont(name: APP_FONT, size: 15.0)!,NSAttributedString.Key.foregroundColor:Theme.PRIMARY_COLOR])
        return myTitle
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 3) {
            return 40
        }
        return UITableView.automaticDimension
    }
    
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        if (selectedTextfield == 0) {
            bookingNoticeTimeLbl = bookingNoticeTimeArr[row]
            pickerView.selectRow(row, inComponent: component, animated: true)
            Utility.shared.step3ValuesInfo.updateValue(bookingNoticeIdArray[row], forKey: "bookingNoticeTime")
        }else if selectedTextfield == 1 {
            fromTime = fromoptionsArray[row]
            pickerView.selectRow(row, inComponent: component, animated: true)
            
            if(fromTime == "Flexible") {
                Utility.shared.step3ValuesInfo.updateValue("Flexible", forKey: "checkInStart")
            } else {
                let index = fromoptionsArray.firstIndex(where: { (item) -> Bool in
                    item == fromTime
                })
                Utility.shared.step3ValuesInfo.updateValue(fromTimeArray[index != nil ? index! : 0], forKey: "checkInStart")
            }
            
        } else if selectedTextfield == 2 {
            toTime = tooptionsArray[row]
            
            if(toTime == "Flexible") {
                Utility.shared.step3ValuesInfo.updateValue("Flexible", forKey: "checkInEnd")
            } else{
                
                let index = tooptionsArray.firstIndex(where: { (item) -> Bool in
                    item == toTime
                })
                Utility.shared.step3ValuesInfo.updateValue(toTimeArray[index != nil ? index! : 0], forKey: "checkInEnd")
            }
        } else if selectedTextfield == 3 {
            cancellationLbl = staticArray[row]
            pickerView.selectRow(row, inComponent: component, animated: true)
            Utility.shared.step3ValuesInfo.updateValue(row+1, forKey: "cancellationPolicy")
        }
    }
    
    func convert12HrTo24Hr(hour:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        let date = dateFormatter.date(from: hour)
        dateFormatter.dateFormat = "HH"
        let Date24 = dateFormatter.string(from: date!)
        return Date24
    }
    
    func convert24hrTo12hr(hour:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let date = dateFormatter.date(from: hour)
        dateFormatter.dateFormat = "ha"
        let Date12 = dateFormatter.string(from: date!)
        return Date12
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextfield = textField.tag
        pickerView.reloadAllComponents()
        if (selectedTextfield == 0) {
            if !bookingNoticeTimeLbl.isEmpty {
                let index = bookingNoticeTimeArr.firstIndex(where: { (item) -> Bool in
                    item == bookingNoticeTimeLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        } else if selectedTextfield == 1 {
            if !fromTime.isEmpty {
                let index = fromoptionsArray.firstIndex(where: { (item) -> Bool in
                    item == fromTime
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            } else {
                pickerView.selectRow(0, inComponent: 0, animated: true)
            }
        } else if selectedTextfield == 2 {
            if !toTime.isEmpty {
                let index = tooptionsArray.firstIndex(where: { (item) -> Bool in
                    item == toTime
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            } else {
                pickerView.selectRow(0, inComponent: 0, animated: true)
            }
        } else if(textField.tag == 3) {
            if !cancellationLbl.isEmpty {
                let index = staticArray.firstIndex(where: { (item) -> Bool in
                    item == cancellationLbl
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.tag > 1) {
            tableView.reloadData()
            view.endEditing(true)
        } else {
            tableView.reloadData()
            view.endEditing(true)
        }
    }
    
}

extension NoticeArrivalViewController: stepsUpdateProtocol{
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
                break
            case 4:
                let guestListing = TripLengthViewController()
                guestListing.modalPresentationStyle = .fullScreen
                self.present(guestListing, animated: false, completion: nil)
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




