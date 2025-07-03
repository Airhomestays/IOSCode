
import UIKit
import Apollo
import Lottie
import IQKeyboardManagerSwift
import Apollo

class BankDetailsVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
   // var completionHandlerGoToAddress:((Int)->())?
    var getSecPaymentResponse = GetSecPaymentQuery.Data.GetSecPayment.Result()
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet weak var btnNext: UIButton! {
        didSet {
            btnNext.isHidden = true
        }
    }
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var offlineView: UIView!
    var lottieWholeView = UIView()
    var lottieView =  LottieAnimationView()
    
    @IBOutlet weak var nextImage: UIImageView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var bankDetailsTable: UITableView!
   // var countryText = String()
    var payout_TF_Array = [String]()
    var tax_TF_Array = [String]()
    var inputPickerView = UIView()
    var pickerView = UIPickerView()
    var accountypeLabel = ""
    var account_typeArray = [String]()
    var selectedTextfield = Int()
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
      
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    @IBOutlet var lblHeader: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialsetup()
        self.setdropdown()
        self.fetchBankDetails()
    }
    
    func setdropdown()
    {
        inputPickerView.frame = CGRect(x: 0, y: FULLHEIGHT-200, width: FULLWIDTH, height: 200)
        pickerView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 200)
        inputPickerView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tintColor = Theme.PRIMARY_COLOR
        pickerView.backgroundColor = UIColor(named: "colorController")
        pickerView.reloadAllComponents()
    }
    
    func initialsetup() {
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.view.backgroundColor =   UIColor(named: "colorController")
        bankDetailsTable.register(UINib(nibName: "PayoutTextfieldCell", bundle: nil), forCellReuseIdentifier: "PayoutTextfieldCell")
        
      //  print("-----\("\((Utility.shared.getLanguage()?.value(forKey:"accountType"))!)")")
        
        payout_TF_Array = ["Account Type", "Account Holder Name", "Mobile Number", "Account Number", "Confirm Account Number", "IFSC Code"] //["\((Utility.shared.getLanguage()?.value(forKey:"accountType"))!)","\((Utility.shared.getLanguage()?.value(forKey:"accountHolderName"))!)","\((Utility.shared.getLanguage()?.value(forKey:"mobNumber"))!)","\((Utility.shared.getLanguage()?.value(forKey:"accountNumber"))!)","\((Utility.shared.getLanguage()?.value(forKey:"confirmAccountNumber"))!)","\((Utility.shared.getLanguage()?.value(forKey:"ifscCode"))!)"]
        
        tax_TF_Array = ["GST Number", "PAN Number"]
        //["\((Utility.shared.getLanguage()?.value(forKey:"gstNumber"))!)","\((Utility.shared.getLanguage()?.value(forKey:"panNumber"))!)"]
        
        self.account_typeArray = ["\(Utility.shared.getLanguage()?.value(forKey: "Individual") ?? "Individual")","\(Utility.shared.getLanguage()?.value(forKey: "Company") ?? "Company")"]
        accountypeLabel = account_typeArray.first!
        
        self.continueBtn.layer.cornerRadius = continueBtn.frame.size.height / 2
        self.continueBtn.layer.masksToBounds = true
        continueBtn.backgroundColor = Theme.Button_BG
        
        bankDetailsTable.rowHeight = UITableView.automaticDimension
        bankDetailsTable.estimatedRowHeight = 70
        self.offlineView.isHidden = true
        Utility.shared.bankDetails_Dict["accountType"] = ""
        Utility.shared.bankDetails_Dict["accountHolderName"] = ""
        Utility.shared.bankDetails_Dict["mobNumber"] = ""
        Utility.shared.bankDetails_Dict["accountNumber"] = ""
        Utility.shared.bankDetails_Dict["confirmAccountNumber"] = ""
        Utility.shared.bankDetails_Dict["ifscCode"] = ""
        Utility.shared.taxDetails_Dict["gstNumber"] = ""
        Utility.shared.taxDetails_Dict["panNumber"] = ""
        IQKeyboardManager.shared.enableAutoToolbar = false
        continueBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        lblHeader.text = "Bank Details" //"\((Utility.shared.getLanguage()?.value(forKey:"bank_Details"))!)"
        lblHeader.font = UIFont(name:APP_FONT_MEDIUM, size: 18)
        continueBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        lblHeader.textColor = UIColor(named: "Title_Header")
        
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        if(Utility.shared.isRTLLanguage()) {
            backBtn.imageView?.performRTLTransform()
            lblHeader.textAlignment = .right
        }
        bankDetailsTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
    }
    
    @IBAction func continuebtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            
            if((Utility.shared.bankDetails_Dict["accountType"]) == nil || ((Utility.shared.bankDetails_Dict["accountType"]as! String) == "")) {
                self.view.makeToast("Enter Account Type")
               // self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enteraAccountType"))!)")
            }
            else if((Utility.shared.bankDetails_Dict["accountHolderName"]) == nil || ((Utility.shared.bankDetails_Dict["accountHolderName"]as! String) == ""))
            {
                self.view.makeToast("Enter Account Name")
               // self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enteraccName"))!)")
            }
            else if((Utility.shared.bankDetails_Dict["mobNumber"]) == nil || ((Utility.shared.bankDetails_Dict["mobNumber"]as! String) == ""))
            {
                self.view.makeToast("Enter Mobile Number")
                //self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"entermobb"))!)")
            }
            else if((Utility.shared.bankDetails_Dict["accountNumber"]) == nil || ((Utility.shared.bankDetails_Dict["accountNumber"]as! String) == ""))
            {
                self.view.makeToast("Enter Account Number")
              //  self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enteracco"))!)")
            }
            else if((Utility.shared.bankDetails_Dict["confirmAccountNumber"]) == nil || ((Utility.shared.bankDetails_Dict["confirmAccountNumber"]as! String) == ""))
            {
                self.view.makeToast("Enter Account Confirm Number")
               // self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enterconacco"))!)")
            }
            else if (Utility.shared.bankDetails_Dict["accountNumber"]) as? String ?? "" != (Utility.shared.bankDetails_Dict["confirmAccountNumber"])  as? String ?? "" {
                self.view.makeToast("Account Number & Confirm Number donot match")
               // self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enterconaccoMatch"))!)")
            }
            else if((Utility.shared.bankDetails_Dict["ifscCode"]) == nil || ((Utility.shared.bankDetails_Dict["ifscCode"]as! String) == ""))
            {
                self.view.makeToast("Enter IFSC Codef")
                //self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enterifsc"))!)")
            }
            else {
                if getSecPaymentResponse.accountHolderName != nil && getSecPaymentResponse.accountHolderName != "" {
                    self.updateBankDetails()
                } else {
                    self.createBankDetails()
                }
            }
        } else {
            self.view.endEditing(true)
            self.continueBtn.isHidden = true
            self.offlineView.isHidden = false
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
    
    func fetchBankDetails() {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            
            var apollo_headerClient: ApolloClient = {
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
                let url = URL(string:graphQLEndpoint)!
                
                return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
            }()
            print("===\(Utility.shared.getCurrentUserID()! as String)")
            let getBankDetailsQuery = GetSecPaymentQuery(userId: Utility.shared.getCurrentUserID()! as String)
            apollo_headerClient.fetch(query:getBankDetailsQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
              
                guard (result?.data?.getSecPayment?.status) != nil else
                {
                    if result?.data?.getSecPayment?.status == "500"{
                        let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message: result?.data?.getSecPayment?.errorMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "\(Utility.shared.getLanguage()?.value(forKey: "okay") ?? "Okay")", style: .default, handler: { (action) in
                            UserDefaults.standard.removeObject(forKey: "user_token")
                            UserDefaults.standard.removeObject(forKey: "user_id")
                            UserDefaults.standard.removeObject(forKey: "password")
                            UserDefaults.standard.removeObject(forKey: "currency_rate")
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            let welcomeObj = WelcomePageVC()
                            appDelegate.setInitialViewController(initialView: welcomeObj)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }else{
                        self.view.makeToast(result?.data?.getSecPayment?.errorMessage!)
                    return
                    }
                }
                if result?.data?.getSecPayment?.result?.accountHolderName != nil || result?.data?.getSecPayment?.result?.accountHolderName != "" {
                    self.getSecPaymentResponse = result?.data?.getSecPayment?.result ?? (GetSecPaymentQuery.Data.GetSecPayment.Result())
//                    self.btnNext.isHidden = false
//                    self.btnNext.layer.cornerRadius = self.btnNext.frame.size.height / 2
//                    self.btnNext.layer.masksToBounds = true
//                    self.btnNext.backgroundColor = Theme.Button_BG
//                    self.btnNext.setTitle("Cont.", for: .normal) //("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for:.normal)
                    self.continueBtn.setTitle("Update", for: .normal)
//                    self.btnNext.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
                    
                    self.accountypeLabel = self.getSecPaymentResponse.accountType ?? ""
                    Utility.shared.bankDetails_Dict["accountType"] = self.getSecPaymentResponse.accountType ?? ""
                    Utility.shared.bankDetails_Dict["accountHolderName"] = self.getSecPaymentResponse.accountHolderName ?? ""
                    Utility.shared.bankDetails_Dict["mobNumber"] = self.getSecPaymentResponse.mobileNumber ?? ""
                    Utility.shared.bankDetails_Dict["accountNumber"] = self.getSecPaymentResponse.accountNumber ?? ""
                    Utility.shared.bankDetails_Dict["confirmAccountNumber"] = self.getSecPaymentResponse.confirmAccountNumber ?? ""
                    Utility.shared.bankDetails_Dict["ifscCode"] = self.getSecPaymentResponse.ifscCode ?? ""
                    Utility.shared.taxDetails_Dict["gstNumber"] = self.getSecPaymentResponse.gstNumber ?? ""
                    Utility.shared.taxDetails_Dict["panNumber"] = self.getSecPaymentResponse.panNumber ?? ""
                    
                    self.bankDetailsTable.reloadData()
                }
//                print("-->>>\((result?.data?.getSecPayment?.result)!)")
            }
            
        } else {
            self.view.endEditing(true)
            self.continueBtn.isHidden = true
            self.offlineView.isHidden = false
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
    
    
    func updateBankDetails() {
        let updateSecPaymentMutation = UpdateSecPaymentMutation(userId: ("\(Utility.shared.getCurrentUserID()! as String)"),
                                                                country: (Utility.shared.payout_Address_Dict["country"]) as? String,
                                                                address1: (Utility.shared.payout_Address_Dict["address1"]) as? String,
                                                                address2: (Utility.shared.payout_Address_Dict["address2"]) as? String,
                                                                city: (Utility.shared.payout_Address_Dict["city"]) as? String,
                                                                state: (Utility.shared.payout_Address_Dict["state"]) as? String,
                                                                zipcode: (Utility.shared.payout_Address_Dict["zipcode"]) as? String,
                                                                accountNumber: (Utility.shared.bankDetails_Dict["accountNumber"]) as? String,
                                                                confirmAccountNumber: Utility.shared.bankDetails_Dict["confirmAccountNumber"] as? String,
                                                                ifscCode: Utility.shared.bankDetails_Dict["ifscCode"] as? String,
                                                                accountHolderName: Utility.shared.bankDetails_Dict["accountHolderName"] as? String,
                                                                gstNumber: Utility.shared.taxDetails_Dict["gstNumber"] as? String,
                                                                panNumber: Utility.shared.taxDetails_Dict["panNumber"] as? String,
                                                                mobileNumber: Utility.shared.bankDetails_Dict["mobNumber"] as? String,
                                                                accountType: self.accountypeLabel)
        
        apollo_headerClient.perform(mutation: updateSecPaymentMutation) { (result, error) in
//            if let error = error {
//                print("GraphQL Error: \(error.localizedDescription)")
//                self.view.makeToast("An error occurred: \(error.localizedDescription)")
//                return
//            }
            
            if let response = result?.data?.updateSecPayment {
                print("Response: \(response)")
                
                if response.status == "200" || response.status == "success" {
                    print("--->>Update Done")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("PayoutDetailsUpdate"), object: nil)

                        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

//                        self.completionHandlerGoToAddress?(1)
//                        self.dismiss(animated: true)
                    }
                    
                    
                } else {
                    let errorMessage = response.errorMessage ?? "An unknown error occurred."
                    self.view.makeToast(errorMessage)
                }
            } else {
                self.view.makeToast("No data returned from server.")
            }
        }
    }

    func createBankDetails() {
        let bankDetailMutation = CreateBankDetailsMutation(userId: Utility.shared.getCurrentUserID()! as String, 
                                                           country: (Utility.shared.payout_Address_Dict["country"]) as? String ?? "",
                                                           address1: (Utility.shared.payout_Address_Dict["address1"]) as? String ?? "",
                                                           address2: (Utility.shared.payout_Address_Dict["address2"]) as? String ?? "",
                                                           city: (Utility.shared.payout_Address_Dict["city"]) as? String ?? "",
                                                           state: (Utility.shared.payout_Address_Dict["state"]) as? String ?? "",
                                                           zipcode: (Utility.shared.payout_Address_Dict["zipcode"]) as? String ?? "",
                                                           accountType: self.accountypeLabel,
                                                           mobileNumber: Utility.shared.bankDetails_Dict["mobNumber"] as? String ?? "",
                                                           accountHolderName: Utility.shared.bankDetails_Dict["accountHolderName"] as? String ?? "",
                                                           accountNumber: (Utility.shared.bankDetails_Dict["accountNumber"]) as? String ?? "",
                                                           confirmAccountNumber: Utility.shared.bankDetails_Dict["confirmAccountNumber"] as? String ?? "",
                                                           ifscCode: Utility.shared.bankDetails_Dict["ifscCode"] as? String ?? "",
                                                           gstNumber: Utility.shared.taxDetails_Dict["gstNumber"] as? String ?? "",
                                                           panNumber: Utility.shared.taxDetails_Dict["panNumber"] as? String ?? "")
        
        apollo_headerClient.perform(mutation: bankDetailMutation){ (result,error) in
            self.lottieWholeView.isHidden = true
            self.lottieView.isHidden = true
            if(result?.data?.createbankDetails?.status == 400)
            {
                self.lottieWholeView.isHidden = true
                self.lottieView.isHidden = true
                self.view.makeToast(result?.data?.createbankDetails?.errorMessage!)
                return
            }else if result?.data?.createbankDetails?.status == 500{
                self.lottieWholeView.isHidden = true
                self.lottieView.isHidden = true
                let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message: result?.data?.createbankDetails?.errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "\(Utility.shared.getLanguage()?.value(forKey: "okay") ?? "Okay")", style: .default, handler: { (action) in
                    UserDefaults.standard.removeObject(forKey: "user_token")
                    UserDefaults.standard.removeObject(forKey: "user_id")
                    UserDefaults.standard.removeObject(forKey: "password")
                    UserDefaults.standard.removeObject(forKey: "currency_rate")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let welcomeObj = WelcomePageVC()
                    appDelegate.setInitialViewController(initialView: welcomeObj)
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }else{
                DispatchQueue.main.async {
                self.lottieWholeView.isHidden = true
                self.lottieView.isHidden = true
                print("Success....")
                
                    NotificationCenter.default.post(name: Notification.Name("PayoutDetailsUpdate"), object: nil)

                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

//                        self.completionHandlerGoToAddress?(1)
//                        self.dismiss(animated: true)
                }
                
            }
        }
    }
    
    func lottiewholeAnimation() {
        self.lottieView.isHidden = false
        self.lottieWholeView.isHidden = false
        lottieView = LottieAnimationView.init(name: "loading_qwe")
        self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(lottieWholeView)
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-50, y: FULLHEIGHT/2-50, width: 100, height: 100)
        self.lottieWholeView.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor(named: "lottie-bg")
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscrolling), userInfo: nil, repeats: true)
    }
    
    @objc func autoscrolling() {
        self.lottieView.play()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.continueBtn.isHidden = false
            self.offlineView.isHidden = true
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let headerTitle = UILabel(frame: CGRect(x: 20, y: 10, width: tableView.frame.size.width-40, height: 20))
        headerTitle.text = section == 0 ? "\(Utility.shared.getLanguage()?.value(forKey: "bank_Details") ?? "Bank Details")" : "\(Utility.shared.getLanguage()?.value(forKey: "taxDetails") ?? "Tax Details")"
        headerTitle.font = UIFont(name: APP_FONT, size: 16)
        headerTitle.textColor =  UIColor(named: "Title_Header")
        headerTitle.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        headerView.backgroundColor = .white
        headerView.addSubview(headerTitle)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (payout_TF_Array.count) : (self.tax_TF_Array.count)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayoutTextfieldCell", for: indexPath)as! PayoutTextfieldCell
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            cell.payoutTF.tag = indexPath.row
            cell.payoutTF.placeholder = payout_TF_Array[indexPath.row]
        } else {
            cell.payoutTF.tag = indexPath.row + 100
            cell.payoutTF.placeholder = tax_TF_Array[indexPath.row]
        }
        
        cell.payoutTF.autocorrectionType = UITextAutocorrectionType.no
        cell.payoutTF.delegate = self
        
        cell.payoutTF.tintColor = UIColor(named: "Title_Header")
       // cell.payoutTF.tag = indexPath.row
        
        let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
        cell.payoutTF.inputAccessoryView = toolBar
        toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
        cell.imgDownArrow.isHidden = true
        //cell.payoutTF.isUserInteractionEnabled = true
        cell.payoutTF.inputView = nil
        cell.payoutTF.reloadInputViews()
        
        if indexPath.section == 0{
            cell.payoutTF.attributedPlaceholder =  NSAttributedString(string:payout_TF_Array[indexPath.row],
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            if(indexPath.row == 0)
            {
                cell.payoutTF.inputView = pickerView
               // cell.payoutTF.delegate = self
                cell.imgDownArrow.isHidden = false
                //cell.payoutTF.isUserInteractionEnabled = false
                cell.lblHeader.text = "Account Type"//"\((Utility.shared.getLanguage()?.value(forKey:"accountType"))!)"
                
                cell.payoutTF.text = accountypeLabel
                cell.payoutTF.attributedPlaceholder = NSAttributedString(string: accountypeLabel,
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header") ?? "Title_Header"])
                
            } else if(indexPath.row == 1) {
                cell.lblHeader.text = "Account Holder Name"//"\((Utility.shared.getLanguage()?.value(forKey:"accountHolderName"))!)"
                cell.payoutTF.text = Utility.shared.bankDetails_Dict["accountHolderName"] as? String
            } else if(indexPath.row == 2) {
                cell.lblHeader.text = "Mobile Number"//"\((Utility.shared.getLanguage()?.value(forKey:"mobNumber"))!)"
                cell.payoutTF.text = Utility.shared.bankDetails_Dict["mobNumber"] as? String
            } else if(indexPath.row == 3) {
                cell.lblHeader.text = "Account Number"//"\((Utility.shared.getLanguage()?.value(forKey:"accountNumber"))!)"
                cell.payoutTF.text = Utility.shared.bankDetails_Dict["accountNumber"] as? String
            } else if(indexPath.row == 4) {
                cell.lblHeader.text = "Confirm Account Number"//"\((Utility.shared.getLanguage()?.value(forKey:"confirmAccountNumber"))!)"
                cell.payoutTF.text = Utility.shared.bankDetails_Dict["confirmAccountNumber"] as? String
            } else if(indexPath.row == 5) {
                cell.lblHeader.text = "IFSC Code"//"\((Utility.shared.getLanguage()?.value(forKey:"ifscCode"))!)"
                cell.payoutTF.text = Utility.shared.bankDetails_Dict["ifscCode"] as? String
            }
        } else {
            cell.payoutTF.attributedPlaceholder =  NSAttributedString(string:tax_TF_Array[indexPath.row],
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            if(indexPath.row == 0)
            {
                cell.lblHeader.text = "GST Number"//"\((Utility.shared.getLanguage()?.value(forKey:"gstNumber"))!)"
                cell.payoutTF.text = Utility.shared.taxDetails_Dict["gstNumber"] as? String
            } else if(indexPath.row == 1) {
                cell.lblHeader.text = "PAN Number"//"\((Utility.shared.getLanguage()?.value(forKey:"panNumber"))!)"
                cell.payoutTF.text = Utility.shared.taxDetails_Dict["panNumber"] as? String
            }
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            if indexPath.row == 0 {
//                selectedTextfield = 0
//                if !accountypeLabel.isEmpty
//                {
//                    let index = account_typeArray.firstIndex(where: { (item) -> Bool in
//                        item == accountypeLabel
//                    })
//                    pickerView.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
//                }
//                pickerView.reloadAllComponents()
//            }
//            
//        }
//    }
    @objc func dismissgenderPicker() {
        view.endEditing(true)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextfield = textField.tag
        if textField.tag == 0 {
            pickerView.reloadAllComponents()
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
        if(textField.text!.contains(".") && string == ".")
        {
            return false
        }
        return true
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        
        //  self.GoBtn.frame.origin.y -= keyboardFrame.height
        self.continueBtn.frame.origin.y = keyboardFrame.origin.y - 60
        self.nextImage.frame.origin.y = keyboardFrame.origin.y - 45
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.continueBtn.frame.origin.y = FULLHEIGHT - 70
        self.nextImage.frame.origin.y = FULLHEIGHT - 55
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let textvalue = textField.text!.trimmingCharacters(in: .whitespaces)
        if(textField.tag == 0)
        {
            selectedTextfield = textField.tag
            let cell = self.bankDetailsTable.cellForRow(at: IndexPath(row: 0, section: 0)) as! PayoutTextfieldCell
            cell.payoutTF.text = self.accountypeLabel
//            self.bankDetailsTable.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .none)
           // Utility.shared.bankDetails_Dict.updateValue(countryText, forKey: "accountType")
        }
        if(textField.tag == 1)
        {
            Utility.shared.bankDetails_Dict.updateValue(textvalue, forKey: "accountHolderName")
        } else if(textField.tag == 2) {
            Utility.shared.bankDetails_Dict.updateValue(textvalue, forKey: "mobNumber")
            
        } else if(textField.tag == 3) {
            Utility.shared.bankDetails_Dict.updateValue(textvalue, forKey: "accountNumber")
            
        } else if(textField.tag == 4) {
            Utility.shared.bankDetails_Dict.updateValue(textvalue, forKey: "confirmAccountNumber")
            
        } else if(textField.tag == 5) {
            Utility.shared.bankDetails_Dict.updateValue(textvalue, forKey: "ifscCode")
            
        }
        else if(textField.tag == 100) {
           Utility.shared.taxDetails_Dict.updateValue(textvalue, forKey: "gstNumber")
           
       }
        else if(textField.tag == 101) {
           Utility.shared.taxDetails_Dict.updateValue(textvalue, forKey: "panNumber")
           
       }
        view.endEditing(true)
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
            Utility.shared.bankDetails_Dict.updateValue(account_typeArray[row], forKey: "accountType")
            pickerView.selectRow(row, inComponent: component, animated: true)
            
        }
        
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
}


public final class CreateBankDetailsMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation createSecPayment($userId: String!, $country: String!, $address1: String, $address2: String, $city: String!, $state: String!, $zipcode: String!, $accountType: String!, $mobileNumber: String!, $accountHolderName: String!, $accountNumber: String!, $confirmAccountNumber: String!, $ifscCode: String!, $gstNumber: String!, $panNumber: String!) {\n  createSecPayment(userId: $userId, country: $country, address1: $address1, address2: $address2, city: $city, state: $state, zipcode: $zipcode, accountType: $accountType, mobileNumber: $mobileNumber, accountHolderName: $accountHolderName, accountNumber: $accountNumber, confirmAccountNumber: $confirmAccountNumber, ifscCode: $ifscCode, gstNumber: $gstNumber, panNumber: $panNumber) {\n    status\n    errorMessage\n    __typename\n  }\n}"

  public var userId: String
    public var country: String
    public var address1: String
    public var address2: String
    public var city: String
    public var state: String
    public var zipcode: String
    public var accountType: String
    public var mobileNumber: String
    public var accountHolderName: String
    public var accountNumber: String
    public var confirmAccountNumber: String
    public var ifscCode: String
    public var gstNumber: String?
    public var panNumber: String?
    
  public init(userId: String, country: String, address1: String, address2: String, city: String, state: String, zipcode: String, accountType: String, mobileNumber: String, accountHolderName: String, accountNumber: String, confirmAccountNumber: String, ifscCode: String, gstNumber: String? = nil, panNumber: String? = nil) {
    self.userId = userId
      self.country = country
      self.address1 = address1
      self.address2 = address2
      self.city = city
      self.state = state
      self.zipcode = zipcode
      self.accountType = accountType
      self.mobileNumber = mobileNumber
      self.accountHolderName = accountHolderName
      self.accountNumber = accountNumber
      self.confirmAccountNumber = confirmAccountNumber
      self.ifscCode = ifscCode
      self.gstNumber = gstNumber
      self.panNumber = panNumber
      
  }

  public var variables: GraphQLMap? {
    return ["userId": userId, "country": country, "address1": address1, "address2": address2, "city": city, "state": state, "zipcode": zipcode, "accountType": accountType, "mobileNumber": mobileNumber, "accountHolderName": accountHolderName, "accountNumber": accountNumber, "confirmAccountNumber": confirmAccountNumber, "ifscCode": ifscCode, "gstNumber": gstNumber, "panNumber": panNumber]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createSecPayment", arguments: ["userId": GraphQLVariable("userId"), "country": GraphQLVariable("country"), "address1": GraphQLVariable("address1"), "address2": GraphQLVariable("address2"), "city": GraphQLVariable("city"), "state": GraphQLVariable("state"), "zipcode": GraphQLVariable("zipcode"), "accountType": GraphQLVariable("accountType"), "mobileNumber": GraphQLVariable("mobileNumber"), "accountHolderName": GraphQLVariable("accountHolderName"), "accountNumber": GraphQLVariable("accountNumber"), "confirmAccountNumber": GraphQLVariable("confirmAccountNumber"), "ifscCode": GraphQLVariable("ifscCode"), "gstNumber": GraphQLVariable("gstNumber"), "panNumber": GraphQLVariable("panNumber")], type: .object(CreatebankDetails.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createbankDetails: CreatebankDetails? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createSecPayment": createbankDetails.flatMap { (value: CreatebankDetails) -> ResultMap in value.resultMap }])
    }

    public var createbankDetails: CreatebankDetails? {
      get {
        return (resultMap["createSecPayment"] as? ResultMap).flatMap { CreatebankDetails(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createSecPayment")
      }
    }

    public struct CreatebankDetails: GraphQLSelectionSet {
      public static let possibleTypes = ["SecPayment"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("status", type: .scalar(Int.self)),
        GraphQLField("errorMessage", type: .scalar(String.self))
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init( status: Int? = nil, errorMessage: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "SecPayment",  "status": status, "errorMessage": errorMessage])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

//      public var results: Result? {
//        get {
//          return (resultMap["results"] as? ResultMap).flatMap { Result(unsafeResultMap: $0) }
//        }
//        set {
//          resultMap.updateValue(newValue?.resultMap, forKey: "results")
//        }
//      }

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

//      public var requireAdditionalAction: Bool? {
//        get {
//          return resultMap["requireAdditionalAction"] as? Bool
//        }
//        set {
//          resultMap.updateValue(newValue, forKey: "requireAdditionalAction")
//        }
//      }
//
//      public var paymentIntentSecret: String? {
//        get {
//          return resultMap["paymentIntentSecret"] as? String
//        }
//        set {
//          resultMap.updateValue(newValue, forKey: "paymentIntentSecret")
//        }
//      }
//
//      public var reservationId: Int? {
//        get {
//          return resultMap["reservationId"] as? Int
//        }
//        set {
//          resultMap.updateValue(newValue, forKey: "reservationId")
//        }
//      }
//
//      public var redirectUrl: String? {
//        get {
//          return resultMap["redirectUrl"] as? String
//        }
//        set {
//          resultMap.updateValue(newValue, forKey: "redirectUrl")
//        }
//      }

      public struct Result: GraphQLSelectionSet {
        public static let possibleTypes = ["Reservation"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
//          GraphQLField("id", type: .scalar(Int.self)),
//          GraphQLField("listId", type: .scalar(Int.self)),
//          GraphQLField("hostId", type: .scalar(String.self)),
//          GraphQLField("guestId", type: .scalar(String.self)),
//          GraphQLField("checkIn", type: .scalar(String.self)),
//          GraphQLField("checkOut", type: .scalar(String.self)),
//          GraphQLField("guests", type: .scalar(Int.self)),
//          GraphQLField("message", type: .scalar(String.self)),
//          GraphQLField("basePrice", type: .scalar(Double.self)),
//          GraphQLField("cleaningPrice", type: .scalar(Double.self)),
//          GraphQLField("currency", type: .scalar(String.self)),
//          GraphQLField("discount", type: .scalar(Double.self)),
//          GraphQLField("discountType", type: .scalar(String.self)),
//          GraphQLField("guestServiceFee", type: .scalar(Double.self)),
//          GraphQLField("hostServiceFee", type: .scalar(Double.self)),
//          GraphQLField("total", type: .scalar(Double.self)),
//          GraphQLField("confirmationCode", type: .scalar(Int.self)),
//          GraphQLField("createdAt", type: .scalar(String.self)),
//          GraphQLField("reservationState", type: .scalar(String.self)),
//          GraphQLField("paymentState", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init() {
          self.init(unsafeResultMap: ["__typename": "Payment"])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

//        public var id: Int? {
//          get {
//            return resultMap["id"] as? Int
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "id")
//          }
//        }
//
//        public var listId: Int? {
//          get {
//            return resultMap["listId"] as? Int
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "listId")
//          }
//        }
//
//        public var hostId: String? {
//          get {
//            return resultMap["hostId"] as? String
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "hostId")
//          }
//        }
//
//        public var guestId: String? {
//          get {
//            return resultMap["guestId"] as? String
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "guestId")
//          }
//        }
//
//        public var checkIn: String? {
//          get {
//            return resultMap["checkIn"] as? String
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "checkIn")
//          }
//        }
//
//        public var checkOut: String? {
//          get {
//            return resultMap["checkOut"] as? String
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "checkOut")
//          }
//        }
//
//        public var guests: Int? {
//          get {
//            return resultMap["guests"] as? Int
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "guests")
//          }
//        }
//
//        public var message: String? {
//          get {
//            return resultMap["message"] as? String
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "message")
//          }
//        }
//
//        public var basePrice: Double? {
//          get {
//            return resultMap["basePrice"] as? Double
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "basePrice")
//          }
//        }
//
//        public var cleaningPrice: Double? {
//          get {
//            return resultMap["cleaningPrice"] as? Double
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "cleaningPrice")
//          }
//        }
//
//        public var currency: String? {
//          get {
//            return resultMap["currency"] as? String
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "currency")
//          }
//        }
//
//        public var discount: Double? {
//          get {
//            return resultMap["discount"] as? Double
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "discount")
//          }
//        }
//
//        public var discountType: String? {
//          get {
//            return resultMap["discountType"] as? String
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "discountType")
//          }
//        }
//
//        public var guestServiceFee: Double? {
//          get {
//            return resultMap["guestServiceFee"] as? Double
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "guestServiceFee")
//          }
//        }
//
//        public var hostServiceFee: Double? {
//          get {
//            return resultMap["hostServiceFee"] as? Double
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "hostServiceFee")
//          }
//        }
//
//        public var total: Double? {
//          get {
//            return resultMap["total"] as? Double
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "total")
//          }
//        }
//
//        public var confirmationCode: Int? {
//          get {
//            return resultMap["confirmationCode"] as? Int
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "confirmationCode")
//          }
//        }
//
//        public var createdAt: String? {
//          get {
//            return resultMap["createdAt"] as? String
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "createdAt")
//          }
//        }
//
//        public var reservationState: String? {
//          get {
//            return resultMap["reservationState"] as? String
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "reservationState")
//          }
//        }

