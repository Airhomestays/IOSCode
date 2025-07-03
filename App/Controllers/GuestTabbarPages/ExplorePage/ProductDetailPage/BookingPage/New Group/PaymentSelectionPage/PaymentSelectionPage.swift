
import UIKit
import Stripe
import Lottie
import Apollo
import SwiftMessages
import Razorpay
import Foundation

// verify Payment {"razorpay_payment_id":"pay_OhVtOv0FxO1Uai","razorpay_order_id":"order_OhVsEsmMwwGRGf","razorpay_signature":"8bd682ff4b7e348a104e96d2ad4cfdfe10e8c713a76f9dadb1b87fde167bd504","reservation_id":104,"total_amount":178000}
//orderId, signature, paymentId

class PaymentSelectionPage: UIViewController,  RazorpayPaymentCompletionProtocol {
    
    var isFromm = ""
    var keyInstant = ""
    var totalPetPrice = 0.0
    var totalInfantPrice = 0.0
    var totalVisitorPrice = 0.0
    var totalAdditionalPrice = 0.0
    var additionalGuestCount = "0"
    var overallTotal = 0.0
    
    func onPaymentError(_ code: Int32, description str: String) {
        print("Error")
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        razorResId = payment_id
        self.createRes()
        
        print("Success")
    }
    
    var resssToken = 0
    
    var orderId = ""
    
    // TEST
//    var RZP_TEST_KEY_ID = "rzp_test_ySqOhBgupFu1xq"
//    var RZP_TEST_SECRET = "6AyCdpepARwTzOcGlfxKS3dQ"
    
    // PRODUCTION
    var RZP_TEST_KEY_ID = "rzp_live_rSubgkgENfYNid"//"rzp_test_ySqOhBgupFu1xq"
    var RZP_TEST_SECRET = "f3ixKnmsfRrqg7Da61eXTtwa"//"6AyCdpepARwTzOcGlfxKS3dQ"
    var navigationControllerReference: UINavigationController?
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var proceedToPayBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var threadId = Int()
    
    var razorpay: RazorpayCheckout!
    
    let availablePaymentTypes = ["Paypal", "Razor Pay"]
    var selectedPaymentType: Int = 0
    var inputPickerView = UIPickerView()
    var inputUIView = UIView()
    var currencyPaymentTypes: [GetCurrenciesListQuery.Data.GetCurrency.Result]? = []
    var selectedCurrency = ""
    
    var getpaymentmethodsArray = [GetPaymentMethodsQuery.Data.GetPaymentMethod.Result]()
    var getpaymentmethodsArrayFilter = [GetPaymentMethodsQuery.Data.GetPaymentMethod.Result]()
    
    @IBOutlet var lblPaymentType: UILabel!
    var lottieWholeView = UIView()
    var lottieView =  LottieAnimationView()
    
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
      
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    
    var currencyvalue_from_API_base = ""
    var getbillingArray = GetBillingCalculationQueryy.Data.GetBillingCalculation.Result()
    var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    var reservID = 0
    var razorResId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialSetup()
        
        self.navigationController?.navigationBar.isHidden = true
        razorpay = RazorpayCheckout.initWithKey(RZP_TEST_KEY_ID, andDelegate: self)

        self.payoutAPICall()
        self.view.backgroundColor = UIColor(named: "colorController")
        self.bottomView.backgroundColor = UIColor(named: "colorController")
        self.bottomView.bringSubviewToFront(self.proceedToPayBtn)
        
        self.configurePaypalCheckOut()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func showPaymentForm() {
        DispatchQueue.main.async {
            let options: [String:Any] = [
                "amount": "\((((self.getbillingArray.total ?? Double(0.0)) * 100.0)))", // amount in paise (e.g., 100 paise = 1 INR) //subtotal
                "currency": "\(self.getbillingArray.currency ?? "INR")", //currency
                // "description": "Purchase Description",
                // "image": "https://your_logo_url.com",
                "name": "Airhomestays",
                "prefill": [
                    "contact": "",
                    "email": ""
                ],
                "theme": [
                    "color": "#F37254"
                ]
            ]
            
            
            self.razorpay.open(options, displayController: self)
        }
               
    }
    
    func payoutAPICall()
    {
        
        self.lottieAnimation()
        let getpayoutquery = GetPaymentMethodsQuery()
        apollo_headerClient.fetch(query: getpayoutquery,cachePolicy:.fetchIgnoringCacheData){ [self](result,error) in
            guard (result?.data?.getPaymentMethods?.results) != nil else{
              
                self.lottieView.isHidden = true
                self.lottieWholeView.isHidden = true
                self.view.makeToast(result?.data?.getPaymentMethods?.errorMessage)
                return
            }
            
            self.lottieView.isHidden = true
            self.lottieWholeView.isHidden = true
          
            self.getpaymentmethodsArray = ((result?.data?.getPaymentMethods?.results)!) as! [GetPaymentMethodsQuery.Data.GetPaymentMethod.Result]
          
            getpaymentmethodsArrayFilter  =  getpaymentmethodsArray.filter { result in
                result.isEnable == true
            }
            
            self.tableView.reloadData()
            
        }
        
    }
    
    
    func lottieAnimation()
    {
        self.lottieView.isHidden = false
        self.lottieWholeView.isHidden = false
        self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(lottieWholeView)
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-50, y: FULLHEIGHT/2-50, width: 100, height: 100)
        self.lottieWholeView.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor(named: "lottie-bg")
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    
    func initialSetup() {
        lottieView = LottieAnimationView.init(name: "loading_qwe")
        updateCurrencyTypes()
        tableView.register(UINib(nibName: "EditAboutCell", bundle: nil), forCellReuseIdentifier: "EditAboutCell")
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "textfieldcell")
        tableView.register(UINib(nibName: "PaymentCell", bundle: nil), forCellReuseIdentifier: "PaymentCell")
        tableView.register(UINib(nibName: "PaymentFooterCell", bundle: nil), forCellReuseIdentifier: "PaymentFooterCell")
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        lblPaymentType.font = UIFont(name: APP_FONT_SEMIBOLD, size: 18)
        lblPaymentType.text = "\(Utility.shared.getLanguage()?.value(forKey: "paymenttype") ?? "Payment Type")"
        
        proceedToPayBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "Proceed_Pay") ?? "Proceed to pay")", for: .normal)
        proceedToPayBtn.layer.cornerRadius = proceedToPayBtn.frame.size.height / 2
        proceedToPayBtn.layer.masksToBounds = true
        if Utility.shared.isRTLLanguage(){
            backBtn.rotateImageViewofBtn()
        }
        setdropdown()
        
    }
    
    
    func updateCurrencyTypes(){
        currencyPaymentTypes?.removeAll()
        for currency in Utility.shared.currencyDataArray {
            if currency.isPayment ?? false{
                currencyPaymentTypes?.append(currency)
            }
        }
    }
    
    
    func setdropdown()
    {
        inputUIView.frame = CGRect(x: 0, y: FULLHEIGHT-200, width: FULLWIDTH, height: 200)
        inputPickerView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 200)
        inputUIView.addSubview(inputPickerView)
        inputPickerView.delegate = self
        inputPickerView.dataSource = self
        inputPickerView.tintColor = Theme.PRIMARY_COLOR
        inputPickerView.backgroundColor = UIColor(named: "colorController")
        inputPickerView.reloadAllComponents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let shadowSize : CGFloat = 3.0
        
        
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: self.bottomView.frame.size.width+40 + shadowSize,
                                                   height: self.bottomView.frame.size.height + shadowSize))
        
    }
    @IBAction func backBtnActionTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func configurePaypalCheckOut(){
        
        
    }
    
    @IBAction func proceedToPayTapped(_ sender: UIButton) {
        
        if self.selectedPaymentType == nil{
            self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey: "Select_Payment_Type") ?? "Please select Payment type")")
        }else if self.selectedPaymentType == 0 && self.selectedCurrency == ""{
            self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey: "Select_Currency_Error") ?? "Please select currency")")
        }else{
            if self.selectedPaymentType == 1{
                self.postRazorPayAPI()
                
//                if let vc = UIApplication.getTopViewController()  {
//                    print("---\(vc)")
//                    self.showPaymentForm()
//                }
                
                
              //  self.stripePayments()
            }else{
                self.lottieAnimation()
                self.PaymentAPICall(cardtoken: "")
            }
        }
        
    }
    
