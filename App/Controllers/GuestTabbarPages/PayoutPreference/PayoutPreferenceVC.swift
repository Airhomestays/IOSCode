
import UIKit
import Apollo
import Lottie
import MKToolTip
import SwiftMessages

class PayoutPreferenceVC: UIViewController,UITableViewDelegate,UITableViewDataSource,WebviewVCDelegate  ,CountryDelegate {
    func setPayoutCall(accountid: String) {
        
    }
    
    func onSuccessPayPalPayment(isSuccess: Bool,toastermsg: String,successURL: URL?) {
        
    }
    
    func setSelectedCountry(selectedCountry: String, selectedcountryCode: String, selectdialcode: String) {
        Utility.shared.selected_Countrycode_Payout = selectedcountryCode
        country = selectedCountry
    }
    
    @IBOutlet weak var btnUpdate: UIButton!{
        didSet {
            btnUpdate.isHidden = true
        }
    }
    
    var getSecPaymentResponse = GetSecPaymentQuery.Data.GetSecPayment.Result()
    @IBOutlet var headerLabel: UILabel!
    var accountypeLabel = ""
    var payout_TF_Array = [String]()
    
    @IBOutlet var topContView: UIView!
    @IBOutlet var topView: UIView!
    @IBOutlet var btnAddPayout: UIButton!
    var country = String()
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nopayoutLabel: UILabel!
    @IBOutlet weak var payoutLabel: UILabel!
    @IBOutlet weak var offlineview: UIView!
    @IBOutlet weak var addBtn: UIButton!

    @IBOutlet weak var payoutTable: UITableView!
    @IBOutlet weak var nodataview: UIView!
    var lottieWholeView = UIView()
    var lottieView1 =  LottieAnimationView()
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var getpayoutArray = [GetPayoutsQuery.Data.GetPayout.Result]()
    var lottieView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.payoutDetailsUpdate(notification:)), name: Notification.Name("PayoutDetailsUpdate"), object: nil)

        offlineview.backgroundColor =  UIColor(named: "Button_Grey_Color")
        print("----")
        self.initialsetup()
        self.lottieAnimation()
//        self.payoutAPICall()
        self.fetchBankDetails()
    }
    
    @objc func payoutDetailsUpdate(notification: Notification) {
        self.fetchBankDetails()
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
                self.lottieView.isHidden = true
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
                    self.btnUpdate.isHidden = false
                    self.btnAddPayout.setImage(nil, for: .normal)
                    self.btnAddPayout.setTitle("Ok", for: .normal)
                    self.btnAddPayout.backgroundColor = Theme.Button_BG
                    self.btnUpdate.layer.cornerRadius = self.btnUpdate.frame.size.height / 2
                    self.btnAddPayout.layer.masksToBounds = true
                    self.btnUpdate.layer.masksToBounds = true
                    self.btnUpdate.backgroundColor = Theme.Button_BG
                    self.btnUpdate.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
                    self.btnAddPayout.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
                    self.btnAddPayout.setTitleColor(UIColor.white, for: .normal)
                    
                    self.accountypeLabel = self.getSecPaymentResponse.accountType ?? ""
                    
                    Utility.shared.payout_Address_Dict["country"] = self.getSecPaymentResponse.country ?? ""
                    Utility.shared.payout_Address_Dict["address1"] = self.getSecPaymentResponse.address1 ?? ""
                    Utility.shared.payout_Address_Dict["address2"] = self.getSecPaymentResponse.address2 ?? ""
                    Utility.shared.payout_Address_Dict["city"] = self.getSecPaymentResponse.city ?? ""
                    Utility.shared.payout_Address_Dict["state"] = self.getSecPaymentResponse.state ?? ""
                    Utility.shared.payout_Address_Dict["zipcode"] = self.getSecPaymentResponse.zipcode ?? ""
                    
                    
                    Utility.shared.bankDetails_Dict["accountType"] = self.getSecPaymentResponse.accountType ?? ""
                    Utility.shared.bankDetails_Dict["accountHolderName"] = self.getSecPaymentResponse.accountHolderName ?? ""
                    Utility.shared.bankDetails_Dict["mobNumber"] = self.getSecPaymentResponse.mobileNumber ?? ""
                    Utility.shared.bankDetails_Dict["accountNumber"] = self.getSecPaymentResponse.accountNumber ?? ""
                    Utility.shared.bankDetails_Dict["confirmAccountNumber"] = self.getSecPaymentResponse.confirmAccountNumber ?? ""
                    Utility.shared.bankDetails_Dict["ifscCode"] = self.getSecPaymentResponse.ifscCode ?? ""
                    
                    Utility.shared.taxDetails_Dict["gstNumber"] = self.getSecPaymentResponse.gstNumber ?? ""
                    Utility.shared.taxDetails_Dict["panNumber"] = self.getSecPaymentResponse.panNumber ?? ""
                    
                    self.payoutTable.reloadData()
                }
