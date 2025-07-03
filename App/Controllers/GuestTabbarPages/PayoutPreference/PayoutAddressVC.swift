

import UIKit
import IQKeyboardManagerSwift
import Apollo
import Lottie
import MKToolTip
import SwiftMessages

class PayoutAddressVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
//    var completionHandlerGoToPayoutDetails:((Int)->())?
    var getSecPaymentResponse = GetSecPaymentQuery.Data.GetSecPayment.Result()
    var lottieWholeView = UIView()
    var lottieView =  LottieAnimationView()
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var offlineView: UIView!
    
    @IBOutlet weak var nextImage: UIImageView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var payoutAddressTable: UITableView!
    var countryText = String()
    var payout_TF_Array = [String]()
    
    @IBOutlet var lblHeader: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialsetup()
        self.lottiewholeAnimation()
        self.fetchBankDetails()
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
    
    func initialsetup() {
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.view.backgroundColor =   UIColor(named: "colorController")
        payoutAddressTable.register(UINib(nibName: "PayoutTextfieldCell", bundle: nil), forCellReuseIdentifier: "PayoutTextfieldCell")
        payout_TF_Array = ["\((Utility.shared.getLanguage()?.value(forKey:"country"))!)","\((Utility.shared.getLanguage()?.value(forKey:"addressline1"))!)","\((Utility.shared.getLanguage()?.value(forKey:"addressline2"))!)","\((Utility.shared.getLanguage()?.value(forKey:"city"))!)","\((Utility.shared.getLanguage()?.value(forKey:"stateprovince"))!)","\((Utility.shared.getLanguage()?.value(forKey:"zipcode"))!)"]
        self.continueBtn.layer.cornerRadius = continueBtn.frame.size.height / 2
        self.continueBtn.layer.masksToBounds = true
        continueBtn.backgroundColor = Theme.Button_BG
        
        payoutAddressTable.rowHeight = UITableView.automaticDimension
        payoutAddressTable.estimatedRowHeight = 70
        self.offlineView.isHidden = true
        Utility.shared.payout_Address_Dict["city"] = ""
        Utility.shared.payout_Address_Dict["state"] = ""
        Utility.shared.payout_Address_Dict["zipcode"] = ""
        IQKeyboardManager.shared.enableAutoToolbar = false
        continueBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        lblHeader.text = "\((Utility.shared.getLanguage()?.value(forKey:"address"))!)"
        lblHeader.font = UIFont(name:APP_FONT_MEDIUM, size: 18)
        continueBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        lblHeader.textColor = UIColor(named: "Title_Header")
        
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        if(Utility.shared.isRTLLanguage()) {
            backBtn.imageView?.performRTLTransform()
            lblHeader.textAlignment = .right
        }
        payoutAddressTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
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
                self.lottieWholeView.isHidden = true
                self.lottieView.isHidden = true
                guard (result?.data?.getSecPayment?.status) != nil else
                {
                    if result?.data?.getSecPayment?.status == "500"{
                        self.lottieWholeView.isHidden = true
                        self.lottieView.isHidden = true
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
                        self.lottieWholeView.isHidden = true
                        self.lottieView.isHidden = true
                        self.view.makeToast(result?.data?.getSecPayment?.errorMessage!)
                    return
                    }
                }
                DispatchQueue.main.async {
                    if result?.data?.getSecPayment?.result?.accountHolderName != nil || result?.data?.getSecPayment?.result?.accountHolderName != "" {
                        self.getSecPaymentResponse = result?.data?.getSecPayment?.result ?? (GetSecPaymentQuery.Data.GetSecPayment.Result())
                        
                        Utility.shared.payout_Address_Dict["country"] = self.countryText
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
                        
                        self.payoutAddressTable.reloadData()
                    }
//                    print("-->>>\((result?.data?.getSecPayment?.result)!)")
                }
            }
            
        } else {
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
    
    @IBAction func continuebtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            
            if((Utility.shared.payout_Address_Dict["address1"]) == nil || ((Utility.shared.payout_Address_Dict["address1"]as! String) == "")) {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enteradd"))!)")
            }
            else if((Utility.shared.payout_Address_Dict["city"]) == nil || ((Utility.shared.payout_Address_Dict["city"]as! String) == ""))
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"entercity"))!)")
            }
            else if((Utility.shared.payout_Address_Dict["state"]) == nil || ((Utility.shared.payout_Address_Dict["state"]as! String) == ""))
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enterstate"))!)")
            }
            else if((Utility.shared.payout_Address_Dict["zipcode"]) == nil || ((Utility.shared.payout_Address_Dict["zipcode"]as! String) == ""))
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enterzipcode"))!)")
            } else {
//                let paymethodObj = PaymentMethodVC()
//                paymethodObj.modalPresentationStyle = .fullScreen
//                self.present(paymethodObj, animated: true, completion: nil)
                
                let paymethodObj = BankDetailsVC()
//                paymethodObj.completionHandlerGoToAddress = { result in
//                    DispatchQueue.main.async {
//                        self.completionHandlerGoToPayoutDetails?(1)
//                        self.dismiss(animated: true)
//                    }
//                }
                paymethodObj.modalPresentationStyle = .fullScreen
                self.present(paymethodObj, animated: true, completion: nil)
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
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.continueBtn.isHidden = false
            self.offlineView.isHidden = true
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payout_TF_Array.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayoutTextfieldCell", for: indexPath)as! PayoutTextfieldCell
        cell.selectionStyle = .none
        cell.payoutTF.placeholder = payout_TF_Array[indexPath.row]
        cell.payoutTF.autocorrectionType = UITextAutocorrectionType.no
        cell.payoutTF.delegate = self
        
        cell.payoutTF.tintColor = UIColor(named: "Title_Header")
        cell.payoutTF.tag = indexPath.row
        cell.tag = indexPath.row + 2000
        let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
        cell.payoutTF.inputAccessoryView = toolBar
        toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
        cell.imgDownArrow.isHidden = true
        cell.payoutTF.isUserInteractionEnabled = true
        if(indexPath.row == 0)
        {
            cell.payoutTF.isUserInteractionEnabled = false
            
            cell.payoutTF.text = countryText
            Utility.shared.payout_Address_Dict.updateValue(countryText, forKey: "country")
            cell.lblHeader.text = "\((Utility.shared.getLanguage()?.value(forKey:"country"))!)"
        } else if(indexPath.row == 1) {
            cell.lblHeader.text = "\((Utility.shared.getLanguage()?.value(forKey:"addressline1"))!)"
            cell.payoutTF.text = Utility.shared.payout_Address_Dict["address1"] as? String
        } else if(indexPath.row == 2) {
            cell.lblHeader.text = "\((Utility.shared.getLanguage()?.value(forKey:"addressline2"))!)"
            cell.payoutTF.text = Utility.shared.payout_Address_Dict["address2"] as? String
        } else if(indexPath.row == 3) {
            cell.lblHeader.text = "\((Utility.shared.getLanguage()?.value(forKey:"city"))!)"
            cell.payoutTF.text = Utility.shared.payout_Address_Dict["city"] as? String
        } else if(indexPath.row == 4) {
            cell.lblHeader.text = "\((Utility.shared.getLanguage()?.value(forKey:"stateprovince"))!)"
            cell.payoutTF.text = Utility.shared.payout_Address_Dict["state"] as? String
        } else if(indexPath.row == 5) {
            cell.lblHeader.text = "\((Utility.shared.getLanguage()?.value(forKey:"zipcode"))!)"
            cell.payoutTF.text = Utility.shared.payout_Address_Dict["zipcode"] as? String
        }
        return cell
    }
    @objc func dismissgenderPicker() {
        view.endEditing(true)
        
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
            Utility.shared.payout_Address_Dict.updateValue(countryText, forKey: "country")
        }
        if(textField.tag == 1)
        {
            
            
            Utility.shared.payout_Address_Dict.updateValue(textvalue, forKey: "address1")
        } else if(textField.tag == 2) {
            Utility.shared.payout_Address_Dict.updateValue(textvalue, forKey: "address2")
            
        } else if(textField.tag == 3) {
            Utility.shared.payout_Address_Dict.updateValue(textvalue, forKey: "city")
            
        } else if(textField.tag == 4) {
            Utility.shared.payout_Address_Dict.updateValue(textvalue, forKey: "state")
            
        } else if(textField.tag == 5) {
            Utility.shared.payout_Address_Dict.updateValue(textvalue, forKey: "zipcode")
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