//        public var paymentState: String? {
//          get {
//            return resultMap["paymentState"] as? String
//          }
//          set {
//            resultMap.updateValue(newValue, forKey: "paymentState")
//          }
//        }
      }
    }
  }
}


public final class GetBankDetailsQueryy: GraphQLQuery {
    public let operationDefinition =
        """
        query getSecPayment($userId: String) {
          getSecPayment(userId: $userId) {
            __typename
            status
            errorMessage
            result {
              __typename
              id
              userId
              address1
              address2
              city
              zipcode
              state
              country
              accountType
              accountNumber
              confirmAccountNumber
              ifscCode
              accountHolderName
              gstNumber
              panNumber
              mobileNumber
              createdAt
            }
          }
        }
        """
    
    public var userId: String?
    
    public init(userId: String? = nil) {
        self.userId = userId
    }
    
    public var variables: GraphQLMap? {
        return ["userId": userId]
    }
    
    public struct Data: GraphQLSelectionSet {
        public static let possibleTypes = ["Query"]
        
        public static let selections: [GraphQLSelection] = [
            GraphQLField("getSecPayment", arguments: ["userId": GraphQLVariable("userId")], type: .object(UserBankDetails.selections)),
        ]
        
        public private(set) var resultMap: ResultMap
        
        public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
        }
        
