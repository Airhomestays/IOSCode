

import UIKit
import Lottie
import SwiftMessages
import Apollo

class BasePriceViewController: BaseHostTableviewController {
    
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
    @IBOutlet weak var errorLabel:UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    var currencyDataArray = [GetCurrenciesListQuery.Data.GetCurrency.Result]()
    
    var basePriceValue = ""
    var cleaningPriceValue = ""
    var infantCount = ""
    var infantPrice = ""
    var petCount = ""
    var petPrice = ""
    var visitorCount = ""
    var visitorPrice = ""
    var guestesOnBasePrice = ""
    var extraGuestsPerPerson = ""
    var hasVisitor = false
    var hasPets = true
    var hasInfant = true
    var taxesPriceValue = ""
    let alphabet: Set<Character> = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    var inputPickerView = UIPickerView()
    var inputUIView = UIView()
    var lottieView1: LottieAnimationView!
    var currencyArr = [String]()
    let characterset = NSCharacterSet(charactersIn: "0123456789.")
    let cleaning_character = NSCharacterSet(charactersIn: "0123456789")
    
    var isSelected = false
    
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    var dynamicCells = 0
    
    var step1ListingDetails = GetStep1ListingDetailsQuery.Data.GetListingDetail.Result()
    var totalPersoncapacity = 0
    
    func getStep1ListingDetails() {
        var apollo_headerClient: ApolloClient = {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
            let url = URL(string:graphQLEndpoint)!
            
            return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
        }()
        let listId = "\(Utility.shared.createId)"
        let step1ListingDetailsquery = GetStep1ListingDetailsQuery(listId: listId, preview: true)
        apollo_headerClient.fetch(query: step1ListingDetailsquery,cachePolicy:.fetchIgnoringCacheData){(result,error)in
            guard (result?.data?.getListingDetails?.results) != nil else{
                if(result?.data?.getListingDetails?.status == 400) {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"nolist"))!)")
                }
                return
            }
            self.step1ListingDetails = (result?.data?.getListingDetails?.results)!
            if let personCapacity = (result?.data?.getListingDetails?.results?.personCapacity) {
                self.totalPersoncapacity = personCapacity
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStep1ListingDetails()
        dynamicCells = dynamicCells + 2
        dynamicCells = dynamicCells + 2
        
        let arr = Utility.shared.step3ValuesInfo["houseRules"] as? NSArray ?? []
        if arr.contains(48) { // Infants
            hasInfant = false
            dynamicCells = dynamicCells - 2
        }
        if arr.contains(50) { //Pets
            hasPets = false
            dynamicCells = dynamicCells - 2
        }
        if arr.contains(243) { //Visitors
            hasVisitor = true
            dynamicCells = dynamicCells + 2
        }
        
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
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "baseprice") ?? "Pricing")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        currencyAPICall()
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
        self.stepsTitleView.selectedViewIndex = 2
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
        tableView.reloadData()
    }
    
    func currencyAPICall() {
        Utility.shared.currencyvalue = (Utility.shared.currencyDataArray.first?.symbol!)!
        for i in Utility.shared.currencyDataArray {
            self.currencyArr.append(i.symbol!)
        }
        if(Utility.shared.step3ValuesInfo["currency"] != nil && "\(Utility.shared.step3ValuesInfo["currency"]!)" != "") {
            let index = self.currencyArr.firstIndex(of:"\(Utility.shared.step3ValuesInfo["currency"]!)")
            self.inputPickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
        } else {
            self.inputPickerView.selectRow(0, inComponent: 0, animated: true)
        }
        self.tableView.reloadData()
        
    }
    
    override func setdropdown() {
        inputUIView.frame = CGRect(x: 0, y: FULLHEIGHT-200, width: FULLWIDTH, height: 200)
        inputPickerView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 200)
        inputUIView.addSubview(inputPickerView)
        inputPickerView.delegate = self
        inputPickerView.tintColor = Theme.PRIMARY_COLOR
        inputPickerView.backgroundColor = UIColor(named: "colorController")
        inputPickerView.reloadAllComponents()
    }
    
    override func registerCells() {
        tableView.register(UINib(nibName: "DiscountTextFieldCell", bundle: nil), forCellReuseIdentifier: "discounttextfieldcell")
        
        tableView.register(UINib(nibName: "TipCell", bundle: nil), forCellReuseIdentifier: "TipCell")
    }
    
    override func addLottieViewAsSubview() {
        self.view.addSubview(self.lottieView)
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
        self.offlineUIView.layer.shadowOffset = CGSize(width: 0.0, height: 00.0)
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
            self.view.endEditing(true)
            if basePriceValue.isEmpty  || basePriceValue == "."  || basePriceValue == "0" || Utility.shared.host_basePrice < 1.0 || (basePriceValue.rangeOfCharacter(from: characterset.inverted) != nil) {
                if((basePriceValue == "."  || basePriceValue == "0" || Utility.shared.host_basePrice < 1.0) && (basePriceValue != "") && (basePriceValue.rangeOfCharacter(from: characterset.inverted) == nil)) {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"invalidbaseprice"))!)")
                    
                } else {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"baseprice_require"))!)")
                }
                return
            }
            
            var gsts = 0.0
            let ggsts = Utility.shared.step3ValuesInfo["guestesOnBasePrice"]
            if let gst = ggsts as? Int {
                gsts = Double(gst)
            } else if let gst = ggsts as? Double {
                gsts = gst
            }
