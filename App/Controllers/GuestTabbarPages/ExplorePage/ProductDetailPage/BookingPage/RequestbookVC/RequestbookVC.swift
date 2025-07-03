

import UIKit
import Apollo
import MKToolTip
import Lottie

protocol RequestbookVCDelegate {
    func passSelectedStartDate(selectedstartDate:Date)
    func passSelectedEndDate(selectedenddate:Date)
    func billingListAPICall(startDate:String, endDate:String)
    
}


class RequestbookVC: UIViewController,UITableViewDelegate,UITableViewDataSource,AirbnbDatePickerDelegate,AirbnbOccupantFilterControllerDelegate,checkTextviewCellDelegate{
    func didChangeText(text: String?, cell: checkTextviewCell) {
        requestTable.beginUpdates()
        Utility.shared.booking_message = text!
        requestTable.endUpdates()
    }
    
    var navigationControllerReference: UINavigationController?
    
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet var lblHeader: UILabel!
    
    @IBOutlet var backBtn: UIButton!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLAbel: UILabel!
    @IBOutlet weak var bookBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var requestTable: UITableView!
    var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    var currencyvalue_from_API_base = String()
    var currency_Dict = NSDictionary()
    var lottieView: LottieAnimationView!
    public var selectedStartDate: Date?
    public var selectedEndDate: Date?
    var delegate:RequestbookVCDelegate?
    var ProfileAPIArray = GetProfileQuery.Data.UserAccount.Result()
    var addDateinLabel = String()
    var addDateoutLabel = String()
    var totalPriceLabel = String()
    var guestLabel_text = String()
    
    var guestBase_text = String()
    var additionalPrice_text = String()
    var infantLimit_text = String()
    var infantPrice_text = String()
    var petLimit_text = String()
    var petPrice_text = String()
    var visitorLimit_text = String()
    var visitorPrice_text = String()
    
    var threadId = Int()
    
    var adultCount: Int = 1
    var childrenCount: Int = 0
    var infantCount: Int = 0
    var hasPet: Bool = false
    var isFromMessage = false
    var isFromCalendar = false
    var guest_filter = Int()
    
    
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
       
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    var getbillingArray = GetBillingCalculationQueryy.Data.GetBillingCalculation.Result()
    
    var hasGuestPrice = false
    var hasInafant = false
    var hasPett = false
    var hasVisitor = false
    var dynamicCells = 0 //1 //GST
    var isPromotionApplied = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.initialsetUp()
        if(self.guestBase_text == "")
        {
            self.guestBase_text = "1 Additional guests"
        }
        bookBtn.layer.cornerRadius = (bookBtn.frame.size.height / 2)
        lottieView = LottieAnimationView.init(name: "animation_white")
        
        
        
//        if self.viewListingArray.listingData?.guestBasePrice != nil {
            dynamicCells = dynamicCells + 1
            hasGuestPrice = true
//        }
        if self.viewListingArray.listingData?.infantLimit != nil {
            dynamicCells = dynamicCells + 1
            hasInafant = true
        }
        if self.viewListingArray.listingData?.petLimit != nil {
            dynamicCells = dynamicCells + 1
            hasPett = true
        }
        if self.viewListingArray.listingData?.visitorsLimit != nil {
            dynamicCells = dynamicCells + 1
            hasVisitor = true
        }
      
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        if(selectedStartDate != nil && selectedEndDate != nil)
        {
            let cell = view.viewWithTag((2) + 2000) as? checkTextviewCell
            Utility.shared.booking_message = (cell?.checkTxtview.text ?? "")!
            self.delegate?.passSelectedStartDate(selectedstartDate: selectedStartDate!)
            self.delegate?.passSelectedEndDate(selectedenddate: selectedEndDate!)
            let fmt = DateFormatter()
          
            fmt.dateFormat = "yyyy-MM-dd"
            self.delegate?.billingListAPICall(startDate: fmt.string(from: selectedStartDate!), endDate: fmt.string(from: selectedEndDate!))
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            offlineView.isHidden = true
            self.bottomView.isHidden = false
            let fmt = DateFormatter()
          
            fmt.dateFormat = "yyyy-MM-dd"
            if(selectedStartDate != nil && selectedEndDate != nil)
            {
                billingListAPICall(startDate: fmt.string(from: selectedStartDate!), endDate: fmt.string(from: selectedEndDate!)) }
        }
    }
    @IBAction func requestBookBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            
            
            let fmt = DateFormatter()
          
            fmt.dateFormat = "yyyy-MM-dd"
            self.setBillingListAPICall(startDate: fmt.string(from: selectedStartDate!), endDate: fmt.string(from: selectedEndDate!))
            