//    func stripePayments(){
//        let addCardViewController = STPAddCardViewController()
//        
//        addCardViewController.delegate = self
//        
//        let navigationController = UINavigationController(rootViewController: addCardViewController)
//        
//        navigationController.modalPresentationStyle = .fullScreen
//        self.present(navigationController, animated: true)
//    }
    
    func confirmPaymentCall(reservationId:Int,paymentIntentId:String){
        let confirmpaymentmutation = ConfirmReservationMutation(reservationId: reservationId, paymentIntentId: paymentIntentId)
        apollo_headerClient.perform(mutation: confirmpaymentmutation){(result,error) in
            
            if(result?.data?.confirmReservation?.status == 200)
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"paymentsuccess"))!)")
                if #available(iOS 11.0, *) {
                    Utility.shared.PreApprovedID = false
                    let itenaryPageObj = BookingItenaryVC()
                    Utility.shared.isfromTripsPage = false
                    itenaryPageObj.viewListingArray = self.viewListingArray
                    itenaryPageObj.getbillingArray = self.getbillingArray
                    itenaryPageObj.currencyvalue_from_API_base = self.currencyvalue_from_API_base
                    itenaryPageObj.createReservationAPICall(reservationid:reservationId)
                    self.lottieWholeView.isHidden = true
                    self.lottieView.isHidden = true
                    Utility.shared.guestc = ""
                    itenaryPageObj.isFromReviewPage = false
                    itenaryPageObj.modalPresentationStyle = .fullScreen
                    self.present(itenaryPageObj, animated: true, completion: nil)
                }
            }
            else if(result?.data?.confirmReservation?.status == 400)
            {
                self.handlePayment(reservationId:reservationId, paymentIntentId: paymentIntentId)
            }else if result?.data?.confirmReservation?.status == 500{
                self.lottieWholeView.isHidden = true
                self.lottieView.isHidden = true
                let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message: result?.data?.confirmReservation?.errorMessage, preferredStyle: .alert)
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
            }
        }
    }
    
    func PaymentAPICall(cardtoken:String)
    {
        var currency_con = String()
        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
        {
            currency_con = Utility.shared.getPreferredCurrency()!
        }
        else
        {
            currency_con = self.currencyvalue_from_API_base
        }
        var discountLabel = String()
        if(getbillingArray.discountLabel == nil)
        {
            discountLabel = ""
        }
        else
        {
            discountLabel = getbillingArray.discountLabel!
        }
        
        var bookedArrayType = String()
        if keyInstant != "" {
            bookedArrayType = "instant"
        } else {
            if Utility.shared.PreApprovedID{
                
                bookedArrayType = "instant"
                
            }else{
                
                bookedArrayType = viewListingArray.bookingType!
                
            }
        }
        
        
        
       
//        let paymentMutation = CreateReservationMutation(listId: viewListingArray.id!, checkIn: getbillingArray.checkIn!, checkOut: getbillingArray.checkOut!, guests: Utility.shared.guestCountToBeSend, message: Utility.shared.booking_message, basePrice: getbillingArray.averagePrice!, cleaningPrice: getbillingArray.cleaningPrice!, currency: getbillingArray.currency!, discount: getbillingArray.discount!,discountType:getbillingArray.discountLabel, guestServiceFee: getbillingArray.guestServiceFee!, hostServiceFee: getbillingArray.hostServiceFee!, total: getbillingArray.total!, bookingType: bookedArrayType, cardToken: cardtoken, paymentType: self.selectedPaymentType == 1 ? 2 : self.selectedPaymentType, convCurrency: currency_con,averagePrice:getbillingArray.averagePrice!, nights:getbillingArray.nights!, paymentCurrency: self.selectedCurrency,threadId: threadId)
        
        var gstCnt = 0
        if self.additionalGuestCount == "" {
            gstCnt  = 0
        } else {
            gstCnt = Int(self.additionalGuestCount) ?? 0
        }
        if self.isFromm == "insss" {
            Utility.shared.guestCountToBeSend = Utility.shared.guestCountToBeSend + gstCnt
        }
        let paymentMutation = CreateReservationMutationn(listId: viewListingArray.id!
                                                         , checkIn: getbillingArray.checkIn!
                                                         , checkOut: getbillingArray.checkOut!
                                                         , guests: Utility.shared.guestCountToBeSend
                                                         , pets: Utility.shared.petLimitToBeSend
                                                         , infants: Utility.shared.infantLimitToBeSend
                                                         , visitors: Utility.shared.visitorToBeSend
                                                         , petPrice: self.totalPetPrice
                                                         , visitorsPrice: self.totalVisitorPrice
                                                         , infantPrice: self.totalInfantPrice
                                                         , additionalPrice: self.totalAdditionalPrice
                                                         , additionalGuest: gstCnt
                                                         , razorpayOrderId: ""
                                                         , razorpayPaymentId: ""
                                                         , message: Utility.shared.booking_message
                                                         , basePrice: getbillingArray.averagePrice!
                                                         , cleaningPrice: getbillingArray.cleaningPrice!
                                                         , currency: getbillingArray.currency!
                                                         , discount: getbillingArray.discount!
                                                         , discountType:getbillingArray.discountLabel
                                                         , guestServiceFee: getbillingArray.guestServiceFee!
                                                         , hostServiceFee: getbillingArray.hostServiceFee!
                                                         , total: getbillingArray.total!
                                                         , bookingType: bookedArrayType
                                                         , cardToken: cardtoken
                                                         , paymentType: self.selectedPaymentType == 1 ? 2 : self.selectedPaymentType
                                                         , convCurrency: currency_con
//                                                         ,averagePrice:getbillingArray.averagePrice!
                                                         , nights:getbillingArray.nights!
                                                         , paymentCurrency: self.selectedCurrency
                                                         ,threadId: threadId)
    
        
        apollo_headerClient.perform(mutation: paymentMutation){ (result,error) in
            if(result?.data?.createReservation?.status == 400)
            {
                self.lottieWholeView.isHidden = true
                self.lottieView.isHidden = true
                if(result?.data?.createReservation?.reservationId != nil && result?.data?.createReservation?.paymentIntentSecret != nil)
                {
                    self.handlePayment(reservationId: (result?.data?.createReservation?.reservationId!)!, paymentIntentId: (result?.data?.createReservation?.paymentIntentSecret!)!)
                }
                else{
                    self.view.makeToast(result?.data?.createReservation?.errorMessage!)
                }
                return
            }else if result?.data?.createReservation?.status == 500{
                self.lottieWholeView.isHidden = true
                self.lottieView.isHidden = true
                let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message: result?.data?.createReservation?.errorMessage, preferredStyle: .alert)
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
                Utility.shared.guestCountToBeSend = 1
                if self.selectedPaymentType == 0 {
                    if result?.data?.createReservation?.results?.paymentState == "pending"{
                        let webviewObj = WebviewVC()
                        
                        self.reservID = result?.data?.createReservation?.results?.id ?? 0
                        webviewObj.isForPayPal = true
                        webviewObj.delegate = self
                        webviewObj.webstring = result?.data?.createReservation?.redirectUrl ?? ""
                        webviewObj.pageTitle = ""
                        webviewObj.modalPresentationStyle = .fullScreen
                        webviewObj.webviewRedirection(webviewString:result?.data?.createReservation?.redirectUrl ?? "")
                        self.present(webviewObj, animated: true, completion: nil)
                    }else{
                        
                    }
                }else{
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"paymentsuccess"))!)")
                    if #available(iOS 11.0, *) {
                        Utility.shared.PreApprovedID = false
                        let itenaryPageObj = BookingItenaryVC()
                        Utility.shared.isfromTripsPage = false
                        itenaryPageObj.getbillingArray = self.getbillingArray
                        itenaryPageObj.currencyvalue_from_API_base = self.currencyvalue_from_API_base
                        itenaryPageObj.isFromReviewPage = false
                        itenaryPageObj.createReservationAPICall(reservationid: (result?.data?.createReservation?.results?.id)!)
                        self.lottieWholeView.isHidden = true
                        self.lottieView.isHidden = true
                        itenaryPageObj.modalPresentationStyle = .fullScreen
                        Utility.shared.guestc = ""
                        self.present(itenaryPageObj, animated: true, completion: nil)
                    } else {
                     
                    }
                }
            }
        }
        
        
        
    }
    
    
    func createRes() {
        
        var currency_con = String()
        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
        {
            currency_con = Utility.shared.getPreferredCurrency()!
        }
        else
        {
            currency_con = self.currencyvalue_from_API_base
        }
        var discountLabel = String()
        if(getbillingArray.discountLabel == nil)
        {
            discountLabel = ""
        }
        else
        {
            discountLabel = getbillingArray.discountLabel!
        }
        
        
        var bookedArrayType = String()
//        if Utility.shared.PreApprovedID{
//            
//            bookedArrayType = "instant"
//            
//        }else{
//            
//            bookedArrayType = viewListingArray.bookingType!
//            
//        }
        
        
        if keyInstant != "" {
            bookedArrayType = "instant"
        } else {
            if Utility.shared.PreApprovedID{
                
                bookedArrayType = "instant"
                
            }else{
                
                bookedArrayType = viewListingArray.bookingType!
                
            }
        }
        var gstCnt = 0
        if self.additionalGuestCount == "" {
            gstCnt  = 0
        } else {
            gstCnt = Int(self.additionalGuestCount) ?? 0
        }
        if self.isFromm == "insss" {
            Utility.shared.guestCountToBeSend = Utility.shared.guestCountToBeSend + gstCnt
        }
        let paymentMutation = CreateReservationMutationn(listId: viewListingArray.id!
                                                         , checkIn: getbillingArray.checkIn!
                                                         , checkOut: getbillingArray.checkOut!
                                                         , guests: Utility.shared.guestCountToBeSend
                                                         , pets: Utility.shared.petLimitToBeSend
                                                         , infants: Utility.shared.infantLimitToBeSend
                                                         , visitors: Utility.shared.visitorToBeSend
                                                         , petPrice: self.totalPetPrice
                                                         , visitorsPrice: self.totalVisitorPrice
                                                         , infantPrice: self.totalInfantPrice
                                                         , additionalPrice: self.totalAdditionalPrice
                                                         , additionalGuest: gstCnt //Int(self.additionalGuestCount == "" ? "0" : self.additionalGuestCount)
                                                         , razorpayOrderId: self.orderId
                                                         , razorpayPaymentId: self.razorResId
                                                         , message: Utility.shared.booking_message
                                                         , basePrice: getbillingArray.averagePrice!
                                                         , cleaningPrice: getbillingArray.cleaningPrice!
                                                         , currency: getbillingArray.currency!
                                                         , discount: getbillingArray.discount!
                                                         , discountType:(getbillingArray.discountLabel == nil ? "" : getbillingArray.discountLabel)!
                                                         , guestServiceFee: getbillingArray.guestServiceFee!
                                                         , hostServiceFee: getbillingArray.hostServiceFee!
                                                         , total: getbillingArray.total!
                                                         , bookingType: bookedArrayType
                                                         , cardToken: ""
                                                         , paymentType: self.selectedPaymentType == 1 ? 2 : self.selectedPaymentType
                                                         , convCurrency: currency_con
                                                         //                                                         ,averagePrice:getbillingArray.averagePrice!
                                                         , nights:getbillingArray.nights!
                                                         , paymentCurrency: self.selectedCurrency
                                                         , threadId: threadId)
        
    
        
        apollo_headerClient.perform(mutation: paymentMutation){ (result,error) in
            
            if let error = error as? GraphQLHTTPResponseError, let data = error.body {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("Error details: \(json)")
                }
            }
            
            if(result?.data?.createReservation?.status == 400)
            {
                self.lottieWholeView.isHidden = true
                self.lottieView.isHidden = true
                if(result?.data?.createReservation?.reservationId != nil && result?.data?.createReservation?.paymentIntentSecret != nil)
                {
                    
                    self.handlePayment(reservationId: (result?.data?.createReservation?.reservationId!)!, paymentIntentId: (result?.data?.createReservation?.paymentIntentSecret!)!)
                }
                else{
                    self.view.makeToast(result?.data?.createReservation?.errorMessage!)
                }
                return
            }else if result?.data?.createReservation?.status == 500{
                self.lottieWholeView.isHidden = true
                self.lottieView.isHidden = true
                let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message: result?.data?.createReservation?.errorMessage, preferredStyle: .alert)
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
                
                self.resssToken = result?.data?.createReservation?.reservationId ?? 0
                self.verifyRazorPayAPI()
                
//                Utility.shared.guestCountToBeSend = 1
//                if self.selectedPaymentType == 0 {
//                    if result?.data?.createReservation?.results?.paymentState == "pending"{
//                        let webviewObj = WebviewVC()
//                        
//                        self.reservID = result?.data?.createReservation?.results?.id ?? 0
//                        webviewObj.isForPayPal = true
//                        webviewObj.delegate = self
//                        webviewObj.webstring = result?.data?.createReservation?.redirectUrl ?? ""
//                        webviewObj.pageTitle = ""
//                        webviewObj.modalPresentationStyle = .fullScreen
//                        webviewObj.webviewRedirection(webviewString:result?.data?.createReservation?.redirectUrl ?? "")
//                        self.present(webviewObj, animated: true, completion: nil)
//                    }else{
//                        
//                    }
////                }else{
//                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"paymentsuccess"))!)")
//                    if #available(iOS 11.0, *) {
//                        Utility.shared.PreApprovedID = false
//                        let itenaryPageObj = BookingItenaryVC()
//                        Utility.shared.isfromTripsPage = false
//                        itenaryPageObj.getbillingArray = self.getbillingArray
//                        itenaryPageObj.currencyvalue_from_API_base = self.currencyvalue_from_API_base
//                        itenaryPageObj.isFromReviewPage = false
//                        itenaryPageObj.createReservationAPICall(reservationid: (result?.data?.createReservation?.results?.id!)!)
//                        self.lottieWholeView.isHidden = true
//                        self.lottieView.isHidden = true
//                        itenaryPageObj.modalPresentationStyle = .fullScreen
//                        Utility.shared.guestc = ""
//                        self.present(itenaryPageObj, animated: true, completion: nil)
//                    } else {
//                     
//                    }
//                }
            }
        }
    }
    @objc func dismissgenderPicker(text:Int) {
        view.endEditing(true)
    }
    
    @objc func countryBtnTapped(_ sender: UIButton){
        let cell = view.viewWithTag(sender.tag + 8000) as! PaymentFooterCell
        cell.txtFiled.becomeFirstResponder()
    }
    
    func postRazorPayAPI() {
        let url = URL(string: "https://www.airhomestays.com/createOrder")!
        let body: [String: Any] = [
            "amount": Int((self.getbillingArray.total ?? Double(0.0)) * 100.0), //Double(self.getbillingArray.total ?? Double(0.0)),
            "currency": "\((self.getbillingArray.currency ?? "INR"))",
//            "receipt": "\(self.razorResId)",
//            "notes": [
//                "notes_key_1": "Tea, Earl Grey, Hot",
//                "notes_key_2": "Tea, Earl Grey… decaf."
//            ]
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            print("Error: Could not create JSON data from the body dictionary")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        // Optional: Add authorization header (if required)
        // request.setValue("Basic <base64_encoded_credentials>", forHTTPHeaderField: "Authorization")

        // Create a data task to send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error: Server responded with an error")
                return
            }
            
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("Response JSON: \(json)")
                            let dct = json["data"] as? NSDictionary
                            self.orderId = dct?["id"] as? String ?? ""
                            if let vc = UIApplication.getTopViewController()  {
                                print("---\(vc)")
                                self.showPaymentForm()
                            }
                            
    //                        self.showPaymentForm()
                        }
                    } catch {
                        print("Error: Could not parse JSON response")
                    }
                }
            }
            
        }
        task.resume()

    }
    
    // verify Payment {"razorpay_payment_id":"pay_OhVtOv0FxO1Uai","razorpay_order_id":"order_OhVsEsmMwwGRGf","razorpay_signature":"8bd682ff4b7e348a104e96d2ad4cfdfe10e8c713a76f9dadb1b87fde167bd504","reservation_id":104,"total_amount":178000}
    //orderId, signature, paymentId
    
    func verifyRazorPayAPI() {
//        let url = URL(string: "https://api.razorpay.com/v1/orders")!
        let url = URL(string: "https://www.airhomestays.com/verifyPayment")!
        let body: [String: Any] = [
            "razorpay_payment_id": razorResId,
            "razorpay_order_id": self.orderId,
            "razorpay_signature": "",
            "reservation_id": "\(self.resssToken)", //"\(self.reservID)",
            "total_amount": "\(Double(self.getbillingArray.total ?? Double(0.0)))"
//            ]
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            print("Error: Could not create JSON data from the body dictionary")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        // Optional: Add authorization header (if required)
        // request.setValue("Basic <base64_encoded_credentials>", forHTTPHeaderField: "Authorization")

        // Create a data task to send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("Error: Server responded with an error")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self.goToItenary()
                }
            }
            