        public init(userBankDetails: UserBankDetails? = nil) {
            self.init(unsafeResultMap: ["__typename": "Query", "getSecPayment": userBankDetails.flatMap { (value: UserBankDetails) -> ResultMap in value.resultMap }])
        }
        
        public var userBankDetails: UserBankDetails? {
            get {
                return (resultMap["getSecPayment"] as? ResultMap).flatMap { UserBankDetails(unsafeResultMap: $0) }
            }
            set {
                resultMap.updateValue(newValue?.resultMap, forKey: "getSecPayment")
            }
        }
        
        public struct UserBankDetails: GraphQLSelectionSet {
            public static let possibleTypes = ["BankDetails"]
            
            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("result", type: .object(Result.selections)),
                GraphQLField("status", type: .scalar(Int.self)),  // Updated to String
                GraphQLField("errorMessage", type: .scalar(String.self)),
            ]
            
            public private(set) var resultMap: ResultMap
            
            public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
            }
            
            public init(result: Result? = nil, status: Int? = nil, errorMessage: String? = nil) { // Updated to String
                self.init(unsafeResultMap: ["__typename": "BankDetails", "result": result.flatMap { (value: Result) -> ResultMap in value.resultMap }, "status": status, "errorMessage": errorMessage])
            }
            
            public var __typename: String {
                get {
                    return resultMap["__typename"]! as! String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                }
            }
            
            public var result: Result? {
                get {
                    return (resultMap["result"] as? ResultMap).flatMap { Result(unsafeResultMap: $0) }
                }
                set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "result")
                }
            }
            
            public var status: Int? {  // Updated to String
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
            
            public struct Result: GraphQLSelectionSet {
                public static let possibleTypes = ["BankDetails"]
                
                public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("id", type: .scalar(Int.self)),
                    GraphQLField("userId", type: .scalar(String.self)),
                    GraphQLField("address1", type: .scalar(String.self)),
                    GraphQLField("address2", type: .scalar(String.self)),
                    GraphQLField("city", type: .scalar(String.self)),
                    GraphQLField("zipcode", type: .scalar(String.self)),
                    GraphQLField("state", type: .scalar(String.self)),
                    GraphQLField("country", type: .scalar(String.self)),
                    GraphQLField("accountType", type: .scalar(String.self)),
                    GraphQLField("accountNumber", type: .scalar(String.self)),
                    GraphQLField("confirmAccountNumber", type: .scalar(String.self)),
                    GraphQLField("ifscCode", type: .scalar(String.self)),
                    GraphQLField("accountHolderName", type: .scalar(String.self)),
                    GraphQLField("gstNumber", type: .scalar(String.self)),
                    GraphQLField("panNumber", type: .scalar(String.self)),
                    GraphQLField("mobileNumber", type: .scalar(String.self)),  // Added mobileNumber
                    GraphQLField("createdAt", type: .scalar(String.self)),
                ]
                
                public private(set) var resultMap: ResultMap
                
                public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                }
                
                public init(userId: String? = nil, id: Int? = nil, address1: String? = nil, address2: String? = nil, city: String? = nil, zipcode: String? = nil, state: String? = nil, country: String? = nil, accountType: String? = nil, accountNumber: String? = nil, confirmAccountNumber: String? = nil, ifscCode: String? = nil, accountHolderName: String? = nil, gstNumber: String? = nil, panNumber: String? = nil, mobileNumber: String? = nil, createdAt: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "BankDetails", "id": id, "userId": userId, "address1": address1, "address2": address2, "city": city, "zipcode": zipcode, "state": state, "country": country, "accountType": accountType, "accountNumber": accountNumber, "confirmAccountNumber": confirmAccountNumber, "ifscCode": ifscCode, "accountHolderName": accountHolderName, "gstNumber": gstNumber, "panNumber": panNumber, "mobileNumber": mobileNumber, "createdAt": createdAt])
                }
                
                public var __typename: String {
                    get {
                        return resultMap["__typename"]! as! String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                    }
                }
                
                public var userId: String? {
                    get {
                        return resultMap["userId"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "userId")
                    }
                }
                
                public var profileId: Int? {
                    get {
                        return resultMap["id"] as? Int
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "id")
                    }
                }
                
                public var address1: String? {
                    get {
                        return resultMap["address1"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "address1")
                    }
                }
                
                public var address2: String? {
                    get {
                        return resultMap["address2"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "address2")
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
                
                public var zipcode: String? {
                    get {
                        return resultMap["zipcode"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "zipcode")
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
                
                public var country: String? {
                    get {
                        return resultMap["country"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "country")
                    }
                }
                
                public var accountType: String? {
                    get {
                        return resultMap["accountType"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "accountType")
                    }
                }
                
//                confirmAccountNumber
//                ifscCode
//                accountHolderName
//                gstNumber
//                panNumber
//                mobileNumber
//                createdAt
                
                
                public var accountNumber: String? {
                    get {
                        return resultMap["accountNumber"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "accountNumber")
                    }
                }
                
                public var confirmAccountNumber: String? {
                    get { resultMap["confirmAccountNumber"] as? String }
                    set { resultMap.updateValue(newValue, forKey: "confirmAccountNumber") }
                }

                public var ifscCode: String? {
                    get { resultMap["ifscCode"] as? String }
                    set { resultMap.updateValue(newValue, forKey: "ifscCode") }
                }

                public var accountHolderName: String? {
                    get { resultMap["accountHolderName"] as? String }
                    set { resultMap.updateValue(newValue, forKey: "accountHolderName") }
                }

                public var gstNumber: String? {
                    get { resultMap["gstNumber"] as? String }
                    set { resultMap.updateValue(newValue, forKey: "gstNumber") }
                }

                public var panNumber: String? {
                    get { resultMap["panNumber"] as? String }
                    set { resultMap.updateValue(newValue, forKey: "panNumber") }
                }

                public var mobileNumber: String? {
                    get { resultMap["mobileNumber"] as? String }
                    set { resultMap.updateValue(newValue, forKey: "mobileNumber") }
                }

                public var createdAt: String? {
                    get { resultMap["createdAt"] as? String }
                    set { resultMap.updateValue(newValue, forKey: "createdAt") }
                }
            }
        }
    }
}