//            if(self.viewListingArray.bookingType! == "instant") {
//                self.lottieanimation()
//                let cell = view.viewWithTag((2) + 2000) as? checkTextviewCell
//                Utility.shared.booking_message = (cell?.checkTxtview.text ?? "")
//                
//                if(Utility.shared.booking_message == "")
//                {
//                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"messagealert"))!)")
//                    lottieView.isHidden = true
//                } else{
//                    
//                    self.profileAPICall()
//                }
//            } else {
//                self.lottieanimation()
//                let cell = view.viewWithTag((2) + 2000) as? checkTextviewCell
//                Utility.shared.booking_message = (cell?.checkTxtview.text ?? "")
//                if(Utility.shared.booking_message == "")
//                {
//                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"messagealert"))!)")
//                    lottieView.isHidden = true
//                } else{
//                    
//                    self.requestBookAPICall(message: Utility.shared.booking_message ?? "")
//                }
//                
//            }
            
        }
        else
        {
            self.offlineView.isHidden = false
            self.bottomView.isHidden = true
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
            if IS_IPHONE_X || IS_IPHONE_XR {
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    func initialsetUp()
    {
        if IS_IPHONE_XR
        {
            self.topView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH-40, height: 80)
            requestTable.frame = CGRect(x: 0, y: 85, width: FULLWIDTH-40, height: FULLHEIGHT-300)
            
        }
        
        self.view.backgroundColor = UIColor(named: "colorController")
        bottomView.backgroundColor = UIColor(named: "colorController")
        lblHeader.font = UIFont(name:APP_FONT_SEMIBOLD, size: 18)
        if(self.viewListingArray.bookingType! == "instant") {
            lblHeader.text = "\((Utility.shared.getLanguage()?.value(forKey:"reviewpay_small"))!)"
        } else {
            lblHeader.text = "Request A Book"
        }
        
        lblHeader.textColor = UIColor(named: "Title_Header")
        bookBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        errorLAbel.font = UIFont(name: APP_FONT, size: 15)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        requestTable.register(UINib(nibName: "ContactheaderCell", bundle: nil), forCellReuseIdentifier: "ContactheaderCell")
        requestTable.register(UINib(nibName: "contactcheckCell", bundle: nil), forCellReuseIdentifier: "contactcheckCell")
        requestTable.register(UINib(nibName: "RequestBookcellTableViewCell", bundle: nil), forCellReuseIdentifier: "RequestBookcellTableViewCell")
        requestTable.register(UINib(nibName: "ReservationCell", bundle: nil), forCellReuseIdentifier: "ReservationCell")
        requestTable.register(UINib(nibName: "BookingTotalCell", bundle: nil), forCellReuseIdentifier: "BookingTotalCell")
        requestTable.register(UINib(nibName: "TripsLocationCell", bundle: nil), forCellReuseIdentifier: "TripsLocationCell")
        requestTable.register(UINib(nibName: "bookcancellationCell", bundle: nil), forCellReuseIdentifier: "bookcancellationCell")
        requestTable.register(UINib(nibName: "AgreetermsCell", bundle: nil), forCellReuseIdentifier: "AgreetermsCell")
        requestTable.register(UINib(nibName: "checkTextviewCell", bundle: nil), forCellReuseIdentifier: "checkTextviewCell")
        let shadowSize : CGFloat = 3.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: self.bottomView.frame.size.width+40 + shadowSize,
                                                   height: self.bottomView.frame.size.height + shadowSize))
        
        self.bottomView.layer.masksToBounds = false
        self.bottomView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.bottomView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.bottomView.layer.shadowOpacity = 0.3
        self.bottomView.layer.shadowPath = shadowPath.cgPath
        bookBtn.backgroundColor = Theme.SECONDARY_COLOR
        
        
        if(Utility.shared.isRTLLanguage()) {
            backBtn.imageView?.performRTLTransform()
            lblHeader.textAlignment = .right
        }
        else{
            
        }
        if(viewListingArray.bookingType! == "instant")
        {
            self.bookBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"addpayment"))!)", for: .normal)
        }
        else
        {
            self.bookBtn.setTitle("Request A Book", for: .normal)
//            self.bookBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"addpayment"))!)", for: .normal)
        }
        self.offlineView.isHidden = true
        errorLAbel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
    }
    
    //MARK: setDiscount
    func setDiscount(cell: RequestBookcellTableViewCell, indexPath: IndexPath, currenySymbol: String) {
      cell.priceLabel.text =  "Coupon Discount \(indexPath)"
      
      cell.priceLeftLabel.text = "-\(currenySymbol)\(100)"
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 4) {
            
            if(getbillingArray.cleaningPrice == 0) {
                if(getbillingArray.discountLabel != nil && getbillingArray.discount != 0 && getbillingArray.taxPrice != 0.0) {
                    return 4 + dynamicCells
                } else if (getbillingArray.discountLabel != nil && getbillingArray.discount != 0){
                    return 3 + dynamicCells
                } else if (getbillingArray.taxPrice != 0.0){
                    return 3 + dynamicCells
                }
                return 2 + dynamicCells
            } else {
                if(getbillingArray.discountLabel != nil && getbillingArray.discount != 0 && getbillingArray.taxPrice != 0.0) {
                    return 5 + dynamicCells
                }else if (getbillingArray.discountLabel != nil && getbillingArray.discount != 0){
                    return 4 + dynamicCells
                } else if (getbillingArray.taxPrice != 0.0){
                    return 4 + dynamicCells
                }
                return 3 + dynamicCells
            }
            
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0)
        {
            return 125
        }
        else if(indexPath.section == 1)
        {
            return  UITableView.automaticDimension //450//167
        }
        else if(indexPath.section == 2)
        {
            return UITableView.automaticDimension
        }
        else if(indexPath.section == 3)
        {
            return 45
        }
        else if(indexPath.section == 4)
        {
            return 40
        }
        else if(indexPath.section == 5)
        {
            return 110
        }
        else if(indexPath.section == 6)
        {
            return UITableView.automaticDimension
        }
        
        else if(indexPath.section == 7)
        {
            return UITableView.automaticDimension
        }
        else{
            return 100
        }
    }
    
    func getPreSubTotal() -> Double {
        var reqSub = Double(0.0)
        reqSub = Double((getbillingArray.averagePrice!) * Double(Utility.shared.numberofnights_Selected))
        return reqSub
    }
    
    func getBasePrice() -> Double {
        let nights = Utility.shared.numberofnights_Selected
        return Double((self.viewListingArray.listingData?.additionalPrice ?? 1.0) * (Double(Utility.shared.basePriceToBeSend)) * Double(nights))
    }
    func getInfantPrice() -> Double {
        let nights = Utility.shared.numberofnights_Selected
        return Double((self.viewListingArray.listingData?.infantPrice ?? 1.0) * (Double(Utility.shared.infantLimitToBeSend)) * Double(nights))
    }
    
    func getPetPrice() -> Double {
        let nights = Utility.shared.numberofnights_Selected
        return Double((self.viewListingArray.listingData?.petPrice ?? 1.0) * (Double(Utility.shared.petLimitToBeSend)) * Double(nights))
    }
    
    func getVisitorPrice() -> Double {
        return Double((self.viewListingArray.listingData?.visitorsPrice ?? 1.0) * (Double(Utility.shared.visitorToBeSend)))
    }
    
    func getServicefee() -> Double {
        var reqSerFee = Double(0.0)
        let serviceFee = Double(getbillingArray.guestServiceFee != nil ? (getbillingArray.guestServiceFee!) : 0.0)
        let serviceFeePercent = Double(getbillingArray.guestServiceFeePercentage != nil ? (getbillingArray.guestServiceFeePercentage!) : 0.0)
        if serviceFeePercent > 0 && serviceFeePercent != nil{
            reqSerFee = ((getBasePrice() + getInfantPrice() + getPetPrice() + getVisitorPrice() + (getPreSubTotal())) * (serviceFeePercent)) / 100.0
        } else {
            reqSerFee = serviceFee
        }
        return reqSerFee
    }
    
    func getGST() -> Double{
        let nights = Utility.shared.numberofnights_Selected
        var gst = Double(0.0)
        let p1 = (getBasePrice()) + (getInfantPrice()) + (getPetPrice())
        let p2 = (getVisitorPrice() + (getPreSubTotal())) + (getCleaningFee())
        let sbbDay = (p1 + p2) / Double(nights)
        if sbbDay  > 7500 {
            let subTotal = p1 + p2
            gst = ((subTotal) * 18.0) / 100.0
        } else {
            let subTotal = p1 + p2
            gst = ((subTotal) * 12.0) / 100.0
        }
        return gst
    }
    
    func getCleaningFee() -> Double {
        return getbillingArray.cleaningPrice ?? 0.0
    }
    
    func getTotal() -> Double {
        var total = Double(0.0)
        let p1 = (getBasePrice()) + (getInfantPrice()) + (getPetPrice())
        let p2 = (getVisitorPrice() + Double((getbillingArray.averagePrice!) * Double(Utility.shared.numberofnights_Selected))) + self.getGST() + self.getServicefee() + self.getCleaningFee()
        
        return p1 + p2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripsLocationCell", for: indexPath)as! TripsLocationCell
            cell.selectionStyle = .none
            
            var listTypeString = ""
            listTypeString = "\(viewListingArray.roomType ?? "")"
            if ((viewListingArray.beds ?? 0) > 1){
                listTypeString = listTypeString + " / " + "\(viewListingArray.beds ?? 0)" + " beds"
            }else if ((viewListingArray.beds ?? 0) == 1){
                listTypeString = listTypeString + " / " + "\(viewListingArray.beds ?? 0)" + " bed"
            }
            
            cell.lblRoomType.text = listTypeString
            cell.lblDescription.text = viewListingArray.title
            let value1 = Float(viewListingArray.reviewsCount ?? 0)
            let value2 = Float(viewListingArray.reviewsStarRating ?? 0)
            if(value2 != 0.0){
                let reviewcount = (value2/value1)
                
                let divideValue = value2/value1
                cell.lblRating.setTitle(" \(Int(divideValue.rounded()))", for: .normal)
                
                
                cell.lblRating.isHidden = false
                cell.lblReview.isHidden = false
                cell.lblRatingTop.constant = 12
                cell.lblReviewTop.constant = 12
                cell.lblDescriptionTop.constant = 5.5
            }
            else{
                cell.lblRating.titleLabel?.text = " 0.0 "
                cell.lblRating.isHidden = true
                cell.lblReview.isHidden = true
                cell.lblRatingTop.constant = 0
                cell.lblReviewTop.constant = 0
                cell.lblDescriptionTop.constant = 0
            }
            
            
            
            
            if((viewListingArray.reviewsCount!) > 0)
            {
                if((viewListingArray.reviewsCount!) == 1) {
                    cell.lblReview.text = "\u{2022} \(viewListingArray.reviewsCount ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"review"))!)"
                }
                else {
                    cell.lblReview.text = "\u{2022} \(viewListingArray.reviewsCount ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)"
                }
            }
            else
            {
                cell.lblReview.text = "\u{2022} \((Utility.shared.getLanguage()?.value(forKey:"delete_no"))!) \((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)"
                
            }
            
            
            if let imgURL = viewListingArray.listPhotos?[0]?.name {
                cell.imgView.sd_setImage(with: URL(string: "\(IMAGE_LISTING_MEDIUM)\(imgURL)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
                cell.imgView.halfroundedCorners(corners:[.topLeft, .bottomRight] , radius: 10)
              
            }
            return cell
        }
        else if(indexPath.section == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactcheckCell", for: indexPath)as! contactcheckCell
            cell.selectionStyle = .none
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
          
            if(getbillingArray.checkIn != nil) {
                let showDate = inputFormatter.date(from:getbillingArray.checkIn!)
                
                let showDate2 = inputFormatter.date(from:getbillingArray.checkOut!)
                inputFormatter.dateFormat = "MMM dd"
             
                addDateinLabel = inputFormatter.string(from: showDate!)
                addDateoutLabel = inputFormatter.string(from: showDate2!)
                
                cell.checkinoutLabel.text = "\(addDateinLabel) - \(addDateoutLabel)"
            }
          
            if(guestLabel_text == "")
            {
                if Utility.shared.guestc == "" {
                    cell.guestCountsLabel.text = "\(Utility.shared.guestCountToBeSend) \((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                    cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                }
                else {
                    if Utility.shared.guestc == "1" {
                        cell.guestCountsLabel.text = "\(Utility.shared.guestCountToBeSend) \((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                        cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                    }
                    else {
                        cell.guestCountsLabel.text = "\(Utility.shared.guestCountToBeSend)"
                        cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                    }
                }
         
            }
            else{
              
                if Utility.shared.guestc == "" {
                    guestLabel_text = Utility.shared.guestc
                    cell.guestCountsLabel.text = "\(Utility.shared.guestCountToBeSend)"
                    cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                }
                else {
                    cell.guestCountsLabel.text = "\(Utility.shared.guestCountToBeSend)"
                    cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                }
            }
            ///////////////////////////////

            cell.additioNalArrow.isHidden = true
            cell.editAdditonalGuests.isHidden = true
            cell.additionalGuestsView.isHidden = true
            if viewListingArray.listingData?.guestBasePrice != nil {
                cell.additionalGuestsView.isHidden = false
                if(guestBase_text == "")
                {
                    if Utility.shared.guestBase == "" {
                        cell.additionalGuestsValue.text = "\(Utility.shared.basePriceToBeSend) Aditional guests"
    //                    cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                    }
                    else {
                        if Utility.shared.guestBase == "1" {
                            cell.additionalGuestsValue.text = "\(Utility.shared.basePriceToBeSend) Aditional guests"
    //                        cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                        }
                        else {
                            cell.additionalGuestsValue.text = "\(Utility.shared.basePriceToBeSend)"
    //                        cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                        }
                    }
             
                }
                else{
                  
                    if Utility.shared.guestBase == "" {
                        guestBase_text = Utility.shared.guestBase
                        cell.additionalGuestsValue.text = "\(Utility.shared.basePriceToBeSend)"
                       // cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                    }
                    else {
                        cell.additionalGuestsValue.text = "\(Utility.shared.basePriceToBeSend)"
    //                    cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                    }
                }
            }
            
            
            
            
            cell.infantView.isHidden = true
            if viewListingArray.listingData?.infantLimit != nil {
                cell.infantView.isHidden = false
                if(infantLimit_text == "")
                {
                    if Utility.shared.infantLimit == "" {
                        cell.infantValue.text = "\(Utility.shared.infantLimitToBeSend) Infants"
    //                    cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                    }
                    else {
                        if Utility.shared.infantLimit == "1" {
                            cell.infantValue.text = "\(Utility.shared.infantLimitToBeSend) Infants"
    //                        cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                        }
                        else {
                            cell.infantValue.text = "\(Utility.shared.infantLimitToBeSend)"
    //                        cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                        }
                    }
             
                }
                else{
                  
                    if Utility.shared.infantLimit == "" {
                        infantLimit_text = Utility.shared.infantLimit
                        cell.infantValue.text = "\(Utility.shared.infantLimitToBeSend)"
                       // cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                    }
                    else {
                        cell.infantValue.text = "\(Utility.shared.infantLimitToBeSend)"
    //                    cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                    }
                }
                
            }
            
            
            
            
            cell.petView.isHidden = true
            if viewListingArray.listingData?.petLimit != nil {
                cell.petView.isHidden = false
                if(petLimit_text == "")
                {
                    if Utility.shared.pettLimit == "" {
                        cell.petValue.text = "\(Utility.shared.petLimitToBeSend) Pet"
    //                    cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                    }
                    else {
                        if Utility.shared.pettLimit == "1" {
                            cell.petValue.text = "\(Utility.shared.petLimitToBeSend) Pet"
    //                        cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                        }
                        else {
                            cell.petValue.text = "\(Utility.shared.petLimitToBeSend)"
    //                        cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                        }
                    }
             
                }
                else{
                  
                    if Utility.shared.pettLimit == "" {
                        petLimit_text = Utility.shared.pettLimit
                        cell.petValue.text = "\(Utility.shared.petLimitToBeSend)"
                       // cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                    }
                    else {
                        cell.petValue.text = "\(Utility.shared.petLimitToBeSend)"
    //                    cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                    }
                }
                
            }
            
            
            
            
            cell.visitorsView.isHidden = true
            if viewListingArray.listingData?.visitorsLimit != nil {
                cell.visitorsView.isHidden = false
                if(visitorLimit_text == "")
                {
                    if Utility.shared.visitorLimit == "" {
                        cell.visitorsValue.text = "\(Utility.shared.visitorToBeSend) Visitor"
    //                    cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                    }
                    else {
                        if Utility.shared.visitorLimit == "1" {
                            cell.visitorsValue.text = "\(Utility.shared.visitorToBeSend) Visitor"
    //                        cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                        }
                        else {
                            cell.visitorsValue.text = "\(Utility.shared.visitorToBeSend)"
    //                        cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                        }
                    }
             
                }
                else{
                  
                    if Utility.shared.visitorLimit == "" {
                        visitorLimit_text = Utility.shared.visitorLimit
                        cell.visitorsValue.text = "\(Utility.shared.visitorToBeSend)"
                       // cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                    }
                    else {
                        cell.visitorsValue.text = "\(Utility.shared.visitorToBeSend)"
    //                    cell.checkguestLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
                    }
                }
            }
            
            
            if(isFromMessage){
                cell.addOutDateLabel.isHidden = true
                cell.guestLabel.isHidden = true
                cell.checkinimg.isHidden = true
                cell.guestImg.isHidden = true
            }
            else {
                cell.addOutDateLabel.isHidden = false
                cell.guestLabel.isHidden = false
                cell.checkinimg.isHidden = false
                cell.guestImg.isHidden = false
            }
            
            cell.editPetGuests.addTarget(self, action: #selector(petBtnTapped), for: .touchUpInside)
            cell.editVisitorsGuests.addTarget(self, action: #selector(visitorBtnTapped), for: .touchUpInside)
            cell.editInfantGuests.addTarget(self, action: #selector(infantBtnTapped), for: .touchUpInside)
            cell.editAdditonalGuests.addTarget(self, action: #selector(additionalguestBtnTapped), for: .touchUpInside)
            cell.addOutDateLabel.addTarget(self, action: #selector(addinBtnTapped), for: .touchUpInside)
            cell.guestLabel.addTarget(self, action: #selector(guestBtnTapped), for: .touchUpInside)
            return cell
        }
        else if(indexPath.section == 2)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "checkTextviewCell", for: indexPath)as! checkTextviewCell
            cell.selectionStyle = .none
            cell.tag = indexPath.section+2000
            cell.delegate = self
            if(Utility.shared.booking_message != "") {
                cell.checkTxtview.text = Utility.shared.booking_message
                cell.placeholderLabel.isHidden = true
            } else{
                cell.checkTxtview.text = ""
            }
            let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
            toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
            cell.checkTxtview.inputAccessoryView = toolBar
            cell.checkTxtview.autocorrectionType = UITextAutocorrectionType.no
            if isPromotionApplied {
                cell.couponAppliedLabel.isHidden = false
            }else {
                cell.couponAppliedLabel.isHidden = true
            }
            cell.applyCopounCodeBtn.addTarget(self, action: #selector(applyCouponBtnTapped), for: .touchUpInside)
            return cell
        } else if(indexPath.section == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCell", for: indexPath)as! ReservationCell
            cell.selectionStyle = .none
            return cell
        } else if(indexPath.section == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestBookcellTableViewCell", for: indexPath)as! RequestBookcellTableViewCell
            cell.selectionStyle = .none
            var currencysymbol = String()
            cell.specialImage.isHidden = true
            cell.specialImage.addTarget(self, action: #selector(tooltipBtnTapped),for:.touchUpInside)
            
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "") {
                currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)!
            } else {
                currencysymbol = Utility.shared.getSymbol(forCurrencyCode:self.currencyvalue_from_API_base)!
            }
            
            if(getbillingArray.cleaningPrice == 0) {
                if(getbillingArray.discountLabel != nil && getbillingArray.discount != 0 && getbillingArray.taxPrice != 0.0) {
                   
                    if(indexPath.row == 0) {
                      
                        if Utility.shared.numberofnights_Selected > 1 {
                            cell.priceLabel.text = "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text = "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \( getbillingArray.nights ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                        
                        cell.priceLabel.sizeToFit()
                        if(getbillingArray.isSpecialPriceAssigned == true)
                        {
                            
                            cell.specialImage.isHidden = false
                            cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? (getbillingArray.priceForDays!.clean) : "")"
                    }
                    else if(indexPath.row == 1)
                    {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getServicefee())"
                    }
                    else if (indexPath.row == 2){
                        cell.priceLabel.text =  getbillingArray.discountLabel != nil ? getbillingArray.discountLabel!.capitalized : ""
                        
                        cell.priceLeftLabel.text = "-\(currencysymbol)\(getbillingArray.discount != nil ? (getbillingArray.discount!.clean) : "")"
                    }
//                    else if (indexPath.row == 3){
//                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
//                        
//                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.taxPrice != nil ? "\(getbillingArray.taxPrice!.clean)" : "")"
//                    } 
                    else if indexPath.row == 3 && hasGuestPrice == true {
                        cell.priceLabel.text =  "Additional Guest Price"
                        
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getBasePrice())"
                    } else if (indexPath.row == 4 && hasGuestPrice == true && hasInafant == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == true){
                        cell.priceLabel.text =  "Infants"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getInfantPrice())"
                    } else if (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == false && hasPett ==  true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == false && hasPett ==  true){
                        cell.priceLabel.text =  "Pets"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getPetPrice())"
                    } else if (indexPath.row == 6 && hasGuestPrice == true && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == false && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == false && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == false && hasPett ==  false && hasVisitor == true) {
                        cell.priceLabel.text =  "Visitors"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getVisitorPrice())"
                    } else {
                        cell.priceLabel.text =  "GST"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getGST())"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                }
                else if (getbillingArray.discountLabel != nil && getbillingArray.discount != 0){
                    if(indexPath.row == 0) {
                        if Utility.shared.numberofnights_Selected > 1 {
                            cell.priceLabel.text = "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text = "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                        
                        cell.priceLabel.sizeToFit()
                        if(getbillingArray.isSpecialPriceAssigned == true)
                        {
                            
                            cell.specialImage.isHidden = false
                            cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? (getbillingArray.priceForDays!.clean) : "")"
                    }
                    else if(indexPath.row == 1)
                    {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getServicefee())"
                    }
                    else if(indexPath.row == 2){
                        cell.priceLabel.text =  getbillingArray.discountLabel != nil ? getbillingArray.discountLabel!.capitalized : ""
                        
                        cell.priceLeftLabel.text = "-\(currencysymbol)\(getbillingArray.discount != nil ? (getbillingArray.discount!.clean) : "")"
                    }  else if indexPath.row == 3 && hasGuestPrice == true {
                        cell.priceLabel.text =  "Additional Guest Price"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getBasePrice())"
                    } else if (indexPath.row == 4 && hasGuestPrice == true && hasInafant == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == true){
                        cell.priceLabel.text =  "Infants"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getInfantPrice())"
                    } else if (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == false && hasPett ==  true) 
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == false && hasPett ==  true){
                        cell.priceLabel.text =  "Pets"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getPetPrice())"
                    } else if (indexPath.row == 6 && hasGuestPrice == true && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == false && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == false && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == false && hasPett ==  false && hasVisitor == true) {
                        cell.priceLabel.text =  "Visitors"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getVisitorPrice())"
                    } else {
                        cell.priceLabel.text =  "GST"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getGST())"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                    
                } else if (getbillingArray.taxPrice != 0.0){
                    
                    if(indexPath.row == 0) {
                        if Utility.shared.numberofnights_Selected > 1 {
                            cell.priceLabel.text = "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text = "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                        
                        cell.priceLabel.sizeToFit()
                        if(getbillingArray.isSpecialPriceAssigned == true)
                        {
                            
                            cell.specialImage.isHidden = false
                            cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? (getbillingArray.priceForDays!.clean) : "")"
                    } else if(indexPath.row == 1) {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getServicefee())"
                    }
//                    else if (indexPath.row == 2){
//                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
//                        
//                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.taxPrice != nil ? "\(getbillingArray.taxPrice!.clean)" : "")"
//                    }  
                    else if indexPath.row == 2 && hasGuestPrice == true {
                        cell.priceLabel.text =  "Additional Guest Price"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getBasePrice())"
                    } else if (indexPath.row == 3 && hasGuestPrice == true && hasInafant == true)
                                || (indexPath.row == 2 && hasGuestPrice == false && hasInafant == true){
                        cell.priceLabel.text =  "Infants"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getInfantPrice())"
                    } else if (indexPath.row == 4 && hasGuestPrice == true && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 3 && hasGuestPrice == true && hasInafant == false && hasPett ==  true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 2 && hasGuestPrice == false && hasInafant == false && hasPett ==  true){
                        cell.priceLabel.text =  "Pets"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getPetPrice())"
                    } else if (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 3 && hasGuestPrice == true && hasInafant == false && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 2 && hasGuestPrice == false && hasInafant == false && hasPett ==  false && hasVisitor == true) {
                        cell.priceLabel.text =  "Visitors"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getVisitorPrice())"
                    } else {
                        cell.priceLabel.text =  "GST"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getGST())"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                } else {
                    if(indexPath.row == 0) {
                        if Utility.shared.numberofnights_Selected > 1 {
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                        cell.priceLabel.sizeToFit()
                        if(getbillingArray.isSpecialPriceAssigned == true)
                        {
                            
                            cell.specialImage.isHidden = false
                            cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? (getbillingArray.priceForDays!.clean) : "")"
                    }
                    else if(indexPath.row == 1){
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getServicefee())"
                    }  else if indexPath.row == 2 && hasGuestPrice == true {
                        cell.priceLabel.text =  "Additional Guest Price"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getBasePrice())"
                    } else if (indexPath.row == 3 && hasGuestPrice == true && hasInafant == true)
                                || (indexPath.row == 2 && hasGuestPrice == false && hasInafant == true){
                        cell.priceLabel.text =  "Infants"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getInfantPrice())"
                    } else if (indexPath.row == 4 && hasGuestPrice == true && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 3 && hasGuestPrice == true && hasInafant == false && hasPett ==  true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 2 && hasGuestPrice == false && hasInafant == false && hasPett ==  true){
                        cell.priceLabel.text =  "Pets"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getPetPrice())"
                    } else if (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 3 && hasGuestPrice == true && hasInafant == false && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 2 && hasGuestPrice == false && hasInafant == false && hasPett ==  false && hasVisitor == true) {
                        cell.priceLabel.text =  "Visitors"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getVisitorPrice())"
                    } else {
                        cell.priceLabel.text =  "GST"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getGST())"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                    
                }
                
            } else{
                
                if(getbillingArray.discountLabel != nil &&  getbillingArray.discount != 0 && getbillingArray.taxPrice != 0.0) {
                    
                    if(indexPath.row == 0) {
                       
                        if Utility.shared.numberofnights_Selected > 1 {
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \( getbillingArray.nights ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                        cell.priceLabel.sizeToFit()
                        
                        if(getbillingArray.isSpecialPriceAssigned == true) {
                            
                            cell.specialImage.isHidden = false
                            cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? (getbillingArray.priceForDays!.clean) : "")"
                    } else if(indexPath.row == 1) {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.cleaningPrice != nil ? (getbillingArray.cleaningPrice!.clean) : "")"
                    } else if(indexPath.row == 2) {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getServicefee())"
                    }
                    else if(indexPath.row == 3){
                        cell.priceLabel.text =  getbillingArray.discountLabel != nil ? getbillingArray.discountLabel!.capitalized : ""
                        
                        cell.priceLeftLabel.text = "-\(currencysymbol)\(getbillingArray.discount != nil ? (getbillingArray.discount!.clean) : "")"
                    }
//                    else if (indexPath.row == 4){
//                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
//                        
//                        
//                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.taxPrice != nil ? "\(getbillingArray.taxPrice!.clean)" : "")"
//                    } 
                    else if indexPath.row == 4 && hasGuestPrice == true {
                        cell.priceLabel.text =  "Additional Guest Price"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getBasePrice())"
                    } else if (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true){
                        cell.priceLabel.text =  "Infants"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getInfantPrice())"
                    } else if (indexPath.row == 6 && hasGuestPrice == true && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == false && hasPett ==  true)
                                || (indexPath.row == 5 && hasGuestPrice == false && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == false && hasPett ==  true){
                        cell.priceLabel.text =  "Pets"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getPetPrice())"
                    } else if (indexPath.row == 7 && hasGuestPrice == true && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 6 && hasGuestPrice == false && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 6 && hasGuestPrice == true && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 6 && hasGuestPrice == true && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == false && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == false && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == false && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == false && hasPett ==  false && hasVisitor == true) {
                        cell.priceLabel.text =  "Visitors"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getVisitorPrice())"
                    } else {
                        cell.priceLabel.text =  "GST"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getGST())"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                }
                else if (getbillingArray.discountLabel != nil && getbillingArray.discount != 0){
                    if(indexPath.row == 0)
                    {
                        if Utility.shared.numberofnights_Selected > 1 {
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \( getbillingArray.nights ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                        
                        let calculated_Price = Double(String(format: "%.2f",(getbillingArray.basePrice! * Double(Utility.shared.numberofnights_Selected))))as! Double
                        cell.priceLabel.sizeToFit()
                        if(getbillingArray.isSpecialPriceAssigned == true)
                        {
                            
                            cell.specialImage.isHidden = false
                            cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? (getbillingArray.priceForDays!.clean) : "")"
                    }
                    else if(indexPath.row == 1)
                    {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.cleaningPrice != nil ? (getbillingArray.cleaningPrice!.clean) : "")"
                    }
                    else if(indexPath.row == 2)
                    {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getServicefee())"
                    }
                    else if(indexPath.row == 3){
                        cell.priceLabel.text =  getbillingArray.discountLabel != nil ? getbillingArray.discountLabel!.capitalized : ""
                        
                        cell.priceLeftLabel.text = "-\(currencysymbol)\(getbillingArray.discount != nil ? (getbillingArray.discount!.clean) : "")"
                    } else if indexPath.row == 4 && hasGuestPrice == true {
                        cell.priceLabel.text =  "Additional Guest Price"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getBasePrice())"
                    } else if (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true){
                        cell.priceLabel.text =  "Infants"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getInfantPrice())"
                    } else if (indexPath.row == 6 && hasGuestPrice == true && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == false && hasPett ==  true)
                                || (indexPath.row == 5 && hasGuestPrice == false && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == false && hasPett ==  true){
                        cell.priceLabel.text =  "Pets"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getPetPrice())"
                    } else if (indexPath.row == 7 && hasGuestPrice == true && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 6 && hasGuestPrice == false && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 6 && hasGuestPrice == true && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 6 && hasGuestPrice == true && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == false && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == false && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == false && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == false && hasPett ==  false && hasVisitor == true) {
                        cell.priceLabel.text =  "Visitors"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getVisitorPrice())"
                    } else {
                        cell.priceLabel.text =  "GST"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getGST())"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                    
                } else if (getbillingArray.taxPrice != 0.0){
                  
                    if(indexPath.row == 0) {
                        if Utility.shared.numberofnights_Selected > 1 {
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \( getbillingArray.nights ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                        cell.priceLabel.sizeToFit()
                        if(getbillingArray.isSpecialPriceAssigned == true) {
                            cell.specialImage.isHidden = false
                            cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? (getbillingArray.priceForDays!.clean) : "")"
                    } else if(indexPath.row == 1) {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.cleaningPrice != nil ? (getbillingArray.cleaningPrice!.clean) : "")"
                    } else if(indexPath.row == 2) {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getServicefee())"
                    }
//                    else if(indexPath.row == 3){
//                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"taxes"))!)"
//                        
//                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.taxPrice != nil ? "\(getbillingArray.taxPrice!.clean)" : "")"
//                    } 
                    else if indexPath.row == 3 && hasGuestPrice == true {
                        cell.priceLabel.text =  "Additional Guest Price"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getBasePrice())"
                    } else if (indexPath.row == 4 && hasGuestPrice == true && hasInafant == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == true){
                        cell.priceLabel.text =  "Infants"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getInfantPrice())"
                    } else if (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == false && hasPett ==  true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == false && hasPett ==  true){
                        cell.priceLabel.text =  "Pets"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getPetPrice())"
                    } else if (indexPath.row == 6 && hasGuestPrice == true && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == false && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == false && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == false && hasPett ==  false && hasVisitor == true) {
                        cell.priceLabel.text =  "Visitors"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getVisitorPrice())"
                    } else if indexPath.row == 4 && isPromotionApplied {
                      self.setDiscount(cell: cell, indexPath: indexPath, currenySymbol: currencysymbol)
                    }
                    else {
                        cell.priceLabel.text =  "GST"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getGST())"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                    
                } else{
                    if(indexPath.row == 0) {
                        if Utility.shared.numberofnights_Selected > 1 {
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \( getbillingArray.nights ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                        
                        let calculated_Price = Double(String(format: "%.2f",(getbillingArray.basePrice! * Double(Utility.shared.numberofnights_Selected))))as! Double
                        cell.priceLabel.sizeToFit()
                        if(getbillingArray.isSpecialPriceAssigned == true) {
                            
                            cell.specialImage.isHidden = false
                            cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? (getbillingArray.priceForDays!.clean) : "")"
                    } else if(indexPath.row == 1) {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.cleaningPrice != nil ? (getbillingArray.cleaningPrice!.clean) : "")"
                    } else if(indexPath.row == 2){
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getServicefee())"
                    }  else if indexPath.row == 3 && hasGuestPrice == true {
                        cell.priceLabel.text =  "Additional Guest Price"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getBasePrice())"
                    } else if (indexPath.row == 4 && hasGuestPrice == true && hasInafant == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == true){
                        cell.priceLabel.text =  "Infants"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getInfantPrice())"
                    } else if (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == false && hasPett ==  true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true && hasPett ==  true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == false && hasPett ==  true){
                        cell.priceLabel.text =  "Pets"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getPetPrice())"
                    } else if (indexPath.row == 6 && hasGuestPrice == true && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == false && hasInafant == true && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 5 && hasGuestPrice == true && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == false && hasPett ==  true && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == true && hasInafant == false && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 4 && hasGuestPrice == false && hasInafant == true && hasPett ==  false && hasVisitor == true)
                                || (indexPath.row == 3 && hasGuestPrice == false && hasInafant == false && hasPett ==  false && hasVisitor == true) {
                        cell.priceLabel.text =  "Visitors"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getVisitorPrice())"
                    } else {
                        cell.priceLabel.text =  "GST"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(self.getGST())"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                }
                
                
            }
            
            
            
        }
        
        else if(indexPath.section == 5)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingTotalCell", for: indexPath)as! BookingTotalCell
            cell.selectionStyle = .none
            var currencysymbol = String()
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
            {
                currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)!
            }
            else
            {
                currencysymbol = Utility.shared.getSymbol(forCurrencyCode:self.currencyvalue_from_API_base)!
            }
