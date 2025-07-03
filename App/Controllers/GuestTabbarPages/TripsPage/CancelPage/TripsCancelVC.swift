

import UIKit
import Apollo
import Lottie
import SwiftMessages
import IQKeyboardManagerSwift

class TripsCancelVC: UIViewController,UITableViewDelegate,UITableViewDataSource,CancelTextviewCellDelegate, ReservationTextviewCellDelegate{
    
   
    
    @IBOutlet var lblCancelReservation: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var offlineView: UIView!
    var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
     var cancelResrvarionArray  = CancellationDataQuery.Data.CancelReservationDatum.Result()
    var checkinDate = String()
    var checkoutDate = String()
    var textviewValue = String()
    var cancelationTitle  = String()
    var cancellationContent = String()
    var listID = Int()
    var profileId = Int()
    var profileName = String()
    var lottieView: LottieAnimationView!

    @IBOutlet weak var cancelTable: UITableView!
    @IBOutlet weak var topView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.view.backgroundColor = UIColor(named: "colorController")
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        self.lottieAnimation()
        initialsetup()
      
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        Utility.shared.isfromcancelPAge = false
        self.dismiss(animated: true, completion: nil)
    }
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:100, height:100)
        self.view.addSubview(self.lottieView)
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
    
    func initialsetup()
    {
        if IS_IPHONE_XR
        {
            self.topView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH-40, height: 80)
            cancelTable.frame = CGRect(x: 0, y: 85, width: FULLWIDTH-40, height: FULLHEIGHT-400)
            
        }
        
        lblCancelReservation.textColor = UIColor(named: "Title_Header")
        lblCancelReservation.font = UIFont(name: APP_FONT_SEMIBOLD, size: 18)
        lblCancelReservation.text = "\((Utility.shared.getLanguage()?.value(forKey:"cancelreservation"))!)"
        
        cancelTable.register(UINib(nibName: "tripscancellCell", bundle: nil), forCellReuseIdentifier: "tripscancellCell")
        cancelTable.register(UINib(nibName: "CancelTextviewCell", bundle: nil), forCellReuseIdentifier: "CancelTextviewCell")
         cancelTable.register(UINib(nibName: "ReservationCancelCell", bundle: nil), forCellReuseIdentifier: "ReservationCancelCell")
        cancelTable.register(UINib(nibName: "TripsLocationCell", bundle: nil), forCellReuseIdentifier: "TripsLocationCell")

        cancelTable.rowHeight = UITableView.automaticDimension
        self.offlineView.isHidden = true
  
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.font = UIFont(name: APP_FONT, size: 15)
              retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        if(Utility.shared.isRTLLanguage()) {
            self.backBtn.imageView?.performRTLTransform()
            lblCancelReservation.textAlignment = .right
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(cancelResrvarionArray.reservationId != nil)
        {
        return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 1)
        {
            if Utility.shared.getAppLanguageCode() == "en" || Utility.shared.getAppLanguageCode() == "En"{
                 return 245
            }else{
                return 255
            }
            
        }
        else if(indexPath.section == 2)
        {
          return UITableView.automaticDimension
        }
        else if(indexPath.section == 3)
        {
            return 300
        }
        else{
            return UITableView.automaticDimension
        }

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripsLocationCell", for: indexPath)as! TripsLocationCell
            cell.selectionStyle = .none
            
            var listTypeString = ""
            listTypeString = "\(cancelResrvarionArray.listData?.roomType ?? "")"
            if ((cancelResrvarionArray.listData?.beds ?? 0) > 1){
                listTypeString = listTypeString + " / " + "\(cancelResrvarionArray.listData?.beds ?? 0)" + " beds"
            }else if ((cancelResrvarionArray.listData?.beds ?? 0) == 1){
                listTypeString = listTypeString + " / " + "\(cancelResrvarionArray.listData?.beds ?? 0)" + " bed"
            }
           
            cell.lblRoomType.text = listTypeString
            
            
           
            cell.lblDescription.text = cancelResrvarionArray.listData?.title
            
            let reviewsCount = cancelResrvarionArray.listData?.reviewsCount ?? 0
            let ratings = cancelResrvarionArray.listData?.reviewsStarRating ?? 0
            
            let value1 = Float("\(reviewsCount)") ?? 0.0
            let value2 = Float("\(ratings)") ?? 0.0
            if(value2 != 0.0){
                let divideValue = value2/value1
          
                cell.lblRating.setTitle( "  \(Int(divideValue.rounded()))  " , for: .normal)
                cell.lblRating.isHidden = false
                cell.lblReview.isHidden = false
                cell.lblRatingTop.constant = 12
                cell.lblReviewTop.constant = 12
                cell.lblDescriptionTop.constant = 5.5
            }else{
                cell.lblRating.titleLabel?.text = " 0.0 "
                cell.lblRating.isHidden = true
                cell.lblReview.isHidden = true
                cell.lblRatingTop.constant = 0
                cell.lblReviewTop.constant = 0
                cell.lblDescriptionTop.constant = 0
            }
    
            if((cancelResrvarionArray.listData?.reviewsCount!)! > 0)
            {
                if((cancelResrvarionArray.listData?.reviewsCount!)! == 1) {
                    cell.lblReview.text = "\u{2022} \(cancelResrvarionArray.listData?.reviewsCount ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"review"))!)"
                }
                else {
                cell.lblReview.text = "\u{2022} \(cancelResrvarionArray.listData?.reviewsCount ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)"
                }
            }
            else
            {
                cell.lblReview.text = "\u{2022} \((Utility.shared.getLanguage()?.value(forKey:"delete_no"))!) \((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)"
                
            }
            if let imgURL = cancelResrvarionArray.listData?.listPhotos?[0]?.name {
            cell.imgView.sd_setImage(with: URL(string: "\(IMAGE_LISTING_MEDIUM)\(imgURL)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
                cell.imgView.halfroundedCorners(corners:[.topLeft, .bottomRight] , radius: 10)
            }
            return cell
        }
        
       else if(indexPath.section == 1)
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tripscancellCell", for: indexPath)as! tripscancellCell
            cell.selectionStyle = .none

            
            if cancelResrvarionArray.startedIn ?? 0 > 1{
                cell.startLabel.text = "\(cancelResrvarionArray.startedIn!) \((Utility.shared.getLanguage()?.value(forKey:"days")) ?? "days")"
            }else{
                cell.startLabel.text = "\(cancelResrvarionArray.startedIn!) \((Utility.shared.getLanguage()?.value(forKey:"day"))!)"
            }
            
             let night = Double(cancelResrvarionArray.stayingFor!)
            
            
            if cancelResrvarionArray.stayingFor ?? 0 > 1{
                cell.nightsLabel.text = "\(night.clean) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights") - \(checkinDate) \((Utility.shared.getLanguage()?.value(forKey:"tosmall"))!) \(checkoutDate)"
            }else{
                cell.nightsLabel.text = "\(night.clean) \((Utility.shared.getLanguage()?.value(forKey:"night"))!) - \(checkinDate) \((Utility.shared.getLanguage()?.value(forKey:"tosmall"))!) \(checkoutDate)"
            }
            
            
            if cancelResrvarionArray.guests ?? 0 > 1{
                cell.travellingLabel.text = "\(cancelResrvarionArray.guests!) \((Utility.shared.getLanguage()?.value(forKey:"CapGuests")) ?? "Guests")"
            }else{
                cell.travellingLabel.text = "\(cancelResrvarionArray.guests!) \((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
            }

            return cell
        }

        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCancelCell", for: indexPath)as! ReservationCancelCell
            cell.Listimage.layer.cornerRadius = cell.Listimage.frame.size.width/2
            cell.Listimage.layer.masksToBounds = true
            cell.selectionStyle = .none
            cell.refundContainer.halfroundedCorners(corners:[.topLeft, .bottomRight] , radius: 15)
            cell.viewMissedEarnings.halfroundedCorners(corners:[.topLeft, .bottomRight], radius: 15)
            cell.descriptionCancellationPolicy.text =  "Cancellation Policy is '\(self.cancelationTitle)' and you can \(cancellationContent)"
            cell.descriptionCancellationPolicy.textColor =  UIColor(named: "searchPlaces_TextColor")
            if( Utility.shared.host_message_isfromHost)
            {
                cell.keepReservationBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"keepreservation"))!)", for: .normal)
            }
            else {
                cell.keepReservationBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"keeptrip")) ?? "Keep your trip")", for: .normal)
               
               
            }
           
            let fullString =  "Cancellation Policy is '\(self.cancelationTitle)' and you can \(cancellationContent)"

            let coloredString = "'\(self.cancelationTitle)'"

       let rangeOfColoredString = (fullString as! NSString).range(of: coloredString)

            let attributedString = NSMutableAttributedString(string:fullString)
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR],
                                    range: rangeOfColoredString)
       cell.descriptionCancellationPolicy.attributedText = attributedString
            
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            cell.descriptionCancellationPolicy.addGestureRecognizer(tapGesture)
            cell.descriptionCancellationPolicy.isUserInteractionEnabled = true

            
            if(!Utility.shared.host_cancel_isfromCancel)
            {
           cell.placeholderLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"hostnote"))!)"
                
            }
            else
            {
              cell.placeholderLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"hostnote"))!)"
            }
            cell.borderView.layer.cornerRadius = 6.0
            cell.borderView.layer.masksToBounds = true
            cell.borderView.layer.borderWidth = 1.0
            cell.borderView.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
            cell.checkTxtView.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            cell.delegate = self
            
            
            
            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: cancelResrvarionArray.currency!)
            let restricted_price = Double(String(format: "%.2f",cancelResrvarionArray.nonRefundableNightPrice!))
            if(restricted_price! < 0) {
                cell.priceLAbel.attributedText = "\(currencysymbol!) 0.0".strikingThrough()
            }
            else {
            cell.priceLAbel.attributedText = "\(currencysymbol!)\(restricted_price!.clean)".strikingThrough()
            }
            let total_price = Double(String(format: "%.2f",cancelResrvarionArray.refundToGuest!)) ?? 0.0
            if(total_price > 0.0)
            
            {
                cell.totalLabel.text = "\(currencysymbol!)\(total_price.clean)"
                 cell.inLabel.isHidden = false
                cell.refundContainer.isHidden = false
                cell.refundHeightConstant.constant = 60
                cell.refundableheightConstant.constant = 20
                
            }else{
                cell.totalLabel.text  = ""
                cell.refundContainer.isHidden = true
                 cell.inLabel.isHidden = true
                cell.refundContainer.isHidden = true
                cell.refundContainer.isHidden = true
                cell.refundHeightConstant.constant = 0
                cell.refundableheightConstant.constant = 0
            }
            if(!Utility.shared.host_cancel_isfromCancel)
            {
            cell.nameLabel.text = cancelResrvarionArray.hostName!
               
            }
            else
            {
             cell.nameLabel.text = cancelResrvarionArray.guestName!
            }

            let tap = UITapGestureRecognizer(target: self, action: #selector(TripsCancelVC.titleClicked))
         

            tap.numberOfTapsRequired = 1
            tap.view?.tag = indexPath.row
          
            if(!Utility.shared.host_cancel_isfromCancel)
            {
            cell.hostnightLabel.isHidden = true
            cell.missedearningsLabel.isHidden = true
                
                cell.refundContainer.isHidden = false
                cell.refundHeightConstant.constant = 60
                cell.refundableheightConstant.constant = 20
                if(Utility.shared.host_message_isfromHost)
                {
                    cell.lblGuest.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                }
                else {
                    cell.lblGuest.text = "\((Utility.shared.getLanguage()?.value(forKey:"host"))!)"
                   
                }
               
                cell.refundContainer.backgroundColor = UIColor(named: "Refund_Container_Color")
                
                if( Utility.shared.host_message_isfromHost)
                {
                    cell.cancelReservationBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"cancelreservation"))!)", for: .normal)
                }
                else {
                    cell.cancelReservationBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"canceltrip")) ?? "Cancel your trip")", for: .normal)
                   
                   
                }
               
                cell.imgView.image = UIImage(#imageLiteral(resourceName: "succcessRefund"))
                
                cell.viewMissedEarnings.backgroundColor = UIColor().hexValue(hex: "FFF3F5")
                cell.nonRefundableImage.image = UIImage(#imageLiteral(resourceName: "missedearn"))
            }
            else
            {
                cell.hostnightLabel.isHidden = false
                cell.missedearningsLabel.isHidden = false
                cell.nonrefundableLabel.isHidden = true
                cell.inLabel.isHidden = true
                cell.refundContainer.isHidden = true
                cell.refundHeightConstant.constant = 0
                cell.refundableheightConstant.constant = 0
                
                
                
                if(Utility.shared.host_message_isfromHost)
                {
                    cell.lblGuest.text = "\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
                }
                else {
                    cell.lblGuest.text = "\((Utility.shared.getLanguage()?.value(forKey:"host"))!)"
                   
                }
                
                cell.viewMissedEarnings.backgroundColor = UIColor().hexValue(hex: "FFF3F5")

                cell.cancelReservationBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"cancelreservation"))!)", for: .normal)
                cell.nonRefundableImage.image = UIImage(#imageLiteral(resourceName: "missedearn"))
            
                
                if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                    let from_currency = cancelResrvarionArray.listData?.listingData?.currency!
                  
                    let currency_amount = (cancelResrvarionArray.isSpecialPriceAverage ?? 0.0)
                    let restricted_price =  Double(String(format: "%.2f",currency_amount))
                    
                    
                    if cancelResrvarionArray.stayingFor ?? 0.0 > 1.0{
                        cell.hostnightLabel.text = "\(currencysymbol!)\(restricted_price!.clean)  x \(cancelResrvarionArray.stayingFor!.clean) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                    }else{
                        cell.hostnightLabel.text = "\(currencysymbol!)\(restricted_price!.clean)  x \(cancelResrvarionArray.stayingFor!.clean) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                    }
                }
                else
                {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                    let from_currency = cancelResrvarionArray.listData?.listingData?.currency!
                    let currency_amount = cancelResrvarionArray.isSpecialPriceAverage ?? 0.0
                    let restricted_price =  Double(String(format: "%.2f",currency_amount))
                    

                    if cancelResrvarionArray.stayingFor ?? 0.0 > 1.0{
                        cell.hostnightLabel.text = "\(currencysymbol!)\(restricted_price!.clean) x \(cancelResrvarionArray.stayingFor!.clean) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                    }else{
                        cell.hostnightLabel.text = "\(currencysymbol!)\(restricted_price!.clean) x \(cancelResrvarionArray.stayingFor!.clean) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                    }
                }
                cell.totalLabel.isHidden = true
            }
            
            if(!Utility.shared.host_cancel_isfromCancel){
                
                self.profileName = cancelResrvarionArray.hostName ?? ""
            }
            else {
                
                self.profileName = cancelResrvarionArray.guestName ?? ""
            }
            
            
            if(cancelResrvarionArray.hostProfilePicture != nil)
            {
                if(!Utility.shared.host_cancel_isfromCancel)
                {
            let listimage = cancelResrvarionArray.hostProfilePicture!
                   
                
            cell.Listimage.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_MEDIUM)\(listimage)"), placeholderImage: #imageLiteral(resourceName: "unknown"))
                }
                else if(cancelResrvarionArray.guestProfilePicture != nil)
                {
                    let listimage = cancelResrvarionArray.guestProfilePicture!
                    
                    cell.Listimage.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_MEDIUM)\(listimage)"), placeholderImage: #imageLiteral(resourceName: "unknown"))
                }
                else
                {
                   cell.Listimage.image = #imageLiteral(resourceName: "unknown")
                }
            }
            else{
                cell.Listimage.image = #imageLiteral(resourceName: "unknown")
            }
            
            if(cancelResrvarionArray.nonRefundableNightPrice! <= 0 && !Utility.shared.host_cancel_isfromCancel)
            {
                cell.nonrefundableLabel.isHidden = true
                cell.missedEarningsTop.constant = 0
                cell.missedEarningsHeight.constant = 0
                cell.priceLAbel.isHidden = true
                cell.viewMissedEarnings.isHidden = true

            }
            
            
            if(cancelResrvarionArray.refundToGuest! == 0 )
            
            {
                cell.totalLabel.isHidden = true
                 cell.inLabel.isHidden = true
                cell.refundContainer.isHidden = true
                cell.refundContainer.isHidden = true
                cell.refundHeightConstant.constant = 0
                cell.refundableheightConstant.constant = 0
                cell.aboveCostLAbel.isHidden = true

            }
            if(Utility.shared.host_cancel_isfromCancel){
                cell.aboveCostLAbel.isHidden = true

            }
            
            cell.keepReservationBtn.addTarget(self, action: #selector(keepBtnTapped), for: .touchUpInside)
            cell.cancelReservationBtn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
            
            cell.userImgButton.addTarget(self, action: #selector(userBtnTapped), for: .touchUpInside)
            
            
            
            if (cell.nonrefundableLabel.isHidden && cell.missedearningsLabel.isHidden){
                
            }else{
            }
            
            
            return cell
        }
    }
    @objc func titleClicked(_ sender: UITapGestureRecognizer) {
        let viewListing = UpdatedViewListing()
        viewListing.listID = listID
        Utility.shared.unpublish_preview_check = false
        viewListing.modalPresentationStyle = .fullScreen
        self.present(viewListing, animated: true, completion: nil)
    }
    @objc func keepBtnTapped(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func userBtnTapped(_ sender: UIButton)
    {
        let editprofileobj = HostProfileViewPage()
        editprofileobj.isfromreview = true;
        editprofileobj.profileid = self.profileId
        editprofileobj.profilename = self.profileName
        editprofileobj.showprofileAPICall(profileid:self.profileId)
        if !Utility.shared.isFromMessageListingPage_host{
            editprofileobj.isfromreview = false
        }
        else {
            editprofileobj.isfromreview = true
        }
        editprofileobj.modalPresentationStyle = .fullScreen
        self.present(editprofileobj, animated: true, completion: nil)
    }
    @objc func cancelBtnTapped(_ sender: UIButton)
    {
         if Utility().isConnectedToNetwork(){
        if(textviewValue.containsNothing)
        {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"messagealert"))!)")
        }
        else
        {
            self.lottieAnimation()
     cancellationBookingAPICall()
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
            if IS_IPHONE_X || IS_IPHONE_XR {
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-95, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
        }
    }
    
    func getdateValue(timestamp:String) -> String
    {
         if(Int(timestamp) != nil ) {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
             if(Utility.shared.isRTLLanguage()) {
        dateFormatter.locale = NSLocale(localeIdentifier:"en") as Locale
             }
             else {
                 dateFormatter.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
             }
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
        dateFormatter1.dateFormat = "EEE"
              if(Utility.shared.isRTLLanguage()) {
         dateFormatter1.locale = NSLocale(localeIdentifier:"en") as Locale
              }
              else {
                  dateFormatter1.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
              }
        let day = dateFormatter1.string(from: showDate)
            return day } else  {
            return Utility.shared.getdateformatter1(date: timestamp)
        }
    }
    func didChangeText(text: String?, cell: CancelTextviewCell) {
    }
    func textendEditing(text: String?, cell: CancelTextviewCell) {

    }
    func didChangeText(text: String?, cell: ReservationCancelCell) {
    
    }
    
    func textendEditing(text: String?, cell: ReservationCancelCell) {
        textviewValue = text!
    }
    
   
    
    
    