//                print("-->>>\((result?.data?.getSecPayment?.result)!)")
            }
            
        } else {
            self.offlineview.isHidden = false
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: self.offlineview.frame.size.width + shadowSize2,
                                                        height: self.offlineview.frame.size.height + shadowSize2))
            
            self.offlineview.layer.masksToBounds = false
            self.offlineview.layer.shadowColor = Theme.TextLightColor.cgColor
            self.offlineview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.offlineview.layer.shadowOpacity = 0.3
            self.offlineview.layer.shadowPath = shadowPath2.cgPath
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineview.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineview.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    func initialsetup() {
        
        self.view.backgroundColor =   UIColor(named: "colorController")
//        payoutTable.register(UINib(nibName: "PayoutCell", bundle: nil), forCellReuseIdentifier: "PayoutCell")
        payoutTable.register(UINib(nibName: "BankDetCell", bundle: nil), forCellReuseIdentifier: "BankDetCell")
        
        self.topContView.backgroundColor =  UIColor(named: "becomeAHostStep_Color")
        self.nodataview.isHidden = true
        self.offlineview.isHidden = true
        errorLabel.textColor =  UIColor(named: "Title_Header")
        headerLabel.font = UIFont(name:APP_FONT_SEMIBOLD , size:18 )
        headerLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"payoutpreferences")) ?? "Payout preferences")"
        headerLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        btnAddPayout.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"addpayout"))!)  ", for:.normal)
        btnAddPayout.titleLabel?.font = UIFont(name:APP_FONT_MEDIUM, size: 14)
        btnAddPayout.layer.cornerRadius = btnAddPayout.frame.size.height / 2
        btnAddPayout.layer.masksToBounds = true
        btnAddPayout.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
        
        
        self.btnUpdate.isHidden = false
        self.btnUpdate.layer.cornerRadius = self.btnUpdate.frame.size.height / 2
        self.btnUpdate.layer.masksToBounds = true
        self.btnUpdate.backgroundColor = Theme.Button_BG
        self.btnUpdate.setTitle("Update", for: .normal) //("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for:.normal)
        self.btnUpdate.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        
        payoutLabel.text = " \((Utility.shared.getLanguage()?.value(forKey:"payoutmethod"))!) "
        nopayoutLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nopayoutmethods"))!)"
        
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLabel.font = UIFont(name: APP_FONT, size: 15)
        nopayoutLabel.font = UIFont(name: APP_FONT, size: 18)
        payoutLabel.font = UIFont(name: APP_FONT, size: 28)
        
        payout_TF_Array = ["\((Utility.shared.getLanguage()?.value(forKey:"country"))!)","\((Utility.shared.getLanguage()?.value(forKey:"addressline1"))!)","\((Utility.shared.getLanguage()?.value(forKey:"addressline2"))!)","\((Utility.shared.getLanguage()?.value(forKey:"city"))!)","\((Utility.shared.getLanguage()?.value(forKey:"stateprovince"))!)","\((Utility.shared.getLanguage()?.value(forKey:"zipcode"))!)", "Account Type", "Account Holder Name", "Mobile Number Number", "Account Number", "Confirm Account Number", "IFSC Code", "GST Number", "PAN Number"]
        
        if(Utility.shared.isRTLLanguage()) {
            backBtn.imageView?.performRTLTransform()
            headerLabel.textAlignment = .right
        }
    }
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-150, width:100, height:100)
        self.payoutTable.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll() {
        self.lottieView.play()
        
    }
    @objc func autoscrolling() {
        self.lottieView1.play()
    }
    
    @IBAction func actionUpdate(_ sender: Any) {
        Utility.shared.payout_Address_Dict.removeAll()
        let countryList = CountrycodeVC()
        
        countryList.completionHandlerGoToPayoutDetailss = { result in
            DispatchQueue.main.async {
                self.fetchBankDetails()
            }
        }
        
        Utility.shared.isPhonenumberCountrycode = false
        countryList.titleForHeader = "\((Utility.shared.getLanguage()?.value(forKey:"selectcountry"))!)"
        countryList.delegate = self
        countryList.isFromPayoutRefrence = true
        countryList.modalPresentationStyle = .fullScreen
        self.present(countryList, animated: true, completion: nil)
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if getSecPaymentResponse.accountHolderName != nil || getSecPaymentResponse.accountHolderName != "" {
                self.dismiss(animated: true)
            } else {
                Utility.shared.payout_Address_Dict.removeAll()
                let countryList = CountrycodeVC()
                countryList.completionHandlerGoToPayoutDetailss = { result in
                    DispatchQueue.main.async {
                        self.fetchBankDetails()
                    }
                }
                Utility.shared.isPhonenumberCountrycode = false
                countryList.titleForHeader = "\((Utility.shared.getLanguage()?.value(forKey:"selectcountry"))!)"
                countryList.delegate = self
                countryList.isFromPayoutRefrence = true
                countryList.modalPresentationStyle = .fullScreen
                self.present(countryList, animated: true, completion: nil)
            }
        } else {
            self.offlineview.isHidden = false
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: self.offlineview.frame.size.width + shadowSize2,
                                                        height: self.offlineview.frame.size.height + shadowSize2))
            
            self.offlineview.layer.masksToBounds = false
            self.offlineview.layer.shadowColor = Theme.TextLightColor.cgColor
            self.offlineview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.offlineview.layer.shadowOpacity = 0.3
            self.offlineview.layer.shadowPath = shadowPath2.cgPath
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineview.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineview.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    
    @IBAction func beckBtnTapped(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
//    func numberOfSections(in tableView: UITableView) -> Int{
//        if getSecPaymentResponse.accountHolderName != nil || getSecPaymentResponse.accountHolderName != "" {
//            return self.payout_TF_Array.count
//        }
//        return 0
//    }
//    
//    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String? {
//        if(section == 0){
//            
//            if(getpayoutArray.count > 0) {
//                
//                return ""
//            }
//            return "\((Utility.shared.getLanguage()?.value(forKey:"nopayoutmethods"))!)"
//        }
//        return ""
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.white
//        
//        let lineLabel = UILabel(frame: CGRect(x:30, y: 0, width:
//                                                FULLWIDTH-30, height: 1.0))
//        lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
//        let headerLabel = UILabel(frame: CGRect(x:20, y:0, width:FULLWIDTH-40, height: 80))
//        headerLabel.font = UIFont(name: APP_FONT_MEDIUM, size:25)
//        headerLabel.textColor =  UIColor(named: "Title_Header")
//        headerLabel.numberOfLines = 2
//        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
//        headerView.addSubview(headerLabel)
//        return headerView
//    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineview.isHidden = true
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if(section == 0) {
//            if(getpayoutArray.count > 0) {
//                return 0
//            }
//            if Utility.shared.getAppLanguageCode() == "En" || Utility.shared.getAppLanguageCode() == "en"{
//                return 60
//            }
//            return 90
//            
//        }
//        return CGFloat.leastNormalMagnitude
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getSecPaymentResponse.accountHolderName != nil || getSecPaymentResponse.accountHolderName != "" {
            return self.payout_TF_Array.count
        }
        return 0
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BankDetCell", for: indexPath)as! BankDetCell
        cell.selectionStyle = .none
        cell.lblTtl.text = self.payout_TF_Array[indexPath.row]
        
        switch indexPath.row {
        case 0:
            cell.lblDesc.text = Utility.shared.payout_Address_Dict["country"] as? String
        case 1:
            cell.lblDesc.text = Utility.shared.payout_Address_Dict["address1"] as? String
        case 2:
            cell.lblDesc.text = Utility.shared.payout_Address_Dict["address2"] as? String
        case 3:
            cell.lblDesc.text = Utility.shared.payout_Address_Dict["city"] as? String
        case 4:
            cell.lblDesc.text = Utility.shared.payout_Address_Dict["state"] as? String
        case 5:
            cell.lblDesc.text = Utility.shared.payout_Address_Dict["zipcode"] as? String
        
        case 6:
            cell.lblDesc.text = Utility.shared.bankDetails_Dict["accountType"] as? String
        case 7:
            cell.lblDesc.text = Utility.shared.bankDetails_Dict["accountHolderName"] as? String
        case 8:
            cell.lblDesc.text = Utility.shared.bankDetails_Dict["mobNumber"] as? String
        case 9:
            cell.lblDesc.text = Utility.shared.bankDetails_Dict["accountNumber"] as? String
        case 10:
            cell.lblDesc.text = Utility.shared.bankDetails_Dict["confirmAccountNumber"] as? String
        case 11:
            cell.lblDesc.text = Utility.shared.bankDetails_Dict["ifscCode"] as? String
        case 12:
            cell.lblDesc.text = Utility.shared.taxDetails_Dict["gstNumber"] as? String
        default:
            cell.lblDesc.text = Utility.shared.taxDetails_Dict["panNumber"] as? String
        }
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PayoutCell", for: indexPath)as! PayoutCell
//        cell.selectionStyle = .none
//        
//        if("\((getpayoutArray[indexPath.row].paymentMethod?.id)!)" == "1") {
//            cell.payoutLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"paypal"))!)"
//            cell.payoutLAbel.textColor =  UIColor(named: "Title_Header")
//            cell.detailLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"Details"))!) \(getpayoutArray[indexPath.row].payEmail!)"
//            cell.typeImage.image = #imageLiteral(resourceName: "paypal")
//        } else {
//            cell.payoutLAbel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bankaccountsmall") ?? "Bank account")"
//            cell.payoutLAbel.textColor =  UIColor(named: "Title_Header")
//            
//            
//            cell.typeImage.image = #imageLiteral(resourceName: "stripe")
//            cell.detailLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"Details"))!) *******\(getpayoutArray[indexPath.row].last4Digits!)"
//        }
//        cell.payoutLAbel.textColor =  UIColor(named: "Title_Header")
//        cell.currencyLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"currency"))!):  [\(getpayoutArray[indexPath.row].currency!)]"
//        if getpayoutArray[indexPath.row].default == true {
//            cell.defaultBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"default"))!)  ", for: .normal)
//            cell.defaultBtn.backgroundColor = UIColor(named: "colorController")
//            cell.defaultBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
//            cell.defaultBtn.isUserInteractionEnabled = false
//            cell.deleteBtn.isHidden = true
//            cell.heightConstraint.constant = 0
//            cell.bottomConstraint.constant = 0
//            cell.verifyInfoicon.isHidden = true
//            cell.statusLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"statusready"))!)"
//        } else if(getpayoutArray[indexPath.row].default == false && getpayoutArray.count == 1 && getpayoutArray[indexPath.row].isVerified != false) {
//            cell.defaultBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"default"))!)  ", for: .normal)
//            cell.defaultBtn.imageView?.layer.transform = CATransform3DIdentity
//            cell.defaultBtn.backgroundColor = UIColor(named: "colorController")
//            cell.defaultBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
//            cell.defaultBtn.isUserInteractionEnabled = false
//            cell.deleteBtn.isHidden = true
//            cell.heightConstraint.constant = 0
//            cell.bottomConstraint.constant = 0
//            cell.verifyInfoicon.isHidden = true
//            cell.statusLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"statusready"))!)"
//            
//        } else {
//            if(getpayoutArray[indexPath.row].isVerified == false) {
//                cell.defaultBtn.tag = indexPath.row
//                cell.defaultBtn.isUserInteractionEnabled = true
//                cell.deleteBtn.isHidden = false
//                cell.heightConstraint.constant = 45
//                cell.bottomConstraint.constant = 13
//                cell.defaultBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"Verify"))!)  ", for: .normal)
//                
//                cell.defaultBtn.setImage(nil, for: .normal)
//                cell.defaultBtn.backgroundColor = Theme.PRIMARY_COLOR
//                cell.defaultBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
//                cell.statusLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"notready"))!)"
//                cell.defaultBtn.removeTarget(self, action: nil, for: .allEvents)
//                cell.defaultBtn.addTarget(self, action:  #selector(verifyBtnTapped), for: .touchUpInside)
//                cell.verifyInfoicon.isHidden = false
//                if Utility.shared.getAppLanguageCode() == "It" || Utility.shared.getAppLanguageCode() == "it" || Utility.shared.getAppLanguageCode() == "Pt" || Utility.shared.getAppLanguageCode() == "pt"{
//                    
//                    cell.verifyInfoicon.frame.origin.x = 175
//                }
//                cell.verifyInfoicon.addTarget(self, action: #selector(tooltipBtnTapped(_:)), for: .touchUpInside)
//            } else {
//                cell.statusLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"statusready"))!)"
//                cell.verifyInfoicon.isHidden = true
//                cell.defaultBtn.tag = indexPath.row
//                cell.defaultBtn.isUserInteractionEnabled = true
//                cell.defaultBtn.setImage(nil, for: .normal)
//                cell.deleteBtn.isHidden = false
//                cell.heightConstraint.constant = 45
//                cell.bottomConstraint.constant = 13
//                cell.defaultBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"setdefault"))!)  ", for: .normal)
//                cell.defaultBtn.setTitleColor(UIColor(named: "whites"), for: .normal)
//                cell.defaultBtn.backgroundColor = Theme.PRIMARY_COLOR
//                
//                cell.defaultBtn.removeTarget(self, action: nil, for: .allEvents)
//                cell.defaultBtn.addTarget(self, action:  #selector(defaultBtnTapped), for: .touchUpInside)
//            }
//        }
//        cell.deleteBtn.tag = indexPath.row
//        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnTapped), for: .touchUpInside)
        
        return cell
    }
//    @objc func tooltipBtnTapped(_ sender: UIButton!)
//    {
//        let preference = ToolTipPreferences()
//        preference.drawing.bubble.color = UIColor.darkGray
//        preference.drawing.bubble.spacing = 10
//        preference.drawing.bubble.cornerRadius = 5
//        preference.drawing.bubble.inset = 15
//        preference.drawing.bubble.border.color = UIColor.darkGray
//        preference.drawing.bubble.border.width = 1
//        preference.drawing.arrow.tipCornerRadius = 5
//        preference.drawing.message.color = UIColor.white
//        preference.drawing.message.font = UIFont(name: APP_FONT, size:15)!
//        preference.drawing.button.color = UIColor(red: 0.074, green: 0.231, blue: 0.431, alpha: 1.000)
//        preference.drawing.button.font = UIFont(name: APP_FONT, size:15)!
//        sender.showToolTip(identifier: "", message:"\((Utility.shared.getLanguage()?.value(forKey:"stripe_verificationInfo"))!)", button:nil, arrowPosition: .bottom, preferences: preference, delegate: nil)
//        
//        
//    }
//    @objc func verifyBtnTapped(_ sender: UIButton) {
//        if Utility().isConnectedToNetwork(){
//            self.VerifyAPICall(stripeaccountID: getpayoutArray[sender.tag].payEmail!)
//        } else {
//            self.offlineview.isHidden = false
//            let shadowSize2 : CGFloat = 3.0
//            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
//                                                        y: -shadowSize2 / 2,
//                                                        width: self.offlineview.frame.size.width + shadowSize2,
//                                                        height: self.offlineview.frame.size.height + shadowSize2))
//            
//            self.offlineview.layer.masksToBounds = false
//            self.offlineview.layer.shadowColor = Theme.TextLightColor.cgColor
//            self.offlineview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//            self.offlineview.layer.shadowOpacity = 0.3
//            self.offlineview.layer.shadowPath = shadowPath2.cgPath
//            if IS_IPHONE_X || IS_IPHONE_XR{
//                offlineview.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
//            }else{
//                offlineview.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
//            }
//            
//        }
//    }
    func lottiewholeAnimation() {
        self.lottieView1.isHidden = false
        self.lottieWholeView.isHidden = false
        lottieView1 = LottieAnimationView.init(name: "loading_qwe")
        self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(lottieWholeView)
        self.lottieView1.frame = CGRect(x:FULLWIDTH/2-50, y: FULLHEIGHT/2-50, width: 100, height: 100)
        self.lottieWholeView.addSubview(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor(named: "lottie-bg")
        self.lottieView1.layer.cornerRadius = 6.0
        self.lottieView1.clipsToBounds = true
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscrolling), userInfo: nil, repeats: true)
    }