//            cell.totalPriceLabel.text = "\(currencysymbol)\(getbillingArray.total != nil ? (getbillingArray.total!.clean) : "")"
//            totalPriceLabel = "\(currencysymbol)\(getbillingArray.total != nil ? (getbillingArray.total!.clean) : "")"
//
            
            cell.totalPriceLabel.text = "\(currencysymbol)\(self.getTotal())"
            totalPriceLabel = "\(currencysymbol)\(self.getTotal())"
            
            if Utility.shared.isRTLLanguage(){
                
                cell.totalPriceLabel.textAlignment = .left
            }else{
                cell.totalPriceLabel.textAlignment = .right
            }
            
            return cell
        }
        else if(indexPath.section == 6)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookcancellationCell", for: indexPath)as! bookcancellationCell
            cell.cancelpolicyLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 14)
            cell.cancelpolicycontentLabel.font = UIFont(name: APP_FONT, size: 14)
            cell.cancelpolicyLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"cancellations"))!)"
            cell.cancelpolicycontentLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            let fullString =  "Cancellation Policy is '\(viewListingArray.listingData?.cancellation?.policyName ?? "")' and you can \(viewListingArray.listingData?.cancellation?.policyContent ?? "")"
            
           
            let coloredString = "'\(viewListingArray.listingData?.cancellation?.policyName! ?? "")'"
            
           
            let rangeOfColoredString = (fullString as! NSString).range(of: coloredString)
            
          
            let attributedString = NSMutableAttributedString(string:fullString)
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR],
                                           range: rangeOfColoredString)
            cell.cancelpolicycontentLabel.attributedText = attributedString
            
            
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            cell.cancelpolicycontentLabel.addGestureRecognizer(tapGesture)
            cell.cancelpolicycontentLabel.isUserInteractionEnabled = true
            
            cell.selectionStyle = .none
            return cell
        }
        
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AgreetermsCell", for: indexPath)as! AgreetermsCell
            cell.selectionStyle = .none
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
            cell.agreeLabel.addGestureRecognizer(tapGesture)
            cell.agreeLabel.isUserInteractionEnabled = true
            return cell
        }
    }
    

    @objc func dismissgenderPicker() {
        view.endEditing(true)
    }
    
    @objc func addinBtnTapped(_ sender: UIButton!) {
        Utility.shared.blocked_date_month.removeAllObjects()
        for i in viewListingArray.fullBlockedDates!
        {
            let timestamp = i?.blockedDates
            let timestamValue = Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
            let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "dd-LL-YYYY"
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "LL"
            dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
            let date = "\(dateFormatter.string(from: newTime))"
            if(i?.calendarStatus != "available")
            {
                Utility.shared.blocked_date_month.add("\(date)")
            }
            Utility.shared.blockedDates.add(dateFormatter.string(from: newTime))
        }
        
        Utility.shared.fullcheckBlockedDateMonth.removeAllObjects()
        for i in viewListingArray.blockedDates!
        {
            let timestamp = i?.blockedDates
            let timestamValue = Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
            let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "dd-LL-YYYY"
            let dateFormatter1 = DateFormatter()
            dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter1.dateFormat = "LL"
            let date = "\(dateFormatter.string(from: newTime))"
            if(i?.calendarStatus != "available")
            {
                Utility.shared.fullcheckBlockedDateMonth.add("\(date)")
            }
        }
        
        if let checkInDates = viewListingArray.checkInBlockedDates{
            Utility.shared.checkedInDates.removeAllObjects()
            for i in checkInDates{
                let timestamp = i?.blockedDates
                let timestamValue = Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
                let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                dateFormatter.dateFormat = "dd-LL-yyyy"
                
                Utility.shared.checkedInDates.add(dateFormatter.string(from: newTime))
            }
        }
        Utility.shared.minimumstay = (viewListingArray.listingData?.minNight != nil ? ((viewListingArray.listingData?.minNight!)!) : 0)
        Utility.shared.isfromcheckingPage = true
        Utility.shared.maximum_days_notice = Utility.shared.maximum_notice_period(maximumnoticeperiod: (viewListingArray.listingData?.maxDaysNotice != nil ? ((viewListingArray.listingData?.maxDaysNotice!)!) : ""))!
        let datePickerViewController = AirbnbDatePickerViewController(dateFrom: selectedStartDate, dateTo: selectedEndDate)
        datePickerViewController.delegate = self
        datePickerViewController.isFromEdit = true
        datePickerViewController.isFromFilter = false
        datePickerViewController.viewListingArray = viewListingArray
        let navigationController = UINavigationController(rootViewController: datePickerViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    @objc func tooltipBtnTapped(_ sender: UIButton!)
    {
        let preference = ToolTipPreferences()
        preference.drawing.bubble.color = UIColor.darkGray
        preference.drawing.bubble.spacing = 10
        preference.drawing.bubble.cornerRadius = 5
        preference.drawing.bubble.inset = 15
        preference.drawing.bubble.border.color = UIColor(red: 0.768, green: 0.843, blue: 0.937, alpha: 1.000)
        preference.drawing.bubble.border.width = 1
        preference.drawing.arrow.tipCornerRadius = 5
        preference.drawing.message.color = UIColor.white
        preference.drawing.message.font = UIFont(name: APP_FONT, size:15)!
        preference.drawing.button.color = UIColor(red: 0.074, green: 0.231, blue: 0.431, alpha: 1.000)
        preference.drawing.button.font = UIFont(name: APP_FONT, size:15)!
        sender.showToolTip(identifier: "", message:"\((Utility.shared.getLanguage()?.value(forKey:"specialtooltip"))!)", button:nil, arrowPosition: .bottom, preferences: preference, delegate: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        requestTable.beginUpdates()
        Utility.shared.booking_message = textField.text!
        requestTable.endUpdates()
    }
    
    var isEditNumber = 0
    @objc func guestBtnTapped(_ sender: UIButton!) {
        Utility.shared.isfromcheckingPage = true
        isEditNumber = 0
        Utility.shared.maximum_Count_for_booking = viewListingArray.personCapacity != nil ? viewListingArray.personCapacity! : 0
        let occupantController = AirbnbOccupantFilterController(adultCount: adultCount, childrenCount: childrenCount, infantCount: infantCount, hasPet: hasPet, additionalGuestCount: 0, infantCountt: 0, petCountt: 0, visitorCountt:  0)
        occupantController.delegate = self
        let navigationController = UINavigationController(rootViewController: occupantController)
        navigationController.modalPresentationStyle = .overFullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func additionalguestBtnTapped(_ sender: UIButton!) {
        Utility.shared.isfromcheckingPage = true
        isEditNumber = 1
        Utility.shared.maximum_Count_for_additionalGuests = viewListingArray.listingData?.guestBasePrice != nil ? (viewListingArray.listingData?.guestBasePrice!)! : 0
        let occupantController = AirbnbOccupantFilterController(adultCount: adultCount, childrenCount: childrenCount, infantCount: infantCount, hasPet: hasPet, additionalGuestCount: Utility.shared.basePriceToBeSend, isFromAdditionalGuest: true, infantCountt: 0, petCountt: 0, visitorCountt:  0)
        occupantController.delegate = self
        let navigationController = UINavigationController(rootViewController: occupantController)
        navigationController.modalPresentationStyle = .overFullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func infantBtnTapped(_ sender: UIButton!) {
        Utility.shared.isfromcheckingPage = true
        isEditNumber = 2
        Utility.shared.maximum_Count_for_Inafant = viewListingArray.listingData?.infantLimit != nil ? (viewListingArray.listingData?.infantLimit!)! : 0
        let occupantController = AirbnbOccupantFilterController(adultCount: adultCount, childrenCount: childrenCount, infantCount: infantCount, hasPet: hasPet, additionalGuestCount: 0, isFromInafnt: true, infantCountt: Utility.shared.infantLimitToBeSend, petCountt: 0, visitorCountt:  0)
        occupantController.delegate = self
        let navigationController = UINavigationController(rootViewController: occupantController)
        navigationController.modalPresentationStyle = .overFullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func petBtnTapped(_ sender: UIButton!) {
        Utility.shared.isfromcheckingPage = true
        isEditNumber = 3
        Utility.shared.maximum_Count_for_Pet = viewListingArray.listingData?.petLimit != nil ? (viewListingArray.listingData?.petLimit!)! : 0
        let occupantController = AirbnbOccupantFilterController(adultCount: adultCount, childrenCount: childrenCount, infantCount: infantCount, hasPet: hasPet, additionalGuestCount: 0, infantCountt: 0, isFromPet: true, petCountt: Utility.shared.petLimitToBeSend, visitorCountt:  0)
        occupantController.delegate = self
        let navigationController = UINavigationController(rootViewController: occupantController)
        navigationController.modalPresentationStyle = .overFullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func visitorBtnTapped(_ sender: UIButton!) {
        Utility.shared.isfromcheckingPage = true
        isEditNumber = 4
        Utility.shared.maximum_Count_for_Visitor = viewListingArray.listingData?.visitorsLimit != nil ? (viewListingArray.listingData?.visitorsLimit!)! : 0
        let occupantController = AirbnbOccupantFilterController(adultCount: adultCount, childrenCount: childrenCount, infantCount: infantCount, hasPet: hasPet, additionalGuestCount: 0, infantCountt: 0, petCountt: 0, isFromVisitor: true, visitorCountt:  Utility.shared.visitorToBeSend)
        occupantController.delegate = self
        let navigationController = UINavigationController(rootViewController: occupantController)
        navigationController.modalPresentationStyle = .overFullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func datePickerController(_ datePickerController: AirbnbDatePickerViewController, didSaveStartDate startDate: Date?, endDate: Date?) {
        
        selectedStartDate = startDate
        selectedEndDate = endDate
        
        let dateFormatterGet = DateFormatter()
      
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        if(startDate != nil && endDate != nil){
          
        }
        
        if selectedStartDate == nil && selectedEndDate == nil {
            
        } else {
            let fmt = DateFormatter()

            fmt.dateFormat = "yyyy-MM-dd"
           
            isFromCalendar = true
            billingListAPICall(startDate: fmt.string(from: startDate!), endDate: fmt.string(from: endDate!))
        }
    }
    
    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        let houserulesObj = HouseRulesVC()
        houserulesObj.houserulesArray = viewListingArray.houseRules! as! [ViewListingDetailsQueryy.Data.ViewListing.Result.HouseRule]
        houserulesObj.titleString = "\((Utility.shared.getLanguage()?.value(forKey:"houserules"))!)"
        houserulesObj.modalPresentationStyle = .fullScreen
        self.present(houserulesObj, animated: true, completion: nil)
    }
    
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        let cancellationObj = CancellationVC()
        
        
        cancellationObj.cancelpolicy = viewListingArray.listingData?.cancellation?.policyName ?? ""
        
        
        cancellationObj.cancelpolicy_content = viewListingArray.listingData?.cancellation?.policyContent ?? ""
        
        
        cancellationObj.modalPresentationStyle = .fullScreen
        self.present(cancellationObj, animated: true, completion: nil)
    }
    
    @objc func applyCouponBtnTapped(_ sender: UIButton) {
        if isPromotionApplied {
            isPromotionApplied = false
            dynamicCells -= 1
        }
        let promotionVC = PromotionVC()
        promotionVC.delegate = self
        let navigationController = UINavigationController(rootViewController: promotionVC)
        navigationController.modalPresentationStyle = .overFullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func occupantFilterController(_ occupantFilterController: AirbnbOccupantFilterController, didSaveAdult adult: Int, children: Int, infant: Int, pet: Bool, guestBase: Int, infantLimit: Int, petLimit: Int, visitorLimit: Int) {
        self.adultCount = adult
        self.childrenCount = children
        self.infantCount = infant
        self.hasPet = pet
        self.guest_filter = adult
        
        let human = adult + children
      //  Utility.shared.guestCountToBeSend = human
        
        //viewListingArray.personCapacity != nil ? viewListingArray.personCapacity! : 0
        
        var basesG = self.viewListingArray.listingData?.guestBasePrice ?? 0
        if basesG == 0 || basesG == nil {
            basesG = (viewListingArray.personCapacity != nil ? viewListingArray.personCapacity! : 0)
        }
        let humann = (human > basesG) ? basesG : human
        Utility.shared.guestCountToBeSend = humann
        
        let infant = "\(infant > 0 ? (infant.description + " infant" + (infant > 1 ? "s" : "")) : "")"
        let pet = "\(pet ? "pets" : "")"
        
        if isEditNumber == 1 {
            guestBase_text = "\(guestBase) Additional Guests"
            Utility.shared.guestBase = guestBase_text
            Utility.shared.basePriceToBeSend = guestBase
            self.requestTable.reloadSections([1,3,4,5], with: .none)
        } else if isEditNumber == 2 {
            infantLimit_text = "\(infantLimit) Infants"
            Utility.shared.infantLimit = infantLimit_text
            Utility.shared.infantLimitToBeSend = infantLimit
            self.requestTable.reloadSections([1,3,4,5], with: .none)
        } else if isEditNumber == 3 {
            petLimit_text = "\(petLimit) Pets"
            Utility.shared.pettLimit = petLimit_text
            Utility.shared.petLimitToBeSend = petLimit
            self.requestTable.reloadSections([1,3,4,5], with: .none)
        } else if isEditNumber == 4 {
            visitorLimit_text = "\(visitorLimit) Visitor"
            Utility.shared.visitorLimit = visitorLimit_text
            Utility.shared.visitorToBeSend = visitorLimit
            self.requestTable.reloadSections([1,3,4,5], with: .none)
        } else {
            if human > 1{
                guestLabel_text = "\(human) \((Utility.shared.getLanguage()?.value(forKey:"CapGuests")) ?? "Guests")" + (infant != "" ? ", " + infant : "") + (pet != "" ? ", " + pet : "")
                Utility.shared.guestc = guestLabel_text
            }else{
                guestLabel_text = "\(human) \((Utility.shared.getLanguage()?.value(forKey:"guest"))!)" + (infant != "" ? ", " + infant : "") + (pet != "" ? ", " + pet : "")
                Utility.shared.guestc = guestLabel_text
            }
            var basesG = self.viewListingArray.listingData?.guestBasePrice ?? 0
            if basesG == 0 || basesG == nil {
                basesG = (viewListingArray.personCapacity != nil ? viewListingArray.personCapacity! : 0)
            }
            let selectedG = Int((Utility.shared.guestc).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "Guests", with: "").replacingOccurrences(of: "Guest", with: "").replacingOccurrences(of: "guests", with: "").replacingOccurrences(of: "guest", with: "")) ?? 0
            let maxG = Utility.shared.maximum_Count_for_booking
            let addG = (selectedG > basesG) ? (selectedG - basesG) : 0
            guestBase_text = "\(addG)"//"\(guestBase) Additional Guests"
            Utility.shared.guestBase = guestBase_text
            Utility.shared.basePriceToBeSend = addG
            
            self.requestTable.reloadSections([1,3,4,5], with: .none)
        }
            
        
        
    }
    
    
    func setBillingListAPICall(startDate:String,endDate:String)
    {
        var currency = String()
        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
        {
            currency = Utility.shared.getPreferredCurrency()!
        }
        else
        {
            currency = Utility.shared.currencyvalue_from_API_base
        }
        let billingListquery = GetBillingCalculationQueryy(listId: viewListingArray.id!, startDate: startDate, endDate: endDate, guests: (Utility.shared.guestCountToBeSend) + (Int(Utility.shared.guestBase ?? "0") ?? 0), visitors: Utility.shared.visitorToBeSend, pets: Utility.shared.petLimitToBeSend, infants: Utility.shared.infantLimitToBeSend, convertCurrency:currency)
        apollo_headerClient.fetch(query: billingListquery){(result,error) in
            
            DispatchQueue.main.async {
                
                guard (result?.data?.getBillingCalculation?.result) != nil else{
                    self.view.makeToast(result?.data?.getBillingCalculation?.errorMessage)
                    return
                }
                self.getbillingArray = (result?.data?.getBillingCalculation?.result)!
//                Utility.shared.guestCountToBeSend = self.getbillingArray.guests ?? Utility.shared.guestCountToBeSend
//                if self.isFromCalendar {
//                    self.isFromCalendar = false
//                    self.requestTable.reloadSections([1,3,4,5], with: .none)
//                }
//                else {
//                    self.requestTable.reloadData()
//                }
                
                if(self.viewListingArray.bookingType! == "instant") {
                    self.lottieanimation()
                    let cell = self.view.viewWithTag((2) + 2000) as? checkTextviewCell
                    Utility.shared.booking_message = (cell?.checkTxtview.text ?? "")
                    
                    if(Utility.shared.booking_message == "")
                    {
                        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"messagealert"))!)")
                        self.lottieView.isHidden = true
                    } else{
                        
                        self.profileAPICall()
                    }
                } else {
                    self.lottieanimation()
                    let cell = self.view.viewWithTag((2) + 2000) as? checkTextviewCell
                    Utility.shared.booking_message = (cell?.checkTxtview.text ?? "")
                    if(Utility.shared.booking_message == "")
                    {
                        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"messagealert"))!)")
                        self.lottieView.isHidden = true
                    } else{
                        
                        self.requestBookAPICall(message: Utility.shared.booking_message ?? "")
                    }
                    
                }
            }
            
            
        }
        
    }
    
    func billingListAPICall(startDate:String,endDate:String)
    {
        var currency = String()
        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
        {
            currency = Utility.shared.getPreferredCurrency()!
        }
        else
        {
            currency = Utility.shared.currencyvalue_from_API_base
        }
        let billingListquery = GetBillingCalculationQueryy(listId: viewListingArray.id!, startDate: startDate, endDate: endDate, guests: Utility.shared.guestCountToBeSend, visitors: Utility.shared.visitorToBeSend, pets: Utility.shared.petLimitToBeSend, infants: Utility.shared.infantLimitToBeSend, convertCurrency:currency)
        apollo_headerClient.fetch(query: billingListquery){(result,error) in
            guard (result?.data?.getBillingCalculation?.result) != nil else{
                self.view.makeToast(result?.data?.getBillingCalculation?.errorMessage)
                return
            }
            self.getbillingArray = (result?.data?.getBillingCalculation?.result)!
            Utility.shared.guestCountToBeSend = self.getbillingArray.guests ?? Utility.shared.guestCountToBeSend
            if self.isFromCalendar {
                self.isFromCalendar = false
                self.requestTable.reloadSections([1,3,4,5], with: .none)
            }
            else {
                self.requestTable.reloadData()
            }
            
        }
        
    }
    func lottieanimation()
    {
     
        lottieView = LottieAnimationView.init(name: "animation_white")
        
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:bookBtn.frame.size.width/2-60, y:-25, width:100, height:100)
        self.bookBtn.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.play()
        
    }
    
    func getTopViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    func profileAPICall()
    {
        let profileQuery = GetProfileQuery()
        
        apollo_headerClient.fetch(query:profileQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            
            guard (result?.data?.userAccount?.result) != nil else
            {
                if result?.data?.userAccount?.status == 500{
                    let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message: result?.data?.userAccount?.errorMessage, preferredStyle: .alert)
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
                    self.lottieView.isHidden = true
                    if(self.viewListingArray.bookingType! == "instant")
                    {
                        self.bookBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"addpayment"))!)", for: .normal)
                    }
                    else
                    {
                        self.bookBtn.setTitle("Request A Book", for: .normal)
//                        self.bookBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"addpayment"))!)", for: .normal)
                    }
                    return
                }
                
            }
            self.lottieView.isHidden = true
            
            self.ProfileAPIArray = ((result?.data?.userAccount?.result)!)
            
            self.lottieView.isHidden = true
            if(self.viewListingArray.bookingType! == "instant")
            {
                self.bookBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"addpayment"))!)", for: .normal)
            }
            else
            {
                self.bookBtn.setTitle("Request A Book", for: .normal)
//                self.bookBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"addpayment"))!)", for: .normal)
            }
            
            
            
            if(self.ProfileAPIArray.verification?.isEmailConfirmed == true)
            {
                
                if(self.ProfileAPIArray.picture == nil)
                {
                    Utility.shared.isprofilepictureVerified = true
                }
                else
                {
                    Utility.shared.isprofilepictureVerified = false
                }
                
                
                
                Utility.shared.bookingListimage = self.viewListingArray.listPhotoName != nil ? self.viewListingArray.listPhotoName! : ""
                Utility.shared.bookingListname = self.viewListingArray.title != nil ? self.viewListingArray.title! : ""
                if(self.guestLabel_text == "")
                {
                    self.guestLabel_text = "1 \((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                }
                Utility.shared.bookingdateLabel = "\(self.addDateinLabel) - \(self.addDateoutLabel), \(self.guestLabel_text)"
                
                if(Utility.shared.isprofilepictureVerified)
                {
                    let bookingThreeObj = BookingStepThreeVC()
                    
                    bookingThreeObj.viewListingArray = self.viewListingArray
                    bookingThreeObj.currencyvalue_from_API_base = self.currencyvalue_from_API_base
                    bookingThreeObj.getbillingArray = self.getbillingArray
                    bookingThreeObj.viewListingArray = self.viewListingArray
                    bookingThreeObj.modalPresentationStyle = .fullScreen
                    self.present(bookingThreeObj, animated: true, completion: nil)
                } else {
                    
//                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                       let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
//                        let navigationController = UINavigationController(rootViewController: self)
//                        keyWindow.rootViewController = navigationController
//                        
//                        let paymentSelectionPage = PaymentSelectionPage()
//                        paymentSelectionPage.currencyvalue_from_API_base = self.currencyvalue_from_API_base
//                        paymentSelectionPage.threadId = self.threadId
//                        paymentSelectionPage.getbillingArray = self.getbillingArray
//                        paymentSelectionPage.viewListingArray = self.viewListingArray
//
//                        // Push the view controller onto the navigation stack
//                        self.navigationController?.pushViewController(paymentSelectionPage, animated: true)
//                    }
                    DispatchQueue.main.async {
                        
//                        let paymentSelectionPage = PaymentSelectionPage()
//                        paymentSelectionPage.navigationControllerReference = self.navigationControllerReference
//                        paymentSelectionPage.currencyvalue_from_API_base = self.currencyvalue_from_API_base
//                        paymentSelectionPage.threadId = self.threadId
//                        paymentSelectionPage.getbillingArray = self.getbillingArray
//                        paymentSelectionPage.viewListingArray = self.viewListingArray
                        
                        
                        //                        if let topViewController = self.getTopViewController() {
                        //                            let navigationVC = UINavigationController(rootViewController: paymentSelectionPage)
                        //                            navigationVC.isNavigationBarHidden = true
                        //                            navigationVC.modalPresentationStyle = .fullScreen
                        //                            self.navigationControllerReference?.pushViewController(paymentSelectionPage, animated: true)
                        ////                            topViewController.present(navigationVC, animated: true, completion: nil)
                        //                        }
                        
                        
                        //                        let navigationVC = UINavigationController(rootViewController: paymentSelectionPage)
                        //                        navigationVC.isNavigationBarHidden = true
                        //                        navigationVC.modalPresentationStyle = .fullScreen
                        //                        self.present(navigationVC, animated: true, completion: nil)
                        
                        //                        self.navigationControllerReference?.pushViewController(paymentSelectionPage, animated: true)
                        //                    }
                        
                                            let paymentSelectionPage = PaymentSelectionPage()
                        
                        paymentSelectionPage.overallTotal = self.getTotal()
                        paymentSelectionPage.totalPetPrice = self.getPetPrice()
                        paymentSelectionPage.totalInfantPrice = self.getInfantPrice()
                        paymentSelectionPage.totalVisitorPrice = self.getVisitorPrice()
                        paymentSelectionPage.totalAdditionalPrice = self.getBasePrice()
                        paymentSelectionPage.additionalGuestCount = Utility.shared.guestBase
                        paymentSelectionPage.isFromm = "insss"
                                            paymentSelectionPage.navigationControllerReference = self.navigationControllerReference
                                            paymentSelectionPage.currencyvalue_from_API_base = self.currencyvalue_from_API_base
                                            paymentSelectionPage.threadId = self.threadId
                                            paymentSelectionPage.getbillingArray = self.getbillingArray
                                            paymentSelectionPage.viewListingArray = self.viewListingArray
//                                            self.navigationControllerReference?.pushViewController(paymentSelectionPage, animated: true)
                                            paymentSelectionPage.modalPresentationStyle = .fullScreen
                                            self.present(paymentSelectionPage, animated: true, completion: nil)
                    }
                }
             
                
            }
            else{
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"emailverifyalert"))!)")
                
            }
        }
        
        
    }
    
 
    func requestBookAPICall(message: String) {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM-dd-yyyy"
        
        let createlist = CreateRequestToBookMutation(listId: viewListingArray.id!
                                                     , hostId: viewListingArray.userId!
                                                     , content:message
                                                     , userId: "\(Utility.shared.getCurrentUserID()!)"
                                                     , type: "requestToBook"
                                                     , startDate: fmt.string(from: selectedStartDate!)
                                                     , endDate: fmt.string(from: selectedEndDate!)
                                                     , personCapacity: (Utility.shared.guestCountToBeSend ?? 0) + (Int(Utility.shared.guestBase ?? "0") ?? 0)
                                                     , visitors: Utility.shared.visitorToBeSend ?? 0
                                                     , pets: Utility.shared.petLimitToBeSend ?? 0
                                                     , infants: Utility.shared.infantLimitToBeSend ?? 0 )
        apollo_headerClient.perform(mutation: createlist){ (result,error) in
            self.lottieView.isHidden = true
            if result?.data?.createRequestToBook?.status == 200 {
                self.dismiss(animated: true)
            } else {
                self.view.makeToast(result?.data?.createRequestToBook?.errorMessage ?? "Error")
                self.bookBtn.setTitle("Request A Book", for: .normal)
            }
//            if(result?.data?.createListing?.status == 200) {
//
//                self.updateResultsStep1 = (result?.data?.createListing?.results)!
//                Utility.shared.createId = (result?.data?.createListing?.id)!
//                self.manageListingSteps(listId: "\((result?.data?.createListing?.id)!)", currentStep: 1)
//            } else {
//                self.lottieView1.isHidden = true
//                self.nextBtn.setTitle("Next", for:.normal)
//            }
        }
    }
    
}