public final class GetSecPaymentQuery: GraphQLQuery {
    public let operationDefinition =
    """
    query getSecPayment($userId: String!) {
      getSecPayment(userId: $userId) {
        status
        errorMessage
        result {
          id
          userId
          address1
          address2
          city
          zipcode
          state
          country
          accountType
          accountNumber
          confirmAccountNumber
          ifscCode
          accountHolderName
          gstNumber
          panNumber
          mobileNumber
          createdAt
        }
      }
    }
    """
    
    public var userId: String
    
    public init(userId: String) {
        self.userId = userId
    }
    
    public var variables: GraphQLMap? {
        return ["userId": userId]
    }
    
    public struct Data: GraphQLSelectionSet {
        public static let possibleTypes = ["Query"]
        
        public static let selections: [GraphQLSelection] = [
            GraphQLField("getSecPayment", arguments: ["userId": GraphQLVariable("userId")], type: .object(GetSecPayment.selections)),
        ]
        
        public private(set) var resultMap: ResultMap
        
        public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
        }
        
        public init(getSecPayment: GetSecPayment? = nil) {
            self.init(unsafeResultMap: ["__typename": "Query", "getSecPayment": getSecPayment.flatMap { (value: GetSecPayment) -> ResultMap in value.resultMap }])
        }
        