//    func setPayoutCall(accountid:String) {
//        self.lottiewholeAnimation()
//        let setPayoutMutation = ConfirmPayoutMutation(currentAccountId:accountid)
//        apollo_headerClient.perform(mutation:setPayoutMutation){(result,error) in
//            if(result?.data?.confirmPayout?.status == 200) {
//                self.payoutAPICall()
//                self.lottieView1.isHidden = true
//                self.lottieWholeView.isHidden = true
//            } else {
//                self.lottieView1.isHidden = true
//                self.lottieWholeView.isHidden = true
//                self.view.makeToast(result?.data?.confirmPayout?.errorMessage)
//            }
//        }
//        
//        
//    }
//    func VerifyAPICall(stripeaccountID:String) {
//        let verifyPayoutmutation = VerifyPayoutMutation(stripeAccount: stripeaccountID)
//        apollo_headerClient.perform(mutation:verifyPayoutmutation) {(result,error) in
//            if(result?.data?.verifyPayout?.status == 200) {
//                let webviewObj = WebviewVC()
//                webviewObj.delegate = self
//                webviewObj.webstring = (result?.data?.verifyPayout?.connectUrl)!
//                webviewObj.modalPresentationStyle = .fullScreen
//                webviewObj.succesURL = (result?.data?.verifyPayout?.successUrl)!
//                webviewObj.failureURL = (result?.data?.verifyPayout?.failureUrl)!
//                webviewObj.webviewRedirection(webviewString:(result?.data?.verifyPayout?.connectUrl!)!)
//                webviewObj.accountID = (result?.data?.verifyPayout?.stripeAccountId!)!
//                webviewObj.pageTitle = ""
//                self.present(webviewObj, animated: true, completion: nil)
//            } else {
//                self.view.makeToast(result?.data?.verifyPayout?.errorMessage)
//            }
//        }
//        
//    }
//    @objc func defaultBtnTapped(_ sender: UIButton) {
//        if Utility().isConnectedToNetwork(){
//            self.setDefaultAPICall(id: getpayoutArray[sender.tag].id!, type: "set")
//        } else {
//            self.offlineview.isHidden = false
//            let shadowSize2 : CGFloat = 3.0
//            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
//                                                        y: -shadowSize2 / 2,
//                                                        width: self.offlineview.frame.size.width + shadowSize2,
//                                                        height: self.offlineview.frame.size.height + shadowSize2))
//            
//            self.offlineview.layer.masksToBounds = false
//            self.offlineview.layer.shadowColor = Theme.TextLightColor.cgColor
//            self.offlineview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//            self.offlineview.layer.shadowOpacity = 0.3
//            self.offlineview.layer.shadowPath = shadowPath2.cgPath
//            if IS_IPHONE_X || IS_IPHONE_XR{
//                offlineview.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
//            }else{
//                offlineview.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
//            }
//            
//        }
//        
//    }
//    @objc func deleteBtnTapped(_ sender: UIButton) {
//        if Utility().isConnectedToNetwork(){
//            if((getpayoutArray.count > sender.tag) && getpayoutArray[sender.tag].id != nil)
//            {
//                self.setDefaultAPICall(id: getpayoutArray[sender.tag].id!, type: "remove")
//            }
//        } else {
//            self.offlineview.isHidden = false
//            let shadowSize2 : CGFloat = 3.0
//            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
//                                                        y: -shadowSize2 / 2,
//                                                        width: self.offlineview.frame.size.width + shadowSize2,
//                                                        height: self.offlineview.frame.size.height + shadowSize2))
//            
//            self.offlineview.layer.masksToBounds = false
//            self.offlineview.layer.shadowColor = Theme.TextLightColor.cgColor
//            self.offlineview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//            self.offlineview.layer.shadowOpacity = 0.3
//            self.offlineview.layer.shadowPath = shadowPath2.cgPath
//            if IS_IPHONE_X || IS_IPHONE_XR{
//                offlineview.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
//            }else{
//                offlineview.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
//            }
//            
//        }
//        
//    }
    