//MARK: Promotion Delegates
extension RequestbookVC: PromotionDelegate {
    func didApplyPromotion(type: PromotionType) {
        if type == .none {
            isPromotionApplied = false
        }else {
            if isPromotionApplied == false {
                dynamicCells += 1
            }
            isPromotionApplied = true
        }
        self.requestTable.reloadSections([2,4], with: .automatic)
    }
}

public final class GetBillingCalculationQueryy: GraphQLQuery {
  public let operationDefinition =
    """
    query getBillingCalculation($listId: Int!, $startDate: String!, $endDate: String!, $guests: Int!, $visitors: Int!, $pets: Int!, $infants: Int!, $convertCurrency: String!) {
      getBillingCalculation(listId: $listId, startDate: $startDate, endDate: $endDate, guests: $guests, visitors: $visitors, pets: $pets, infants: $infants, convertCurrency: $convertCurrency) {
        __typename
        result {
          __typename
          checkIn
          checkOut
          nights
          basePrice
          cleaningPrice
          taxPrice
          guests
          guestBasePrice
          additionalPrice
          visitorsLimit
          visitorsPrice
          petLimit
          petPrice
          infantLimit
          infantPrice
          currency
          guestServiceFeePercentage
          hostServiceFeePercentage
          weeklyDiscountPercentage
          monthlyDiscountPercentage
          guestServiceFee
          hostServiceFee
          discountLabel
          discount
          subtotal
          total
          averagePrice
          priceForDays
          specialPricing {
            __typename
            blockedDates
            isSpecialPrice
          }
          isSpecialPriceAssigned
        }
        status
        errorMessage
      }
    }
    """

