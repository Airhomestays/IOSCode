
import UIKit
import IQKeyboardManagerSwift
import Apollo
import Lottie


protocol ContacthostVCDelegate {
    func passSelectedStartDate(selectedstartDate:Date)
    func passSelectedEndDate(selectedenddate:Date)
    func passgetBillingArray(getbillingArray:GetBillingCalculationQueryy.Data.GetBillingCalculation.Result)
    
    
}

class ContacthostVC: UIViewController,UITableViewDelegate,UITableViewDataSource,checkTextviewCellDelegate,AirbnbDatePickerDelegate,AirbnbOccupantFilterControllerDelegate {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var offlineView: UIView!
    
    @IBOutlet weak var errorLAbel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var contacthostTable: UITableView!
     var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    var getbillingArray = GetBillingCalculationQueryy.Data.GetBillingCalculation.Result()
    var currencyvalue_from_API_base = String()
    var currency_Dict = NSDictionary()
    var addDateinLabel = String()
    var addDateoutLabel = String()
    var guestLabel_text = String()
    var selected_datein_Label = String()
    var selected_dateout_Label = String()
    public var selectedStartDate: Date?
    public var selectedEndDate: Date?
    var adultCount: Int = 1
    var childrenCount: Int = 0
    var infantCount: Int = 0
    var hasPet: Bool = false
    var guest_filter = Int()
    var delegate:ContacthostVCDelegate?
    var guest_Count = Int()
    var lottieView: LottieAnimationView!
    
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        // Add additional headers as needed
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"] // Replace `<token>`
        
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.initialSetup()
        contacthostTable.rowHeight = UITableView.automaticDimension
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = Theme.ButtonBack_BG
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        self.view.backgroundColor = UIColor(named: "colorController")
        titleLabel.textColor = UIColor(named: "Title_Header")
        titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 18.0)
        titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "contacthost") ?? "Contact host")"
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        // Do any additional setup after loading the view.
    }

    func initialSetup(){
       // selectedStartDate = nil
      //  selectedEndDate = nil
        sendBtn.backgroundColor = Theme.Button_BG
        
        contacthostTable.register(UINib(nibName: "ContactheaderCell", bundle: nil), forCellReuseIdentifier: "ContactheaderCell")
        contacthostTable.register(UINib(nibName: "contactcheckCell", bundle: nil), forCellReuseIdentifier: "contactcheckCell")
        contacthostTable.register(UINib(nibName: "checkTextviewCell", bundle: nil), forCellReuseIdentifier: "checkTextviewCell")
        contacthostTable.register(UINib(nibName: "TripsLocationCell", bundle: nil), forCellReuseIdentifier: "TripsLocationCell")
        contacthostTable.rowHeight = UITableView.automaticDimension
        self.offlineView.isHidden = true
        self.sendBtn.layer.cornerRadius = sendBtn.frame.size.height/2
        self.sendBtn.layer.masksToBounds = true
        lottieView = LottieAnimationView.init(name: "animation_white")
        errorLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        sendBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"sendmessage"))!)", for:.normal)
        sendBtn.titleLabel?.font = UIFont(name: APP_FONT_SEMIBOLD, size: 16.0)
        errorLAbel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLAbel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        if(Utility.shared.isRTLLanguage()) {
            backBtn.rotateImageViewofBtn()
        }
        
    }
    func lottieanimation()
    {
        sendBtn.setTitle("", for:.normal)
        lottieView = LottieAnimationView.init(name: "animation_white")
       
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:sendBtn.frame.size.width/2-60, y:-25, width:100, height:100)
        self.sendBtn.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.play()
       
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    
func ContacthostAPICall(message:String)
{
    let contacthostMutation = ContactHostMutation(listId: viewListingArray.id!, hostId: viewListingArray.userId!, content:message, userId: "\(Utility.shared.getCurrentUserID()!)", type: "inquiry", startDate: selected_datein_Label, endDate: selected_dateout_Label, personCapacity: guest_Count)
    
    Utility.shared.personCapcityForMessagePage = guest_Count
    
    apollo_headerClient.perform(mutation: contacthostMutation){ (result,error) in
        
        if(result?.data?.createEnquiry?.status == 200)
        {
           self.lottieView.isHidden = true
            self.sendBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"sendmessage"))!)", for: .normal)
            
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"sendmessage_alert"))!)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
                self.sendBtn.isUserInteractionEnabled = true
                self.dismiss(animated: true, completion: nil)
            }
        }
        else{
            
        
            
            self.sendBtn.isUserInteractionEnabled = true;
            self.view.makeToast(result?.data?.createEnquiry?.errorMessage)
        }
    }
    
    }

    @IBAction func sendMesgBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
        let cell = view.viewWithTag((2) + 2000) as? checkTextviewCell
        let text = cell?.checkTxtview.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if(Utility.shared.checkEmptyWithString(value: text!))
        {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"messagealert"))!)")
        }
        else if(selected_datein_Label == "")
        {
        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"selectdate"))!)")
        }
        else{
            sendBtn.isUserInteractionEnabled = false
            self.lottieanimation()
            self.ContacthostAPICall(message:(cell?.checkTxtview.text!)!)
            
        }
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
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
             self.bottomView.isHidden = false
        }
            
    }
    
    @objc func listBtnTapped(_ sender: UIButton)
     {
         if Utility().isConnectedToNetwork(){
             let viewListing = UpdatedViewListing()
             viewListing.listID = viewListingArray.id ?? 0
             Utility.shared.unpublish_preview_check = false
             viewListing.modalPresentationStyle = .fullScreen
             self.present(viewListing, animated: true, completion: nil)
        }
         else
         {
            self.view.endEditing(true)
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
    @IBAction func backBtnTapped(_ sender: Any) {
        if(selectedStartDate != nil)
        {
        self.delegate?.passSelectedStartDate(selectedstartDate: selectedStartDate!)
        self.delegate?.passSelectedEndDate(selectedenddate: selectedEndDate!)
        self.delegate?.passgetBillingArray(getbillingArray: getbillingArray)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0)
        {
            return 125
        }
        else if(indexPath.row == 1)
        {
        return  167
        }
        else{
            return UITableView.automaticDimension
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0)
        {

            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripsLocationCell", for: indexPath)as! TripsLocationCell
            
            cell.selectionStyle = .none
            cell.lblRoomType.text = viewListingArray.roomType
            cell.lblDescription.text = viewListingArray.title
            

            let value1 = Float(viewListingArray.reviewsCount ?? 0)
            let value2 = Float(viewListingArray.reviewsStarRating ?? 0)
            if(value2 != 0.0){
                let reviewcount = (value2/value1)
                
                let divideValue = value2/value1
                cell.lblRating.setTitle(" \(Int(divideValue.rounded()) ) ", for: .normal)
                
               
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
        else if(indexPath.row == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactcheckCell", for: indexPath)as! contactcheckCell
            cell.selectionStyle = .none
            
            cell.checkguestLabel.isHidden = true
            cell.guestCountsLabel.isHidden = true
            cell.guestLabel.isHidden = true
            cell.guestImg.isHidden = true
            
            cell.visitorsValue.isHidden = true
            cell.editVisitorsGuests.isHidden = true
            cell.visitorsLabel.isHidden = true
            cell.visitorsView.isHidden = true
            
            cell.petValue.isHidden = true
            cell.editPetGuests.isHidden = true
            cell.petLabel.isHidden = true
            cell.petView.isHidden = true
            
            cell.infantValue.isHidden = true
            cell.editInfantGuests.isHidden = true
            cell.infantLabel.isHidden = true
            cell.infantView.isHidden = true
            
            cell.additioNalArrow.isHidden = true
            cell.additionalGuestsValue.isHidden = true
            cell.editAdditonalGuests.isHidden = true
            cell.additionalGuestsLabel.isHidden = true
            cell.additionalGuestsView.isHidden = true
            
            
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            if(getbillingArray.checkIn != nil && getbillingArray.checkOut != nil)
            {
            let showDate = inputFormatter.date(from:getbillingArray.checkIn!)
            let showDate2 = inputFormatter.date(from:getbillingArray.checkOut!)
                inputFormatter.dateFormat = "MMM dd"
                if(Utility.shared.isRTLLanguage()) {
                    inputFormatter.locale = NSLocale(localeIdentifier:"en") as Locale
                }
                else {
                    inputFormatter.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
                }
                addDateinLabel = inputFormatter.string(from: showDate!)
                addDateoutLabel = inputFormatter.string(from: showDate2!)
                cell.checkinoutLabel.text = "\(addDateinLabel) - \(addDateoutLabel)"
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd"
                let showDate3 = dateformatter.date(from:getbillingArray.checkIn!)
                let showDate4 = dateformatter.date(from:getbillingArray.checkOut!)
                dateformatter.dateFormat = "MM-dd-yyyy"
                selected_datein_Label = dateformatter.string(from: showDate3!)
                selected_dateout_Label = dateformatter.string(from: showDate4!)
                
            }
            else
            {
                cell.checkinoutLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"adddate") ?? "Add date")"
            }
            if(guestLabel_text == "")
            {
                cell.guestCountsLabel.text = "1 \(Utility.shared.getLanguage()?.value(forKey:"guest") ?? "Guest")"
                guest_Count = 1
            }
            else{
                cell.guestCountsLabel.text = guestLabel_text
            }
            cell.addOutDateLabel.addTarget(self, action: #selector(addinBtnTapped), for: .touchUpInside)
            cell.guestLabel.addTarget(self, action: #selector(guestBtnTapped), for: .touchUpInside)
            return cell
            
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "checkTextviewCell", for: indexPath)as! checkTextviewCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.tag = indexPath.row + 2000
            cell.checkTxtview.layer.cornerRadius = 6.0
            cell.checkTxtview.layer.masksToBounds = true
          
            let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissPicker))
            toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
            cell.checkTxtview.inputAccessoryView = toolBar

            
            cell.placeholderLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"writemessage") ?? "Write your message here")"
            cell.messageLabel.text =  "\(Utility.shared.getLanguage()?.value(forKey:"Your_message") ?? "Your message")"
            return cell
        }
    }
    @objc func dismissPicker()
    {
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
        Utility.shared.maximum_days_notice = Utility.shared.maximum_notice_period(maximumnoticeperiod: (viewListingArray.listingData?.maxDaysNotice!)!)!
        let datePickerViewController = AirbnbDatePickerViewController(dateFrom: selectedStartDate, dateTo: selectedEndDate)
        datePickerViewController.delegate = self
        datePickerViewController.isFromEdit = true
        datePickerViewController.isFromFilter = false
        datePickerViewController.viewListingArray = viewListingArray
        let navigationController = UINavigationController(rootViewController: datePickerViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
        
        
    }
    
    @objc func guestBtnTapped(_ sender: UIButton!) {
        Utility.shared.isfromcheckingPage = true
        Utility.shared.maximum_Count_for_booking = viewListingArray.personCapacity!
        let occupantController = AirbnbOccupantFilterController(adultCount: adultCount, childrenCount: childrenCount, infantCount: infantCount, hasPet: hasPet, additionalGuestCount: 0, infantCountt: 0, petCountt: 0, visitorCountt: 0)
        occupantController.delegate = self
        let navigationController = UINavigationController(rootViewController: occupantController)
        navigationController.modalPresentationStyle = .fullScreen
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
            billingListAPICall(startDate: fmt.string(from: startDate!), endDate: fmt.string(from: endDate!))
        }
    }
    
    func occupantFilterController(_ occupantFilterController: AirbnbOccupantFilterController, didSaveAdult adult: Int, children: Int, infant: Int, pet: Bool, guestBase: Int, infantLimit: Int, petLimit: Int, visitorLimit: Int) {
        self.adultCount = adult
        self.childrenCount = children
        self.infantCount = infant
        self.hasPet = pet
        self.guest_filter = adult
        
        let human = adult + children
        Utility.shared.guestCountToBeSend = human
        let infant = "\(infant > 0 ? (infant.description + " infant" + (infant > 1 ? "s" : "")) : "")"
        let pet = "\(pet ? "pets" : "")"
        guest_Count = human
        
        if human > 1{
            guestLabel_text = "\(human) \((Utility.shared.getLanguage()?.value(forKey:"CapGuests")) ?? "Guests")" + (infant != "" ? ", " + infant : "") + (pet != "" ? ", " + pet : "")
        }else{
            guestLabel_text = "\(human) \((Utility.shared.getLanguage()?.value(forKey:"guest"))!)" + (infant != "" ? ", " + infant : "") + (pet != "" ? ", " + pet : "")
        }
        
        contacthostTable.reloadData()
        
    }
    func billingListAPICall(startDate:String,endDate:String)
    {
        if Utility().isConnectedToNetwork(){
            var currency = String()
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
            {
                currency = Utility.shared.getPreferredCurrency()!
            }
            else
            {
                currency = Utility.shared.currencyvalue_from_API_base
            }
            if viewListingArray.id != nil {
        let billingListquery = GetBillingCalculationQueryy(listId: viewListingArray.id!, startDate: startDate, endDate: endDate, guests: Utility.shared.guestCountToBeSend, visitors: 0, pets: 0, infants: 0 , convertCurrency:currency)
        apollo_headerClient.fetch(query: billingListquery){(result,error) in
            guard (result?.data?.getBillingCalculation?.result) != nil else{
               
                self.view.makeToast(result?.data?.getBillingCalculation?.errorMessage!)
                return
            }
            self.getbillingArray = (result?.data?.getBillingCalculation?.result)!
            Utility.shared.guestCountToBeSend = self.getbillingArray.guests ?? Utility.shared.guestCountToBeSend
            self.contacthostTable.reloadData()
            
        }
            
        }
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
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
            
        }
    }
    func configureNextBtn(enable:Bool){
        
        if(enable){
            self.sendBtn.isUserInteractionEnabled = true
            self.sendBtn.alpha = 1.0
        }
        else {
            self.sendBtn.isUserInteractionEnabled = false
            self.sendBtn.alpha = 0.7
        }
        
    }
    
    func didChangeText(text: String?, cell: checkTextviewCell) {

    }

}

