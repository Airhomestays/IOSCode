
import UIKit
import Apollo
import Lottie
import IQKeyboardManagerSwift
import SwiftMessages

class PaypalPayoutVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,LanguageVCDelegate {
    func didupdateAppearanceStatus() {
        
    }
    
    
    
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var offlineView: UIView!
    
    @IBOutlet var lblHeader: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var paypalTable: UITableView!
    @IBOutlet weak var topview: UIView!
    var payemail = String()
    var gettingCurrencyString = String()
    var currencycode = String()
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var paypal_Array = [String]()
    var lottieView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.initialsetup()
    }
    
    @IBAction func backbtnTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.finishBtn.isHidden = false
            self.offlineView.isHidden = true
        }
    }
    @IBAction func finishBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            if(payemail == "")
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enteremailplease"))!)")
            }
            else
            {
                if(!(payemail.isValidEmail()))
                {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"validemailenter"))!)")
                }
                else
                {
                    self.lottieanimation()
                    self.finishAPICall()
                }
            }
        }
        else
        {
            self.view.endEditing(true)
            self.finishBtn.isHidden = true
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
    func initialsetup()
    {
        paypalTable.register(UINib(nibName: "paymentpaypalcell", bundle: nil), forCellReuseIdentifier: "paymentpaypalcell")
        paypalTable.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "textfieldcell")
        if(Utility.shared.isRTLLanguage()) {
            backBtn.imageView?.performRTLTransform()
        }
        
        self.view.backgroundColor =   UIColor(named: "colorController")
        lblHeader.font = UIFont(name:APP_FONT_MEDIUM, size: 18)
        lblHeader.text = "\((Utility.shared.getLanguage()?.value(forKey:"paypal"))!)"
        
        lblHeader.textColor = UIColor(named: "Title_Header")
        self.finishBtn.layer.cornerRadius = finishBtn.frame.size.height / 2
        self.finishBtn.backgroundColor = Theme.Button_BG
        self.finishBtn.layer.masksToBounds = true
        currencycode = "USD"
        gettingCurrencyString = currencycode
        self.paypal_Array = ["\((Utility.shared.getLanguage()?.value(forKey:"youremail"))!)","\((Utility.shared.getLanguage()?.value(forKey:"currency"))!)"]
        self.offlineView.isHidden = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        finishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"finish"))!)", for:.normal)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        finishBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        
        
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
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    
    func finishAPICall()
    {
        let addpayoutmutation = AddPayoutMutation(methodId: 1, payEmail: payemail, address1: Utility.shared.payout_Address_Dict["address1"] as? String ?? "", address2: Utility.shared.payout_Address_Dict["address2"] as? String ?? "", city: Utility.shared.payout_Address_Dict["city"] as? String ?? "", state: Utility.shared.payout_Address_Dict["state"] as? String ?? "", country: Utility.shared.selected_Countrycode_Payout, zipcode: Utility.shared.payout_Address_Dict["zipcode"] as? String ?? "", currency: currencycode)
        apollo_headerClient.perform(mutation: addpayoutmutation){(result,error) in
            if(result?.data?.addPayout?.status == 200)
            {
                self.lottieView.isHidden = true
                let payoutObj = PayoutPreferenceVC()
                Utility.shared.isfrom_payoutcurrency = true
                payoutObj.modalPresentationStyle = .fullScreen
                self.present(payoutObj, animated: true, completion: nil)
            }
            else
            {
                self.lottieView.isHidden = true
                
                
                self.view.makeToast(result?.data?.addPayout?.errorMessage!)
            }
            
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return 1
        }
        else
        {
            return 2
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0)
        {
            return 120
        }
        else{
            return 105
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentpaypalcell", for: indexPath)as! paymentpaypalcell
            cell.selectionStyle = .none
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textfieldcell", for: indexPath)as! TextFieldCell
            cell.stepOneBottom.constant = 0
            cell.stepOneHeight.constant = 0
            cell.lineLabel.isHidden = true
            cell.queryTitleLbl.font = UIFont(name: APP_FONT, size:14)
            cell.txtField.placeholder = paypal_Array[indexPath.row]
            cell.txtField.textColor = UIColor(named: "Title_Header")
            if(indexPath.row == 0)
            {
                cell.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"emailaddress"))!)"
                cell.imgDownArrow.isHidden = true
            }
            else
            {
                
                cell.queryTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"currency"))!)"
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: currencycode)
                
                if(currencysymbol == currencycode) {
                    cell.txtField.attributedPlaceholder = NSAttributedString(string: "\(currencycode)",
                                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                }
                else {
                    cell.txtField.attributedPlaceholder = NSAttributedString(string: "\(currencysymbol ?? "USD") \(currencycode)",
                                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                }
                
                
                cell.imgDownArrow.isHidden = false
            }
            
            cell.selectionStyle = .none
            let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
            toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
            cell.txtField.inputAccessoryView = toolBar
            cell.txtField.tag = indexPath.row
            cell.txtField.delegate = self
            cell.txtField.textColor = UIColor(named: "Title_Header")
            cell.stepnumberLbl.isHidden = true
            
            return cell
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if(textField.tag == 1)
        {
            textField.resignFirstResponder()
            let languageObj = LanguageVC()
            Utility.shared.isfromLanguage = false
            Utility.shared.isfromCurrency = false
            languageObj.payout_currency_symbol = currencycode
            Utility.shared.isfrom_payoutcurrency = true
            languageObj.delegate = self
            languageObj.modalPresentationStyle = .overFullScreen
            self.present(languageObj, animated: true, completion: nil)
        }
        
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
        
    }
    @objc func dismissgenderPicker() {
        view.endEditing(true)
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.tag == 0)
        {
            payemail = textField.text!
        }
        if(textField.tag == 1)
        {
            currencycode = gettingCurrencyString
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getcurrencycode(code: String) {
        currencycode = code
        gettingCurrencyString = code
        paypalTable.reloadData()
    }
    
}