        public var getSecPayment: GetSecPayment? {
            get {
                return (resultMap["getSecPayment"] as? ResultMap).flatMap { GetSecPayment(unsafeResultMap: $0) }
            }
            set {
                resultMap.updateValue(newValue?.resultMap, forKey: "getSecPayment")
            }
        }
        
        public struct GetSecPayment: GraphQLSelectionSet {
            public static let possibleTypes = ["SecPayment"]
            
            public static let selections: [GraphQLSelection] = [
                GraphQLField("status", type: .scalar(String.self)),
                GraphQLField("errorMessage", type: .scalar(String.self)),
                GraphQLField("result", type: .object(Result.selections)),
            ]
            
            public private(set) var resultMap: ResultMap
            
            public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
            }
            
            public init(status: String? = nil, errorMessage: String? = nil, result: Result? = nil) {
                self.init(unsafeResultMap: ["status": status, "errorMessage": errorMessage, "result": result.flatMap { (value: Result) -> ResultMap in value.resultMap }])
            }
            
            public var status: String? {
                get {
                    return resultMap["status"] as? String
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
            
            public var result: Result? {
                get {
                    return (resultMap["result"] as? ResultMap).flatMap { Result(unsafeResultMap: $0) }
                }
                set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "result")
                }
            }
            