//            let gsts = ((Utility.shared.step3ValuesInfo["guestesOnBasePrice"] ?? 0.0)) as? Double
            if Double(self.totalPersoncapacity) < gsts {
                self.view.makeToast("Base guests should be less than \(self.totalPersoncapacity)")
                return
            }
            
            if(cleaningPriceValue == "") {
                Utility.shared.step3ValuesInfo["cleaningPrice"] = 0.0
//                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"invalidcleaning"))!)")
//                return
            }
            
            if !taxesPriceValue.isEmpty  || (taxesPriceValue.rangeOfCharacter(from: characterset.inverted) != nil ) || taxesPriceValue.contains("."){
                if(taxesPriceValue == ".") {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invalidtaxPrice"))!)")
                    return
                }
                if taxesPriceValue.contains("."){
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invalidtaxPrice"))!)")
                    return
                }
                
                if Double(taxesPriceValue) ?? 0.0 > 100 {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invalidtaxPrice"))!)")
                    return
                }
            }
            
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.currencyvalue, forKey: "currency")
            let amenities = DiscountViewController()
            self.view.window?.backgroundColor = UIColor.white
            amenities.modalPresentationStyle = .fullScreen
            self.present(amenities, animated: false, completion: nil)
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            view.endEditing(true)
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
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIView.isHidden = true
        }
    }
    
    @available(iOS 16.0, *)
    @IBAction func saveandexitAction(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            if basePriceValue.isEmpty  || basePriceValue == "."  || basePriceValue == "0" || Utility.shared.host_basePrice < 1.0 || (basePriceValue.rangeOfCharacter(from: characterset.inverted) != nil) {
                if((basePriceValue == "."  || basePriceValue == "0" || Utility.shared.host_basePrice < 1.0) && (basePriceValue != "") && (basePriceValue.rangeOfCharacter(from: characterset.inverted) == nil) ) {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"invalidbaseprice"))!)")
                    
                } else {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"baseprice_require"))!)")
                }
                return
            }
            
//            let gsts = ((Utility.shared.step3ValuesInfo["guestesOnBasePrice"] ?? 0.0))
//            if (self.totalPersoncapacity) < gsts as! Int {
//                self.view.makeToast("Base guests should be less than \(self.totalPersoncapacity)")
//                return
//            }
            
            var gsts = 0.0
            let ggsts = Utility.shared.step3ValuesInfo["guestesOnBasePrice"]
            if let gst = ggsts as? Int {
                gsts = Double(gst)
            } else if let gst = ggsts as? Double {
                gsts = gst
            }