  public var listId: Int
  public var startDate: String
  public var endDate: String
  public var guests: Int
  public var visitors: Int
  public var pets: Int
  public var infants: Int
  public var convertCurrency: String

  public init(listId: Int, startDate: String, endDate: String, guests: Int, visitors: Int, pets: Int, infants: Int, convertCurrency: String) {
    self.listId = listId
    self.startDate = startDate
    self.endDate = endDate
    self.guests = guests
    self.visitors = visitors
    self.pets = pets
    self.infants = infants
    self.convertCurrency = convertCurrency
  }

  public var variables: GraphQLMap? {
    return ["listId": listId, "startDate": startDate, "endDate": endDate, "guests": guests, "visitors": visitors, "pets": pets, "infants": infants, "convertCurrency": convertCurrency]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getBillingCalculation", arguments: [
        "listId": GraphQLVariable("listId"),
        "startDate": GraphQLVariable("startDate"),
        "endDate": GraphQLVariable("endDate"),
        "guests": GraphQLVariable("guests"),
        "visitors": GraphQLVariable("visitors"),
        "pets": GraphQLVariable("pets"),
        "infants": GraphQLVariable("infants"),
        "convertCurrency": GraphQLVariable("convertCurrency")
      ], type: .object(GetBillingCalculation.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }


    public init(getBillingCalculation: GetBillingCalculation? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getBillingCalculation": getBillingCalculation.flatMap { (value: GetBillingCalculation) -> ResultMap in value.resultMap }])
    }