            public struct Result: GraphQLSelectionSet {
                public static let possibleTypes = ["SecPaymentResult"]
                
                public static let selections: [GraphQLSelection] = [
                    GraphQLField("id", type: .scalar(Int.self)),
                    GraphQLField("userId", type: .scalar(String.self)),
                    GraphQLField("address1", type: .scalar(String.self)),
                    GraphQLField("address2", type: .scalar(String.self)),
                    GraphQLField("city", type: .scalar(String.self)),
                    GraphQLField("zipcode", type: .scalar(String.self)),
                    GraphQLField("state", type: .scalar(String.self)),
                    GraphQLField("country", type: .scalar(String.self)),
                    GraphQLField("accountType", type: .scalar(String.self)),
                    GraphQLField("accountNumber", type: .scalar(String.self)),
                    GraphQLField("confirmAccountNumber", type: .scalar(String.self)),
                    GraphQLField("ifscCode", type: .scalar(String.self)),
                    GraphQLField("accountHolderName", type: .scalar(String.self)),
                    GraphQLField("gstNumber", type: .scalar(String.self)),
                    GraphQLField("panNumber", type: .scalar(String.self)),
                    GraphQLField("mobileNumber", type: .scalar(String.self)),
                    GraphQLField("createdAt", type: .scalar(String.self)),
                ]
                