//            if let data = data {
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        print("Response JSON: \(json)")
//                        self.showPaymentForm()
//                    }
//                } catch {
//                    print("Error: Could not parse JSON response")
//                }
//            }
        }
        task.resume()

    }
    func goToItenary() {
        let receiptPageObj = BookingItenaryVC()
        receiptPageObj.isFromReviewPage = true
        receiptPageObj.reservID = self.resssToken
        
//        receiptPageObj.getbillingArray = self.getbillingArray
//        receiptPageObj.currencyvalue_from_API_base = self.currencyvalue_from_API_base
//        receiptPageObj.isFromReviewPage = false
//        receiptPageObj.createReservationAPICall(reservationid: self.reservID)
        
        receiptPageObj.modalPresentationStyle = .fullScreen
        self.present(receiptPageObj, animated: true, completion: nil)
    }
}

extension PaymentSelectionPage: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return getpaymentmethodsArrayFilter.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PaymentCell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        cell.selectionStyle = .none
        
        if(indexPath.section == 0) {
            if("\((getpaymentmethodsArrayFilter[indexPath.section].id!))" == "1")
            {
                cell.typeImg.image = #imageLiteral(resourceName: "paypal")
                cell.lineLbl.isHidden = self.selectedPaymentType == 0
            }
            else {
                cell.typeImg.image = UIImage(named: "razorpay")
                cell.lineLbl.isHidden = true
                self.selectedPaymentType = 1
            }
        }
        else {
            cell.typeImg.image = UIImage(named: "razorpay")
            cell.lineLbl.isHidden = true
        }
        cell.lineLbl.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        if("\((getpaymentmethodsArrayFilter[indexPath.section].id!))" == "1")
        {
            cell.aboutLabel.text = availablePaymentTypes[0]
        }
        else {
            cell.aboutLabel.text = availablePaymentTypes[1]
        }
        cell.aboutLabel.textColor = UIColor(named: "Title_Header")
        cell.tag = indexPath.section + 6000
        if("\((getpaymentmethodsArrayFilter[indexPath.section].id!))" == "1")
        {
            if self.selectedPaymentType == indexPath.section{
                cell.rightArrowimg.image = #imageLiteral(resourceName: "verify-round")
            }else{
                cell.rightArrowimg.image = #imageLiteral(resourceName: "price_unclick")
            }
        }
        else {
            if getpaymentmethodsArrayFilter.count == 1 {
                if self.selectedPaymentType == 1 {
                    cell.rightArrowimg.image = #imageLiteral(resourceName: "verify-round")
                }
            }
            else {
                if self.selectedPaymentType == indexPath.section{
                    cell.rightArrowimg.image = #imageLiteral(resourceName: "verify-round")
                }else{
                    cell.rightArrowimg.image = #imageLiteral(resourceName: "price_unclick")
                }
            }
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedPaymentType != indexPath.section{
            self.selectedPaymentType = indexPath.section
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 && self.selectedPaymentType == 0 &&  ("\((getpaymentmethodsArrayFilter[section].id!))" == "1") ? 80 : 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView : PaymentFooterCell = tableView.dequeueReusableCell(withIdentifier: "PaymentFooterCell") as! PaymentFooterCell
        footerView.txtFiled.placeholder = "\(Utility.shared.getLanguage()?.value(forKey: "currency") ?? "Currency")"
        if(section == 0 && self.selectedPaymentType == 0) {
            let cell = view.viewWithTag(section + 6000) as! PaymentCell
            cell.lineLbl.isHidden = true
        }
        footerView.lineview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        footerView.tag = section + 8000
        footerView.countryBtn.addTarget(self, action: #selector(countryBtnTapped), for: .touchUpInside)
        footerView.txtFiled.tag = section
        footerView.countryBtn.tag = section
        footerView.txtFiled.font = UIFont(name: APP_FONT, size:14)
        let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
        toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
        footerView.txtFiled.inputAccessoryView = toolBar
        footerView.txtFiled.inputView = inputPickerView
        footerView.txtFiled.tintColor = UIColor.clear
        footerView.txtFiled.delegate = self
        footerView.txtFiled.text = selectedCurrency
        footerView.txtFiled.textColor = Theme.PRIMARY_COLOR
        
        return footerView
    }
}


extension PaymentSelectionPage: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyPaymentTypes?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var titleData = ""
        
        titleData =  currencyPaymentTypes?[row].symbol ?? "USD"
        
        let myTitle = NSAttributedString(string: titleData , attributes: [NSAttributedString.Key.font:UIFont(name: APP_FONT, size: 15.0)!,NSAttributedString.Key.foregroundColor:Theme.PRIMARY_COLOR])
        
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCurrency = currencyPaymentTypes?[row].symbol ?? ""
    }
    
}