//            let gsts = ((Utility.shared.step3ValuesInfo["guestesOnBasePrice"] ?? 0.0)) as? Double
            if Double(self.totalPersoncapacity) < gsts {
                self.view.makeToast("Base guests should be less than \(self.totalPersoncapacity)")
                return
            }
            
            if(cleaningPriceValue == "") {
                Utility.shared.step3ValuesInfo["cleaningPrice"] = 0.0
//                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"invalidcleaning"))!)")
//                return
            }
            if !taxesPriceValue.isEmpty  || (taxesPriceValue.rangeOfCharacter(from: characterset.inverted) != nil){
                if(taxesPriceValue == ".") {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invalidtaxPrice"))!)")
                    return
                }
                if taxesPriceValue.contains("."){
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invalidtaxPrice"))!)")
                    return
                }
                if Double(taxesPriceValue) ?? 0.0 >= 100 {
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invalidtaxPrice"))!)")
                    return
                }
            }
            self.lottieViewanimation()
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.selectedRules, forKey: "houseRules")
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.createId, forKey: "id")
            super.updateStep3ListingAPICall{ (success) -> Void in
                if success {
                    saveandExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                    
                    self.lottieView1.isHidden = true
                }
            }
        } else {
            self.offlineviewShow()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + dynamicCells + 2
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerLabel = UILabel(frame: CGRect(x:15, y: 8, width:FULLWIDTH-40, height: 100))
        headerLabel.font =  UIFont(name: APP_FONT_MEDIUM, size:25)
        headerLabel.addCharacterSpacing()
        headerLabel.textColor =  UIColor(named: "Title_Header")
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        headerLabel.numberOfLines = 0
        let headerView = UIView(frame: CGRect(x:15, y: 8, width: tableView.bounds.size.width - 20, height: 100))
        headerView.backgroundColor = UIColor.white
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 2 {
            let cells = tableView
                .dequeueReusableCell(withIdentifier: "TipCell", for: indexPath) as? TipCell
            cells?.tipText.text = "\(Utility.shared.getLanguage()?.value(forKey: "basepricedsec")as! String)"
            
            cells?.selectionStyle = .none
            return cells!
        } else {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "discounttextfieldcell", for: indexPath) as? DiscountTextFieldCell
            if indexPath.row == 1{
                isSelected = true
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"baseprices"))!)"
                cell?.selectionStyle = .none
                cell?.txtField.delegate = self
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "\((Utility.shared.getLanguage()?.value(forKey:"pricepernight"))!)",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                cell?.txtField.tag = 1
                cell?.imgDownArrow.isHidden = true
                cell?.txtField.addTarget(self, action: #selector(didChangeText(field:)), for: .editingChanged)
                if(Utility.shared.step3ValuesInfo["basePrice"] != nil) {
                    basePriceValue = "\(Utility.shared.step3ValuesInfo["basePrice"]!)"
                    let base_value = Double(basePriceValue)?.clean
                    cell?.txtField.text = "\(base_value!)"
                }
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
                cell?.txtField.keyboardType = .decimalPad
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
                cell?.txtField.inputAccessoryView = toolBar
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.tintColor =  UIColor(named: "Title_Header")
                cell?.txtField.inputView = nil
                if Utility.shared.isRTLLanguage() {
                    cell?.txtField.leftView = nil
                    cell?.txtField.leftViewMode = .always
                    cell?.txtField.clearButtonMode = .whileEditing
                    cell?.txtField.textAlignment = .right
                } else{
                    cell?.txtField.rightView = nil
                    cell?.txtField.rightViewMode = .always
                    cell?.txtField.clearButtonMode = .whileEditing
                    cell?.txtField.textAlignment = .left
                }
                cell?.linetopconstant.constant = 0
                cell?.linebottomconstant.constant = 0
            } else if indexPath.row == 0 {
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"currency"))!)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                if(Utility.shared.step3ValuesInfo["currency"] != nil) {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.step3ValuesInfo["currency"]! as! String)
                    if(currencysymbol == (Utility.shared.step3ValuesInfo["currency"] as! String)) {
                        cell?.txtField.text = "\(currencysymbol ?? "USD")"
                    }
                    else {
                        cell?.txtField.text = "\(currencysymbol!) \(Utility.shared.step3ValuesInfo["currency"]!)"
                    }
                    Utility.shared.currencyvalue = "\(Utility.shared.step3ValuesInfo["currency"]!)"
                    
                } else {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue)
                    if(currencysymbol == Utility.shared.currencyvalue) {
                        cell?.txtField.text = "\(currencysymbol ?? "USD")"
                    } else {
                        cell?.txtField.text = "\(currencysymbol!) \(Utility.shared.currencyvalue)"
                    }
                }
                cell?.txtField.tag = 3
                cell?.txtField.tintColor = UIColor.clear
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputAccessoryView = toolBar
                cell?.txtField.inputView = inputPickerView
                cell?.txtField.delegate = self
                
                cell?.imgDownArrow.isHidden = false
                
                
                cell?.linetopconstant.constant = 0
                cell?.linebottomconstant.constant = 10
            } 
            else if indexPath.row == 3 {
                isSelected = true
                cell?.txtField.delegate = self
//                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"cleaningprice"))!)"
//                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "\((Utility.shared.getLanguage()?.value(forKey:"cleaningprice"))!)",
//                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                
                cell?.queryTitleLbl.text = "Number of Guests Allow on Base Price"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "Number of Guests Allow on Base Price",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                cell?.txtField.tag = 11
                cell?.txtField.addTarget(self, action: #selector(GuestesOnBasePriceText(field:)), for: .editingChanged)
                if(Utility.shared.step3ValuesInfo["guestesOnBasePrice"] != nil && ((Utility.shared.step3ValuesInfo["guestesOnBasePrice"]as? Double) != 0.0)) {
                    
                    guestesOnBasePrice =  "\(Utility.shared.step3ValuesInfo["guestesOnBasePrice"]!)"
                    let guestes_On_BasePrice = Double(guestesOnBasePrice)?.clean
                    cell?.txtField.text = "\(guestes_On_BasePrice!)"
                } else {
                    cell?.txtField.text = ""
                }
                cell?.imgDownArrow.isHidden = true
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
                cell?.txtField.keyboardType = .numberPad
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
                cell?.txtField.inputAccessoryView = toolBar
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputView = nil
                cell?.txtField.tintColor =  UIColor(named: "Title_Header")
                
                if Utility.shared.isRTLLanguage(){
                    cell?.txtField.leftView = nil
                    cell?.txtField.leftViewMode = .always
                    cell?.txtField.clearButtonMode = .whileEditing
                    cell?.txtField.textAlignment = .right
                }else{
                    cell?.txtField.rightView = nil
                    cell?.txtField.rightViewMode = .always
                    cell?.txtField.clearButtonMode = .whileEditing
                    cell?.txtField.textAlignment = .left
                }
                
            }
            
            else if indexPath.row == 4 {
               isSelected = true
               cell?.txtField.delegate = self
//                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"cleaningprice"))!)"
//                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "\((Utility.shared.getLanguage()?.value(forKey:"cleaningprice"))!)",
//                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
               
               cell?.queryTitleLbl.text = "Extra Guests Fee(Per Person)"
               cell?.txtField.attributedPlaceholder = NSAttributedString(string: "Extra Guests Fee(Per Person)",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
               cell?.txtField.tag = 12
               cell?.txtField.addTarget(self, action: #selector(ExtraGuestsPerPersonext(field:)), for: .editingChanged)
               if(Utility.shared.step3ValuesInfo["extraGuestsPerPerson"] != nil && ((Utility.shared.step3ValuesInfo["extraGuestsPerPerson"]as? Double) != 0.0)) {
                   
                   extraGuestsPerPerson =  "\(Utility.shared.step3ValuesInfo["extraGuestsPerPerson"]!)"
                   let extra_Guests_Per_Person = Double(extraGuestsPerPerson)?.clean
                   cell?.txtField.text = "\(extra_Guests_Per_Person!)"
               } else {
                   cell?.txtField.text = ""
               }
               cell?.imgDownArrow.isHidden = true
               cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
               cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
               cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
               cell?.txtField.keyboardType = .numberPad
               let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
               cell?.txtField.inputAccessoryView = toolBar
               toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
               cell?.txtField.inputView = nil
               cell?.txtField.tintColor =  UIColor(named: "Title_Header")
               
               if Utility.shared.isRTLLanguage(){
                   cell?.txtField.leftView = nil
                   cell?.txtField.leftViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .right
               }else{
                   cell?.txtField.rightView = nil
                   cell?.txtField.rightViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .left
               }
               
           }
            
            else if indexPath.row == 5 {
                isSelected = true
                cell?.txtField.delegate = self
                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"cleaningprice"))!)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "\((Utility.shared.getLanguage()?.value(forKey:"cleaningprice"))!)",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                cell?.txtField.tag = 2
                cell?.txtField.addTarget(self, action: #selector(CleaningText(field:)), for: .editingChanged)
                if(Utility.shared.step3ValuesInfo["cleaningPrice"] != nil && ((Utility.shared.step3ValuesInfo["cleaningPrice"]as? Double) != 0.0)) {
                    
                    cleaningPriceValue =  "\(Utility.shared.step3ValuesInfo["cleaningPrice"]!)"
                    let cleaning_value = Double(cleaningPriceValue)?.clean
                    cell?.txtField.text = "\(cleaning_value!)"
                } else {
                    cell?.txtField.text = ""
                }
                cell?.imgDownArrow.isHidden = true
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
                cell?.txtField.keyboardType = .decimalPad
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
                cell?.txtField.inputAccessoryView = toolBar
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputView = nil
                cell?.txtField.tintColor =  UIColor(named: "Title_Header")
                
                if Utility.shared.isRTLLanguage(){
                    cell?.txtField.leftView = nil
                    cell?.txtField.leftViewMode = .always
                    cell?.txtField.clearButtonMode = .whileEditing
                    cell?.txtField.textAlignment = .right
                }else{
                    cell?.txtField.rightView = nil
                    cell?.txtField.rightViewMode = .always
                    cell?.txtField.clearButtonMode = .whileEditing
                    cell?.txtField.textAlignment = .left
                }
                
            } 
//            else if indexPath.row == 4{
//                isSelected = true
//                cell?.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
//                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)",
//                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
//                cell?.txtField.tag = 4
//                cell?.txtField.delegate = self
//                if(Utility.shared.step3ValuesInfo["taxesPrice"] == nil || ((Utility.shared.step3ValuesInfo["taxesPrice"]as? Double) == 0.0) || Utility.shared.step3ValuesInfo["taxesPrice"] as? String == "0") {
//                    cell?.txtField.text = ""
//                }  else {
//                    taxesPriceValue =  "\(Utility.shared.step3ValuesInfo["taxesPrice"]!)"
//                    let cleaning_value =  Double(taxesPriceValue)?.clean
//                    cell?.txtField.text = "\(cleaning_value ?? "0")"
//                    
//                }
//                cell?.imgDownArrow.isHidden = true
//                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
//                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
//                cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
//                cell?.txtField.keyboardType = .decimalPad
//                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
//                cell?.txtField.inputAccessoryView = toolBar
//                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
//                cell?.txtField.inputView = nil
//                cell?.txtField.tintColor =  UIColor(named: "Title_Header")
//                cell?.lblPercentage.isHidden = false
//                if Utility.shared.isRTLLanguage(){
//                    cell?.lblPercentage.halfroundedCorners(corners:[ .topLeft, .bottomLeft], radius: 5)
//                } else {
//                    cell?.lblPercentage.halfroundedCorners(corners:[ .topRight, .bottomRight], radius: 5)
//                }
//                
//                if Utility.shared.isRTLLanguage(){
//                    cell?.txtField.leftView = nil
//                    cell?.txtField.leftViewMode = .always
//                    cell?.txtField.clearButtonMode = .whileEditing
//                    cell?.txtField.textAlignment = .right
//                }else{
//                    cell?.txtField.rightView = nil
//                    cell?.txtField.rightViewMode = .always
//                    cell?.txtField.clearButtonMode = .whileEditing
//                    cell?.txtField.textAlignment = .left
//                }
//                
//            } 
            else if indexPath.row == 6 && hasInfant == true {
                isSelected = true
                cell?.txtField.delegate = self
                cell?.queryTitleLbl.text = "Number of Infants(Below 3 years)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: "Number of Infants(Below 3 years)",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                cell?.txtField.tag = 5
                cell?.txtField.addTarget(self, action: #selector(InfantCountText(field:)), for: .editingChanged)
                if(Utility.shared.step3ValuesInfo["infantCount"] != nil && ((Utility.shared.step3ValuesInfo["infantCount"]as? Double) != 0.0)) {
                    
                    infantCount =  "\(Utility.shared.step3ValuesInfo["infantCount"]!)"
                    let infant_Count = Double(infantCount)?.clean
                    cell?.txtField.text = "\(infant_Count!)"
                } else {
                    cell?.txtField.text = ""
                }
                cell?.imgDownArrow.isHidden = true
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
                cell?.txtField.keyboardType = .numberPad
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
                cell?.txtField.inputAccessoryView = toolBar
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputView = nil
                cell?.txtField.tintColor =  UIColor(named: "Title_Header")
                
                if Utility.shared.isRTLLanguage(){
                    cell?.txtField.leftView = nil
                    cell?.txtField.leftViewMode = .always
                    cell?.txtField.clearButtonMode = .whileEditing
                    cell?.txtField.textAlignment = .right
                }else{
                    cell?.txtField.rightView = nil
                    cell?.txtField.rightViewMode = .always
                    cell?.txtField.clearButtonMode = .whileEditing
                    cell?.txtField.textAlignment = .left
                }
                
            } else if indexPath.row == 7  && hasInfant == true {
               isSelected = true
               cell?.txtField.delegate = self
               cell?.queryTitleLbl.text = "Infant Charges/Night"
               cell?.txtField.attributedPlaceholder = NSAttributedString(string: "Infant Charges/Night",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
               cell?.txtField.tag = 6
               cell?.txtField.addTarget(self, action: #selector(InfantPriceText(field:)), for: .editingChanged)
               if(Utility.shared.step3ValuesInfo["infantPrice"] != nil && ((Utility.shared.step3ValuesInfo["infantPrice"]as? Double) != 0.0)) {
                   
                   infantPrice =  "\(Utility.shared.step3ValuesInfo["infantPrice"]!)"
                   let infant_Price = Double(infantPrice)?.clean
                   cell?.txtField.text = "\(infant_Price!)"
               } else {
                   cell?.txtField.text = ""
               }
               cell?.imgDownArrow.isHidden = true
               cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
               cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
               cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
               cell?.txtField.keyboardType = .numberPad
               let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
               cell?.txtField.inputAccessoryView = toolBar
               toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
               cell?.txtField.inputView = nil
               cell?.txtField.tintColor =  UIColor(named: "Title_Header")
               
               if Utility.shared.isRTLLanguage(){
                   cell?.txtField.leftView = nil
                   cell?.txtField.leftViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .right
               }else{
                   cell?.txtField.rightView = nil
                   cell?.txtField.rightViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .left
               }
               
           } else if (indexPath.row == 8 && hasPets == true && hasInfant == true) || (indexPath.row == 6 && hasPets == true && hasInfant == false) {
               isSelected = true
               cell?.txtField.delegate = self
               
               cell?.queryTitleLbl.text = "Number of Pets"
               cell?.txtField.attributedPlaceholder = NSAttributedString(string: "Number of Pets",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
               cell?.txtField.tag = 7
               cell?.txtField.addTarget(self, action: #selector(PetCountText(field:)), for: .editingChanged)
               if(Utility.shared.step3ValuesInfo["petCount"] != nil && ((Utility.shared.step3ValuesInfo["petCount"]as? Double) != 0.0)) {
                   
                   petCount =  "\(Utility.shared.step3ValuesInfo["petCount"]!)"
                   let pet_Count = Double(petCount)?.clean
                   cell?.txtField.text = "\(pet_Count!)"
               } else {
                   cell?.txtField.text = ""
               }
               cell?.imgDownArrow.isHidden = true
               cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
               cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
               cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
               cell?.txtField.keyboardType = .numberPad
               let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
               cell?.txtField.inputAccessoryView = toolBar
               toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
               cell?.txtField.inputView = nil
               cell?.txtField.tintColor =  UIColor(named: "Title_Header")
               
               if Utility.shared.isRTLLanguage(){
                   cell?.txtField.leftView = nil
                   cell?.txtField.leftViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .right
               }else{
                   cell?.txtField.rightView = nil
                   cell?.txtField.rightViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .left
               }
               
           } else if (indexPath.row == 9 && hasPets == true && hasInfant == true) || (indexPath.row == 7 && hasPets == true && hasInfant == false) {
               isSelected = true
               cell?.txtField.delegate = self
               
               cell?.queryTitleLbl.text = "Pet Charges/Night"
               cell?.txtField.attributedPlaceholder = NSAttributedString(string: "Pet Charges/Night",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
               cell?.txtField.tag = 8
               cell?.txtField.addTarget(self, action: #selector(PetPriceText(field:)), for: .editingChanged)
               if(Utility.shared.step3ValuesInfo["petPrice"] != nil && ((Utility.shared.step3ValuesInfo["petPrice"]as? Double) != 0.0)) {
                   
                   petPrice =  "\(Utility.shared.step3ValuesInfo["petPrice"]!)"
                   let pet_Price = Double(petPrice)?.clean
                   cell?.txtField.text = "\(pet_Price!)"
               } else {
                   cell?.txtField.text = ""
               }
               cell?.imgDownArrow.isHidden = true
               cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
               cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
               cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
               cell?.txtField.keyboardType = .numberPad
               let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
               cell?.txtField.inputAccessoryView = toolBar
               toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
               cell?.txtField.inputView = nil
               cell?.txtField.tintColor =  UIColor(named: "Title_Header")
               
               if Utility.shared.isRTLLanguage(){
                   cell?.txtField.leftView = nil
                   cell?.txtField.leftViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .right
               }else{
                   cell?.txtField.rightView = nil
                   cell?.txtField.rightViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .left
               }
               
           } else if (indexPath.row == 10 && hasVisitor == true && hasPets == true && hasInfant == true) || (indexPath.row == 8 && hasVisitor == true && hasPets == true && hasInfant == false) || (indexPath.row == 8 && hasVisitor == true && hasPets == false && hasInfant == true) || (indexPath.row == 6 && hasVisitor == true && hasPets == false && hasInfant == false) {
               isSelected = true
               cell?.txtField.delegate = self
               
               cell?.queryTitleLbl.text = "Number of Visitors"
               cell?.txtField.attributedPlaceholder = NSAttributedString(string: "Number of Visitors",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
               cell?.txtField.tag = 9
               cell?.txtField.addTarget(self, action: #selector(VisitorCountText(field:)), for: .editingChanged)
               if(Utility.shared.step3ValuesInfo["visitorCount"] != nil && ((Utility.shared.step3ValuesInfo["visitorCount"]as? Double) != 0.0)) {
                   
                   visitorCount =  "\(Utility.shared.step3ValuesInfo["visitorCount"]!)"
                   let visitor_Count = Double(visitorCount)?.clean
                   cell?.txtField.text = "\(visitor_Count!)"
               } else {
                   cell?.txtField.text = ""
               }
               cell?.imgDownArrow.isHidden = true
               cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
               cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
               cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
               cell?.txtField.keyboardType = .numberPad
               let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
               cell?.txtField.inputAccessoryView = toolBar
               toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
               cell?.txtField.inputView = nil
               cell?.txtField.tintColor =  UIColor(named: "Title_Header")
               
               if Utility.shared.isRTLLanguage(){
                   cell?.txtField.leftView = nil
                   cell?.txtField.leftViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .right
               }else{
                   cell?.txtField.rightView = nil
                   cell?.txtField.rightViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .left
               }
               
           } else if (indexPath.row == 11 && hasVisitor == true && hasPets == true && hasInfant == true) || (indexPath.row == 9 && hasVisitor == true && hasPets == true && hasInfant == false) || (indexPath.row == 9 && hasVisitor == true && hasPets == false && hasInfant == true) || (indexPath.row == 7 && hasVisitor == true && hasPets == false && hasInfant == false) {
               isSelected = true
               cell?.txtField.delegate = self
               
               cell?.queryTitleLbl.text = "Visitor Charges/Night"
               cell?.txtField.attributedPlaceholder = NSAttributedString(string: "Visitor Charges/Night",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
               cell?.txtField.tag = 10
               cell?.txtField.addTarget(self, action: #selector(VisitorPriceText(field:)), for: .editingChanged)
               if(Utility.shared.step3ValuesInfo["visitorPrice"] != nil && ((Utility.shared.step3ValuesInfo["visitorPrice"]as? Double) != 0.0)) {
                   
                   visitorPrice =  "\(Utility.shared.step3ValuesInfo["visitorPrice"]!)"
                   let visitor_Price = Double(visitorPrice)?.clean
                   cell?.txtField.text = "\(visitor_Price!)"
               } else {
                   cell?.txtField.text = ""
               }
               cell?.imgDownArrow.isHidden = true
               cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size:16)
               cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
               cell?.txtField.font = UIFont(name: APP_FONT_MEDIUM, size:14)
               cell?.txtField.keyboardType = .numberPad
               let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismisskeyborad))
               cell?.txtField.inputAccessoryView = toolBar
               toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
               cell?.txtField.inputView = nil
               cell?.txtField.tintColor =  UIColor(named: "Title_Header")
               
               if Utility.shared.isRTLLanguage(){
                   cell?.txtField.leftView = nil
                   cell?.txtField.leftViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .right
               }else{
                   cell?.txtField.rightView = nil
                   cell?.txtField.rightViewMode = .always
                   cell?.txtField.clearButtonMode = .whileEditing
                   cell?.txtField.textAlignment = .left
               }
               
           }
            
            cell?.txtField.textColor = UIColor(named: "Title_Header")
            cell?.stepnumberLbl.isHidden = true
            cell?.stepnumberLbl.text = ""
            let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
            cell?.txtField.leftView = paddingView
            cell?.txtField.leftViewMode = .always
            cell?.stepOneBottom.constant = 0
            cell?.stepOneHeight.constant = 0
            cell?.stepNumberLblTopConstraint.constant = 0
            cell?.selectionStyle = .none
            cell?.txtField.delegate = self
            return cell!
            
        }
    }
    
    @objc func onClickedDownArrow(sender: UIButton){
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! DiscountTextFieldCell
        cell.txtField.becomeFirstResponder()
    }
    
    @objc func dismisskeyborad() {
        view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            selectedTextfield = 3
        }
        inputPickerView.reloadAllComponents()
    }
    
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  Utility.shared.currencyDataArray.count
    }
    
    override func pickerView( _ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var titleData = ""
        
        if(selectedTextfield == 3) {
            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.currencyDataArray[row].symbol!)
            if(currencysymbol == Utility.shared.currencyDataArray[row].symbol!) {
                titleData = "\(Utility.shared.currencyDataArray[row].symbol!)"
            } else {
                titleData = "\(currencysymbol!) \(Utility.shared.currencyDataArray[row].symbol!)"
            }
        }
        
        let myTitle = NSAttributedString(string: titleData , attributes: [NSAttributedString.Key.font:UIFont(name: APP_FONT, size: 15.0)!,NSAttributedString.Key.foregroundColor:Theme.PRIMARY_COLOR])
        return myTitle
    }
    
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        if(selectedTextfield == 3) {
            Utility.shared.currencyvalue =  Utility.shared.currencyDataArray[row].symbol!
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.currencyvalue, forKey: "currency")
            pickerView.selectRow(row, inComponent: component, animated: true)
        }
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextfield = textField.tag
        inputPickerView.reloadAllComponents()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        let newlength = currentCharacterCount + string.count - range.length
        
        if textField.tag == 4 {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            if updatedText.isEmpty {
                return true
            } else if let number = Int(updatedText), updatedText.count <= 2 {
                return true
            } else {
                return false
            }
        }
        
        if isSelected  {
            
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            if (allowedCharacters.isSuperset(of: characterSet) == false) || range.length + range.location > currentCharacterCount || (((textField.text?.contains("."))!) && (string == ".") )  {
                return false
            } else{
                return newlength <= 12
            }
        }
        return false
        
    }
    
    @objc func didChangeText(field: UITextField) {
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            basePriceValue = field.text!
        }
    }
    @objc func CleaningText(field: UITextField){
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            cleaningPriceValue = field.text!
        }
    }
    
    @objc func InfantCountText(field: UITextField){
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            infantCount = field.text!
        }
    }
    
    @objc func InfantPriceText(field: UITextField){
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            infantPrice = field.text!
        }
    }
    
    @objc func PetCountText(field: UITextField){
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            petCount = field.text!
        }
    }
    
    @objc func GuestesOnBasePriceText(field: UITextField){
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            guestesOnBasePrice = field.text!
        }
    }
    
    @objc func ExtraGuestsPerPersonext(field: UITextField){
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            extraGuestsPerPerson = field.text!
        }
    }
    
    @objc func PetPriceText(field: UITextField){
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            petPrice = field.text!
        }
    }
    
    @objc func VisitorCountText(field: UITextField){
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            visitorCount = field.text!
        }
    }
    
    @objc func VisitorPriceText(field: UITextField){
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english
            visitorPrice = field.text!
        }
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.text == "." || textField.text?.rangeOfCharacter(from: characterset.inverted) != nil) {
            self.view.endEditing(true)
            if textField.tag == 1 {
                basePriceValue = textField.text!
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"invalidbaseprice"))!)")
            } else if textField.tag == 2 {
                cleaningPriceValue = textField.text!
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"invalidcleaning"))!)")
            } else if textField.tag == 4{
                taxesPriceValue = textField.text!
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"invalidtaxPrice"))!)")
            } else if textField.tag == 11 {
                guestesOnBasePrice = textField.text!
                self.view.makeToast("Invalid Guests on BasePrice")
            } else if textField.tag == 12 {
                extraGuestsPerPerson = textField.text!
                self.view.makeToast("Invalid Extra Guests Fee(Per Person)")
            } else if textField.tag == 5 {
                infantCount = textField.text!
                self.view.makeToast("Invalid Number of Infants(Below 3 years)")
            } else if textField.tag == 6 {
                infantPrice = textField.text!
                self.view.makeToast("Invalid Infant Charges/Night")
            } else if textField.tag == 7 {
                petCount = textField.text!
                self.view.makeToast("Invalid Number of Pets")
            } else if textField.tag == 8 {
                petPrice = textField.text!
                self.view.makeToast("Invalid Pet Charges/Night")
            } else if textField.tag == 9 {
                visitorCount = textField.text!
                self.view.makeToast("Invalid Number of Visitors")
            } else if textField.tag == 10 {
                visitorPrice = textField.text!
                self.view.makeToast("Invalid Visitor Charges/Night")
            }
            
        } else {
            if textField.tag == 1 {
                basePriceValue = textField.text!
                if(basePriceValue != "" ) {
                    Utility.shared.host_basePrice = (Double(basePriceValue)) ?? 0.0
                    Utility.shared.step3ValuesInfo.updateValue((Double(basePriceValue)?.clean) ?? 0.0, forKey: "basePrice")
                } else {
                    Utility.shared.host_basePrice = 0.0
                    Utility.shared.step3ValuesInfo.updateValue(0.0, forKey: "basePrice")
                }
            }
            if textField.tag == 2 {
                cleaningPriceValue = textField.text!
                if(cleaningPriceValue == "") {
                    Utility.shared.host_cleanPrice = 0.0
                    Utility.shared.step3ValuesInfo.updateValue(0.0, forKey: "cleaningPrice")
                } else {
                    Utility.shared.host_cleanPrice = (Double(cleaningPriceValue)) ?? 0.0
                    Utility.shared.step3ValuesInfo.updateValue((Double(cleaningPriceValue)?.clean) ?? 0.0, forKey: "cleaningPrice")
                }
            }
            
            if textField.tag == 4 {
                taxesPriceValue = textField.text!
                if taxesPriceValue == "" {
                    Utility.shared.host_taxPrice = 0.0
                    Utility.shared.step3ValuesInfo.updateValue(0.0, forKey: "taxesPrice")
                } else {
                    Utility.shared.host_taxPrice = (Double(taxesPriceValue)) ?? 0.0
                    Utility.shared.step3ValuesInfo.updateValue((Double(taxesPriceValue)?.clean) ?? 0.0, forKey: "taxesPrice")
                }
            }
            
            if textField.tag == 11 {
                guestesOnBasePrice = textField.text!
                if(guestesOnBasePrice != "" ) {
                    Utility.shared.host_GuestsOnBasePrice = (Int(guestesOnBasePrice)) ?? 0
                    Utility.shared.step3ValuesInfo.updateValue((Int(guestesOnBasePrice)) ?? 0, forKey: "guestesOnBasePrice")
                } else {
                    Utility.shared.host_GuestsOnBasePrice = 0
                    Utility.shared.step3ValuesInfo.updateValue(0.0, forKey: "guestesOnBasePrice")
                }
            }
            
            if textField.tag == 12 {
                extraGuestsPerPerson = textField.text!
                if(extraGuestsPerPerson != "" ) {
                    Utility.shared.host_GuestsPrice = (Double(extraGuestsPerPerson)) ?? 0.0
                    Utility.shared.step3ValuesInfo.updateValue((Double(extraGuestsPerPerson)?.clean) ?? 0.0, forKey: "extraGuestsPerPerson")
                } else {
                    Utility.shared.host_GuestsPrice = 0.0
                    Utility.shared.step3ValuesInfo.updateValue(0.0, forKey: "extraGuestsPerPerson")
                }
            }
            
            if textField.tag == 5 {
                infantCount = textField.text!
                if(infantCount != "" ) {
                    Utility.shared.host_InfantCount = (Int(infantCount)) ?? 0
                    Utility.shared.step3ValuesInfo.updateValue((Int(infantCount)) ?? 0, forKey: "infantCount")
                } else {
                    Utility.shared.host_InfantCount = 0
                    Utility.shared.step3ValuesInfo.updateValue(0.0, forKey: "infantCount")
                }
            }
            
            if textField.tag == 6 {
                infantPrice = textField.text!
                if(infantPrice != "" ) {
                    Utility.shared.host_InfantPrice = (Double(infantPrice)) ?? 0.0
                    Utility.shared.step3ValuesInfo.updateValue((Double(infantPrice)?.clean) ?? 0.0, forKey: "infantPrice")
                } else {
                    Utility.shared.host_InfantPrice = 0.0
                    Utility.shared.step3ValuesInfo.updateValue(0.0, forKey: "infantPrice")
                }
            }

            if textField.tag == 7 {
                petCount = textField.text!
                if(petCount != "" ) {
                    Utility.shared.host_PetCount = (Int(petCount)) ?? 0
                    Utility.shared.step3ValuesInfo.updateValue((Int(petCount)) ?? 0, forKey: "petCount")
                } else {
                    Utility.shared.host_PetCount = 0
                    Utility.shared.step3ValuesInfo.updateValue(0.0, forKey: "petCount")
                }
            }
            
            if textField.tag == 8 {
                petPrice = textField.text!
                if(petPrice != "" ) {
                    Utility.shared.host_PetPrice = (Double(petPrice)) ?? 0.0
                    Utility.shared.step3ValuesInfo.updateValue((Double(petPrice)?.clean) ?? 0.0, forKey: "petPrice")
                } else {
                    Utility.shared.host_PetPrice = 0.0
                    Utility.shared.step3ValuesInfo.updateValue(0.0, forKey: "petPrice")
                }
            }
            
            if textField.tag == 9 {
                visitorCount = textField.text!
                if(visitorCount != "" ) {
                    Utility.shared.host_VisitorCount = (Int(visitorCount)) ?? 0
                    Utility.shared.step3ValuesInfo.updateValue((Int(visitorCount)) ?? 0, forKey: "visitorCount")
                } else {
                    Utility.shared.host_VisitorCount = 0
                    Utility.shared.step3ValuesInfo.updateValue(0.0, forKey: "visitorCount")
                }
            }
            
            if textField.tag == 10 {
                visitorPrice = textField.text!
                if(visitorPrice != "" ) {
                    Utility.shared.host_VisitorPrice = (Double(visitorPrice)) ?? 0.0
                    Utility.shared.step3ValuesInfo.updateValue((Double(visitorPrice)?.clean) ?? 0.0, forKey: "visitorPrice")
                } else {
                    Utility.shared.host_VisitorPrice = 0.0
                    Utility.shared.step3ValuesInfo.updateValue(0.0, forKey: "visitorPrice")
                }
            }
            
        }
        
        if textField.tag == 3{
            let indexPaths = IndexPath(item: 0, section: 0)
            tableView.reloadRows(at: [indexPaths], with: .none)
        }
        
        view.endEditing(true)
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
extension String {
    var containsNonEnglishNumbersChecking: Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
    
    var english: String {
        return self.applyingTransform(StringTransform.toLatin, reverse: false) ?? self
    }
}
extension FloatingPoint {
    var isInteger: Bool { rounded() == self }
}



extension BasePriceViewController: stepsUpdateProtocol{
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


extension BasePriceViewController{
    
    func textField1(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        let isNumeric = string.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
        return isNumeric || string.isEmpty
    }
}
