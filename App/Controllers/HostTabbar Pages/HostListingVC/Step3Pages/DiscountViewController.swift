

import UIKit
import Lottie
import IQKeyboardManagerSwift
import SwiftMessages

class DiscountViewController: BaseHostTableviewController {
    
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var saveandExit: UIButton!
    @IBOutlet weak var offlineUIView: UIView!
    @IBOutlet weak var retryBtn: UIButton!
    
    var currencyDataArray = [GetCurrenciesListQuery.Data.GetCurrency.Result]()
    
    @IBOutlet weak var errorLabel: UILabel!
    var weeklydiscountvalue = String()
    var monthlydiscountvalue = String()
    var lottieView1: LottieAnimationView!
    let characterset = NSCharacterSet(charactersIn: "0123456789.")
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
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
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "discounts") ?? "Discounts")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveandExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
        saveandExit.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveandExit.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        self.stepsTitleView.whichStep = 3
        self.stepsTitleView.selectedViewIndex = 3
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
    }
    
    override func setDropdownList() {
        if(Utility.shared.step3ValuesInfo["weeklyDiscount"] != nil) {
            weeklydiscountvalue = "\(Utility.shared.step3ValuesInfo["weeklyDiscount"]!)"
        }
        if(Utility.shared.step3ValuesInfo["monthlyDiscount"] != nil) {
            monthlydiscountvalue = "\(Utility.shared.step3ValuesInfo["monthlyDiscount"]!)"
        }
        self.lottieView.isHidden = true
        tableView.reloadData()
    }
    
    override func registerCells() {
        tableView.register(UINib(nibName: "DiscountTextFieldCell", bundle: nil), forCellReuseIdentifier: "discounttextfieldcell")
        tableView.register(UINib(nibName: "TipCell", bundle: nil), forCellReuseIdentifier: "TipCell")
    }

    override func addLottieViewAsSubview() {
        self.view.addSubview(self.lottieView)
    }

    @IBAction func RedirectNextPage(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            if !weeklydiscountvalue.isEmpty  || (weeklydiscountvalue.rangeOfCharacter(from: characterset.inverted) != nil){
                if(weeklydiscountvalue == ".") {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invaliddiscount"))!)")
                    return
                }
                if Double(weeklydiscountvalue)! >= 100 {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invaliddiscount"))!)")
                    return
                }
            }
            if !monthlydiscountvalue.isEmpty || (weeklydiscountvalue.rangeOfCharacter(from: characterset.inverted) != nil) {
                if(monthlydiscountvalue == ".") {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invaliddiscount"))!)")
                    return
                }
                if Double(monthlydiscountvalue)! >= 100 {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invaliddiscount"))!)")
                    return
                }
            }
            let amenities = TripLengthViewController()
            self.view.window?.backgroundColor = UIColor.white
            amenities.modalPresentationStyle = .fullScreen
            self.present(amenities, animated: false, completion: nil)
        } else {
            self.offlineviewShow()
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            if !weeklydiscountvalue.isEmpty || (weeklydiscountvalue.rangeOfCharacter(from: characterset.inverted) != nil) {
                if(weeklydiscountvalue == ".") {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invaliddiscount"))!)")
                    return
                }
                if Double(weeklydiscountvalue)! > 100 {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invaliddiscount"))!)")
                    return
                }
            }
            if !monthlydiscountvalue.isEmpty || (monthlydiscountvalue.rangeOfCharacter(from: characterset.inverted) != nil) {
                if(monthlydiscountvalue == ".") {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invaliddiscount"))!)")
                    return
                }
                if Double(monthlydiscountvalue)! > 100 {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invaliddiscount"))!)")
                    return
                }
            }
            
            if(Utility.shared.step3_Edit) {
                let StepTwoObj = HouseRulesViewController()
                self.view.window?.backgroundColor = UIColor.white
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
            } else{
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
    @IBAction func saveandexitAction(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            self.lottieViewanimation()
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.selectedRules, forKey: "houseRules")
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.createId, forKey: "id")
            super.updateStep3ListingAPICall{ (success) -> Void in
                if success {
                    saveandExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                    
                    self.lottieView1.isHidden = true
                }
            }
        } else{
            self.offlineviewShow()
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
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIView.isHidden = true
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 2 {
            let cells = tableView
                .dequeueReusableCell(withIdentifier: "TipCell", for: indexPath) as? TipCell
            cells?.tipText.text = " \((Utility.shared.getLanguage()?.value(forKey:"dislongerdays"))!)"
            cells?.selectionStyle = .none
            return cells!
        } else {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "discounttextfieldcell", for: indexPath) as? DiscountTextFieldCell
            if indexPath.row == 0 {
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"weeklydiscount"))!)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "% \((Utility.shared.getLanguage()?.value(forKey:"off"))!)",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                cell?.txtField.tag = indexPath.row
                cell?.lblPercentage.isHidden = false
                if Utility.shared.isRTLLanguage(){
                    cell?.lblPercentage.halfroundedCorners(corners:[ .topLeft, .bottomLeft], radius: 5)
                } else {
                    cell?.lblPercentage.halfroundedCorners(corners:[ .topRight, .bottomRight], radius: 5)
                }
                
                cell?.txtField.addTarget(self, action: #selector(weeklydiscount(field:)), for: .editingDidEnd)
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                cell?.txtField.font = UIFont(name: APP_FONT, size:14)
                cell?.txtField.text = weeklydiscountvalue
                if(Utility.shared.step3ValuesInfo["weeklyDiscount"] != nil) {
                    if("\(Utility.shared.step3ValuesInfo["weeklyDiscount"]!)" != "0") {
                        cell?.txtField.text = "\(Utility.shared.step3ValuesInfo["weeklyDiscount"]!)"
                    } else {
                        cell?.txtField.text  = ""
                    }
                }
                
                cell?.txtField.keyboardType = .numberPad
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
                cell?.txtField.inputAccessoryView = toolBar
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                
            } else if indexPath.row == 1 {
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"monthlydisc"))!)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "% \((Utility.shared.getLanguage()?.value(forKey:"off"))!)",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                cell?.txtField.tag = indexPath.row
                cell?.txtField.addTarget(self, action: #selector(Monthlydiscount(field:)), for: .editingDidEnd)
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                cell?.txtField.font = UIFont(name: APP_FONT, size:14)
                cell?.txtField.keyboardType = .numberPad
                cell?.txtField.text = monthlydiscountvalue
                cell?.lblPercentage.isHidden = false
                if Utility.shared.isRTLLanguage() {
                    cell?.lblPercentage.halfroundedCorners(corners:[ .topLeft, .bottomLeft], radius: 5)
                } else {
                    cell?.lblPercentage.halfroundedCorners(corners:[ .topRight, .bottomRight], radius: 5)
                }
                cell?.linetopconstant.constant = 0
                cell?.linebottomconstant.constant = 0
                if(Utility.shared.step3ValuesInfo["monthlyDiscount"] != nil) {
                    if("\(Utility.shared.step3ValuesInfo["monthlyDiscount"]!)" != "0") {
                        cell?.txtField.text = "\(Utility.shared.step3ValuesInfo["monthlyDiscount"]!)"
                    } else {
                        cell?.txtField.text  = ""
                    }
                }
            }
            
            let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
            cell?.txtField.leftView = paddingView
            cell?.txtField.leftViewMode = .always
            cell?.txtField.textColor = UIColor(named: "Title_Header")
            cell?.stepnumberLbl.isHidden = true
            cell?.stepnumberLbl.text = ""
            cell?.stepOneBottom.constant = 0
            cell?.stepOneHeight.constant = 0
            cell?.stepNumberLblTopConstraint.constant = 0
            cell?.selectionStyle = .none
            cell?.txtField.delegate = self
            let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
            cell?.txtField.inputAccessoryView = toolBar
            toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
            return cell!
        }
    }
    
    @objc func weeklydiscount(field: UITextField) {
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            weeklydiscountvalue = field.text!
        }
    }
    
    @objc func Monthlydiscount(field: UITextField){
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            monthlydiscountvalue = field.text!
        }
    }
    
    @objc func dismisskeyborad() {
        view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if updatedText.isEmpty || updatedText == "0" || (1...99 ~= Int(updatedText) ?? 0) {
            let newLength = currentText.count + string.count - range.length
            if newLength > 12 {
                return false
            }
            
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            
            if !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }
            if (textField.text?.contains("."))! && (string == ".") {
                return false
            }
            
            return true
        } else {
            return false
        }
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag == 0 {
            weeklydiscountvalue = textField.text!
            Utility.shared.step3ValuesInfo.updateValue(weeklydiscountvalue, forKey: "weeklyDiscount")
        }
        if textField.tag == 1 {
            monthlydiscountvalue = textField.text!
            Utility.shared.step3ValuesInfo.updateValue(monthlydiscountvalue, forKey: "monthlyDiscount")
        }
    }
}




extension DiscountViewController: stepsUpdateProtocol{
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