extension PaymentSelectionPage: UITextFieldDelegate , WebviewVCDelegate{
    
    
    func setPayoutCall(accountid: String) {
        
    }
    
    func onSuccessPayPalPayment(isSuccess: Bool, toastermsg: String,successURL: URL?) {
        if isSuccess{
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"paymentsuccess"))!)")
            
            let urlQuery = successURL?.query
            let arrayOfQuery = urlQuery?.split(separator: "&")
            let paymentID = arrayOfQuery?.first?.split(separator: "=")
            let payerID = arrayOfQuery?.last?.split(separator: "=")
           
            self.ConfirmPayPal(paymentID: "\(paymentID?.last ?? "")", PayerID: "\(payerID?.last ?? "")")
            
        }else{
            self.lottieView.isHidden = true
            self.lottieWholeView.isHidden = true
        }
    }
    
    
    func ConfirmPayPal(paymentID: String, PayerID: String){
        
        
        let confirmPayPal = ConfirmPayPalExecuteMutation(paymentId: paymentID, payerId: PayerID)
        
        apollo_headerClient.perform(mutation: confirmPayPal){(result,error) in
            guard let result = result , error == nil else {
                self.lottieView.isHidden = true
                self.lottieWholeView.isHidden = true
                self.view.makeToast(error?.localizedDescription)
                return
            }
            
            if result.data?.confirmPayPalExecute?.status == 200 {
                if #available(iOS 11.0, *) {
                    Utility.shared.PreApprovedID = false
                    self.lottieView.isHidden = true
                    self.lottieWholeView.isHidden = true
                    let itenaryPageObj = BookingItenaryVC()
                    Utility.shared.isfromTripsPage = false
                    itenaryPageObj.getbillingArray = self.getbillingArray
                    itenaryPageObj.currencyvalue_from_API_base = self.currencyvalue_from_API_base
                    itenaryPageObj.isFromReviewPage = false
                    itenaryPageObj.createReservationAPICall(reservationid: self.reservID)
                    self.lottieWholeView.isHidden = true
                    self.lottieView.isHidden = true
                    Utility.shared.guestc = ""
                    itenaryPageObj.modalPresentationStyle = .fullScreen
                    self.present(itenaryPageObj, animated: true, completion: nil)
                } else {
                  
                }
            }else if result.data?.confirmPayPalExecute?.status == 500{
                self.lottieWholeView.isHidden = true
                self.lottieView.isHidden = true
                let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message: result.data?.confirmPayPalExecute?.errorMessage, preferredStyle: .alert)
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
                self.view.makeToast(result.data?.confirmPayPalExecute?.errorMessage ?? "")
            }
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.inputPickerView.reloadAllComponents()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if currencyPaymentTypes?.count != 0{
            selectedCurrency = (selectedCurrency != "" ? selectedCurrency : currencyPaymentTypes?[0].symbol) ?? ""
        }
        tableView.reloadData()
    }
}