    public var getBillingCalculation: GetBillingCalculation? {
      get {
        return (resultMap["getBillingCalculation"] as? ResultMap).flatMap { GetBillingCalculation(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getBillingCalculation")
      }
    }

    public struct GetBillingCalculation: GraphQLSelectionSet {
      public static let possibleTypes = ["AllBillingType"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("result", type: .object(Result.selections)),
        GraphQLField("status", type: .scalar(Int.self)),
        GraphQLField("errorMessage", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(result: Result? = nil, status: Int? = nil, errorMessage: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "AllBillingType", "result": result.flatMap { (value: Result) -> ResultMap in value.resultMap }, "status": status, "errorMessage": errorMessage])
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

      public struct Result: GraphQLSelectionSet {
        public static let possibleTypes = ["BillingType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("checkIn", type: .scalar(String.self)),
          GraphQLField("checkOut", type: .scalar(String.self)),
          GraphQLField("nights", type: .scalar(Int.self)),
          GraphQLField("basePrice", type: .scalar(Double.self)),
          GraphQLField("cleaningPrice", type: .scalar(Double.self)),
          GraphQLField("taxPrice", type: .scalar(Double.self)),
          GraphQLField("guests", type: .scalar(Int.self)),
          GraphQLField("guestBasePrice", type: .scalar(Int.self)),
          GraphQLField("additionalPrice", type: .scalar(Double.self)),
          GraphQLField("visitorsLimit", type: .scalar(Int.self)),
          GraphQLField("visitorsPrice", type: .scalar(Double.self)),
          GraphQLField("petLimit", type: .scalar(Int.self)),
          GraphQLField("petPrice", type: .scalar(Double.self)),
          GraphQLField("infantLimit", type: .scalar(Int.self)),
          GraphQLField("infantPrice", type: .scalar(Double.self)),
          GraphQLField("currency", type: .scalar(String.self)),
          GraphQLField("guestServiceFeePercentage", type: .scalar(Double.self)),
          GraphQLField("hostServiceFeePercentage", type: .scalar(Double.self)),
          GraphQLField("weeklyDiscountPercentage", type: .scalar(Double.self)),
          GraphQLField("monthlyDiscountPercentage", type: .scalar(Double.self)),
          GraphQLField("guestServiceFee", type: .scalar(Double.self)),
          GraphQLField("hostServiceFee", type: .scalar(Double.self)),
          GraphQLField("discountLabel", type: .scalar(String.self)),
          GraphQLField("discount", type: .scalar(Double.self)),
          GraphQLField("subtotal", type: .scalar(Double.self)),
          GraphQLField("total", type: .scalar(Double.self)),
          GraphQLField("averagePrice", type: .scalar(Double.self)),
          GraphQLField("priceForDays", type: .scalar(Double.self)),
          GraphQLField("specialPricing", type: .list(.object(SpecialPricing.selections))),
          GraphQLField("isSpecialPriceAssigned", type: .scalar(Bool.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(checkIn: String? = nil, checkOut: String? = nil, nights: Int? = nil, basePrice: Double? = nil, cleaningPrice: Double? = nil, taxPrice: Double? = nil, guests: Int? = nil, guestBasePrice: Int? = nil, additionalPrice: Double? = nil, visitorsLimit: Int? = nil, visitorsPrice: Double? = nil, petLimit: Int? = nil, petPrice: Double? = nil, infantLimit: Int? = nil, infantPrice: Double? = nil, currency: String? = nil, guestServiceFeePercentage: Double? = nil, hostServiceFeePercentage: Double? = nil, weeklyDiscountPercentage: Double? = nil, monthlyDiscountPercentage: Double? = nil, guestServiceFee: Double? = nil, hostServiceFee: Double? = nil, discountLabel: String? = nil, discount: Double? = nil, subtotal: Double? = nil, total: Double? = nil, averagePrice: Double? = nil, priceForDays: Double? = nil, specialPricing: [SpecialPricing?]? = nil, isSpecialPriceAssigned: Bool? = nil) {
          self.init(unsafeResultMap: ["__typename": "BillingType", "checkIn": checkIn, "checkOut": checkOut, "nights": nights, "basePrice": basePrice, "cleaningPrice": cleaningPrice, "taxPrice": taxPrice, "guests": guests, "guestBasePrice": guestBasePrice, "additionalPrice": additionalPrice, "visitorsLimit": visitorsLimit, "visitorsPrice": visitorsPrice, "petLimit": petLimit, "petPrice": petPrice, "infantLimit": infantLimit, "infantPrice": infantPrice, "currency": currency, "guestServiceFeePercentage": guestServiceFeePercentage, "hostServiceFeePercentage": hostServiceFeePercentage, "weeklyDiscountPercentage": weeklyDiscountPercentage, "monthlyDiscountPercentage": monthlyDiscountPercentage, "guestServiceFee": guestServiceFee, "hostServiceFee": hostServiceFee, "discountLabel": discountLabel, "discount": discount, "subtotal": subtotal, "total": total, "averagePrice": averagePrice, "priceForDays": priceForDays, "specialPricing": specialPricing.flatMap { (value: [SpecialPricing?]) -> [ResultMap?] in value.map { (value: SpecialPricing?) -> ResultMap? in value.flatMap { (value: SpecialPricing) -> ResultMap in value.resultMap } } }, "isSpecialPriceAssigned": isSpecialPriceAssigned])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
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

        public var nights: Int? {
          get {
            return resultMap["nights"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "nights")
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

        public var taxPrice: Double? {
          get {
            return resultMap["taxPrice"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "taxPrice")
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
          
          public var guestBasePrice: Int? {
            get {
              return resultMap["guestBasePrice"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "guestBasePrice")
            }
          }

          public var additionalPrice: Double? {
            get {
              return resultMap["additionalPrice"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "additionalPrice")
            }
          }
          
          public var visitorsLimit: Int? {
            get {
              return resultMap["visitorsLimit"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "visitorsLimit")
            }
          }
          
          public var visitorsPrice: Double? {
            get {
              return resultMap["visitorsPrice"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "visitorsPrice")
            }
          }
          
          public var petLimit: Int? {
            get {
              return resultMap["petLimit"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "petLimit")
            }
          }
          
          public var petPrice: Double? {
            get {
              return resultMap["petPrice"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "petPrice")
            }
          }
          
          public var infantLimit: Int? {
            get {
              return resultMap["infantLimit"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "infantLimit")
            }
          }
          
          public var infantPrice: Double? {
            get {
              return resultMap["infantPrice"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "infantPrice")
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

        public var guestServiceFeePercentage: Double? {
          get {
            return resultMap["guestServiceFeePercentage"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "guestServiceFeePercentage")
          }
        }

        public var hostServiceFeePercentage: Double? {
          get {
            return resultMap["hostServiceFeePercentage"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "hostServiceFeePercentage")
          }
        }

        public var weeklyDiscountPercentage: Double? {
          get {
            return resultMap["weeklyDiscountPercentage"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "weeklyDiscountPercentage")
          }
        }

        public var monthlyDiscountPercentage: Double? {
          get {
            return resultMap["monthlyDiscountPercentage"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "monthlyDiscountPercentage")
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

        public var discountLabel: String? {
          get {
            return resultMap["discountLabel"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "discountLabel")
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

        public var subtotal: Double? {
          get {
            return resultMap["subtotal"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "subtotal")
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

        public var averagePrice: Double? {
          get {
            return resultMap["averagePrice"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "averagePrice")
          }
        }

        public var priceForDays: Double? {
          get {
            return resultMap["priceForDays"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "priceForDays")
          }
        }

        public var specialPricing: [SpecialPricing?]? {
          get {
            return (resultMap["specialPricing"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [SpecialPricing?] in value.map { (value: ResultMap?) -> SpecialPricing? in value.flatMap { (value: ResultMap) -> SpecialPricing in SpecialPricing(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [SpecialPricing?]) -> [ResultMap?] in value.map { (value: SpecialPricing?) -> ResultMap? in value.flatMap { (value: SpecialPricing) -> ResultMap in value.resultMap } } }, forKey: "specialPricing")
          }
        }

        public var isSpecialPriceAssigned: Bool? {
          get {
            return resultMap["isSpecialPriceAssigned"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isSpecialPriceAssigned")
          }
        }

        public struct SpecialPricing: GraphQLSelectionSet {
          public static let possibleTypes = ["SpecialPricingType"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("blockedDates", type: .scalar(String.self)),
            GraphQLField("isSpecialPrice", type: .scalar(Double.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(blockedDates: String? = nil, isSpecialPrice: Double? = nil) {
            self.init(unsafeResultMap: ["__typename": "SpecialPricingType", "blockedDates": blockedDates, "isSpecialPrice": isSpecialPrice])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var blockedDates: String? {
            get {
              return resultMap["blockedDates"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "blockedDates")
            }
          }

          public var isSpecialPrice: Double? {
            get {
              return resultMap["isSpecialPrice"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "isSpecialPrice")
            }
          }
        }
      }
    }
  }
}


public final class ViewListingDetailsQueryy: GraphQLQuery {
  public let operationDefinition =
    "query viewListingDetails($listId: Int!, $preview: Boolean) {\n  viewListing(listId: $listId, preview: $preview) {\n    __typename\n    results {\n      __typename\n      id\n      userId\n      title\n      residenceType\n      description\n      coverPhoto\n      city\n      state\n      country\n      isPublished\n      lat\n      lng\n      houseType\n      roomType\n      bookingType\n      bedrooms\n      beds\n      personCapacity\n      bathrooms\n      coverPhoto\n      listPhotoName\n      userBedsTypes {\n        __typename\n        bedCount\n        bedName\n      }\n      listPhotos {\n        __typename\n        id\n        name\n      }\n      listingPhotos {\n        __typename\n        id\n        name\n      }\n      user {\n        __typename\n        email\n        profile {\n          __typename\n          profileId\n          displayName\n          picture\n          firstName\n        }\n      }\n      userAmenities {\n        __typename\n        id\n        image\n        itemName\n      }\n      userSafetyAmenities {\n        __typename\n        id\n        image\n        itemName\n      }\n      userSpaces {\n        __typename\n        id\n        image\n        itemName\n      }\n      houseRules {\n        __typename\n        id\n        image\n        itemName\n      }\n      settingsData {\n        __typename\n        listsettings {\n          __typename\n          id\n          itemName\n          settingsType {\n            __typename\n            typeName\n          }\n        }\n      }\n      listingData {\n        __typename\n        bookingNoticeTime\n        checkInStart\n        checkInEnd\n        maxDaysNotice\n        minNight\n        maxNight\n        basePrice\n        guestBasePrice\n        infantLimit\n        additionalPrice\n        visitorsPrice\n        petPrice\n        infantPrice\n        visitorsLimit\n        petLimit\n        cleaningPrice\n        currency\n        weeklyDiscount\n        monthlyDiscount\n        cancellation {\n          __typename\n          id\n          policyName\n          policyContent\n        }\n      }\n      blockedDates {\n        __typename\n        blockedDates\n        reservationId\n        calendarStatus\n        isSpecialPrice\n        listId\n        dayStatus\n      }\n      checkInBlockedDates {\n        __typename\n        listId\n        blockedDates\n        calendarStatus\n        isSpecialPrice\n        dayStatus\n      }\n      fullBlockedDates {\n        __typename\n        listId\n        blockedDates\n        calendarStatus\n        isSpecialPrice\n        dayStatus\n      }\n      reviewsCount\n      reviewsStarRating\n      isListOwner\n      wishListStatus\n      wishListGroupCount\n    }\n    status\n    errorMessage\n  }\n}"

  public var listId: Int
  public var preview: Bool?

  public init(listId: Int, preview: Bool? = nil) {
    self.listId = listId
    self.preview = preview
  }

  public var variables: GraphQLMap? {
    return ["listId": listId, "preview": preview]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("viewListing", arguments: ["listId": GraphQLVariable("listId"), "preview": GraphQLVariable("preview")], type: .object(ViewListing.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(viewListing: ViewListing? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "viewListing": viewListing.flatMap { (value: ViewListing) -> ResultMap in value.resultMap }])
    }

    public var viewListing: ViewListing? {
      get {
        return (resultMap["viewListing"] as? ResultMap).flatMap { ViewListing(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "viewListing")
      }
    }

    public struct ViewListing: GraphQLSelectionSet {
      public static let possibleTypes = ["AllListing"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("results", type: .object(Result.selections)),
        GraphQLField("status", type: .scalar(Int.self)),
        GraphQLField("errorMessage", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(results: Result? = nil, status: Int? = nil, errorMessage: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "AllListing", "results": results.flatMap { (value: Result) -> ResultMap in value.resultMap }, "status": status, "errorMessage": errorMessage])
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

      public struct Result: GraphQLSelectionSet {
        public static let possibleTypes = ["ShowListing"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(Int.self)),
          GraphQLField("userId", type: .scalar(String.self)),
          GraphQLField("title", type: .scalar(String.self)),
          GraphQLField("residenceType", type: .scalar(String.self)),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("coverPhoto", type: .scalar(Int.self)),
          GraphQLField("city", type: .scalar(String.self)),
          GraphQLField("state", type: .scalar(String.self)),
          GraphQLField("country", type: .scalar(String.self)),
          GraphQLField("isPublished", type: .scalar(Bool.self)),
          GraphQLField("lat", type: .scalar(Double.self)),
          GraphQLField("lng", type: .scalar(Double.self)),
          GraphQLField("houseType", type: .scalar(String.self)),
          GraphQLField("roomType", type: .scalar(String.self)),
          GraphQLField("bookingType", type: .scalar(String.self)),
          GraphQLField("bedrooms", type: .scalar(String.self)),
          GraphQLField("beds", type: .scalar(Int.self)),
          GraphQLField("personCapacity", type: .scalar(Int.self)),
          GraphQLField("bathrooms", type: .scalar(Double.self)),
          GraphQLField("coverPhoto", type: .scalar(Int.self)),
          GraphQLField("listPhotoName", type: .scalar(String.self)),
          GraphQLField("userBedsTypes", type: .list(.object(UserBedsType.selections))),
          GraphQLField("listPhotos", type: .list(.object(ListPhoto.selections))),
          GraphQLField("listingPhotos", type: .list(.object(ListingPhoto.selections))),
          GraphQLField("user", type: .object(User.selections)),
          GraphQLField("userAmenities", type: .list(.object(UserAmenity.selections))),
          GraphQLField("userSafetyAmenities", type: .list(.object(UserSafetyAmenity.selections))),
          GraphQLField("userSpaces", type: .list(.object(UserSpace.selections))),
          GraphQLField("houseRules", type: .list(.object(HouseRule.selections))),
          GraphQLField("settingsData", type: .list(.object(SettingsDatum.selections))),
          GraphQLField("listingData", type: .object(ListingDatum.selections)),
          GraphQLField("blockedDates", type: .list(.object(BlockedDate.selections))),
          GraphQLField("checkInBlockedDates", type: .list(.object(CheckInBlockedDate.selections))),
          GraphQLField("fullBlockedDates", type: .list(.object(FullBlockedDate.selections))),
          GraphQLField("reviewsCount", type: .scalar(Int.self)),
          GraphQLField("reviewsStarRating", type: .scalar(Int.self)),
          GraphQLField("isListOwner", type: .scalar(Bool.self)),
          GraphQLField("wishListStatus", type: .scalar(Bool.self)),
          GraphQLField("wishListGroupCount", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: Int? = nil, userId: String? = nil, title: String? = nil, residenceType: String? = nil, description: String? = nil, coverPhoto: Int? = nil, city: String? = nil, state: String? = nil, country: String? = nil, isPublished: Bool? = nil, lat: Double? = nil, lng: Double? = nil, houseType: String? = nil, roomType: String? = nil, bookingType: String? = nil, bedrooms: String? = nil, beds: Int? = nil, personCapacity: Int? = nil, bathrooms: Double? = nil, listPhotoName: String? = nil, userBedsTypes: [UserBedsType?]? = nil, listPhotos: [ListPhoto?]? = nil, listingPhotos: [ListingPhoto?]? = nil, user: User? = nil, userAmenities: [UserAmenity?]? = nil, userSafetyAmenities: [UserSafetyAmenity?]? = nil, userSpaces: [UserSpace?]? = nil, houseRules: [HouseRule?]? = nil, settingsData: [SettingsDatum?]? = nil, listingData: ListingDatum? = nil, blockedDates: [BlockedDate?]? = nil, checkInBlockedDates: [CheckInBlockedDate?]? = nil, fullBlockedDates: [FullBlockedDate?]? = nil, reviewsCount: Int? = nil, reviewsStarRating: Int? = nil, isListOwner: Bool? = nil, wishListStatus: Bool? = nil, wishListGroupCount: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "ShowListing", "id": id, "userId": userId, "title": title, "residenceType": residenceType, "description": description, "coverPhoto": coverPhoto, "city": city, "state": state, "country": country, "isPublished": isPublished, "lat": lat, "lng": lng, "houseType": houseType, "roomType": roomType, "bookingType": bookingType, "bedrooms": bedrooms, "beds": beds, "personCapacity": personCapacity, "bathrooms": bathrooms, "listPhotoName": listPhotoName, "userBedsTypes": userBedsTypes.flatMap { (value: [UserBedsType?]) -> [ResultMap?] in value.map { (value: UserBedsType?) -> ResultMap? in value.flatMap { (value: UserBedsType) -> ResultMap in value.resultMap } } }, "listPhotos": listPhotos.flatMap { (value: [ListPhoto?]) -> [ResultMap?] in value.map { (value: ListPhoto?) -> ResultMap? in value.flatMap { (value: ListPhoto) -> ResultMap in value.resultMap } } }, "listingPhotos": listingPhotos.flatMap { (value: [ListingPhoto?]) -> [ResultMap?] in value.map { (value: ListingPhoto?) -> ResultMap? in value.flatMap { (value: ListingPhoto) -> ResultMap in value.resultMap } } }, "user": user.flatMap { (value: User) -> ResultMap in value.resultMap }, "userAmenities": userAmenities.flatMap { (value: [UserAmenity?]) -> [ResultMap?] in value.map { (value: UserAmenity?) -> ResultMap? in value.flatMap { (value: UserAmenity) -> ResultMap in value.resultMap } } }, "userSafetyAmenities": userSafetyAmenities.flatMap { (value: [UserSafetyAmenity?]) -> [ResultMap?] in value.map { (value: UserSafetyAmenity?) -> ResultMap? in value.flatMap { (value: UserSafetyAmenity) -> ResultMap in value.resultMap } } }, "userSpaces": userSpaces.flatMap { (value: [UserSpace?]) -> [ResultMap?] in value.map { (value: UserSpace?) -> ResultMap? in value.flatMap { (value: UserSpace) -> ResultMap in value.resultMap } } }, "houseRules": houseRules.flatMap { (value: [HouseRule?]) -> [ResultMap?] in value.map { (value: HouseRule?) -> ResultMap? in value.flatMap { (value: HouseRule) -> ResultMap in value.resultMap } } }, "settingsData": settingsData.flatMap { (value: [SettingsDatum?]) -> [ResultMap?] in value.map { (value: SettingsDatum?) -> ResultMap? in value.flatMap { (value: SettingsDatum) -> ResultMap in value.resultMap } } }, "listingData": listingData.flatMap { (value: ListingDatum) -> ResultMap in value.resultMap }, "blockedDates": blockedDates.flatMap { (value: [BlockedDate?]) -> [ResultMap?] in value.map { (value: BlockedDate?) -> ResultMap? in value.flatMap { (value: BlockedDate) -> ResultMap in value.resultMap } } }, "checkInBlockedDates": checkInBlockedDates.flatMap { (value: [CheckInBlockedDate?]) -> [ResultMap?] in value.map { (value: CheckInBlockedDate?) -> ResultMap? in value.flatMap { (value: CheckInBlockedDate) -> ResultMap in value.resultMap } } }, "fullBlockedDates": fullBlockedDates.flatMap { (value: [FullBlockedDate?]) -> [ResultMap?] in value.map { (value: FullBlockedDate?) -> ResultMap? in value.flatMap { (value: FullBlockedDate) -> ResultMap in value.resultMap } } }, "reviewsCount": reviewsCount, "reviewsStarRating": reviewsStarRating, "isListOwner": isListOwner, "wishListStatus": wishListStatus, "wishListGroupCount": wishListGroupCount])
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

        public var userId: String? {
          get {
            return resultMap["userId"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "userId")
          }
        }

        public var title: String? {
          get {
            return resultMap["title"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "title")
          }
        }

        public var residenceType: String? {
          get {
            return resultMap["residenceType"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "residenceType")
          }
        }

        public var description: String? {
          get {
            return resultMap["description"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "description")
          }
        }

        public var coverPhoto: Int? {
          get {
            return resultMap["coverPhoto"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "coverPhoto")
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

        public var country: String? {
          get {
            return resultMap["country"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "country")
          }
        }

        public var isPublished: Bool? {
          get {
            return resultMap["isPublished"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isPublished")
          }
        }

        public var lat: Double? {
          get {
            return resultMap["lat"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "lat")
          }
        }

        public var lng: Double? {
          get {
            return resultMap["lng"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "lng")
          }
        }

        public var houseType: String? {
          get {
            return resultMap["houseType"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "houseType")
          }
        }

        public var roomType: String? {
          get {
            return resultMap["roomType"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "roomType")
          }
        }

        public var bookingType: String? {
          get {
            return resultMap["bookingType"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "bookingType")
          }
        }

        public var bedrooms: String? {
          get {
            return resultMap["bedrooms"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "bedrooms")
          }
        }

        public var beds: Int? {
          get {
            return resultMap["beds"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "beds")
          }
        }

        public var personCapacity: Int? {
          get {
            return resultMap["personCapacity"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "personCapacity")
          }
        }

        public var bathrooms: Double? {
          get {
            return resultMap["bathrooms"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "bathrooms")
          }
        }

        public var listPhotoName: String? {
          get {
            return resultMap["listPhotoName"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "listPhotoName")
          }
        }

        public var userBedsTypes: [UserBedsType?]? {
          get {
            return (resultMap["userBedsTypes"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [UserBedsType?] in value.map { (value: ResultMap?) -> UserBedsType? in value.flatMap { (value: ResultMap) -> UserBedsType in UserBedsType(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [UserBedsType?]) -> [ResultMap?] in value.map { (value: UserBedsType?) -> ResultMap? in value.flatMap { (value: UserBedsType) -> ResultMap in value.resultMap } } }, forKey: "userBedsTypes")
          }
        }

        public var listPhotos: [ListPhoto?]? {
          get {
            return (resultMap["listPhotos"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [ListPhoto?] in value.map { (value: ResultMap?) -> ListPhoto? in value.flatMap { (value: ResultMap) -> ListPhoto in ListPhoto(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [ListPhoto?]) -> [ResultMap?] in value.map { (value: ListPhoto?) -> ResultMap? in value.flatMap { (value: ListPhoto) -> ResultMap in value.resultMap } } }, forKey: "listPhotos")
          }
        }

        public var listingPhotos: [ListingPhoto?]? {
          get {
            return (resultMap["listingPhotos"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [ListingPhoto?] in value.map { (value: ResultMap?) -> ListingPhoto? in value.flatMap { (value: ResultMap) -> ListingPhoto in ListingPhoto(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [ListingPhoto?]) -> [ResultMap?] in value.map { (value: ListingPhoto?) -> ResultMap? in value.flatMap { (value: ListingPhoto) -> ResultMap in value.resultMap } } }, forKey: "listingPhotos")
          }
        }

        public var user: User? {
          get {
            return (resultMap["user"] as? ResultMap).flatMap { User(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "user")
          }
        }

        public var userAmenities: [UserAmenity?]? {
          get {
            return (resultMap["userAmenities"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [UserAmenity?] in value.map { (value: ResultMap?) -> UserAmenity? in value.flatMap { (value: ResultMap) -> UserAmenity in UserAmenity(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [UserAmenity?]) -> [ResultMap?] in value.map { (value: UserAmenity?) -> ResultMap? in value.flatMap { (value: UserAmenity) -> ResultMap in value.resultMap } } }, forKey: "userAmenities")
          }
        }

        public var userSafetyAmenities: [UserSafetyAmenity?]? {
          get {
            return (resultMap["userSafetyAmenities"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [UserSafetyAmenity?] in value.map { (value: ResultMap?) -> UserSafetyAmenity? in value.flatMap { (value: ResultMap) -> UserSafetyAmenity in UserSafetyAmenity(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [UserSafetyAmenity?]) -> [ResultMap?] in value.map { (value: UserSafetyAmenity?) -> ResultMap? in value.flatMap { (value: UserSafetyAmenity) -> ResultMap in value.resultMap } } }, forKey: "userSafetyAmenities")
          }
        }

        public var userSpaces: [UserSpace?]? {
          get {
            return (resultMap["userSpaces"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [UserSpace?] in value.map { (value: ResultMap?) -> UserSpace? in value.flatMap { (value: ResultMap) -> UserSpace in UserSpace(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [UserSpace?]) -> [ResultMap?] in value.map { (value: UserSpace?) -> ResultMap? in value.flatMap { (value: UserSpace) -> ResultMap in value.resultMap } } }, forKey: "userSpaces")
          }
        }

        public var houseRules: [HouseRule?]? {
          get {
            return (resultMap["houseRules"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [HouseRule?] in value.map { (value: ResultMap?) -> HouseRule? in value.flatMap { (value: ResultMap) -> HouseRule in HouseRule(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [HouseRule?]) -> [ResultMap?] in value.map { (value: HouseRule?) -> ResultMap? in value.flatMap { (value: HouseRule) -> ResultMap in value.resultMap } } }, forKey: "houseRules")
          }
        }

        public var settingsData: [SettingsDatum?]? {
          get {
            return (resultMap["settingsData"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [SettingsDatum?] in value.map { (value: ResultMap?) -> SettingsDatum? in value.flatMap { (value: ResultMap) -> SettingsDatum in SettingsDatum(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [SettingsDatum?]) -> [ResultMap?] in value.map { (value: SettingsDatum?) -> ResultMap? in value.flatMap { (value: SettingsDatum) -> ResultMap in value.resultMap } } }, forKey: "settingsData")
          }
        }

        public var listingData: ListingDatum? {
          get {
            return (resultMap["listingData"] as? ResultMap).flatMap { ListingDatum(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "listingData")
          }
        }

        public var blockedDates: [BlockedDate?]? {
          get {
            return (resultMap["blockedDates"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [BlockedDate?] in value.map { (value: ResultMap?) -> BlockedDate? in value.flatMap { (value: ResultMap) -> BlockedDate in BlockedDate(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [BlockedDate?]) -> [ResultMap?] in value.map { (value: BlockedDate?) -> ResultMap? in value.flatMap { (value: BlockedDate) -> ResultMap in value.resultMap } } }, forKey: "blockedDates")
          }
        }

        public var checkInBlockedDates: [CheckInBlockedDate?]? {
          get {
            return (resultMap["checkInBlockedDates"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [CheckInBlockedDate?] in value.map { (value: ResultMap?) -> CheckInBlockedDate? in value.flatMap { (value: ResultMap) -> CheckInBlockedDate in CheckInBlockedDate(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [CheckInBlockedDate?]) -> [ResultMap?] in value.map { (value: CheckInBlockedDate?) -> ResultMap? in value.flatMap { (value: CheckInBlockedDate) -> ResultMap in value.resultMap } } }, forKey: "checkInBlockedDates")
          }
        }

        public var fullBlockedDates: [FullBlockedDate?]? {
          get {
            return (resultMap["fullBlockedDates"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [FullBlockedDate?] in value.map { (value: ResultMap?) -> FullBlockedDate? in value.flatMap { (value: ResultMap) -> FullBlockedDate in FullBlockedDate(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [FullBlockedDate?]) -> [ResultMap?] in value.map { (value: FullBlockedDate?) -> ResultMap? in value.flatMap { (value: FullBlockedDate) -> ResultMap in value.resultMap } } }, forKey: "fullBlockedDates")
          }
        }

        public var reviewsCount: Int? {
          get {
            return resultMap["reviewsCount"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "reviewsCount")
          }
        }

        public var reviewsStarRating: Int? {
          get {
            return resultMap["reviewsStarRating"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "reviewsStarRating")
          }
        }

        public var isListOwner: Bool? {
          get {
            return resultMap["isListOwner"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isListOwner")
          }
        }

        public var wishListStatus: Bool? {
          get {
            return resultMap["wishListStatus"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "wishListStatus")
          }
        }

        public var wishListGroupCount: Int? {
          get {
            return resultMap["wishListGroupCount"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "wishListGroupCount")
          }
        }

        public struct UserBedsType: GraphQLSelectionSet {
          public static let possibleTypes = ["BedTypes"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bedCount", type: .scalar(Int.self)),
            GraphQLField("bedName", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(bedCount: Int? = nil, bedName: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "BedTypes", "bedCount": bedCount, "bedName": bedName])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var bedCount: Int? {
            get {
              return resultMap["bedCount"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "bedCount")
            }
          }

          public var bedName: String? {
            get {
              return resultMap["bedName"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bedName")
            }
          }
        }

        public struct ListPhoto: GraphQLSelectionSet {
          public static let possibleTypes = ["listPhotosData"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
            GraphQLField("name", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int? = nil, name: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "listPhotosData", "id": id, "name": name])
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

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }
        }

        public struct ListingPhoto: GraphQLSelectionSet {
          public static let possibleTypes = ["listPhotosData"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
            GraphQLField("name", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int? = nil, name: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "listPhotosData", "id": id, "name": name])
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

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }
        }

        public struct User: GraphQLSelectionSet {
          public static let possibleTypes = ["user"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("email", type: .scalar(String.self)),
            GraphQLField("profile", type: .object(Profile.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(email: String? = nil, profile: Profile? = nil) {
            self.init(unsafeResultMap: ["__typename": "user", "email": email, "profile": profile.flatMap { (value: Profile) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var email: String? {
            get {
              return resultMap["email"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "email")
            }
          }

          public var profile: Profile? {
            get {
              return (resultMap["profile"] as? ResultMap).flatMap { Profile(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "profile")
            }
          }

          public struct Profile: GraphQLSelectionSet {
            public static let possibleTypes = ["profile"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("profileId", type: .scalar(Int.self)),
              GraphQLField("displayName", type: .scalar(String.self)),
              GraphQLField("picture", type: .scalar(String.self)),
              GraphQLField("firstName", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(profileId: Int? = nil, displayName: String? = nil, picture: String? = nil, firstName: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "profile", "profileId": profileId, "displayName": displayName, "picture": picture, "firstName": firstName])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var profileId: Int? {
              get {
                return resultMap["profileId"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "profileId")
              }
            }

            public var displayName: String? {
              get {
                return resultMap["displayName"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "displayName")
              }
            }

            public var picture: String? {
              get {
                return resultMap["picture"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "picture")
              }
            }

            public var firstName: String? {
              get {
                return resultMap["firstName"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "firstName")
              }
            }
          }
        }

        public struct UserAmenity: GraphQLSelectionSet {
          public static let possibleTypes = ["allListSettingTypes"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
            GraphQLField("image", type: .scalar(String.self)),
            GraphQLField("itemName", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int? = nil, image: String? = nil, itemName: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "allListSettingTypes", "id": id, "image": image, "itemName": itemName])
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

          public var image: String? {
            get {
              return resultMap["image"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "image")
            }
          }

          public var itemName: String? {
            get {
              return resultMap["itemName"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "itemName")
            }
          }
        }

        public struct UserSafetyAmenity: GraphQLSelectionSet {
          public static let possibleTypes = ["allListSettingTypes"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
            GraphQLField("image", type: .scalar(String.self)),
            GraphQLField("itemName", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int? = nil, image: String? = nil, itemName: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "allListSettingTypes", "id": id, "image": image, "itemName": itemName])
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

          public var image: String? {
            get {
              return resultMap["image"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "image")
            }
          }

          public var itemName: String? {
            get {
              return resultMap["itemName"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "itemName")
            }
          }
        }

        public struct UserSpace: GraphQLSelectionSet {
          public static let possibleTypes = ["allListSettingTypes"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
            GraphQLField("image", type: .scalar(String.self)),
            GraphQLField("itemName", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int? = nil, image: String? = nil, itemName: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "allListSettingTypes", "id": id, "image": image, "itemName": itemName])
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

          public var image: String? {
            get {
              return resultMap["image"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "image")
            }
          }

          public var itemName: String? {
            get {
              return resultMap["itemName"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "itemName")
            }
          }
        }

        public struct HouseRule: GraphQLSelectionSet {
          public static let possibleTypes = ["allListSettingTypes"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
            GraphQLField("image", type: .scalar(String.self)),
            GraphQLField("itemName", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int? = nil, image: String? = nil, itemName: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "allListSettingTypes", "id": id, "image": image, "itemName": itemName])
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

          public var image: String? {
            get {
              return resultMap["image"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "image")
            }
          }

          public var itemName: String? {
            get {
              return resultMap["itemName"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "itemName")
            }
          }
        }

        public struct SettingsDatum: GraphQLSelectionSet {
          public static let possibleTypes = ["userListingData"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("listsettings", type: .object(Listsetting.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(listsettings: Listsetting? = nil) {
            self.init(unsafeResultMap: ["__typename": "userListingData", "listsettings": listsettings.flatMap { (value: Listsetting) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var listsettings: Listsetting? {
            get {
              return (resultMap["listsettings"] as? ResultMap).flatMap { Listsetting(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "listsettings")
            }
          }

          public struct Listsetting: GraphQLSelectionSet {
            public static let possibleTypes = ["singleListSettings"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(Int.self)),
              GraphQLField("itemName", type: .scalar(String.self)),
              GraphQLField("settingsType", type: .object(SettingsType.selections)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: Int? = nil, itemName: String? = nil, settingsType: SettingsType? = nil) {
              self.init(unsafeResultMap: ["__typename": "singleListSettings", "id": id, "itemName": itemName, "settingsType": settingsType.flatMap { (value: SettingsType) -> ResultMap in value.resultMap }])
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

            public var itemName: String? {
              get {
                return resultMap["itemName"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "itemName")
              }
            }

            public var settingsType: SettingsType? {
              get {
                return (resultMap["settingsType"] as? ResultMap).flatMap { SettingsType(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "settingsType")
              }
            }

            public struct SettingsType: GraphQLSelectionSet {
              public static let possibleTypes = ["listSettingsTypes"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("typeName", type: .scalar(String.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(typeName: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "listSettingsTypes", "typeName": typeName])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var typeName: String? {
                get {
                  return resultMap["typeName"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "typeName")
                }
              }
            }
          }
        }

        public struct ListingDatum: GraphQLSelectionSet {
          public static let possibleTypes = ["listingData"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bookingNoticeTime", type: .scalar(String.self)),
            GraphQLField("checkInStart", type: .scalar(String.self)),
            GraphQLField("checkInEnd", type: .scalar(String.self)),
            GraphQLField("maxDaysNotice", type: .scalar(String.self)),
            GraphQLField("minNight", type: .scalar(Int.self)),
            GraphQLField("maxNight", type: .scalar(Int.self)),
            GraphQLField("basePrice", type: .scalar(Double.self)),
            GraphQLField("guestBasePrice", type: .scalar(Int.self)),
            GraphQLField("infantLimit", type: .scalar(Int.self)),
            GraphQLField("additionalPrice", type: .scalar(Double.self)),
            GraphQLField("visitorsPrice", type: .scalar(Double.self)),
            GraphQLField("petPrice", type: .scalar(Double.self)),
            GraphQLField("infantPrice", type: .scalar(Double.self)),
            GraphQLField("petLimit", type: .scalar(Int.self)),
            GraphQLField("visitorsLimit", type: .scalar(Int.self)),
            GraphQLField("cleaningPrice", type: .scalar(Double.self)),
            GraphQLField("currency", type: .scalar(String.self)),
            GraphQLField("weeklyDiscount", type: .scalar(Int.self)),
            GraphQLField("monthlyDiscount", type: .scalar(Int.self)),
            GraphQLField("cancellation", type: .object(Cancellation.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(bookingNoticeTime: String? = nil, checkInStart: String? = nil, checkInEnd: String? = nil, maxDaysNotice: String? = nil, minNight: Int? = nil, maxNight: Int? = nil, basePrice: Double? = nil, additionalPrice: Double? = nil, visitorsPrice: Double? = nil, petPrice: Double? = nil, infantPrice: Double? = nil, guestBasePrice: Int? = nil, infantLimit: Int? = nil, petLimit: Int? = nil, visitorsLimit: Int? = nil, cleaningPrice: Double? = nil, currency: String? = nil, weeklyDiscount: Int? = nil, monthlyDiscount: Int? = nil, cancellation: Cancellation? = nil) {
            self.init(unsafeResultMap: ["__typename": "listingData", "bookingNoticeTime": bookingNoticeTime, "checkInStart": checkInStart, "checkInEnd": checkInEnd, "maxDaysNotice": maxDaysNotice, "minNight": minNight, "maxNight": maxNight, "basePrice": basePrice, "additionalPrice": additionalPrice, "visitorsPrice": visitorsPrice, "petPrice": petPrice, "infantPrice": infantPrice, "guestBasePrice": guestBasePrice,"infantLimit": infantLimit,"petLimit": petLimit,"visitorsLimit": visitorsLimit, "cleaningPrice": cleaningPrice, "currency": currency, "weeklyDiscount": weeklyDiscount, "monthlyDiscount": monthlyDiscount, "cancellation": cancellation.flatMap { (value: Cancellation) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var bookingNoticeTime: String? {
            get {
              return resultMap["bookingNoticeTime"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "bookingNoticeTime")
            }
          }

          public var checkInStart: String? {
            get {
              return resultMap["checkInStart"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "checkInStart")
            }
          }

          public var checkInEnd: String? {
            get {
              return resultMap["checkInEnd"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "checkInEnd")
            }
          }

          public var maxDaysNotice: String? {
            get {
              return resultMap["maxDaysNotice"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "maxDaysNotice")
            }
          }

          public var minNight: Int? {
            get {
              return resultMap["minNight"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "minNight")
            }
          }

          public var maxNight: Int? {
            get {
              return resultMap["maxNight"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "maxNight")
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
            
            public var additionalPrice: Double? {
              get {
                return resultMap["additionalPrice"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "additionalPrice")
              }
            }
            
            public var visitorsPrice: Double? {
              get {
                return resultMap["visitorsPrice"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "visitorsPrice")
              }
            }
            
            public var petPrice: Double? {
              get {
                return resultMap["petPrice"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "petPrice")
              }
            }
            
            public var infantPrice: Double? {
              get {
                return resultMap["infantPrice"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "infantPrice")
              }
            }
            
            public var guestBasePrice: Int? {
              get {
                return resultMap["guestBasePrice"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "guestBasePrice")
              }
            }
            public var infantLimit: Int? {
              get {
                return resultMap["infantLimit"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "infantLimit")
              }
            }
            
            public var petLimit: Int? {
              get {
                return resultMap["petLimit"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "petLimit")
              }
            }
            
            public var visitorsLimit: Int? {
              get {
                return resultMap["visitorsLimit"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "visitorsLimit")
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

          public var weeklyDiscount: Int? {
            get {
              return resultMap["weeklyDiscount"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "weeklyDiscount")
            }
          }

          public var monthlyDiscount: Int? {
            get {
              return resultMap["monthlyDiscount"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "monthlyDiscount")
            }
          }

          public var cancellation: Cancellation? {
            get {
              return (resultMap["cancellation"] as? ResultMap).flatMap { Cancellation(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "cancellation")
            }
          }

          public struct Cancellation: GraphQLSelectionSet {
            public static let possibleTypes = ["Cancellation"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(Int.self)),
              GraphQLField("policyName", type: .scalar(String.self)),
              GraphQLField("policyContent", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: Int? = nil, policyName: String? = nil, policyContent: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "Cancellation", "id": id, "policyName": policyName, "policyContent": policyContent])
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

            public var policyName: String? {
              get {
                return resultMap["policyName"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "policyName")
              }
            }

            public var policyContent: String? {
              get {
                return resultMap["policyContent"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "policyContent")
              }
            }
          }
        }

        public struct BlockedDate: GraphQLSelectionSet {
          public static let possibleTypes = ["listBlockedDates"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("blockedDates", type: .scalar(String.self)),
            GraphQLField("reservationId", type: .scalar(Int.self)),
            GraphQLField("calendarStatus", type: .scalar(String.self)),
            GraphQLField("isSpecialPrice", type: .scalar(Double.self)),
            GraphQLField("listId", type: .scalar(Int.self)),
            GraphQLField("dayStatus", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(blockedDates: String? = nil, reservationId: Int? = nil, calendarStatus: String? = nil, isSpecialPrice: Double? = nil, listId: Int? = nil, dayStatus: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "listBlockedDates", "blockedDates": blockedDates, "reservationId": reservationId, "calendarStatus": calendarStatus, "isSpecialPrice": isSpecialPrice, "listId": listId, "dayStatus": dayStatus])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var blockedDates: String? {
            get {
              return resultMap["blockedDates"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "blockedDates")
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

          public var calendarStatus: String? {
            get {
              return resultMap["calendarStatus"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "calendarStatus")
            }
          }

          public var isSpecialPrice: Double? {
            get {
              return resultMap["isSpecialPrice"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "isSpecialPrice")
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

          public var dayStatus: String? {
            get {
              return resultMap["dayStatus"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "dayStatus")
            }
          }
        }

        public struct CheckInBlockedDate: GraphQLSelectionSet {
          public static let possibleTypes = ["listBlockedDates"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("listId", type: .scalar(Int.self)),
            GraphQLField("blockedDates", type: .scalar(String.self)),
            GraphQLField("calendarStatus", type: .scalar(String.self)),
            GraphQLField("isSpecialPrice", type: .scalar(Double.self)),
            GraphQLField("dayStatus", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(listId: Int? = nil, blockedDates: String? = nil, calendarStatus: String? = nil, isSpecialPrice: Double? = nil, dayStatus: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "listBlockedDates", "listId": listId, "blockedDates": blockedDates, "calendarStatus": calendarStatus, "isSpecialPrice": isSpecialPrice, "dayStatus": dayStatus])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
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

          public var blockedDates: String? {
            get {
              return resultMap["blockedDates"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "blockedDates")
            }
          }

          public var calendarStatus: String? {
            get {
              return resultMap["calendarStatus"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "calendarStatus")
            }
          }

          public var isSpecialPrice: Double? {
            get {
              return resultMap["isSpecialPrice"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "isSpecialPrice")
            }
          }

          public var dayStatus: String? {
            get {
              return resultMap["dayStatus"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "dayStatus")
            }
          }
        }

        public struct FullBlockedDate: GraphQLSelectionSet {
          public static let possibleTypes = ["listBlockedDates"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("listId", type: .scalar(Int.self)),
            GraphQLField("blockedDates", type: .scalar(String.self)),
            GraphQLField("calendarStatus", type: .scalar(String.self)),
            GraphQLField("isSpecialPrice", type: .scalar(Double.self)),
            GraphQLField("dayStatus", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(listId: Int? = nil, blockedDates: String? = nil, calendarStatus: String? = nil, isSpecialPrice: Double? = nil, dayStatus: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "listBlockedDates", "listId": listId, "blockedDates": blockedDates, "calendarStatus": calendarStatus, "isSpecialPrice": isSpecialPrice, "dayStatus": dayStatus])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
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

          public var blockedDates: String? {
            get {
              return resultMap["blockedDates"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "blockedDates")
            }
          }

          public var calendarStatus: String? {
            get {
              return resultMap["calendarStatus"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "calendarStatus")
            }
          }

          public var isSpecialPrice: Double? {
            get {
              return resultMap["isSpecialPrice"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "isSpecialPrice")
            }
          }

          public var dayStatus: String? {
            get {
              return resultMap["dayStatus"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "dayStatus")
            }
          }
        }
      }
    }
  }
}


public final class CreateRequestToBookMutation: GraphQLMutation {
  public let operationDefinition =
    """
    mutation CreateRequestToBook($listId: Int!, $hostId: String!, $content: String!, $userId: String!, $type: String, $startDate: String!, $endDate: String!, $personCapacity: Int, $visitors: Int, $pets: Int, $infants: Int) {
      CreateRequestToBook(listId: $listId, hostId: $hostId, userId: $userId, content: $content, type: $type, startDate: $startDate, endDate: $endDate, personCapacity: $personCapacity, visitors: $visitors, pets: $pets, infants: $infants) {
        __typename
        status
        errorMessage
      }
    }
    """

  public var listId: Int
  public var hostId: String
  public var content: String
  public var userId: String
  public var type: String?
  public var startDate: String
  public var endDate: String
  public var personCapacity: Int?
  public var visitors: Int?
  public var pets: Int?
  public var infants: Int?

  public init(listId: Int, hostId: String, content: String, userId: String, type: String? = nil, startDate: String, endDate: String, personCapacity: Int? = nil, visitors: Int? = nil, pets: Int? = nil, infants: Int? = nil) {
    self.listId = listId
    self.hostId = hostId
    self.content = content
    self.userId = userId
    self.type = type
    self.startDate = startDate
    self.endDate = endDate
    self.personCapacity = personCapacity
    self.visitors = visitors
    self.pets = pets
    self.infants = infants
  }

  public var variables: GraphQLMap? {
    return ["listId": listId, "hostId": hostId, "content": content, "userId": userId, "type": type, "startDate": startDate, "endDate": endDate, "personCapacity": personCapacity, "visitors": visitors, "pets": pets, "infants": infants]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("CreateRequestToBook", arguments: ["listId": GraphQLVariable("listId"), "hostId": GraphQLVariable("hostId"), "userId": GraphQLVariable("userId"), "content": GraphQLVariable("content"), "type": GraphQLVariable("type"), "startDate": GraphQLVariable("startDate"), "endDate": GraphQLVariable("endDate"), "personCapacity": GraphQLVariable("personCapacity"), "visitors": GraphQLVariable("visitors"), "pets": GraphQLVariable("pets"), "infants": GraphQLVariable("infants")], type: .object(CreateRequestToBook.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createRequestToBook: CreateRequestToBook? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "CreateRequestToBook": createRequestToBook.flatMap { (value: CreateRequestToBook) -> ResultMap in value.resultMap }])
    }

    public var createRequestToBook: CreateRequestToBook? {
      get {
        return (resultMap["CreateRequestToBook"] as? ResultMap).flatMap { CreateRequestToBook(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "CreateRequestToBook")
      }
    }

    public struct CreateRequestToBook: GraphQLSelectionSet {
      public static let possibleTypes = ["RequestToBook"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("status", type: .scalar(Int.self)),
        GraphQLField("errorMessage", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(status: Int? = nil, errorMessage: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "RequestToBook", "status": status, "errorMessage": errorMessage])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
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
    }
  }
}
