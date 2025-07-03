
import UIKit
import Apollo
import Lottie
import Stripe

class BankAccountVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,WebviewVCDelegate,UIPickerViewDelegate, UIPickerViewDataSource{
    func onSuccessPayPalPayment(isSuccess: Bool,toastermsg: String,successURL: URL?) {
        
    }
    
    
    
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var bankaccountTable: UITableView!
    @IBOutlet weak var topView: UIView!
    var bankaccount_field_Array = [String]()
    var bankaccount_Dict = [String:Any]()
    var accountID = String()
    var account_typeArray = [String]()
    var selectedTextfield = Int()
    var accountypeLabel = String()
    var accountypeLabelPrevious = String()
    var accountypeLabelPreviousCell = String()
    var companyTypeArray = [String]()
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var lottieView: LottieAnimationView!
    
    var lottieWholeView = UIView()
    var lottieView1 =  LottieAnimationView()
    var inputPickerView = UIView()
    var pickerView = UIPickerView()
    var bankToken = ""
    var personToken = ""
    var getpaymentmethodCurrency = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.view.backgroundColor =   UIColor(named: "colorController")
        accountypeLabelPrevious = "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")"
        bankaccount_Dict.updateValue("individual", forKey: "accounttype")
        self.initialsetup()
        setdropdown()
        
        // Do any additional setup after loading the view.
    }
    func setdropdown()
    {
        inputPickerView.frame = CGRect(x: 0, y: FULLHEIGHT-200, width: FULLWIDTH, height: 200)
        pickerView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 200)
        inputPickerView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.tintColor = Theme.PRIMARY_COLOR
        pickerView.backgroundColor = UIColor(named: "colorController")
        pickerView.reloadAllComponents()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.finishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"finish"))!)", for: .normal)
        accountypeLabelPrevious = "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")"
        bankaccount_Dict.updateValue("individual", forKey: "accounttype")
    }
    
    @IBAction func finishBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            
            if(accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Company") ?? "Company")")
            {
                bankaccount_Dict.updateValue("", forKey: "lastname")
            }
            
            if((bankaccount_Dict["accounttype"]) == nil || ((bankaccount_Dict["accounttype"]as! String) == ""))
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"chooseacctype"))!)")
            }
            
            else if((bankaccount_Dict["firstname"]) == nil || ((bankaccount_Dict["firstname"]as! String) == ""))
            {
                if(accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Company") ?? "Company")")
                {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enter_CompanyName"))!)")
                }
                else
                {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"firstnamealert"))!)")
                }
            }
            
            else if(((bankaccount_Dict["lastname"]) == nil || ((bankaccount_Dict["lastname"]as? String) == "")) && accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")")
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"lastnamealert"))!)")
            }
            else if (((bankaccount_Dict["routingnum"]) == nil || ((bankaccount_Dict["routingnum"]as? String) == "")) && (!Utility.shared.isRoutingNotNeeded(selectedCountry: Utility.shared.selected_Countrycode_Payout)))
            {
                
                if Utility.shared.selected_Countrycode_Payout == "GB"{
                    self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey:"Enter_Sort_Number") ?? "Please enter sort number")")
                }else{
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"rooutingnumberalert"))!)")
                }
                
            }
            
            else if((bankaccount_Dict["accnum"]) == nil || ((bankaccount_Dict["accnum"]as? String) == ""))
            {
                if (Utility.shared.isRoutingNotNeeded(selectedCountry: Utility.shared.selected_Countrycode_Payout)){
                    
                    if (Utility.shared.selected_Countrycode_Payout == "MX" || Utility.shared.selected_Countrycode_Payout == "NZ"){
                        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"accountnumberalert"))!)")
                    }else{
                        self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey:"Enter_IBAN_Number") ?? "Please enter IBAN number")")
                        
                    }
                }else{
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"accountnumberalert"))!)")
                }
            }
            
            
            else if((bankaccount_Dict["confirmnum"]) == nil || ((bankaccount_Dict["confirmnum"]as? String) == ""))
            {
                if (Utility.shared.isRoutingNotNeeded(selectedCountry: Utility.shared.selected_Countrycode_Payout)){
                    
                    if (Utility.shared.selected_Countrycode_Payout == "MX" || Utility.shared.selected_Countrycode_Payout == "NZ"){
                        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"confirmaccountalert"))!)")
                    }else{
                        self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey:"Enter_Confirm_IBAN_Number") ?? "Please enter confirm IBAN number")")
                        
                    }
                }else{
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"confirmaccountalert"))!)")
                }
            }
            
            else{
                self.lottieanimation()
                if (accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Company") ?? "Company")"){
                    self.getStripeToken(selectedType: 1)
                }else{
                    self.getStripeToken(selectedType: 2)
                }
                
                
            }
        }
        else
        {
            self.offlineView.isHidden = false
            self.finishBtn.isHidden = true
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: self.offlineView.frame.size.width + shadowSize2,
                                                        height: self.offlineView.frame.size.height + shadowSize2))
            
            self.offlineView.layer.masksToBounds = false
            self.offlineView.layer.shadowColor = Theme.TextLightColor.cgColor
            self.offlineView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.offlineView.layer.shadowOpacity = 0.3
            self.offlineView.layer.shadowPath = shadowPath2.cgPath
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.finishBtn.isHidden = false
            self.offlineView.isHidden = true
        }
        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func lottieanimation()
    {
        finishBtn.setTitle("", for:.normal)
        lottieView = LottieAnimationView.init(name: "animation_white")
        
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:finishBtn.frame.size.width/2-60, y:-25, width:100, height:100)
        self.finishBtn.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    
    func lottiewholeAnimation()
    {
        self.lottieView1.isHidden = false
        self.lottieWholeView.isHidden = false
        lottieView1 = LottieAnimationView.init(name: "loading_qwe")
        self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        self.lottieWholeView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(lottieWholeView)
        self.lottieView1.frame = CGRect(x:FULLWIDTH/2-50, y: FULLHEIGHT/2-50, width: 100, height: 100)
        self.lottieWholeView.addSubview(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor(named: "lottie-bg")
        self.lottieView1.layer.cornerRadius = 6.0
        self.lottieView1.clipsToBounds = true
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    
    func setPayoutCall(accountid:String)
    {
        self.lottiewholeAnimation()
        
        let setPayoutMutation = ConfirmPayoutMutation(currentAccountId:accountid)
        apollo_headerClient.perform(mutation:setPayoutMutation){(result,error) in
            if(result?.data?.confirmPayout?.status == 200)
            {
                self.lottieWholeView.isHidden = true
                self.lottieView1.isHidden = true
                let payoutObj = PayoutPreferenceVC()
                Utility.shared.isfrom_payoutcurrency = true
                payoutObj.modalPresentationStyle = .fullScreen
                self.present(payoutObj, animated: true, completion: nil)
            }
            else
            {
                self.lottieWholeView.isHidden = true
                self.lottieView1.isHidden = true
                self.view.makeToast(result?.data?.confirmPayout?.errorMessage)
            }
        }
        
        
    }
    
    @objc func autoscroll()
    {
        self.lottieView.play()
        self.lottieView1.play()
    }
    func initialsetup()
    {
        
        if(Utility.shared.isRTLLanguage()) {
            backBtn.imageView?.performRTLTransform()
            
        }
        bankaccountTable.register(UINib(nibName: "PayoutTextfieldCell", bundle: nil), forCellReuseIdentifier: "PayoutTextfieldCell")
        
        
        
        self.finishBtn.layer.cornerRadius = finishBtn.frame.size.height / 2
        self.finishBtn.layer.masksToBounds = true
        finishBtn.backgroundColor = Theme.Button_BG
        titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 20)
        titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"Accountdetails"))!)"
        titleLabel.textColor = UIColor(named: "Title_Header")
        
        if Utility.shared.isRoutingNotNeeded(selectedCountry: Utility.shared.selected_Countrycode_Payout){
            
            
            if Utility.shared.selected_Countrycode_Payout == "MX" || Utility.shared.selected_Countrycode_Payout == "NZ" {
                
                self.companyTypeArray = [
                    "\((Utility.shared.getLanguage()?.value(forKey:"acctype"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"company_name"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"accountnumber"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"confirmaccountnumber"))!)"
                ]
                
                self.bankaccount_field_Array = [
                    "\((Utility.shared.getLanguage()?.value(forKey:"acctype"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"FirstName"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"LastName"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"accountnumber"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"confirmaccountnumber"))!)"
                ]
                
            }else{
                
                self.companyTypeArray = [
                    "\((Utility.shared.getLanguage()?.value(forKey:"acctype"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"company_name"))!)",
                    "\(Utility.shared.getLanguage()?.value(forKey:"IBAN_Number") ?? "IBAN number")",
                    "\(Utility.shared.getLanguage()?.value(forKey:"Confirm_IBAN_Number") ?? "Confirm IBAN number")"
                ]
                
                self.bankaccount_field_Array = [
                    "\((Utility.shared.getLanguage()?.value(forKey:"acctype"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"FirstName"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"LastName"))!)",
                    "\(Utility.shared.getLanguage()?.value(forKey:"IBAN_Number") ?? "IBAN number")",
                    "\(Utility.shared.getLanguage()?.value(forKey:"Confirm_IBAN_Number") ?? "Confirm IBAN number")"
                ]
                
            }
        }else{
            if Utility.shared.selected_Countrycode_Payout == "GB"{
                self.companyTypeArray = [
                    "\((Utility.shared.getLanguage()?.value(forKey:"acctype"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"company_name"))!)",
                    "\(Utility.shared.getLanguage()?.value(forKey:"Sort_Number") ?? "Sort number")",
                    "\((Utility.shared.getLanguage()?.value(forKey:"accountnumber"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"confirmaccountnumber"))!)"
                ]
                
                self.bankaccount_field_Array = [
                    "\((Utility.shared.getLanguage()?.value(forKey:"acctype"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"FirstName"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"LastName"))!)",
                    "\(Utility.shared.getLanguage()?.value(forKey:"Sort_Number") ?? "Sort number")",
                    "\((Utility.shared.getLanguage()?.value(forKey:"accountnumber"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"confirmaccountnumber"))!)"
                ]
            }else{
                self.companyTypeArray = [
                    "\((Utility.shared.getLanguage()?.value(forKey:"acctype"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"company_name"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"routingnumber"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"accountnumber"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"confirmaccountnumber"))!)"
                ]
                
                self.bankaccount_field_Array = [
                    "\((Utility.shared.getLanguage()?.value(forKey:"acctype"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"FirstName"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"LastName"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"routingnumber"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"accountnumber"))!)",
                    "\((Utility.shared.getLanguage()?.value(forKey:"confirmaccountnumber"))!)"
                ]
            }
        }
        self.account_typeArray = ["\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")","\(Utility.shared.getLanguage()?.value(forKey: "Company") ?? "Company")"]
        accountypeLabel = account_typeArray.first!
        self.offlineView.isHidden = true
        self.finishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"finish"))!)", for: .normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        finishBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size:18)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        
    }
    func getStripeToken(selectedType: Int){
        if selectedType == 1{ // 1 for company
            let companyParams = STPConnectAccountCompanyParams()
            companyParams.additionalAPIParameters = ["":""]
            
            let ConnectAccountParams = STPConnectAccountParams(tosShownAndAccepted: true, company: companyParams)
            
            let values = STPConnectAccountCompanyParams()
            let address = STPConnectAccountAddress()
            address.city = Utility.shared.payout_Address_Dict["city"] as? String
            address.country = Utility.shared.selected_Countrycode_Payout
            address.postalCode = Utility.shared.payout_Address_Dict["zipcode"] as? String
            address.state = Utility.shared.payout_Address_Dict["state"] as? String
            address.line1 = "\(Utility.shared.payout_Address_Dict["address1"] ?? "")"
            address.line2 = "\(Utility.shared.payout_Address_Dict["address2"] ?? "")"
            
            values.address = address
            values.name = bankaccount_Dict["firstname"] as? String
            
            
            STPAPIClient.shared.createToken(withConnectAccount: STPConnectAccountParams(tosShownAndAccepted: true,company: values)!) { (token, error) in
                guard let token = token, error == nil else {
                    self.lottieView.isHidden = true
                    self.finishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"finish"))!)", for: .normal)
                    self.view.makeToast(error?.localizedDescription)
                    return
                }
                
                self.bankToken = token.tokenId
                self.personToken = ""
                self.finishAPICall()
            }
            
            
        }else{
            let values = STPConnectAccountIndividualParams()
            let address = STPConnectAccountAddress()
            address.city = Utility.shared.payout_Address_Dict["city"] as? String
            address.country = Utility.shared.selected_Countrycode_Payout
            address.postalCode = Utility.shared.payout_Address_Dict["zipcode"] as? String
            address.state = Utility.shared.payout_Address_Dict["state"] as? String
            address.line1 = "\(Utility.shared.payout_Address_Dict["address1"] ?? "")"
            address.line2 = "\(Utility.shared.payout_Address_Dict["address2"] ?? "")"
            
            values.address = address
            values.firstName = bankaccount_Dict["firstname"] as? String
            values.lastName = bankaccount_Dict["lastname"] as? String
            values.idNumber = bankaccount_Dict["routingnum"] as? String
            values.dateOfBirth = DateComponents.init(calendar: nil, timeZone: nil, era: nil, year: 1997, month: 4, day: 1, hour: nil, minute: nil, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
            
            STPAPIClient.shared.createToken(withConnectAccount: STPConnectAccountParams(tosShownAndAccepted: true, individual: values)!) { (token, error) in
                guard let token = token, error == nil else {
                    self.lottieView.isHidden = true
                    self.finishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"finish"))!)", for: .normal)
                    self.view.makeToast(error?.localizedDescription)
                    return
                }
                
                self.bankToken = token.tokenId
                self.personToken = ""
                self.finishAPICall()
            }
            
        }
        
    }
    func getPersonToken(){
        
        
        STPAPIClient.shared.createToken(withPersonalIDNumber: "3456t") { (token, error) in
            guard let token = token, error == nil else {
                self.lottieView.isHidden = true
                self.finishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"finish"))!)", for: .normal)
                self.view.makeToast(error?.localizedDescription)
                return
            }
            self.personToken = token.tokenId
            self.finishAPICall()
        }
    }
    func finishAPICall()
    {
        if(Utility.shared.getEmail() == nil)
        {
            Utility.shared.setEmail(email: "demo@radicalstart.com")
        }
        let addpayoutmutation = AddPayoutMutation(methodId: 2, payEmail:"\(Utility.shared.getEmail())", address1:"\(Utility.shared.payout_Address_Dict["address1"]!)", address2:"\(Utility.shared.payout_Address_Dict["address2"] ?? "")", city:Utility.shared.payout_Address_Dict["city"] as! String, state:Utility.shared.payout_Address_Dict["state"] as! String, country:Utility.shared.selected_Countrycode_Payout, zipcode:Utility.shared.payout_Address_Dict["zipcode"] as! String, currency:self.getpaymentmethodCurrency, firstname: bankaccount_Dict["firstnam?"] as? String, lastname: bankaccount_Dict["lastname"] as? String, accountNumber: bankaccount_Dict["accnum"] as? String, routingNumber: bankaccount_Dict["routingnum"] as? String,businessType:bankaccount_Dict["accounttype"] as! String, accountToken: self.bankToken, personToken: self.personToken)
        
        apollo_headerClient.perform(mutation: addpayoutmutation){(result,error) in
            if(result?.data?.addPayout?.status == 200)
            {
                self.lottieView.isHidden = true
                let webviewObj = WebviewVC()
                webviewObj.delegate = self
                webviewObj.webstring = (result?.data?.addPayout?.connectUrl)!
                webviewObj.modalPresentationStyle = .fullScreen
                webviewObj.succesURL = (result?.data?.addPayout?.successUrl)!
                webviewObj.failureURL = (result?.data?.addPayout?.failureUrl)!
                webviewObj.webviewRedirection(webviewString:(result?.data?.addPayout?.connectUrl!)!)
                webviewObj.accountID = (result?.data?.addPayout?.stripeAccountId!)!
                webviewObj.pageTitle = ""
                self.accountID = (result?.data?.addPayout?.stripeAccountId!)!
                self.present(webviewObj, animated: true, completion: nil)
            }
            else
            {
                self.lottieView.isHidden = true
                self.finishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"finish"))!)", for: .normal)
                
                
                
                self.view.makeToast(result?.data?.addPayout?.errorMessage!)
            }
            
        }
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.finishBtn.frame.origin.y = keyboardFrame.origin.y - 60
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.finishBtn.frame.origin.y = FULLHEIGHT - 70
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(accountypeLabel == "" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")")
        {
            return bankaccount_field_Array.count
        }
        else
        {
            return companyTypeArray.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayoutTextfieldCell", for: indexPath)as! PayoutTextfieldCell
        cell.selectionStyle = .none
        cell.payoutTF.autocorrectionType = UITextAutocorrectionType.no
        cell.payoutTF.delegate = self
        cell.payoutTF.tag = indexPath.row
        let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
        toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
        cell.payoutTF.inputAccessoryView = toolBar
        cell.tag = indexPath.row + 2000
        
        if(accountypeLabel == "" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")")
        {
            
            if accountypeLabelPreviousCell != "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")" {
                
                
                
                if indexPath.row == bankaccount_field_Array.count - 1 {
                    accountypeLabelPreviousCell = accountypeLabel
                }
                
                cell.payoutTF.text = ""
                
                
                
            }
            view.endEditing(true)
        }else{
            
            if accountypeLabelPreviousCell != "\(Utility.shared.getLanguage()?.value(forKey: "Company") ?? "Company")" {
                if indexPath.row == companyTypeArray.count - 1 {
                    accountypeLabelPreviousCell = accountypeLabel
                }
                
                cell.payoutTF.text = ""
            }
            view.endEditing(true)
        }
        
        
        if(accountypeLabel == "" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")")
        {
            cell.payoutTF.attributedPlaceholder =  NSAttributedString(string:bankaccount_field_Array[indexPath.row],
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            cell.lblHeader.text = bankaccount_field_Array[indexPath.row]
            
            
            if(indexPath.row == 0)
            {
                cell.imgDownArrow.isHidden = false
                cell.payoutTF.tintColor = .clear
                if(accountypeLabel == "")
                {
                    cell.payoutTF.attributedPlaceholder = NSAttributedString(string:bankaccount_field_Array[indexPath.row],
                                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                }
                else
                {
                    cell.payoutTF.attributedPlaceholder = NSAttributedString(string: accountypeLabel,
                                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                }
                cell.payoutTF.inputView = pickerView
                cell.payoutTF.delegate = self
                
                return cell
            }
            else
            {
                cell.payoutTF.tintColor =  UIColor(named: "Title_Header")
                cell.imgDownArrow.isHidden = true
                cell.payoutTF.inputView = nil
            }
            if((indexPath.row == 1) || (indexPath.row == 2))
            {
                cell.imgDownArrow.isHidden = true
                cell.payoutTF.tintColor =  UIColor(named: "Title_Header")
                cell.payoutTF.keyboardType = .default
            }
            else if(indexPath.row == 3){
                cell.payoutTF.tintColor =  UIColor(named: "Title_Header")
                cell.imgDownArrow.isHidden = true
                if(accountypeLabel != "" )
                {
                }
                cell.payoutTF.keyboardType = .default
            }
            else{
                cell.payoutTF.tintColor =  UIColor(named: "Title_Header")
                cell.imgDownArrow.isHidden = true
                cell.payoutTF.keyboardType = .default
            }
        }
        else
        {
            if(companyTypeArray.count <= 5)
            {
                cell.payoutTF.attributedPlaceholder =  NSAttributedString(string:companyTypeArray[indexPath.row],
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                cell.lblHeader.text = companyTypeArray[indexPath.row]
            }
            if(indexPath.row == 0)
            {
                if(accountypeLabel == "")
                {
                    cell.payoutTF.attributedPlaceholder = NSAttributedString(string:bankaccount_field_Array[indexPath.row],
                                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                }
                else
                {
                    cell.payoutTF.attributedPlaceholder = NSAttributedString(string: accountypeLabel,
                                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                }
                cell.imgDownArrow.isHidden = false
                cell.payoutTF.tintColor = .clear
                cell.payoutTF.inputView = pickerView
                cell.payoutTF.delegate = self
                return cell
            }
            else if(indexPath.row == 3){
                cell.payoutTF.tintColor =  UIColor(named: "Title_Header")
                cell.imgDownArrow.isHidden = true
                if(accountypeLabel != "" )
                {
                }
                
            }
            else
            {
                cell.payoutTF.inputView = nil
            }
            if((indexPath.row == 1))
            {
                cell.imgDownArrow.isHidden = true
                cell.payoutTF.keyboardType = .default
                cell.payoutTF.tintColor =  UIColor(named: "Title_Header")
            }
            else{
                cell.imgDownArrow.isHidden = true
                cell.payoutTF.keyboardType = .default
                cell.payoutTF.tintColor =  UIColor(named: "Title_Header")
            }
        }
        return cell
    }
    
    @objc func dismissgenderPicker() {
        view.endEditing(true)
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            selectedTextfield = 0
            if !accountypeLabel.isEmpty
            {
                let index = account_typeArray.firstIndex(where: { (item) -> Bool in
                    item == accountypeLabel
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
            
        }
        pickerView.reloadAllComponents()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        selectedTextfield = textField.tag
        pickerView.reloadAllComponents()
        if selectedTextfield == 0
        {
            
            if !accountypeLabel.isEmpty
            {
                let index = account_typeArray.firstIndex(where: { (item) -> Bool in
                    item == accountypeLabel
                })
                pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
            
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(accountypeLabel == "" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")")
        {
            if(textField.tag == 3 && Utility.shared.selected_Countrycode_Payout == "CA")
            {
                if let text = textField.text, let textRange = Range(range, in: text) {
                    let updatedText = text.replacingCharacters(in: textRange, with: string)
                    if textField.text?.count == 5 && updatedText.count == 6 {
                        textField.text = textField.text! + "-" + string
                        return false
                    }
                    if textField.text?.count == 7 && updatedText.count == 6 {
                        let text = textField.text!
                        textField.text = String(text.prefix(3))
                        return false
                    }
                }
                return true
                
            }else{
                if(textField.text!.contains(".") && string == ".")
                {
                    return false
                }
                return true
            }
        }
        else{
            
            if(textField.tag == 2 && Utility.shared.selected_Countrycode_Payout == "CA")
            {
                if let text = textField.text, let textRange = Range(range, in: text) {
                    let updatedText = text.replacingCharacters(in: textRange, with: string)
                    if textField.text?.count == 5 && updatedText.count == 6 {
                        textField.text = textField.text! + "-" + string
                        return false
                    }
                    if textField.text?.count == 7 && updatedText.count == 6 {
                        let text = textField.text!
                        textField.text = String(text.prefix(3))
                        return false
                    }
                }
                return true
                
            }else{
                if(textField.text!.contains(".") && string == ".")
                {
                    return false
                }
                return true
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let textValue = textField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
        
        
        switch textField.tag {
        case 0:
            if(accountypeLabel == "" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")")
            {
                
                if accountypeLabelPrevious != "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")" {
                    accountypeLabelPrevious = accountypeLabel
                    accountypeLabel = "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")"
                    bankaccount_Dict.updateValue("individual", forKey: "accounttype")
                    bankaccountTable.reloadData()
                    
                }
                view.endEditing(true)
            }else{
                
                if accountypeLabelPrevious != "\(Utility.shared.getLanguage()?.value(forKey: "Company") ?? "Company")" {
                    accountypeLabelPrevious = accountypeLabel
                    bankaccount_Dict.updateValue("company", forKey: "accounttype")
                    bankaccountTable.reloadData()
                }
                view.endEditing(true)
            }
            break
        case 1:
            bankaccount_Dict.updateValue(textValue, forKey: "firstname")
            break
        case 2:
            if(accountypeLabel == "" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")")
            {
                bankaccount_Dict.updateValue(textValue, forKey: "lastname")
            }else{
                if Utility.shared.isRoutingNotNeeded(selectedCountry: Utility.shared.selected_Countrycode_Payout){
                    bankaccount_Dict.updateValue(textValue, forKey: "accnum")
                }else{
                    bankaccount_Dict.updateValue(textValue, forKey: "routingnum")
                }
            }
            
            break
        case 3:
            if(accountypeLabel == "" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")")
            {
                if Utility.shared.isRoutingNotNeeded(selectedCountry: Utility.shared.selected_Countrycode_Payout){
                    bankaccount_Dict.updateValue(textValue, forKey: "accnum")
                }else{
                    bankaccount_Dict.updateValue(textValue, forKey: "routingnum")
                }
            }else{
                if Utility.shared.isRoutingNotNeeded(selectedCountry: Utility.shared.selected_Countrycode_Payout){
                    bankaccount_Dict.updateValue(textValue, forKey: "confirmnum")
                }else{
                    bankaccount_Dict.updateValue(textValue, forKey: "accnum")
                }
            }
            break
        case 4:
            if(accountypeLabel == "" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")" || accountypeLabel == "\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")")
            {
                if Utility.shared.isRoutingNotNeeded(selectedCountry: Utility.shared.selected_Countrycode_Payout){
                    bankaccount_Dict.updateValue(textValue, forKey: "confirmnum")
                }else{
                    bankaccount_Dict.updateValue(textValue, forKey: "accnum")
                }
            }else{
                bankaccount_Dict.updateValue(textValue, forKey: "confirmnum")
            }
            break
        case 5:
            bankaccount_Dict.updateValue(textValue, forKey: "confirmnum")
            
            break
            
        default:
            break
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (selectedTextfield == 0)
        {
            return account_typeArray.count
            
        }
        return 0
    }
    
    func pickerView( _ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var titleData = ""
        
        if (selectedTextfield == 0)
        {
            if(account_typeArray.count > row)
            {
                titleData = account_typeArray[row]
            }
            
        }
        let myTitle = NSAttributedString(string: titleData , attributes: [NSAttributedString.Key.font:UIFont(name: APP_FONT, size: 15.0)!,NSAttributedString.Key.foregroundColor:Theme.PRIMARY_COLOR])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        
        if (selectedTextfield == 0)
        {
            accountypeLabel = account_typeArray[row]
            pickerView.selectRow(row, inComponent: component, animated: true)
            
        }
        
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