                public private(set) var resultMap: ResultMap
                
                public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                }
                
                public init(id: Int? = nil, userId: String? = nil, address1: String? = nil, address2: String? = nil, city: String? = nil, zipcode: String? = nil, state: String? = nil, country: String? = nil, accountType: String? = nil, accountNumber: String? = nil, confirmAccountNumber: String? = nil, ifscCode: String? = nil, accountHolderName: String? = nil, gstNumber: String? = nil, panNumber: String? = nil, mobileNumber: String? = nil, createdAt: String? = nil) {
                    self.init(unsafeResultMap: ["id": id, "userId": userId, "address1": address1, "address2": address2, "city": city, "zipcode": zipcode, "state": state, "country": country, "accountType": accountType, "accountNumber": accountNumber, "confirmAccountNumber": confirmAccountNumber, "ifscCode": ifscCode, "accountHolderName": accountHolderName, "gstNumber": gstNumber, "panNumber": panNumber, "mobileNumber": mobileNumber, "createdAt": createdAt])
                }
                
                public var id: Int? {
                    get {
                        return resultMap["id"] as? Int
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "id")
                    }
                }
                
                public var userId: String? {
                    get {
                        return resultMap["userId"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "userId")
                    }
                }
                
                public var address1: String? {
                    get {
                        return resultMap["address1"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "address1")
                    }
                }
                
                public var address2: String? {
                    get {
                        return resultMap["address2"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "address2")
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
                
                public var zipcode: String? {
                    get {
                        return resultMap["zipcode"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "zipcode")
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
                
                public var country: String? {
                    get {
                        return resultMap["country"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "country")
                    }
                }
                
                public var accountType: String? {
                    get {
                        return resultMap["accountType"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "accountType")
                    }
                }
                
                public var accountNumber: String? {
                    get {
                        return resultMap["accountNumber"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "accountNumber")
                    }
                }
                
                public var confirmAccountNumber: String? {
                    get {
                        return resultMap["confirmAccountNumber"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "confirmAccountNumber")
                    }
                }
                
                public var ifscCode: String? {
                    get {
                        return resultMap["ifscCode"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "ifscCode")
                    }
                }
                
                public var accountHolderName: String? {
                    get {
                        return resultMap["accountHolderName"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "accountHolderName")
                    }
                }
                
                public var gstNumber: String? {
                    get {
                        return resultMap["gstNumber"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "gstNumber")
                    }
                }

                public var panNumber: String? {
                    get {
                        return resultMap["panNumber"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "panNumber")
                    }
                }

                public var mobileNumber: String? {
                    get {
                        return resultMap["mobileNumber"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "mobileNumber")
                    }
                }

                public var createdAt: String? {
                    get {
                        return resultMap["createdAt"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "createdAt")
                    }
                }

            }
        }
    }
}

public final class UpdateSecPaymentMutation: GraphQLMutation {
    public let operationDefinition =
    """
        mutation updateSecPayment($userId: String!, $country: String, $address1: String, $address2: String, $city: String, $state: String, $zipcode: String, $accountNumber: String, $confirmAccountNumber: String, $ifscCode: String, $accountHolderName: String, $gstNumber: String, $panNumber: String, $mobileNumber: String, $accountType: String) {
          updateSecPayment(userId: $userId, country: $country, address1: $address1, address2: $address2, city: $city, state: $state, zipcode: $zipcode, accountNumber: $accountNumber, confirmAccountNumber: $confirmAccountNumber, ifscCode: $ifscCode, accountHolderName: $accountHolderName, gstNumber: $gstNumber, panNumber: $panNumber, mobileNumber: $mobileNumber, accountType: $accountType) {
            __typename
            status
            errorMessage
            result {
              __typename
              userId
              country
              address1
              address2
              city
              state
              zipcode
              accountNumber
              confirmAccountNumber
              ifscCode
              accountHolderName
              gstNumber
              panNumber
              mobileNumber
              accountType
            }
          }
        }
        """

    public var userId: String
    public var country: String?
    public var address1: String?
    public var address2: String?
    public var city: String?
    public var state: String?
    public var zipcode: String?
    public var accountNumber: String?
    public var confirmAccountNumber: String?
    public var ifscCode: String?
    public var accountHolderName: String?
    public var gstNumber: String?
    public var panNumber: String?
    public var mobileNumber: String?
    public var accountType: String?

    public init(userId: String, country: String? = nil, address1: String? = nil, address2: String? = nil, city: String? = nil, state: String? = nil, zipcode: String? = nil, accountNumber: String? = nil, confirmAccountNumber: String? = nil, ifscCode: String? = nil, accountHolderName: String? = nil, gstNumber: String? = nil, panNumber: String? = nil, mobileNumber: String? = nil, accountType: String? = nil) {
        self.userId = userId
        self.country = country
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.state = state
        self.zipcode = zipcode
        self.accountNumber = accountNumber
        self.confirmAccountNumber = confirmAccountNumber
        self.ifscCode = ifscCode
        self.accountHolderName = accountHolderName
        self.gstNumber = gstNumber
        self.panNumber = panNumber
        self.mobileNumber = mobileNumber
        self.accountType = accountType
    }