//    func payoutAPICall() {
//        let getpayoutquery = GetPayoutsQuery()
//        apollo_headerClient.fetch(query: getpayoutquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
//            guard (result?.data?.getPayouts?.results) != nil else{
//                self.payoutTable.isHidden = true
//                self.nodataview.isHidden = true
//                self.lottieView.isHidden = true
//                return
//            }
//            
//            self.getpayoutArray = ((result?.data?.getPayouts?.results)!) as! [GetPayoutsQuery.Data.GetPayout.Result]
//            if(self.getpayoutArray.count>0)
//            {
//                self.payoutTable.isHidden = false
//                self.nodataview.isHidden = true
//                self.lottieView.isHidden = true
//                self.payoutTable.reloadData()
//                self.scrollToBottom()
//            } else {
//                self.payoutTable.isHidden = true
//                self.lottieView.isHidden = true
//                self.nodataview.isHidden = true
//            }
//            
//            
//        }
//        
//    }
    
    func scrollToBottom() {
        if self.getpayoutArray.count != 0  {
            let indexPath = IndexPath(row:0,section:0)
            self.payoutTable.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
//    func setDefaultAPICall(id:Int,type:String) {
//        let setdefaultMutation = SetDefaultPayoutMutation(id: id, type: type)
//        apollo_headerClient.perform(mutation: setdefaultMutation) {(result,error) in
//            
//            if (result?.data?.setDefaultPayout?.status == 200)
//            {
//                self.payoutAPICall()
//            } else {
//                self.view.makeToast(result?.data?.setDefaultPayout?.errorMessage)
//            }
//        }
//        
//    }
}