extension PaymentSelectionPage: STPAddCardViewControllerDelegate,STPPaymentCardTextFieldDelegate{
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        self.lottieAnimation()
      
        self.PaymentAPICall(cardtoken: "\(paymentMethod.stripeId)")
        dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
    }
    func handlePayment(reservationId:Int,paymentIntentId:String) {
        
        STPPaymentHandler.shared().handleNextAction(
            forPayment: paymentIntentId,
            with:self,
            returnURL: nil,
            completion: { status, paymentIntent, error in
                if case .succeeded = status, let paymentIntent = paymentIntent {
                    
                    self.lottieAnimation()
                    self.confirmPaymentCall(reservationId: reservationId, paymentIntentId:"\(paymentIntent.stripeId)")
                } else {
                 
                    self.lottieView.isHidden = true
                    self.lottieWholeView.isHidden = true
                }
            })
        
    }
}



extension PaymentSelectionPage: STPAuthenticationContext {
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        
    }
    
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}


extension UIApplication {
    class func getTopViewController(base: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

//(
//    $listId: Int!, $checkIn: String!, $checkOut: String!, $guests: Int!, $pets: Int,
//    $infants: Int, $visitors: Int, $petPrice: Float, $visitorsPrice: Float, $infantPrice: Float,
//    $additionalPrice: Float, $additionalGuest: Int, $razorpayOrderId: String, $razorpayPaymentId: String,
//    $message: String!, $basePrice: Float!, $cleaningPrice: Float!, $currency: String!, $discount: Float,
//    $discountType: String, $guestServiceFee: Float, $hostServiceFee: Float, $total: Float!, $bookingType: String,
//    $cardToken: String!, $paymentType: Int, $convCurrency: String!, $averagePrice: Float, $nights: Int,
//    $paymentCurrency: String, $threadId: Int
//)

public final class CreateReservationMutationn: GraphQLMutation {
  public let operationDefinition =
    "mutation createReservation($listId: Int!, $checkIn: String!, $checkOut: String!, $guests: Int!, $pets: Int!,$infants: Int!, $visitors: Int!, $petPrice: Float!, $visitorsPrice: Float!, $infantPrice: Float!, $additionalPrice: Float!, $additionalGuest: Int!, $razorpayOrderId: String!, $razorpayPaymentId: String!, $message: String!, $basePrice: Float!, $cleaningPrice: Float!, $currency: String!, $discount: Float, $discountType: String, $guestServiceFee: Float, $hostServiceFee: Float, $total: Float!, $bookingType: String, $cardToken: String!, $paymentType: Int, $convCurrency: String!, $averagePrice: Float, $nights: Int, $paymentCurrency: String, $threadId: Int) {\n  createReservation(listId: $listId, checkIn: $checkIn, checkOut: $checkOut, guests: $guests, pets: $pets, infants: $infants, visitors: $visitors, petPrice: $petPrice, visitorsPrice: $visitorsPrice, infantPrice: $infantPrice, additionalPrice: $additionalPrice, additionalGuest: $additionalGuest, razorpayOrderId: $razorpayOrderId, razorpayPaymentId: $razorpayPaymentId, message: $message, basePrice: $basePrice, cleaningPrice: $cleaningPrice, currency: $currency, discount: $discount, discountType: $discountType, guestServiceFee: $guestServiceFee, hostServiceFee: $hostServiceFee, total: $total, bookingType: $bookingType, cardToken: $cardToken, paymentType: $paymentType, convCurrency: $convCurrency, averagePrice: $averagePrice, nights: $nights, paymentCurrency: $paymentCurrency, threadId: $threadId) {\n    __typename\n    results {\n      __typename\n      id\n      listId\n      hostId\n      guestId\n      checkIn\n      checkOut\n      guests\n      pets\n      infants\n      visitors\n      message\n      basePrice\n      cleaningPrice\n      currency\n      discount\n      discountType\n      guestServiceFee\n      hostServiceFee\n      total\n      confirmationCode\n      createdAt\n      reservationState\n      paymentState\n    }\n    status\n    errorMessage\n    requireAdditionalAction\n    paymentIntentSecret\n    reservationId\n    redirectUrl\n  }\n}"

  public var listId: Int
  public var checkIn: String
  public var checkOut: String
  public var guests: Int
    public var pets: Int
    public var infants: Int
    public var visitors: Int
    public var petPrice: Double
    public var visitorsPrice: Double
    public var infantPrice: Double
    public var additionalPrice: Double
    public var additionalGuest: Int
    public var razorpayOrderId: String
    public var razorpayPaymentId: String
  public var message: String
  public var basePrice: Double
  public var cleaningPrice: Double
  public var currency: String
  public var discount: Double?
  public var discountType: String?
  public var guestServiceFee: Double?
  public var hostServiceFee: Double?
  public var total: Double
  public var bookingType: String?
  public var cardToken: String
  public var paymentType: Int?
  public var convCurrency: String
  public var averagePrice: Double?
  public var nights: Int?
  public var paymentCurrency: String?
  public var threadId: Int?

  public init(listId: Int, checkIn: String, checkOut: String, guests: Int, pets: Int, infants: Int, visitors: Int, petPrice: Double, visitorsPrice: Double, infantPrice: Double, additionalPrice: Double, additionalGuest: Int, razorpayOrderId: String, razorpayPaymentId: String, message: String, basePrice: Double, cleaningPrice: Double, currency: String, discount: Double? = nil, discountType: String? = nil, guestServiceFee: Double? = nil, hostServiceFee: Double? = nil, total: Double, bookingType: String? = nil, cardToken: String, paymentType: Int? = nil, convCurrency: String, averagePrice: Double? = nil, nights: Int? = nil, paymentCurrency: String? = nil, threadId: Int? = nil) {
    self.listId = listId
    self.checkIn = checkIn
    self.checkOut = checkOut
    self.guests = guests
      self.pets = pets
      self.infants = infants
      self.visitors = visitors
      self.petPrice = petPrice
      self.visitorsPrice = visitorsPrice
      self.infantPrice = infantPrice
      self.additionalPrice = additionalPrice
      self.additionalGuest = additionalGuest
      self.razorpayOrderId = razorpayOrderId
      self.razorpayPaymentId = razorpayPaymentId
    self.message = message
    self.basePrice = basePrice
    self.cleaningPrice = cleaningPrice
    self.currency = currency
    self.discount = discount
    self.discountType = discountType
    self.guestServiceFee = guestServiceFee
    self.hostServiceFee = hostServiceFee
    self.total = total
    self.bookingType = bookingType
    self.cardToken = cardToken
    self.paymentType = paymentType
    self.convCurrency = convCurrency
    self.averagePrice = averagePrice
    self.nights = nights
    self.paymentCurrency = paymentCurrency
    self.threadId = threadId
  }

  public var variables: GraphQLMap? {
    return ["listId": listId, "checkIn": checkIn, "checkOut": checkOut, "guests": guests, "pets": pets, "infants": infants, "visitors": visitors, "petPrice": petPrice, "visitorsPrice": visitorsPrice, "infantPrice": infantPrice, "additionalPrice": additionalPrice, "additionalGuest": additionalGuest, "razorpayOrderId": razorpayOrderId, "razorpayPaymentId": razorpayPaymentId, "message": message, "basePrice": basePrice, "cleaningPrice": cleaningPrice, "currency": currency, "discount": discount, "discountType": discountType, "guestServiceFee": guestServiceFee, "hostServiceFee": hostServiceFee, "total": total, "bookingType": bookingType, "cardToken": cardToken, "paymentType": paymentType, "convCurrency": convCurrency, "averagePrice": averagePrice, "nights": nights, "paymentCurrency": paymentCurrency, "threadId": threadId]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createReservation", arguments: ["listId": GraphQLVariable("listId"), "checkIn": GraphQLVariable("checkIn"), "checkOut": GraphQLVariable("checkOut")
                                                    , "guests": GraphQLVariable("guests")
                                                    , "pets": GraphQLVariable("pets")
                                                    , "infants": GraphQLVariable("infants")
                                                    , "visitors": GraphQLVariable("visitors")
                                                    , "petPrice": GraphQLVariable("petPrice")
                                                    , "visitorsPrice": GraphQLVariable("visitorsPrice")
                                                    , "infantPrice": GraphQLVariable("infantPrice")
                                                    , "additionalPrice": GraphQLVariable("additionalPrice")
                                                    , "additionalGuest": GraphQLVariable("additionalGuest")
                                                    , "razorpayOrderId": GraphQLVariable("razorpayOrderId")
                                                    , "razorpayPaymentId": GraphQLVariable("razorpayPaymentId")
                                                    
                                                    , "message": GraphQLVariable("message"), "basePrice": GraphQLVariable("basePrice"), "cleaningPrice": GraphQLVariable("cleaningPrice"), "currency": GraphQLVariable("currency"), "discount": GraphQLVariable("discount"), "discountType": GraphQLVariable("discountType"), "guestServiceFee": GraphQLVariable("guestServiceFee"), "hostServiceFee": GraphQLVariable("hostServiceFee"), "total": GraphQLVariable("total"), "bookingType": GraphQLVariable("bookingType"), "cardToken": GraphQLVariable("cardToken"), "paymentType": GraphQLVariable("paymentType"), "convCurrency": GraphQLVariable("convCurrency"), "averagePrice": GraphQLVariable("averagePrice"), "nights": GraphQLVariable("nights"), "paymentCurrency": GraphQLVariable("paymentCurrency"), "threadId": GraphQLVariable("threadId")], type: .object(CreateReservation.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createReservation: CreateReservation? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createReservation": createReservation.flatMap { (value: CreateReservation) -> ResultMap in value.resultMap }])
    }

    public var createReservation: CreateReservation? {
      get {
        return (resultMap["createReservation"] as? ResultMap).flatMap { CreateReservation(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createReservation")
      }
    }

    public struct CreateReservation: GraphQLSelectionSet {
      public static let possibleTypes = ["ReservationPayment"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("results", type: .object(Result.selections)),
        GraphQLField("status", type: .scalar(Int.self)),
        GraphQLField("errorMessage", type: .scalar(String.self)),
        GraphQLField("requireAdditionalAction", type: .scalar(Bool.self)),
        GraphQLField("paymentIntentSecret", type: .scalar(String.self)),
        GraphQLField("reservationId", type: .scalar(Int.self)),
        GraphQLField("redirectUrl", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(results: Result? = nil, status: Int? = nil, errorMessage: String? = nil, requireAdditionalAction: Bool? = nil, paymentIntentSecret: String? = nil, reservationId: Int? = nil, redirectUrl: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "ReservationPayment", "results": results.flatMap { (value: Result) -> ResultMap in value.resultMap }, "status": status, "errorMessage": errorMessage, "requireAdditionalAction": requireAdditionalAction, "paymentIntentSecret": paymentIntentSecret, "reservationId": reservationId, "redirectUrl": redirectUrl])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var results: Result? {
        get {
          return (resultMap["results"] as? ResultMap).flatMap { Result(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "results")
        }
      }

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

      public var requireAdditionalAction: Bool? {
        get {
          return resultMap["requireAdditionalAction"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "requireAdditionalAction")
        }
      }

      public var paymentIntentSecret: String? {
        get {
          return resultMap["paymentIntentSecret"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "paymentIntentSecret")
        }
      }

      public var reservationId: Int? {
        get {
          return resultMap["reservationId"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "reservationId")
        }
      }

      public var redirectUrl: String? {
        get {
          return resultMap["redirectUrl"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "redirectUrl")
        }
      }

      public struct Result: GraphQLSelectionSet {
        public static let possibleTypes = ["Reservation"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(Int.self)),
          GraphQLField("listId", type: .scalar(Int.self)),
          GraphQLField("hostId", type: .scalar(String.self)),
          GraphQLField("guestId", type: .scalar(String.self)),
          GraphQLField("checkIn", type: .scalar(String.self)),
          GraphQLField("checkOut", type: .scalar(String.self)),
          GraphQLField("guests", type: .scalar(Int.self)),
          GraphQLField("pets", type: .scalar(Int.self)),
          GraphQLField("infants", type: .scalar(Int.self)),
          GraphQLField("visitors", type: .scalar(Int.self)),
//          GraphQLField("petPrice", type: .scalar(Double.self)),
//          GraphQLField("visitorsPrice", type: .scalar(Double.self)),
//          GraphQLField("infantPrice", type: .scalar(Double.self)),
//          GraphQLField("additionalPrice", type: .scalar(Double.self)),
//          GraphQLField("additionalGuest", type: .scalar(Int.self)),
//          GraphQLField("razorpayOrderId", type: .scalar(String.self)),
//          GraphQLField("razorpayPaymentId", type: .scalar(String.self)),
          GraphQLField("message", type: .scalar(String.self)),
          GraphQLField("basePrice", type: .scalar(Double.self)),
          GraphQLField("cleaningPrice", type: .scalar(Double.self)),
          GraphQLField("currency", type: .scalar(String.self)),
          GraphQLField("discount", type: .scalar(Double.self)),
          GraphQLField("discountType", type: .scalar(String.self)),
          GraphQLField("guestServiceFee", type: .scalar(Double.self)),
          GraphQLField("hostServiceFee", type: .scalar(Double.self)),
          GraphQLField("total", type: .scalar(Double.self)),
          GraphQLField("confirmationCode", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .scalar(String.self)),
          GraphQLField("reservationState", type: .scalar(String.self)),
          GraphQLField("paymentState", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

          
        public init(id: Int? = nil, listId: Int? = nil, hostId: String? = nil, guestId: String? = nil, checkIn: String? = nil, checkOut: String? = nil, guests: Int? = nil
                    , pets: Int? = nil
                    , infants: Int? = nil
                    , visitors: Int? = nil
//                    , petPrice: Double? = nil
//                    , visitorsPrice: Double? = nil
//                    , infantPrice: Double? = nil
//                    , additionalPrice: Double? = nil
//                    , additionalGuest: Int? = nil
//                    , razorpayOrderId: String? = nil
//                    , razorpayPaymentId: String? = nil
                    , message: String? = nil, basePrice: Double? = nil, cleaningPrice: Double? = nil, currency: String? = nil, discount: Double? = nil, discountType: String? = nil, guestServiceFee: Double? = nil, hostServiceFee: Double? = nil, total: Double? = nil, confirmationCode: Int? = nil, createdAt: String? = nil, reservationState: String? = nil, paymentState: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Reservation", "id": id, "listId": listId, "hostId": hostId, "guestId": guestId, "checkIn": checkIn, "checkOut": checkOut, "guests": guests
                                      , "pets": pets
                                      , "infants": infants
                                      , "visitors": visitors
//                                      , "petPrice": petPrice
//                                      , "visitorsPrice": visitorsPrice
//                                      , "infantPrice": infantPrice
//                                      , "additionalPrice": additionalPrice
//                                      , "additionalGuest": additionalGuest
//                                      , "razorpayOrderId": razorpayOrderId
//                                      , "razorpayPaymentId": razorpayPaymentId
                                      , "message": message, "basePrice": basePrice, "cleaningPrice": cleaningPrice, "currency": currency, "discount": discount, "discountType": discountType, "guestServiceFee": guestServiceFee, "hostServiceFee": hostServiceFee, "total": total, "confirmationCode": confirmationCode, "createdAt": createdAt, "reservationState": reservationState, "paymentState": paymentState])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: Int? {
          get {
            return resultMap["id"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var listId: Int? {
          get {
            return resultMap["listId"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "listId")
          }
        }

        public var hostId: String? {
          get {
            return resultMap["hostId"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "hostId")
          }
        }

        public var guestId: String? {
          get {
            return resultMap["guestId"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "guestId")
          }
        }

        public var checkIn: String? {
          get {
            return resultMap["checkIn"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "checkIn")
          }
        }

        public var checkOut: String? {
          get {
            return resultMap["checkOut"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "checkOut")
          }
        }

        public var guests: Int? {
          get {
            return resultMap["guests"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "guests")
          }
        }
          
          
          public var pets: Int? {
            get {
              return resultMap["pets"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "pets")
            }
          }
          
          public var infants: Int? {
            get {
              return resultMap["infants"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "infants")
            }
          }
          
          public var visitors: Int? {
            get {
              return resultMap["visitors"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "visitors")
            }
          }
          
//          public var petPrice: Double? {
//            get {
//              return resultMap["petPrice"] as? Double
//            }
//            set {
//              resultMap.updateValue(newValue, forKey: "petPrice")
//            }
//          }
//          
//          public var visitorsPrice: Double? {
//            get {
//              return resultMap["visitorsPrice"] as? Double
//            }
//            set {
//              resultMap.updateValue(newValue, forKey: "visitorsPrice")
//            }
//          }
//          
//          public var infantPrice: Double? {
//            get {
//              return resultMap["infantPrice"] as? Double
//            }
//            set {
//              resultMap.updateValue(newValue, forKey: "infantPrice")
//            }
//          }
//          
//          public var additionalPrice: Double? {
//            get {
//              return resultMap["additionalPrice"] as? Double
//            }
//            set {
//              resultMap.updateValue(newValue, forKey: "additionalPrice")
//            }
//          }
//          
//          public var additionalGuest: Int? {
//            get {
//              return resultMap["additionalGuest"] as? Int
//            }
//            set {
//              resultMap.updateValue(newValue, forKey: "additionalGuest")
//            }
//          }
//          
//          public var razorpayOrderId: String? {
//            get {
//              return resultMap["razorpayOrderId"] as? String
//            }
//            set {
//              resultMap.updateValue(newValue, forKey: "razorpayOrderId")
//            }
//          }
//          
//          public var razorpayPaymentId: String? {
//            get {
//              return resultMap["razorpayPaymentId"] as? String
//            }
//            set {
//              resultMap.updateValue(newValue, forKey: "razorpayPaymentId")
//            }
//          }
          
          
          //    $guests: Int!, $pets: Int,
          //    $infants: Int, $visitors: Int, $petPrice: Float, $visitorsPrice: Float, $infantPrice: Float,
          //    $additionalPrice: Float, $additionalGuest: Int
          //)
          
          
        public var message: String? {
          get {
            return resultMap["message"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "message")
          }
        }

        public var basePrice: Double? {
          get {
            return resultMap["basePrice"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "basePrice")
          }
        }

        public var cleaningPrice: Double? {
          get {
            return resultMap["cleaningPrice"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "cleaningPrice")
          }
        }

        public var currency: String? {
          get {
            return resultMap["currency"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var discount: Double? {
          get {
            return resultMap["discount"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "discount")
          }
        }

        public var discountType: String? {
          get {
            return resultMap["discountType"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "discountType")
          }
        }

        public var guestServiceFee: Double? {
          get {
            return resultMap["guestServiceFee"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "guestServiceFee")
          }
        }

        public var hostServiceFee: Double? {
          get {
            return resultMap["hostServiceFee"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "hostServiceFee")
          }
        }

        public var total: Double? {
          get {
            return resultMap["total"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }

        public var confirmationCode: Int? {
          get {
            return resultMap["confirmationCode"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "confirmationCode")
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

        public var reservationState: String? {
          get {
            return resultMap["reservationState"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "reservationState")
          }
        }

        public var paymentState: String? {
          get {
            return resultMap["paymentState"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "paymentState")
          }
        }
      }
    }
  }
}


