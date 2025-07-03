
import UIKit
import Apollo
import Lottie

class PaymentMethodVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var offlineView: UIView!
    
    @IBOutlet weak var nextimg: UIImageView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var paymentMethodTable: UITableView!
    
    @IBOutlet var lblHeader: UILabel!
    
    
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var getpaymentmethodsArray = [GetPaymentMethodsQuery.Data.GetPaymentMethod.Result]()
    var getpaymentmethodsArrayFilter = [GetPaymentMethodsQuery.Data.GetPaymentMethod.Result]()
    var lottieView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialsetup()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.payoutAPICall()
        self.lottieAnimation()
    }
    func initialsetup()
    {
        paymentMethodTable.register(UINib(nibName: "paymethodCell", bundle: nil), forCellReuseIdentifier: "paymethodCell")
        lblHeader.font = UIFont(name:APP_FONT_SEMIBOLD, size:18)
        self.continueBtn.layer.cornerRadius = 22.0
        self.continueBtn.layer.masksToBounds = true
        self.nextimg.image = self.nextimg.image?.withRenderingMode(.alwaysTemplate)
        self.nextimg.tintColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.offlineView.isHidden = true
        errorLabel.textColor =  UIColor(named: "Title_Header")
        self.view.backgroundColor =   UIColor(named: "colorController")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        lblHeader.text = "\((Utility.shared.getLanguage()?.value(forKey:"new_payment"))!)"
        lblHeader.textColor =  UIColor(named: "Title_Header")
    retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        if(Utility.shared.isRTLLanguage()) {
                   backBtn.imageView?.performRTLTransform()
            lblHeader.textAlignment = .right
               }
        
    }
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-150, width:100, height:100)
        self.paymentMethodTable.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    
    func payoutAPICall()
    {
        
        
        let getpayoutquery = GetPaymentMethodsQuery()
        apollo_headerClient.fetch(query: getpayoutquery,cachePolicy:.fetchIgnoringCacheData){ [self](result,error) in
            guard (result?.data?.getPaymentMethods?.results) != nil else{
                 self.lottieView.isHidden = true
                self.view.makeToast(result?.data?.getPaymentMethods?.errorMessage)
                return
            }
            
             self.lottieView.isHidden = true
            self.getpaymentmethodsArray = ((result?.data?.getPaymentMethods?.results)!) as! [GetPaymentMethodsQuery.Data.GetPaymentMethod.Result]
            getpaymentmethodsArrayFilter  =  getpaymentmethodsArray.filter { result in
                result.isEnable == true
            }
            
            self.paymentMethodTable.reloadData()
            
        }
        
    }

    
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.continueBtn.frame.origin.y = keyboardFrame.origin.y - 60
        self.nextimg.frame.origin.y = keyboardFrame.origin.y - 45
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.continueBtn.frame.origin.y = FULLHEIGHT - 70
        self.nextimg.frame.origin.y = FULLHEIGHT - 55
    }
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 186
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getpaymentmethodsArrayFilter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymethodCell", for: indexPath)as! paymethodCell
        cell.selectionStyle = .none
        cell.lblSelect.text = "\((Utility.shared.getLanguage()?.value(forKey:"select"))!)"
        if("\((getpaymentmethodsArrayFilter[indexPath.row].id!))" == "1")
        {
        cell.paypalLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"paypal"))!)"
        cell.typeImage.image = #imageLiteral(resourceName: "paypal")
        }
        else
        {
            cell.paypalLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bankaccountsmall") ?? "Bank account")"
            cell.typeImage.image = #imageLiteral(resourceName: "stripe")
        }
        
        cell.paypalLabel.textColor =   UIColor(named: "Title_Header")
        
        cell.feeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"fees"))!): \(getpaymentmethodsArrayFilter[indexPath.row].fees!)"
        cell.processLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"processedin"))!): \(getpaymentmethodsArrayFilter[indexPath.row].processedIn!)"
        cell.currencyLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"currency"))!):  [\(getpaymentmethodsArrayFilter[indexPath.row].currency!)]"
        cell.selectBtn.addTarget(self, action:  #selector(selectBtnTapped), for: .touchUpInside)
        cell.selectBtn.tag = indexPath.row
        return cell
    }
    
    @objc func selectBtnTapped(_ sender: UIButton)
    {
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Utility().isConnectedToNetwork(){
        if(indexPath.row == 0)
        {
            if("\((getpaymentmethodsArrayFilter[indexPath.row].id!))" == "1") {
            let paymethodObj = PaypalPayoutVC()
            paymethodObj.modalPresentationStyle = .fullScreen
            self.present(paymethodObj, animated: true, completion: nil)
            }
            else {
                let bankmethodObj = BankAccountVC()
                bankmethodObj.getpaymentmethodCurrency = self.getpaymentmethodsArrayFilter[indexPath.row].currency ?? "USD"
                bankmethodObj.modalPresentationStyle = .fullScreen
                self.present(bankmethodObj, animated: true, completion: nil)
            }
        }
        else
        {
            let bankmethodObj = BankAccountVC()
            bankmethodObj.getpaymentmethodCurrency = self.getpaymentmethodsArrayFilter[indexPath.row].currency ?? "USD"
            bankmethodObj.modalPresentationStyle = .fullScreen
            self.present(bankmethodObj, animated: true, completion: nil)
        }
        }
        else{
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
}