    public var variables: GraphQLMap? {
        return [
            "userId": userId,
            "country": country,
            "address1": address1,
            "address2": address2,
            "city": city,
            "state": state,
            "zipcode": zipcode,
            "accountNumber": accountNumber,
            "confirmAccountNumber": confirmAccountNumber,
            "ifscCode": ifscCode,
            "accountHolderName": accountHolderName,
            "gstNumber": gstNumber,
            "panNumber": panNumber,
            "mobileNumber": mobileNumber,
            "accountType": accountType
        ]
    }

    public struct Data: GraphQLSelectionSet {
        public static let possibleTypes = ["Mutation"]

        public static let selections: [GraphQLSelection] = [
            GraphQLField("updateSecPayment", arguments: [
                "userId": GraphQLVariable("userId"),
                "country": GraphQLVariable("country"),
                "address1": GraphQLVariable("address1"),
                "address2": GraphQLVariable("address2"),
                "city": GraphQLVariable("city"),
                "state": GraphQLVariable("state"),
                "zipcode": GraphQLVariable("zipcode"),
                "accountNumber": GraphQLVariable("accountNumber"),
                "confirmAccountNumber": GraphQLVariable("confirmAccountNumber"),
                "ifscCode": GraphQLVariable("ifscCode"),
                "accountHolderName": GraphQLVariable("accountHolderName"),
                "gstNumber": GraphQLVariable("gstNumber"),
                "panNumber": GraphQLVariable("panNumber"),
                "mobileNumber": GraphQLVariable("mobileNumber"),
                "accountType": GraphQLVariable("accountType")
            ], type: .object(UpdateSecPayment.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
        }

        public init(updateSecPayment: UpdateSecPayment? = nil) {
            self.init(unsafeResultMap: ["__typename": "Mutation", "updateSecPayment": updateSecPayment.flatMap { (value: UpdateSecPayment) -> ResultMap in value.resultMap }])
        }

        public var updateSecPayment: UpdateSecPayment? {
            get {
                return (resultMap["updateSecPayment"] as? ResultMap).flatMap { UpdateSecPayment(unsafeResultMap: $0) }
            }
            set {
                resultMap.updateValue(newValue?.resultMap, forKey: "updateSecPayment")
            }
        }

        public struct UpdateSecPayment: GraphQLSelectionSet {
            public static let possibleTypes = ["UpdateSecPaymentResponse"]

            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("status", type: .scalar(String.self)),
                GraphQLField("errorMessage", type: .scalar(String.self)),
                GraphQLField("result", type: .object(Result.selections)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
            }

            public init(status: String? = nil, errorMessage: String? = nil, result: Result? = nil) {
                self.init(unsafeResultMap: ["__typename": "UpdateSecPaymentResponse", "status": status, "errorMessage": errorMessage, "result": result.flatMap { (value: Result) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
                get {
                    return resultMap["__typename"]! as! String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                }
            }

            public var status: String? {
                get {
                    return resultMap["status"] as? String
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

            public var result: Result? {
                get {
                    return (resultMap["result"] as? ResultMap).flatMap { Result(unsafeResultMap: $0) }
                }
                set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "result")
                }
            }

            public struct Result: GraphQLSelectionSet {
                public static let possibleTypes = ["PaymentDetails"]

                public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("userId", type: .scalar(String.self)),
                    GraphQLField("country", type: .scalar(String.self)),
                    GraphQLField("address1", type: .scalar(String.self)),
                    GraphQLField("address2", type: .scalar(String.self)),
                    GraphQLField("city", type: .scalar(String.self)),
                    GraphQLField("state", type: .scalar(String.self)),
                    GraphQLField("zipcode", type: .scalar(String.self)),
                    GraphQLField("accountNumber", type: .scalar(String.self)),
                    GraphQLField("confirmAccountNumber", type: .scalar(String.self)),
                    GraphQLField("ifscCode", type: .scalar(String.self)),
                    GraphQLField("accountHolderName", type: .scalar(String.self)),
                    GraphQLField("gstNumber", type: .scalar(String.self)),
                    GraphQLField("panNumber", type: .scalar(String.self)),
                    GraphQLField("mobileNumber", type: .scalar(String.self)),
                    GraphQLField("accountType", type: .scalar(String.self)),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                }

                public init(userId: String? = nil, country: String? = nil, address1: String? = nil, address2: String? = nil, city: String? = nil, state: String? = nil, zipcode: String? = nil, accountNumber: String? = nil, confirmAccountNumber: String? = nil, ifscCode: String? = nil, accountHolderName: String? = nil, gstNumber: String? = nil, panNumber: String? = nil, mobileNumber: String? = nil, accountType: String? = nil) {
                    self.init(unsafeResultMap: [
                        "__typename": "PaymentDetails",
                        "userId": userId,
                        "country": country,
                        "address1": address1,
                        "address2": address2,
                        "city": city,
                        "state": state,
                        "zipcode": zipcode,
                        "accountNumber": accountNumber,
                        "confirmAccountNumber": confirmAccountNumber,
                        "ifscCode": ifscCode,
                        "accountHolderName": accountHolderName,
                        "gstNumber": gstNumber,
                        "panNumber": panNumber,
                        "mobileNumber": mobileNumber,
                        "accountType": accountType
                    ])
                }

                public var __typename: String {
                    get {
                        return resultMap["__typename"]! as! String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                    }
                }

                public var userId: String? {
                    get {
                        return resultMap["userId"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "userId")
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

                public var address1: String? {
                    get {
                        return resultMap["address1"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "address1")
                    }
                }

                public var address2: String? {
                    get {
                        return resultMap["address2"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "address2")
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

                public var accountNumber: String? {
                    get {
                        return resultMap["accountNumber"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "accountNumber")
                    }
                }

                public var confirmAccountNumber: String? {
                    get {
                        return resultMap["confirmAccountNumber"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "confirmAccountNumber")
                    }
                }

                public var ifscCode: String? {
                    get {
                        return resultMap["ifscCode"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "ifscCode")
                    }
                }

                public var accountHolderName: String? {
                    get {
                        return resultMap["accountHolderName"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "accountHolderName")
                    }
                }

                public var gstNumber: String? {
                    get {
                        return resultMap["gstNumber"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "gstNumber")
                    }
                }

                public var panNumber: String? {
                    get {
                        return resultMap["panNumber"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "panNumber")
                    }
                }

                public var mobileNumber: String? {
                    get {
                        return resultMap["mobileNumber"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "mobileNumber")
                    }
                }

                public var accountType: String? {
                    get {
                        return resultMap["accountType"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "accountType")
                    }
                }
            }
        }
    }
}

