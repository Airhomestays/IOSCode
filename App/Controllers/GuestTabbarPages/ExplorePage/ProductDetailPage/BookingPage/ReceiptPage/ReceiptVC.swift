

import UIKit
import WebKit
import PDFKit
import MKToolTip
import Apollo

@available(iOS 11.0, *)
class ReceiptVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate,UIPrintInteractionControllerDelegate{
    
    

    @IBOutlet weak var receiptTable: UITableView!
    @IBOutlet weak var topView: UIView!
    var documentInteractionController: UIDocumentInteractionController!
    
    var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    var getReservationArrayyy = GetReservationQueryy.Data.GetReservation()
    var getReservationArray = GetReservationQueryy.Data.GetReservation.Result()
     var getbillingArray = GetBillingCalculationQueryy.Data.GetBillingCalculation.Result()
    var getReservation_currencyArray = GetReservationQueryy.Data.GetReservation()
    var totalPriceLabel = String()
    var currencyvalue_from_API_base = String()
    var ISfromShortcut = false
    
    var dynamicPriceCells = 0
    var hasVisitor = false
    var hasPets = false
    var hasInfant = false
    var hasAdditionalGuests = false
    var hasGST = false
    var hasPAN = false
    var panValue = ""
    var gstValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchBankDetails()
        self.initialsetup()
//        setUp()
    }
    
    func setUp() {
        dynamicPriceCells = 0
        if self.getReservationArray.pets != nil && self.getReservationArray.pets != 0 {
            dynamicPriceCells = dynamicPriceCells + 1
            hasPets = true
        }
        if self.getReservationArray.infants != nil && self.getReservationArray.infants != 0 {
            dynamicPriceCells = dynamicPriceCells + 1
            hasInfant = true
        }
        if self.getReservationArray.visitors != nil && self.getReservationArray.visitors != 0 {
            dynamicPriceCells = dynamicPriceCells + 1
            hasVisitor = true
        }
        
        let totalGuests = self.getReservationArrayyy.results?.guests ?? 0//viewListingArray.listingData?.guestBasePrice ?? 0
        let additionalGsts = self.getReservationArrayyy.results?.additionalGuest ?? 0//self.getReservationArray.guests ?? 0
        let baseGsts = totalGuests - additionalGsts
        if self.getReservationArray.additionalGuest != nil && self.getReservationArray.additionalGuest != 0 {
            dynamicPriceCells = dynamicPriceCells + 1
            hasAdditionalGuests = true
        }
        
        
        self.view.backgroundColor = UIColor(named: "colorController")
        receiptTable.backgroundColor =  UIColor(named: "colorController")
        receiptTable.reloadData()
        let pdfFilePath = self.receiptTable.exportAsPdfFromTable()
        let url = URL(fileURLWithPath:pdfFilePath)
        self.documentInteractionController = UIDocumentInteractionController.init(url: url)
        self.documentInteractionController?.delegate = self
      
        if UIPrintInteractionController.canPrint(url) {
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.jobName = url.lastPathComponent
            printInfo.outputType = .photo
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            printController.showsNumberOfCopies = false
            printController.delegate = self
            printController.printingItem = url
            printController.present(animated:true, completionHandler: nil)
        }
        self.receiptTable.isHidden = true

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(AppBackGround), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    @objc func AppBackGround(){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func backbtnTapped(_ sender: Any) {
    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    func printInteractionControllerDidDismissPrinterOptions(_ printInteractionController: UIPrintInteractionController)
    {

        self.presentingViewController?.dismiss(animated: false, completion: {
            Utility.shared.isreceiptAccepted = true
            Utility.shared.isreceiptAcceptedHost = true
        })
    }
        
        func printInteractionControllerWillDismissPrinterOptions(_ printInteractionController: UIPrintInteractionController) {
            self.presentingViewController?.dismiss(animated: false, completion: {
                Utility.shared.isreceiptAccepted = true
                Utility.shared.isreceiptAcceptedHost = true
            })
         
        }
    
    
    func initialsetup()
    {
        if IS_IPHONE_XR || IS_IPHONE_X
        {
            self.topView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH-40, height: 80)
            receiptTable.frame = CGRect(x: 0, y: 85, width: FULLWIDTH-40, height: FULLHEIGHT-300)
            
        }
        
        let shadowSize : CGFloat = 3.0
        
        let shadowPath1 = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                    y: -shadowSize / 2,
                                                    width: self.topView.frame.size.width+40 + shadowSize,
                                                    height: self.topView.frame.size.height + shadowSize))
        
        self.topView.layer.masksToBounds = false
        self.topView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.topView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.topView.layer.shadowOpacity = 0.3
        self.topView.layer.shadowPath = shadowPath1.cgPath
        receiptTable.register(UINib(nibName: "customerReceiptCell", bundle: nil), forCellReuseIdentifier: "customerReceiptCell")
        receiptTable.register(UINib(nibName: "NameReceiptCell", bundle: nil), forCellReuseIdentifier: "NameReceiptCell")
         receiptTable.register(UINib(nibName: "AccommadationCell", bundle: nil), forCellReuseIdentifier: "AccommadationCell")
         receiptTable.register(UINib(nibName: "ItenarycheckCell", bundle: nil), forCellReuseIdentifier: "ItenarycheckCell")
         receiptTable.register(UINib(nibName: "RequestBookcellTableViewCell", bundle: nil), forCellReuseIdentifier: "RequestBookcellTableViewCell")
         receiptTable.register(UINib(nibName: "BookingTotalCell", bundle: nil), forCellReuseIdentifier: "BookingTotalCell")
        receiptTable.register(UINib(nibName: "RentpaymentReceiptCell", bundle: nil), forCellReuseIdentifier: "RentpaymentReceiptCell")
        receiptTable.register(UINib(nibName: "ReservationCell", bundle: nil), forCellReuseIdentifier: "ReservationCell")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
       
        return 8
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 5)
        {
            if(getReservationArray.cleaningPrice == 0 || getReservationArray.cleaningPrice == nil)
            {
                if(getReservationArray.discountType != nil && getReservationArray.discount != 0 && getReservationArray.taxPrice != 0.0 ) {
                    return 4 + self.dynamicPriceCells
                    
                }else if (getReservationArray.discountType != nil && getReservationArray.discount != 0){
                    
                    return 3 + self.dynamicPriceCells
                    
                } else if (getReservationArray.taxPrice != 0.0 ){
                    
                    return 3 + self.dynamicPriceCells
                }
                return 2 + self.dynamicPriceCells
                
            }else{
                
                if(getReservationArray.discountType != nil && getReservationArray.discount != 0 && getReservationArray.taxPrice != 0.0){
                    
                    return 5 + self.dynamicPriceCells
                    
                } else if (getReservationArray.discountType != nil && getReservationArray.discount != 0){
                    
                    return 4 + self.dynamicPriceCells
                    
                } else if (getReservationArray.taxPrice != 0.0){
                    
                    return 4 + self.dynamicPriceCells
                }
                return 3 + self.dynamicPriceCells
            }
        }
            return 1
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
            let getBankDetailsQuery = GetSecPaymentQuery(userId: Utility.shared.getCurrentUserID()! as String)
            apollo_headerClient.fetch(query:getBankDetailsQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                DispatchQueue.main.async {
                    guard (result?.data?.getSecPayment?.status) != nil else
                    {
                        if result?.data?.getSecPayment?.status == "500"{
                            self.view.makeToast("Server Error")
                            return
                        }else{
                            self.view.makeToast(result?.data?.getSecPayment?.errorMessage!)
                        return
                        }
                    }
                    if result?.data?.getSecPayment?.result?.accountHolderName != nil || result?.data?.getSecPayment?.result?.accountHolderName != "" {
                        if result?.data?.getSecPayment?.result?.gstNumber != nil && result?.data?.getSecPayment?.result?.gstNumber != "" {
                            self.hasGST = true
                            self.gstValue = result?.data?.getSecPayment?.result?.gstNumber ?? ""
                        }
                        if result?.data?.getSecPayment?.result?.panNumber != nil && result?.data?.getSecPayment?.result?.panNumber != "" {
                            self.hasPAN = true
                            self.panValue = result?.data?.getSecPayment?.result?.panNumber ?? ""
                        }
                    }
                    self.setUp()
//                    print("-->>>\((result?.data?.getSecPayment?.result)!)")
                }
            }
            
        } else {
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customerReceiptCell", for: indexPath)as! customerReceiptCell
            cell.receiptNumberLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"receipt"))!): #\(getReservationArray.id != nil ? getReservationArray.id! : 0)"
            cell.confirmCodeLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"confirmationcode"))!) \(getReservationArray.confirmationCode != nil ? getReservationArray.confirmationCode! : 0)"
            let timestamValue = Int(getReservationArray.createdAt!)!/1000
            let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = receiptformat

            let dateFormatter1 = DateFormatter()
            dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter1.dateFormat = itenarayReceiptDayFormat

            let day = dateFormatter1.string(from: showDate)
            let date = dateFormatter.string(from: showDate)
            cell.dateLabel.text = "\(day), \(date)"
            cell.selectionStyle = .none
            return cell
        }
        if(indexPath.section == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NameReceiptCell", for: indexPath)as! NameReceiptCell
            cell.selectionStyle = .none
            cell.nameLabel.text = getReservationArray.guestData?.firstName != nil ? getReservationArray.guestData?.firstName! : ""
            cell.destinationLabel.text = getReservationArray.listData?.city != nil ? getReservationArray.listData?.city! : ""
            
            
            if getReservationArray.nights ?? 0 > 1{
                cell.durationLbel.text = "\(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
            }else{
                cell.durationLbel.text = "\(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
            }
            
            cell.accomadationLabel.text = getReservationArray.listData?.roomType != nil ? getReservationArray.listData?.roomType! : ""
            if Utility.shared.isRTLLanguage()
            {
                cell.nameLAbel.textAlignment = .right
                cell.destinationLabel.textAlignment = .right
                cell.durationLbel.textAlignment = .right
                cell.accomadationLabel.textAlignment = .right
                cell.nameLabel.textAlignment = .right
                cell.travelLabel.textAlignment = .right
                cell.durationTitleLAbel.textAlignment = .right
                cell.accomadationTitleLabel.textAlignment = .right
            }
            else
            {
                cell.nameLAbel.textAlignment = .left
                              cell.destinationLabel.textAlignment = .left
                              cell.durationLbel.textAlignment = .left
                              cell.accomadationLabel.textAlignment = .left
                cell.nameLabel.textAlignment = .left
                               cell.travelLabel.textAlignment = .left
                               cell.durationTitleLAbel.textAlignment = .left
                               cell.accomadationTitleLabel.textAlignment = .left
            }
            
            cell.reservationCodeTitle.text = "\((Utility.shared.getLanguage()?.value(forKey:"confirmationcode"))!)"
            cell.reservationCodeLabel.text = "\(getReservationArray.confirmationCode != nil ? getReservationArray.confirmationCode! : 0)"
            return cell
        }
        if(indexPath.section == 2)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccommadationCell", for: indexPath)as! AccommadationCell
            cell.selectionStyle = .none
            cell.addressLAbel.text = "\(getReservationArray.listData?.street != nil ? ((getReservationArray.listData?.street!)!) : "" ), \(getReservationArray.listData?.city != nil ? ((getReservationArray.listData?.city!)!) : "" ), \(getReservationArray.listData?.state != nil ? ((getReservationArray.listData?.state!)!) : "" ), \(getReservationArray.listData?.country != nil ? ((getReservationArray.listData?.country!)!) : "" ), \(getReservationArray.listData?.zipcode != nil ? ((getReservationArray.listData?.zipcode!)!) : "" )"
            cell.hostnameLabel.text = getReservationArray.hostData?.firstName != nil ? getReservationArray.hostData?.firstName! : ""
    
            return cell
        }
        if(indexPath.section == 3)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItenarycheckCell", for: indexPath)as! ItenarycheckCell
            cell.selectionStyle = .none
            let day = getdayValue(timestamp: getReservationArray.checkIn!)
            let date = getdateValue(timestamp: getReservationArray.checkIn!)
            if Utility.shared.isRTLLanguage()
            {
                cell.checkoutLabel.text = "\(day), \(date)"
            }
            else
            {
               cell.checkinLabel.text = "\(day), \(date)"
            }
            
            if(getReservationArray.checkInStart != "" && getReservationArray.checkInStart != ""){
            if (getReservationArray.checkInStart == "Flexible" && getReservationArray.checkInEnd == "Flexible" ) {
            if Utility.shared.isRTLLanguage()
                       {
                               cell.checkouttimeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "checkintimesmal"))!)"
                }
            else{
                cell.checkinTimeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "checkintimesmal"))!)"
                }
                
            } else if (getReservationArray.checkInStart != "Flexible" && getReservationArray.checkInEnd == "Flexible") {
                let date = conversionRailwaytime(time:(getReservationArray.checkInStart!))
                
                if Utility.shared.isRTLLanguage()
                    {
                                   cell.checkouttimeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "from"))!) \(date)"
                    }
                else{
                   cell.checkinTimeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "from"))!) \(date)"
                    }
                
            }else if (getReservationArray.checkInStart == "Flexible" && getReservationArray.checkInEnd != "Flexible") {
                let date = conversionRailwaytime(time:(getReservationArray.checkInEnd!))
                              
                if Utility.shared.isRTLLanguage()
                    {
                        cell.checkouttimeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "upto"))!) \(date)"
                    }
                else{
                    cell.checkinTimeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "upto"))!) \(date)"
                    }
                
            } else if (getReservationArray.checkInStart != "Flexible" && getReservationArray.checkInEnd != "Flexible") {
                let date = conversionRailwaytime(time:(getReservationArray.checkInStart!))
                let date1 = conversionRailwaytime(time:(getReservationArray.checkInEnd!))
                
                if Utility.shared.isRTLLanguage()
                    {
                      cell.checkouttimeLabel.text = "\(date) - \(date1)"
                    }
                else{
                    cell.checkinTimeLabel.text = "\(date) - \(date1)"
                    }
                }}else{
               
                if Utility.shared.isRTLLanguage()
                    {
                       cell.checkouttimeLabel.text = ""
                    }
                else{
                     cell.checkinTimeLabel.text = ""
                    }
            }

            let day1 = getdayValue(timestamp: getReservationArray.checkOut!)
            let date1 = getdateValue(timestamp: getReservationArray.checkOut!)
           
            if Utility.shared.isRTLLanguage()
            {
                 cell.checkinLabel.text = "\(day1), \(date1)"
                cell.checkinTimeLabel.text = ""
            }
            else
            {
                 cell.checkoutLabel.text = "\(day1), \(date1)"
                cell.checkouttimeLabel.text = ""
            }
            return cell
        }
       if(indexPath.section == 4)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCell", for: indexPath)as! ReservationCell
            cell.selectionStyle = .none
        
            return cell
        }
        if(indexPath.section == 5)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestBookcellTableViewCell", for: indexPath)as! RequestBookcellTableViewCell
            cell.selectionStyle = .none
            var currencysymbol = String()
            
            
            cell.specialImage.isHidden = true
            cell.specialImage.addTarget(self, action: #selector(tooltipBtnTapped),for:.touchUpInside)
            if(getReservationArray.cleaningPrice == 0 || getReservationArray.cleaningPrice == nil)
            {
                if(getReservationArray.discountType != nil && getReservationArray.discount != 0 && getReservationArray.taxPrice != 0.0)
                {
                    if(indexPath.row == 0)
                    {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var total = Double()
                            if(getReservationArray.basePrice != nil)
                            {
                                total = Double(getReservationArray.basePrice!)
                            }
                            else
                            {
                                total = Double(getReservation_currencyArray.convertedBasePrice!)
                            }
                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
                            {
                               
                            }
                            if Utility.shared.isRTLLanguage()
                            {
                               
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(getReservation_currencyArray.convertedTotalNightsAmount!)))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(getReservation_currencyArray.convertedTotalNightsAmount!)))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                            var total = Double()
                            if(getReservationArray.basePrice != nil)
                            {
                                total = Double(getReservationArray.basePrice!)
                            }
                            else
                            {
                                total = Double(getReservation_currencyArray.convertedBasePrice!)
                            }
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                              
                            }
                            if Utility.shared.isRTLLanguage()
                            {
                                
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {
                              
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text = "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        
                    }
                    else if(indexPath.row == 1)
                    {
                        
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            
                            
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else
                                {
                                    cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
                            
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                                
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                            
                            
                        }
                        
                        
                    }
                    else if (indexPath.row == 2){
                        
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedDiscount!))
                            if Utility.shared.isRTLLanguage()
                            {
                                cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text = "\(getReservationArray.discountType!.capitalized)"
                            }
                            else{
                                cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text = "\(getReservationArray.discountType!.capitalized)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
                            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedDiscount!))
                            if Utility.shared.isRTLLanguage()
                            {
                                cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text = "\(getReservationArray.discountType!.capitalized)"
                            }
                            else
                            {
                                cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text = "\(getReservationArray.discountType!.capitalized)"
                            }
                            
                            
                        }
                      
                    } else if(indexPath.row == 3){
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedTaxPrice!))
                            if Utility.shared.isRTLLanguage()
                            {
                                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                            }
                            else{
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
                            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedTaxPrice!))
                            if Utility.shared.isRTLLanguage()
                            {
                                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text = "\(getReservationArray.taxPrice)"
                            }
                            else
                            {
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text = "\(getReservationArray.taxPrice)"
                            }
                            
                            
                        }
                        
                        
                    } else if(indexPath.row == 4) && hasInfant == true {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var infantPrice = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//                               
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                               
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                            var total = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//                              
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                                
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {
                              
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text = "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        
                    }
                    
                    
                    else if(indexPath.row == 5 && hasInfant == true && hasPets == true) || (indexPath.row == 4 && hasInfant == false && hasPets == true) {
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    
                    else if(indexPath.row == 6 && hasInfant == true && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == false && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == true && hasPets == false && hasAdditionalGuests == true)  || (indexPath.row == 4 && hasInfant == false && hasPets == false && hasAdditionalGuests == true){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.additionalGuest ?? 0)  Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    else if(indexPath.row == 7 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 6 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 6 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)  || (indexPath.row == 6 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 5 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)
                            || (indexPath.row == 5 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 5 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == false) || (indexPath.row == 4 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == false){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.visitors ?? 0)  visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"//  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    
                    
                    
                    
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                } else if (getReservationArray.discountType != nil && getReservationArray.discount != 0){
                    
                    if(indexPath.row == 0)
                    {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var total = Double()
                            if(getReservationArray.basePrice != nil)
                            {
                                total = Double(getReservationArray.basePrice!)
                            }
                            else
                            {
                                total = Double(getReservation_currencyArray.convertedBasePrice!)
                            }
                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
                            {
                             
                            }
                            if Utility.shared.isRTLLanguage()
                            {
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(getReservation_currencyArray.convertedTotalNightsAmount!)))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(getReservation_currencyArray.convertedTotalNightsAmount!)))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                            var total = Double()
                            if(getReservationArray.basePrice != nil)
                            {
                                total = Double(getReservationArray.basePrice!)
                            }
                            else
                            {
                                total = Double(getReservation_currencyArray.convertedBasePrice!)
                            }
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                              
                            }
                            if Utility.shared.isRTLLanguage()
                            {
                                
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {
                              
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text = "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        
                    }
                    else if(indexPath.row == 1)
                    {
                        
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            
                            
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else
                                {
                                    cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
                            
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                                
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                            
                            
                        }
                        
                        
                    }
                    
                    else if(indexPath.row == 3) && hasInfant == true {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var infantPrice = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                               
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                            var total = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                                
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {
                              
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text = "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        
                    }
                    
                    
                    else if(indexPath.row == 4 && hasInfant == true && hasPets == true) || (indexPath.row == 3 && hasInfant == false && hasPets == true) {
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    
                    else if(indexPath.row == 5 && hasInfant == true && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 4 && hasInfant == false && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 4 && hasInfant == true && hasPets == false && hasAdditionalGuests == true)  || (indexPath.row == 3 && hasInfant == false && hasPets == false && hasAdditionalGuests == true){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.additionalGuest ?? 0)  Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    else if(indexPath.row == 6 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)  || (indexPath.row == 5 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 4 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)
                            || (indexPath.row == 4 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 4 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == false) || (indexPath.row == 3 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == false){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.visitors ?? 0)  visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"//  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    else {
                        
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedDiscount!))
                            if Utility.shared.isRTLLanguage()
                            {
                                cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text = "\(getReservationArray.discountType!.capitalized)"
                            }
                            else{
                                cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text = "\(getReservationArray.discountType!.capitalized)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
                            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedDiscount!))
                            if Utility.shared.isRTLLanguage()
                            {
                                cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text = "\(getReservationArray.discountType!.capitalized)"
                            }
                            else
                            {
                                cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text = "\(getReservationArray.discountType!.capitalized)"
                            }
                            
                            
                        }
                      
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                    
                    
                    
                } else if (getReservationArray.taxPrice != 0.0 ){
                    
                    if(indexPath.row == 0)
                    {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var total = Double()
                            if(getReservationArray.basePrice != nil)
                            {
                                total = Double(getReservationArray.basePrice!)
                            }
                            else
                            {
                                total = Double(getReservation_currencyArray.convertedBasePrice!)
                            }
                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
                            {
                             
                            }
                            if Utility.shared.isRTLLanguage()
                            {
                               
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(getReservation_currencyArray.convertedTotalNightsAmount!)))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(getReservation_currencyArray.convertedTotalNightsAmount!)))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                            var total = Double()
                            if(getReservationArray.basePrice != nil)
                            {
                                total = Double(getReservationArray.basePrice!)
                            }
                            else
                            {
                                total = Double(getReservation_currencyArray.convertedBasePrice!)
                            }
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                             
                            }
                            if Utility.shared.isRTLLanguage()
                            {
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {
                             
                                
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text = "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        
                    }
                    else if(indexPath.row == 1)
                    {
                        
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            
                            
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else
                                {
                                    cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
                            
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                                
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                            
                            
                        }
                        
                        
                    }
                    
                    
                    else if(indexPath.row == 3) && hasInfant == true {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var infantPrice = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                               
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                            var total = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                                
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {
                              
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text = "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        
                    }
                    
                    
                    else if(indexPath.row == 4 && hasInfant == true && hasPets == true) || (indexPath.row == 3 && hasInfant == false && hasPets == true) {
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    
                    else if(indexPath.row == 5 && hasInfant == true && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 4 && hasInfant == false && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 4 && hasInfant == true && hasPets == false && hasAdditionalGuests == true)  || (indexPath.row == 3 && hasInfant == false && hasPets == false && hasAdditionalGuests == true){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.additionalGuest ?? 0)  Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    else if(indexPath.row == 6 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)  || (indexPath.row == 5 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 4 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)
                            || (indexPath.row == 4 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 4 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == false) || (indexPath.row == 3 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == false){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.visitors ?? 0)  visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"//  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    else {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedTaxPrice!))
                            if Utility.shared.isRTLLanguage()
                            {
                                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                            }
                            else{
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
                            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedTaxPrice!))
                            if Utility.shared.isRTLLanguage()
                            {
                                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                            }
                            else
                            {
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                            }
                            
                            
                        }
                        
                        
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                    
                    
                }
            
                else
                {
                    if(indexPath.row == 0)
                    {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var total = Double()
                            if(getReservationArray.basePrice != nil)
                            {
                                total = Double(getReservationArray.basePrice!)
                            }
                            else
                            {
                                total = Double(getReservation_currencyArray.convertedBasePrice!)
                            }
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                           
                            }
                            if Utility.shared.isRTLLanguage()
                            {

                                
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                            let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                            cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{

                                
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency!
                            var total = Double()
                            if(getReservationArray.basePrice != nil)
                            {
                                total = Double(getReservationArray.basePrice!)
                            }
                            else
                            {
                                total = Double(getReservation_currencyArray.convertedBasePrice!)
                            }
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                            }
                            if Utility.shared.isRTLLanguage()
                            {
                                
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{

                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }

                    }
                    else if(indexPath.row == 1)
                    {
                        
                        
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            
                   
                           
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                                 let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                if Utility.shared.isRTLLanguage()
                                {
                              cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                  cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                                if Utility.shared.isRTLLanguage()
                                {
                              cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                     cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                   cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                     cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                            
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
                          
                            
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                         
                                if Utility.shared.isRTLLanguage()
                                  {
                                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                       cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                  }
                                  else{
                                     cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                       cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                  }
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                           
                                if Utility.shared.isRTLLanguage()
                                  {
                                cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                       cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                  }
                                  else{
                                     cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                       cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                  }
                            }
                            
                            
                        }
                    }
                    
                    
                    else if(indexPath.row == 2) && hasInfant == true {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var infantPrice = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                               
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                            var total = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                                
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {
                              
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text = "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        
                    }
                    
                    
                    else if(indexPath.row == 3 && hasInfant == true && hasPets == true) || (indexPath.row == 2 && hasInfant == false && hasPets == true) {
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    
                    else if(indexPath.row == 4 && hasInfant == true && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 3 && hasInfant == false && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 3 && hasInfant == true && hasPets == false && hasAdditionalGuests == true)  || (indexPath.row == 2 && hasInfant == false && hasPets == false && hasAdditionalGuests == true){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.additionalGuest ?? 0)  Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    else if(indexPath.row == 5 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 4 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 4 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)  || (indexPath.row == 4 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 3 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)
                            || (indexPath.row == 3 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 3 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == false) || (indexPath.row == 2 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == false){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.visitors ?? 0)  visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"//  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    
                    
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                    
                }
                
            }
            else{
                
                if(getReservationArray.discountType != nil && getReservationArray.discount != 0 && getReservationArray.taxPrice != 0.0)
                {
                    if(indexPath.row == 0)
                    {
                        var currencysymbol = String()
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)!
                        }
                        else
                        {
                            currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)!
                        }
                        var total = Double()
                        if(getReservationArray.basePrice != nil)
                        {
                            total = Double(getReservationArray.basePrice!)
                        }
                        else
                        {
                            total = Double(getReservation_currencyArray.convertedBasePrice!)
                        }
                        if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                        {
                          
                        }
                        if Utility.shared.isRTLLanguage()
                        {
                            if Utility.shared.numberofnights_Selected > 1{
                                cell.priceLeftLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                            }else{
                                cell.priceLeftLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                            }
                            
                        let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                        cell.priceLabel.text = "\(currencysymbol)\(calculated_Price!.clean)"
                        }
                        else
                        {

                            
                            if Utility.shared.numberofnights_Selected > 1 {
                                cell.priceLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                            }else{
                                cell.priceLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                            }
                            
                                                   let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                                   cell.priceLeftLabel.text = "\(currencysymbol)\(calculated_Price!.clean)"
                        }
                        if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                        {
                        
                        }
                        else
                        {
                           
                        }
                    }
                    else if(indexPath.row == 1)
                    {
                      
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedCleaningPrice!))
                            if Utility.shared.isRTLLanguage()
                            {
                                 cell.priceLabel.text = "\(currencysymbol!)\((restricted_price!).clean)"
                                cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                            }
                            else{
                                cell.priceLeftLabel.text = "\(currencysymbol!)\((restricted_price!).clean)"
                                cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                            }
                           
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedCleaningPrice!))
                            if Utility.shared.isRTLLanguage()
                            {
                            cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                            }
                            else
                            {
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                            }
                            
                            
                        }
                        
                    }
                    else if(indexPath.row == 2)
                    {
                     
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            
                            
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                if Utility.shared.isRTLLanguage()
                                {
                            cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                   cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                                if Utility.shared.isRTLLanguage()
                                {
                                cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                     cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else
                                {
                                   cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
                            
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                if Utility.shared.isRTLLanguage()
                                {
                            cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                     cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                   cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                     cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                          
                                if Utility.shared.isRTLLanguage()
                                    {
                                cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                         cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                    else{
                                       cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                         cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                            }
                            
                            
                        }
                    }
                    else if (indexPath.row == 3){
                      
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedDiscount!))
                            if Utility.shared.isRTLLanguage()
                            {
                            cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text =  getReservationArray.discountType!.capitalized
                            }
                            else{
                                cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text =  getReservationArray.discountType!.capitalized
                            }
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
            
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedDiscount!))
                       
                            if Utility.shared.isRTLLanguage()
                            {
                            cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text =  getReservationArray.discountType!.capitalized
                            }
                            else{
                                cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text =  getReservationArray.discountType!.capitalized
                            }
                        }
                    } 
                    
                    
                    
                    else if(indexPath.row == 5) && hasInfant == true {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var infantPrice = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                               
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                            var total = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                                
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {
                              
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text = "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        
                    }
                    
                    
                    else if(indexPath.row == 6 && hasInfant == true && hasPets == true) || (indexPath.row == 5 && hasInfant == false && hasPets == true) {
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    
                    else if(indexPath.row == 7 && hasInfant == true && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 6 && hasInfant == false && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 6 && hasInfant == true && hasPets == false && hasAdditionalGuests == true)  || (indexPath.row == 5 && hasInfant == false && hasPets == false && hasAdditionalGuests == true){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.additionalGuest ?? 0)  Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    else if(indexPath.row == 8 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 7 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 7 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)  || (indexPath.row == 7 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 6 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)
                            || (indexPath.row == 6 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 6 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == false) || (indexPath.row == 5 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == false){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.visitors ?? 0)  visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"//  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    else {
                       
                         if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                         {
                             let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
             
                             let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedTaxPrice!))
                             if Utility.shared.isRTLLanguage()
                             {
                             cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                 cell.priceLeftLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                             }
                             else{
                                 cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                 cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                             }
                             
                             }
                         else
                         {
                             let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                             
             
                             let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedTaxPrice!))
                         
                             if Utility.shared.isRTLLanguage()
                             {
                             cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                 cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                             }
                             else{
                                 cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                 cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                             }
                         }
                     }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                }  else if (getReservationArray.discountType != nil && getReservationArray.discount != 0){
                    
                   
                        if(indexPath.row == 0)
                        {
                            var currencysymbol = String()
                            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                            {
                                currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)!
                            }
                            else
                            {
                                currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)!
                            }
                            var total = Double()
                            if(getReservationArray.basePrice != nil)
                            {
                                total = Double(getReservationArray.basePrice!)
                            }
                            else
                            {
                                total = Double(getReservation_currencyArray.convertedBasePrice!)
                            }
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                             
                            }
                            if Utility.shared.isRTLLanguage()
                            {
   
                                
                                if Utility.shared.numberofnights_Selected > 1{
                                    cell.priceLeftLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                            let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                            cell.priceLabel.text = "\(currencysymbol)\(calculated_Price!.clean)"
                            }
                            else
                            {
                                
                                if Utility.shared.numberofnights_Selected > 1 {
                                    cell.priceLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                                       let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                                       cell.priceLeftLabel.text = "\(currencysymbol)\(calculated_Price!.clean)"
                            }
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                              
                            }
                            else
                            {
                           
                            }
                        }
                        else if(indexPath.row == 1)
                        {
                        
                            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                            {
                                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                                
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedCleaningPrice!))
                                if Utility.shared.isRTLLanguage()
                                {
                                     cell.priceLabel.text = "\(currencysymbol!)\((restricted_price!).clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\((restricted_price!).clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                                }
                               
                                
                                
                                
                            }
                            else
                            {
                                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                                
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedCleaningPrice!))
                                if Utility.shared.isRTLLanguage()
                                {
                                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                                }
                                else
                                {
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                                }
                                
                                
                            }
                            
                        }
                        else if(indexPath.row == 2)
                        {
                        
                            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                            {
                                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                                
                                
                                if(!Utility.shared.host_isfrom_hostRecipt)
                                {
                                    let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                    if Utility.shared.isRTLLanguage()
                                    {
                                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                        cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                    else{
                                       cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                }
                                else
                                {
                                    let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                                    if Utility.shared.isRTLLanguage()
                                    {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                         cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                    else
                                    {
                                       cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                    
                                }
                                
                                
                                
                            }
                            else
                            {
                                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                                
                                
                                if(!Utility.shared.host_isfrom_hostRecipt)
                                {
                                    let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                    if Utility.shared.isRTLLanguage()
                                    {
                                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                         cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                    else{
                                       cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                         cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                }
                                else
                                {
                                    let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                                    if Utility.shared.isRTLLanguage()
                                        {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                             cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                        }
                                        else{
                                           cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                             cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                        }
                                }
                                
                                
                            }
                        }
                    
                    else if(indexPath.row == 4) && hasInfant == true {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var infantPrice = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                               
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                            var total = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                                
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {
                              
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text = "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        
                    }
                    
                    
                    else if(indexPath.row == 5 && hasInfant == true && hasPets == true) || (indexPath.row == 4 && hasInfant == false && hasPets == true) {
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    
                    else if(indexPath.row == 6 && hasInfant == true && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == false && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == true && hasPets == false && hasAdditionalGuests == true)  || (indexPath.row == 4 && hasInfant == false && hasPets == false && hasAdditionalGuests == true){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.additionalGuest ?? 0)  Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    else if(indexPath.row == 7 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 6 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 6 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)  || (indexPath.row == 6 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 5 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)
                            || (indexPath.row == 5 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 5 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == false) || (indexPath.row == 4 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == false){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.visitors ?? 0)  visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"//  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                        else {
                         
                            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                            {
                                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedDiscount!))
                                if Utility.shared.isRTLLanguage()
                                {
                                cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  getReservationArray.discountType!.capitalized
                                }
                                else{
                                    cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  getReservationArray.discountType!.capitalized
                                }
                                
                                
                            }
                            else
                            {
                                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                                
                
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedDiscount!))
                             
                                if Utility.shared.isRTLLanguage()
                                {
                                cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  getReservationArray.discountType!.capitalized
                                }
                                else{
                                    cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  getReservationArray.discountType!.capitalized
                                }
                            }
                        }
                        cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                        return cell
                    
                    
                } else if (getReservationArray.taxPrice != 0.0){
                    
                    
                        if(indexPath.row == 0)
                        {
                            var currencysymbol = String()
                            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                            {
                                currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)!
                            }
                            else
                            {
                                currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)!
                            }
                            var total = Double()
                            if(getReservationArray.basePrice != nil)
                            {
                                total = Double(getReservationArray.basePrice!)
                            }
                            else
                            {
                                total = Double(getReservation_currencyArray.convertedBasePrice!)
                            }
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                            
                            }
                            if Utility.shared.isRTLLanguage()
                            {
        
                                if Utility.shared.numberofnights_Selected > 1{
                                    cell.priceLeftLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                            let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                            cell.priceLabel.text = "\(currencysymbol)\(calculated_Price!.clean)"
                            }
                            else
                            {

                                
                                if Utility.shared.numberofnights_Selected > 1 {
                                    cell.priceLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(currencysymbol)\(total.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                                       let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                                       cell.priceLeftLabel.text = "\(currencysymbol)\(calculated_Price!.clean)"
                            }
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                               
                            }
                            else
                            {
                               
                            }
                        }
                        else if(indexPath.row == 1)
                        {
                          
                            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                            {
                                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                                
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedCleaningPrice!))
                                if Utility.shared.isRTLLanguage()
                                {
                                     cell.priceLabel.text = "\(currencysymbol!)\((restricted_price!).clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\((restricted_price!).clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                                }
                               
                                
                            }
                            else
                            {
                                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                                
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedCleaningPrice!))
                                if Utility.shared.isRTLLanguage()
                                {
                                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                                }
                                else
                                {
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                                }
                                
                                
                            }
                            
                        }
                        else if(indexPath.row == 2)
                        {
                            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                            {
                                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                                
                                
                                if(!Utility.shared.host_isfrom_hostRecipt)
                                {
                                    let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                    if Utility.shared.isRTLLanguage()
                                    {
                                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                        cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                    else{
                                       cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                }
                                else
                                {
                                    let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                                    if Utility.shared.isRTLLanguage()
                                    {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                         cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                    else
                                    {
                                       cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                       cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                    
                                }
                                
                                
                                
                            }
                            else
                            {
                                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                                
                                
                                if(!Utility.shared.host_isfrom_hostRecipt)
                                {
                                    let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                                    if Utility.shared.isRTLLanguage()
                                    {
                                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                         cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                    else{
                                       cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                         cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                    }
                                }
                                else
                                {
                                    let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                              
                                    if Utility.shared.isRTLLanguage()
                                        {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                             cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                        }
                                        else{
                                           cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                             cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                        }
                                }
                                
                                
                            }
                        }
                    
                    else if(indexPath.row == 4) && hasInfant == true {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var infantPrice = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                               
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                            var total = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                                
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {
                              
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text = "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        
                    }
                    
                    
                    else if(indexPath.row == 5 && hasInfant == true && hasPets == true) || (indexPath.row == 4 && hasInfant == false && hasPets == true) {
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    
                    else if(indexPath.row == 6 && hasInfant == true && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == false && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == true && hasPets == false && hasAdditionalGuests == true)  || (indexPath.row == 4 && hasInfant == false && hasPets == false && hasAdditionalGuests == true){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.additionalGuest ?? 0)  Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    else if(indexPath.row == 7 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 6 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 6 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)  || (indexPath.row == 6 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 5 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)
                            || (indexPath.row == 5 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 5 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == false) || (indexPath.row == 4 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == false){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.visitors ?? 0)  visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"//  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                        else {
                           
                             if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                             {
                                 let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                 
                                 let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedTaxPrice!))
                                 if Utility.shared.isRTLLanguage()
                                 {
                                 cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                     cell.priceLeftLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                                 }
                                 else{
                                     cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                     cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                                 }
                                 
                                 }
                             else
                             {
                                 let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                                 
                 
                                 let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedTaxPrice!))
                               
                                 if Utility.shared.isRTLLanguage()
                                 {
                                 cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                 cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                                 }
                                 else{
                                     cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                     cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
                                 }
                             }
                         }
                        cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                        return cell
                    
                }
                    
                else{
                    if(indexPath.row == 0)
                    {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                           
                            var restricted_price:Double!
                            if(getReservationArray.basePrice != nil && getReservationArray.basePrice != 0.0)
                            {
                                restricted_price =  Double(String(format: "%.2f",getReservationArray.basePrice!))
                            }
                            else
                            {
                                  restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount ?? 0))
                            }
                           
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                            
                            }
                            let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount ?? 0))
                            
                            if Utility.shared.isRTLLanguage()
                            {

                                
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {

                                if getReservationArray.nights! > 1 {
                                    cell.priceLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency!
                            let total = Double(getReservationArray.isSpecialPriceAverage!)
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                            }
                          
                            
                             let calculated_Price = Double(String(format: "%.2f",(getReservation_currencyArray.convertedTotalNightsAmount!)))
                           
                            if Utility.shared.isRTLLanguage()
                            {

                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.basePrice!.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.basePrice!.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                 cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {

                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(getReservationArray.basePrice!.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(currencysymbol!)\(getReservationArray.basePrice!.clean) x \(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
                            {
                            
                            }
                            else
                            {
                                cell.specialImage.isHidden = true
                            }
                            
                        }
                    }
                    else if(indexPath.row == 1)
                    {
                        
                        
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            
                           
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedCleaningPrice!))
                            if Utility.shared.isRTLLanguage()
                            {
                            cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                            }
                            else{
                              cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                            }
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
        
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedCleaningPrice!))
                            if Utility.shared.isRTLLanguage()
                            {
                            cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                            }
                            else{
                              cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                            }
                        }
                    }
                    else if(indexPath.row == 2)
                    {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                            let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                    
                               if Utility.shared.isRTLLanguage()
                               {
                               cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                   cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                               }
                               else{
                                 cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                   cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                               }
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                          
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                 cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            
                            if(!Utility.shared.host_isfrom_hostRecipt)
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedGuestServicefee!))
                     
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                 cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                            else
                            {
                                let restricted_price =  Double(String(format: "%.2f",getReservation_currencyArray.convertedHostServiceFee!))
                        
                                if Utility.shared.isRTLLanguage()
                                {
                                    cell.priceLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                    cell.priceLeftLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                                else{
                                    cell.priceLeftLabel.text = "-\(currencysymbol!)\(restricted_price!.clean)"
                                 cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                                }
                            }
                        }
                    }
                    
                    else if(indexPath.row == 3) && hasInfant == true {
                        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = getReservationArray.currency!
                            var infantPrice = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                infantPrice = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                               
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else{
                              
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            
                            
                            
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                            let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                            var total = Double()
                            if(getReservationArray.infants != nil) && (getReservationArray.infants != 0)
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
                            else
                            {
                                total = Double(getReservationArray.infantPrice!)
                            }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                            if Utility.shared.isRTLLanguage()
                            {
                                
                                if getReservationArray.nights ?? 0 > 1{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLeftLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                            else
                            {
                              
                                if getReservationArray.nights ?? 0 > 1 {
                                    cell.priceLabel.text =  "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                }else{
                                    cell.priceLabel.text = "\(getReservationArray.infants ?? 0) Infants x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                }
                                let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                                cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                            }
                        }
                        
                    }
                    
                    
                    else if(indexPath.row == 4 && hasInfant == true && hasPets == true) || (indexPath.row == 3 && hasInfant == false && hasPets == true) {
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.pets != nil) && (getReservationArray.pets != 0)
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.petPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",getReservation_currencyArray.convertedTotalNightsAmount!))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.pets ?? 0) Pets x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    
                    else if(indexPath.row == 5 && hasInfant == true && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 4 && hasInfant == false && hasPets == true && hasAdditionalGuests == true) || (indexPath.row == 4 && hasInfant == true && hasPets == false && hasAdditionalGuests == true)  || (indexPath.row == 3 && hasInfant == false && hasPets == false && hasAdditionalGuests == true){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.additionalGuest ?? 0)  Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.additionalGuest != nil) && (getReservationArray.additionalGuest != 0)
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.additionalPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.additionalGuest ?? 0) Additoinal Guests x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    
                    
                    else if(indexPath.row == 6 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == true) || (indexPath.row == 5 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)  || (indexPath.row == 5 && hasInfant == true && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 4 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == true)
                            || (indexPath.row == 4 && hasInfant == false && hasPets == true && hasVisitor == true && hasAdditionalGuests == false) ||
                            (indexPath.row == 4 && hasInfant == true && hasPets == false && hasVisitor == true && hasAdditionalGuests == false) || (indexPath.row == 3 && hasInfant == false && hasPets == false && hasVisitor == true && hasAdditionalGuests == false){
                       if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                           let from_currency = getReservationArray.currency!
                           var infantPrice = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               infantPrice = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.basePrice != getReservation_currencyArray.convertedBasePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                              
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(currencysymbol!)\(getReservationArray.visitors ?? 0)  visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else{
                             
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"//  x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",(infantPrice)))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           
                           
                           
                       }
                       else
                       {
                           let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                           let from_currency = getReservationArray.currency != nil ? getReservationArray.currency! : "USD"
                           var total = Double()
                           if(getReservationArray.visitors != nil) && (getReservationArray.visitors != 0)
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
                           else
                           {
                               total = Double(getReservationArray.visitorsPrice!)
                           }
//                            if(getReservationArray.isSpecialPriceAverage != getReservationArray.basePrice)
//                            {
//
//                            }
                           if Utility.shared.isRTLLanguage()
                           {
                               
                               if getReservationArray.nights ?? 0 > 1{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLeftLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                           else
                           {
                             
                               if getReservationArray.nights ?? 0 > 1 {
                                   cell.priceLabel.text =  "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                               }else{
                                   cell.priceLabel.text = "\(getReservationArray.visitors ?? 0) visitors"// x \(getReservationArray.nights != nil ? getReservationArray.nights! : 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                               }
                               let calculated_Price = Double(String(format: "%.2f",total))
                               cell.priceLeftLabel.text = "\(currencysymbol!)\(calculated_Price!.clean)"
                           }
                       }
                       
                   }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                }
            }
        }
        if(indexPath.section == 6)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingTotalCell", for: indexPath)as! BookingTotalCell
            cell.selectionStyle = .none
           
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
            {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
               if(!Utility.shared.host_isfrom_hostRecipt)
               {
                   cell.gstLine.isHidden = true
                   
                if Utility.shared.isRTLLanguage()
                {
                    cell.totalTitleLabel.text = "\(currencysymbol!)\(getReservation_currencyArray.convertTotalWithGuestServiceFee != nil ? getReservation_currencyArray.convertTotalWithGuestServiceFee!.clean : "")"
                                   totalPriceLabel = "\(currencysymbol!)\(getReservation_currencyArray.convertTotalWithGuestServiceFee != nil ? getReservation_currencyArray.convertTotalWithGuestServiceFee!.clean : "")"
                    cell.totalPriceLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"total"))!)"
                }
                else
                {
                    cell.totalPriceLabel.text = "\(currencysymbol!)\(getReservation_currencyArray.convertTotalWithGuestServiceFee != nil ? getReservation_currencyArray.convertTotalWithGuestServiceFee!.clean : "")"
                                  totalPriceLabel = "\(currencysymbol!)\(getReservation_currencyArray.convertTotalWithGuestServiceFee != nil ? getReservation_currencyArray.convertTotalWithGuestServiceFee!.clean : "")"
                    cell.totalTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"total"))!)"
                }
                }
                else
               {
                    cell.gstLine.isHidden = false
                    
                    let val = (getReservation_currencyArray.convertedTotalWithHostServiceFee ?? 0.0) + (self.getReservationArray.hostServiceFee ?? 0.0)
                    var valReq = 0.0
                    if self.hasGST == true && self.hasPAN == false{
                        valReq = val * (0.001)
                        cell.gstLine.text = "GST TCS – U/S 52 of GST for GST Number - \(self.gstValue)  -Rs.\(valReq.roundToPlaces(places: 2))"
                    } else if self.hasGST == false && self.hasPAN == true{
                        valReq = val * (0.001)
                        cell.gstLine.text = "Tax With holding for India Income for Pan Number - \(self.panValue)  -Rs.\(valReq.roundToPlaces(places: 2))"
                    }  else if self.hasGST == true && self.hasPAN == true{
                        valReq = val * (0.001)
                        cell.gstLine.text = "GST TCS – U/S 52 of GST for GST Number - \(self.gstValue)  -Rs.\(valReq.roundToPlaces(places: 2))"
                    }  else if self.hasGST == false && self.hasPAN == false{
                        valReq = val * (0.05)
                        cell.gstLine.text = "Tax With holding for India Income - \(self.gstValue)  -Rs.\(valReq.roundToPlaces(places: 2))"
                    }
                    
                if(getReservation_currencyArray.convertedTotalWithHostServiceFee!.clean.contains("-"))
                {
                    if Utility.shared.isRTLLanguage()
                    {
                        let val = (getReservation_currencyArray.convertedTotalWithHostServiceFee!.clean.replacingOccurrences(of:"-", with: ""))
                        cell.totalTitleLabel.text = "-\(currencysymbol!)\(val)"
                        totalPriceLabel = "-\(currencysymbol!)\(val)"
                        cell.totalPriceLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"total"))!)"
                    }
                    else{
                 let val = (getReservation_currencyArray.convertedTotalWithHostServiceFee!.clean.replacingOccurrences(of:"-", with: ""))
                    cell.totalPriceLabel.text = "-\(currencysymbol!)\(val)"
                    totalPriceLabel = "-\(currencysymbol!)\(val)"
                         cell.totalTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"total"))!)"
                    }
                }
                else
                {
                    if Utility.shared.isRTLLanguage()
                    {
                        cell.totalTitleLabel.text = "\(currencysymbol!)\(getReservation_currencyArray.convertedTotalWithHostServiceFee != nil ? getReservation_currencyArray.convertedTotalWithHostServiceFee!.clean : "")"
                        totalPriceLabel = "\(currencysymbol!)\(getReservation_currencyArray.convertedTotalWithHostServiceFee != nil ? getReservation_currencyArray.convertedTotalWithHostServiceFee!.clean : "")"
                        cell.totalPriceLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"total"))!)"
                    }
                    else{
                    cell.totalPriceLabel.text = "\(currencysymbol!)\(getReservation_currencyArray.convertedTotalWithHostServiceFee != nil ? getReservation_currencyArray.convertedTotalWithHostServiceFee!.clean : "")"
                    totalPriceLabel = "\(currencysymbol!)\(getReservation_currencyArray.convertedTotalWithHostServiceFee != nil ? getReservation_currencyArray.convertedTotalWithHostServiceFee!.clean : "")"
                         cell.totalTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"total"))!)"
                    }
                }
            }
        }
            else
            {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                if(!Utility.shared.host_isfrom_hostRecipt)
                {
                    if Utility.shared.isRTLLanguage()
                    {
                        cell.totalTitleLabel.text = "\(currencysymbol!)\(getReservation_currencyArray.convertTotalWithGuestServiceFee != nil ? getReservation_currencyArray.convertTotalWithGuestServiceFee!.clean : "")"
                                      totalPriceLabel = "\(currencysymbol!)\(getReservation_currencyArray.convertTotalWithGuestServiceFee != nil ? getReservation_currencyArray.convertTotalWithGuestServiceFee!.clean : "")"
                        cell.totalPriceLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"total"))!)"
                    }
                    else
                    {
                    cell.totalPriceLabel.text = "\(currencysymbol!)\(getReservation_currencyArray.convertTotalWithGuestServiceFee != nil ? getReservation_currencyArray.convertTotalWithGuestServiceFee!.clean : "")"
                totalPriceLabel = "\(currencysymbol!)\(getReservation_currencyArray.convertTotalWithGuestServiceFee != nil ? getReservation_currencyArray.convertTotalWithGuestServiceFee!.clean : "")"
                        cell.totalTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"total"))!)"
                    }
                }
                else
                {
                    if Utility.shared.isRTLLanguage()
                                       {
                                        cell.totalTitleLabel.text = "\(currencysymbol!)\(getReservation_currencyArray.convertedTotalWithHostServiceFee != nil ? getReservation_currencyArray.convertedTotalWithHostServiceFee!.clean : "")"
                                                           totalPriceLabel = "\(currencysymbol!)\(getReservation_currencyArray.convertedTotalWithHostServiceFee != nil ? getReservation_currencyArray.convertedTotalWithHostServiceFee!.clean : "")"
                                         cell.totalPriceLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"total"))!)"
                    }
                    else
                    {
                    cell.totalPriceLabel.text = "\(currencysymbol!)\(getReservation_currencyArray.convertedTotalWithHostServiceFee != nil ? getReservation_currencyArray.convertedTotalWithHostServiceFee!.clean : "")"
                    totalPriceLabel = "\(currencysymbol!)\(getReservation_currencyArray.convertedTotalWithHostServiceFee != nil ? getReservation_currencyArray.convertedTotalWithHostServiceFee!.clean : "")"
                         cell.totalTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"total"))!)"
                    }
                }
            }
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RentpaymentReceiptCell", for: indexPath)as! RentpaymentReceiptCell
            cell.selectionStyle = .none
            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
            let day = getdayValue(timestamp: getReservationArray.updatedAt!)
            let date = getdateValue(timestamp: getReservationArray.updatedAt!)
            cell.paymentDateLabel.text = "\(day), \(date)"
            cell.totalLabel.text =  "\(currencysymbol!)\(getReservation_currencyArray.convertTotalWithGuestServiceFee != nil ? getReservation_currencyArray.convertTotalWithGuestServiceFee!.clean : "")"
            
            //"\(currencysymbol ?? "")\(getReservationArrayyy.convertTotalWithGuestServiceFee ?? 0.0)" //totalPriceLabel
            
            if Utility.shared.isRTLLanguage()
                       {
                cell.totalLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"paymentreceive"))!)"
                cell.paymentDateLabel.text = totalPriceLabel
                cell.paymentRTLLabel.text = "\(day), \(date)"
                cell.paymentreceiveLAbel.text = ""
                
                cell.paymentRTLLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            
                cell.paymentDateLabel.textColor = UIColor(named: "Title_Header")
               
                
               
                
                           cell.paymentDateLabel.textAlignment = .right
                           
                           cell.totalLabel.textAlignment = .left
                           cell.paymentreceiveLAbel.textAlignment = .right
                           cell.payemntdescriptionLabel.textAlignment = .right
                           
                       }
                       else{
                           cell.paymentRTLLabel.text = ""
                            cell.paymentDateLabel.textAlignment = .left
                                                    cell.totalLabel.textAlignment = .right
                                                    cell.paymentreceiveLAbel.textAlignment = .left
                                                    cell.payemntdescriptionLabel.textAlignment = .left
                       }
            return cell
        }
    }
    @objc func tooltipBtnTapped(_ sender: UIButton!)
    {
        let preference = ToolTipPreferences()
        preference.drawing.bubble.color = UIColor.darkGray
        preference.drawing.bubble.spacing = 10
        preference.drawing.bubble.cornerRadius = 5
        preference.drawing.bubble.inset = 15
        preference.drawing.bubble.border.color = UIColor.darkGray
        preference.drawing.bubble.border.width = 1
        preference.drawing.arrow.tipCornerRadius = 5
        preference.drawing.message.color = UIColor.white
        preference.drawing.message.font = UIFont(name:APP_FONT, size:15)!
        preference.drawing.button.color = UIColor(red: 0.074, green: 0.231, blue: 0.431, alpha: 1.000)
        preference.drawing.button.font = UIFont(name: APP_FONT, size:15)!
        sender.showToolTip(identifier: "", message:"\((Utility.shared.getLanguage()?.value(forKey:"specialtooltip"))!)", button:nil, arrowPosition: .bottom, preferences: preference, delegate: nil)
    }
    func getCurrencyRate(basecurrency:String,fromCurrency:String,toCurrency:String,CurrencyRate:NSDictionary,amount:Double) -> Double
    {
        if(fromCurrency == basecurrency)
        {
            return (CurrencyRate.object(forKey: toCurrency) as! Double) * (amount)
        }
        else if(toCurrency == basecurrency)
        {
            return  (1 / (CurrencyRate.object(forKey: fromCurrency)as! Double) * (amount))
        }
        else{
            return amount * ((CurrencyRate.object(forKey: toCurrency)as! Double) * ((1 / (CurrencyRate.object(forKey: fromCurrency)as! Double))))
        }
        
    }
    func pdfDataWithTableView(tableView: UITableView)->URL {
        let priorBounds = tableView.bounds
        let fittedSize = tableView.sizeThatFits(CGSize(width:priorBounds.size.width, height:tableView.contentSize.height))
        tableView.bounds = CGRect(x:0, y:0, width:fittedSize.width, height:fittedSize.height)
        let pdfPageBounds = CGRect(x:0, y:0, width:tableView.frame.width, height:self.view.frame.height)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds,nil)
        var pageOriginY: CGFloat = 0
        while pageOriginY < fittedSize.height {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
            UIGraphicsGetCurrentContext()!.saveGState()
            UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -pageOriginY)
            tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
            UIGraphicsGetCurrentContext()!.restoreGState()
           
            
            pageOriginY += pdfPageBounds.size.height
        }
         let screenRect = UIScreen.main.bounds

        UIGraphicsEndPDFContext()
        tableView.bounds = priorBounds
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        docURL = docURL.appendingPathComponent("myDocument.pdf")
        pdfData.write(to: docURL as URL, atomically: true)
       return docURL
    }
   func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
   {
        return self
    }
    func getdateValue(timestamp:String) -> String
    {
         if(Int(timestamp) != nil ) {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = receiptformat
             dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let date = dateFormatter.string(from: showDate)
            return date } else {
            return Utility.shared.getdateformatter(date: timestamp) }
    }
    
    func getdayValue(timestamp:String) -> String
    {
         if(Int(timestamp) != nil ) {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = itenarayReceiptDayFormat
             dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")

        let day = dateFormatter1.string(from: showDate)
            return day } else {
           return Utility.shared.getdateformatter1(date: timestamp) }
    }
    func conversionRailwaytime(time:String) -> String
    {
        var dateAsString = time
        var strArr = time.split{$0 == ":"}.map(String.init)
        let hour = Int(strArr[0])!
        if(hour > 12 && hour != 24 && hour != 25 && hour != 26){
            dateAsString = "\(Int(dateAsString)!-12)" + " " +  "PM"
        }
        else if(hour == 25)
        {
            dateAsString = "1 AM"
        }
        else if(hour == 26)
        {
            dateAsString = "2 AM"
        }
        else if(hour == 12)
        {
            dateAsString = "12 PM"
        }
        else if(hour == 24)
        {
            dateAsString = "12 AM"
        }
        else{
            let trimmedString = dateAsString.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
            dateAsString = trimmedString +  " " +  "AM"
        }
        return dateAsString
    }

}
extension UITableView {
    
   
    func exportAsPdfFromTable() -> String {
        
        let originalBounds = self.bounds
        self.bounds = CGRect(x:originalBounds.origin.x, y: originalBounds.origin.y, width: self.contentSize.width, height:FULLHEIGHT+600)
        let pdfPageFrame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: FULLHEIGHT+600)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        let printPageRenderer = UIPrintPageRenderer()
        guard let pdfContext = UIGraphicsGetCurrentContext() else {
            return ""
        }
        self.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        return self.saveTablePdf(data: pdfData)
    }
  
    func saveTablePdf(data: NSMutableData) -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectoryPath = paths[0]
        let pdfPath = docDirectoryPath.appendingPathComponent("customerReceipt.pdf")
        if data.write(to: pdfPath, atomically: true) {
            return pdfPath.path
        } else {
            return ""
        }
    }
}

extension Double {
    func roundToPlaces(places:Int = 2) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