func getcancellationAPICall(reservationId:Int,userType:String,currency:String)
{
    let getcancellationquery = CancellationDataQuery(reservationId: reservationId, userType: userType, currency: currency)
    apollo_headerClient.fetch(query: getcancellationquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
        guard (result?.data?.cancelReservationData?.results) != nil else{
            self.view.makeToast(result?.data?.cancelReservationData?.errorMessage!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: false, completion: nil)
            }
            return
            
        }
        
        self.cancelResrvarionArray = (result?.data?.cancelReservationData?.results)!
        self.viewDetailAPICall(listid: self.listID)
       
    }
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
   
    
    func cancellationBookingAPICall()
    {
        if(cancelResrvarionArray.payoutToHost == nil)
        {
           cancelResrvarionArray.payoutToHost = 0
        }
        let cancelBookingMutation = CancelReservationMutation(reservationId: cancelResrvarionArray.reservationId!, cancellationPolicy: cancelResrvarionArray.cancellationPolicy!, refundToGuest: cancelResrvarionArray.refundToGuest!, payoutToHost: cancelResrvarionArray.payoutToHost!, guestServiceFee: cancelResrvarionArray.guestServiceFee!, hostServiceFee: cancelResrvarionArray.hostServiceFee!, total: cancelResrvarionArray.total!, currency: cancelResrvarionArray.currency!, threadId: cancelResrvarionArray.threadId!, cancelledBy: cancelResrvarionArray.cancelledBy!, message: textviewValue, checkIn: cancelResrvarionArray.checkIn!, checkOut: cancelResrvarionArray.checkOut!, guests: cancelResrvarionArray.guests!,isTaxRefunded: cancelResrvarionArray.isTaxRefunded ?? false)
        apollo_headerClient.perform(mutation: cancelBookingMutation){(result,error)in
            self.lottieView.isHidden  = true
            if(result?.data?.cancelReservation?.status) != 200 {
                self.view.makeToast(result?.data?.cancelReservation?.errorMessage)
                return
            }
            Utility.shared.isfromcancelPAge = true
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"reservationcancel"))!)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if Utility.shared.isFromMessageListingPage_host{
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    Utility.shared.setHostTab(index: 3)
                    appDelegate.HostTabbarInitialize(initialView: CustomHostTabbar())
                    
                }else if Utility.shared.isFromMessageListingPage_guest {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    Utility.shared.setTab(index: 3)
                    appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
                    
                }else{
                       self.dismiss(animated: true, completion: nil)
                }
             
            }
        }
    }

    func viewDetailAPICall(listid:Int)
    {
       if Utility().isConnectedToNetwork(){
           var viewListQuery = ViewListingDetailsQueryy(listId:self.listID)
        
     
         apollo_headerClient.fetch(query: viewListQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            
        
            if result?.data?.viewListing?.status == 200 {
                    self.viewListingArray = (result?.data?.viewListing?.results)!
                    if(self.viewListingArray.listingData != nil)
                    {
                        self.cancelationTitle = self.viewListingArray.listingData?.cancellation?.policyName ?? ""
                        self.cancellationContent  = self.viewListingArray.listingData?.cancellation?.policyContent ?? ""
                        self.cancelTable.reloadData()
                        self.lottieView.isHidden = true
                    }
            }
             else {
                 self.cancelTable.reloadData()
                 self.lottieView.isHidden = true
             }
         }
        }
    }
    
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
   
        let cancellationObj = CancellationVC()
       
      
            cancellationObj.cancelpolicy = cancelationTitle
      
       
            cancellationObj.cancelpolicy_content = cancellationContent
     

        cancellationObj.modalPresentationStyle = .fullScreen
        self.present(cancellationObj, animated: true, completion: nil)
    }

}
extension String {
    
    var containsNothing: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
}
