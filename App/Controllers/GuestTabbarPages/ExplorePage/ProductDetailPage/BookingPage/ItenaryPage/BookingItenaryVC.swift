

import UIKit
import Apollo
import Lottie
import CoreLocation
import MapKit

@available(iOS 11.0, *)
@available(iOS 11.0, *)
class BookingItenaryVC: UIViewController,UITableViewDelegate,UITableViewDataSource, WhishlistPageVCProtocol {
    func APIMethodCall(listId:Int, status:Bool) {
        
    }
    
    func didupdateWhishlistStatus(status: Bool) {
       
            getReservationArray.listData?.wishListStatus = status
       
        iterationTable.reloadSections([1], with:.none)
    }
    
    
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iterationTable: UITableView!
    var wishlistIndex:Int = -1
    var lottieView: LottieAnimationView!
    let apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
       
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    var getReservationArrayyy = GetReservationQueryy.Data.GetReservation()
    var getReservationArray = GetReservationQueryy.Data.GetReservation.Result()
//    var getReservationArrayy = GetReservationQueryy.Data.GetReservation.Result()
    var getReservation_currencyArray = GetReservationQueryy.Data.GetReservation()
    var getbillingArray = GetBillingCalculationQueryy.Data.GetBillingCalculation.Result()
    var currencyvalue_from_API_base = String()
    var isFromReviewPage = false
    var reservID = 0
    @IBOutlet weak var ErrorView: UIView!
    @IBOutlet weak var uhohLabel: UILabel!
    @IBOutlet weak var ErrorDescLabel: UILabel!
    @IBOutlet weak var ErrorCodeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialsetup()

        self.view.backgroundColor = UIColor(named: "colorController")
        if isFromReviewPage{
            self.getReservationAPICall(reservationid: reservID)
        }
        
        self.ErrorView.isHidden = true
        self.uhohLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "uhoh") ?? "Uh-Oh!")"
        self.ErrorDescLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "404alert") ?? "We can't seem to find anything that you're looking for!")"
        self.ErrorCodeLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "errorCode") ?? "Error Code : 404")"
       
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
    }
    
    func getReservationAPICall(reservationid:Int)
    {
         if Utility().isConnectedToNetwork(){
            self.lottieAnimation()
        let createReservationquery = GetReservationQueryy(reservationId: reservationid)
        apollo_headerClient.fetch(query: createReservationquery){(result,error) in
            self.lottieView.isHidden = true
            self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:0, height:0)
            guard (result?.data?.getReservation?.results) != nil else{
               
                self.view.makeToast(result?.data?.getReservation?.errorMessage)
                return
            }
            self.getReservationArrayyy = (result?.data?.getReservation)!
            self.getReservationArray = (result?.data?.getReservation?.results)!
            self.getReservation_currencyArray = (result?.data?.getReservation!)!
            
            if self.getReservationArray.listData != nil{
                self.iterationTable.isHidden = false
                self.ErrorView.isHidden = true
                
                self.iterationTable.reloadData()
            }else{
                self.iterationTable.isHidden = true
                self.ErrorView.isHidden = false
            }

        }
        }
         else{
            
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if(Utility.shared.isfromTripsPage || self.isFromReviewPage)
        {
          self.dismiss(animated: true, completion: nil)
        }
        else{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        Utility.shared.setTab(index: 0)
            Utility.shared.host_message_isfromHost = false
            Utility.shared.host_message_isfrommessage = false
            Utility.shared.isfromfloatmap_Page = false
            Utility.shared.locationfromSearch  = ""
            Utility.shared.TotalFilterCount = 0
            if(Utility.shared.searchLocationDict.count > 0)
            {
                Utility.shared.searchLocationDict.setValue(nil, forKey: "lat")
                Utility.shared.searchLocationDict.setValue(nil, forKey: "lon")
            }
            Utility.shared.instantBook = ""
            Utility.shared.roomtypeArray.removeAllObjects()
            Utility.shared.amenitiesArray.removeAllObjects()
            Utility.shared.priceRangeArray.removeAllObjects()
            Utility.shared.facilitiesArray.removeAllObjects()
            Utility.shared.houseRulesArray.removeAllObjects()
            Utility.shared.beds_count = 0
            Utility.shared.bedrooms_count = 0
            Utility.shared.bathroom_count = 0
            if(Utility.shared.isSwitchEnable)
            {
                Utility.shared.isSwitchEnable = false
            }
            Utility.shared.isfromGuestProfile = false
            Utility.shared.setopenTabbar(iswhichtabbar: false)

            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
            appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
            
        }
    }
    func initialsetup()
    {
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = Theme.ButtonBack_BG
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "itinerary") ?? "Itinerary")"
        titleLabel.textColor = UIColor(named: "Title_Header")
        titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 18.0)
        
        
        iterationTable.register(UINib(nibName: "ItenaryListCell", bundle: nil), forCellReuseIdentifier: "ItenaryListCell")
         iterationTable.register(UINib(nibName: "ItenaryImageCell", bundle: nil), forCellReuseIdentifier: "ItenaryImageCell")
         iterationTable.register(UINib(nibName: "ItenarycheckCell", bundle: nil), forCellReuseIdentifier: "ItenarycheckCell")
         iterationTable.register(UINib(nibName: "ItenaryaddressCell", bundle: nil), forCellReuseIdentifier: "ItenaryaddressCell")
         iterationTable.register(UINib(nibName: "ItenaryHostCell", bundle: nil), forCellReuseIdentifier: "ItenaryHostCell")
         iterationTable.register(UINib(nibName: "ItenaryBillingCell", bundle: nil), forCellReuseIdentifier: "ItenaryBillingCell")
        
    }
    
    
    func createReservationAPICall(reservationid:Int)
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
        self.lottieAnimation()
     let createReservationquery = GetReservationQueryy(reservationId: reservationid,convertCurrency:currency)
        
        apollo_headerClient.fetch(query: createReservationquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            self.lottieView.isHidden = true
            self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:0, height:0)
            guard (result?.data?.getReservation?.results) != nil else{
                self.view.makeToast(result?.data?.getReservation?.errorMessage)
                return
            }
            self.getReservationArrayyy = (result?.data?.getReservation)!
            self.getReservationArray = (result?.data?.getReservation?.results)!
            self.getReservation_currencyArray = (result?.data?.getReservation!)!
            
            self.iterationTable.reloadData()
        
    }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if(getReservationArray.listData?.city != nil)
        {
        return 6
        }
        return 0
    }
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0)
        {
            return UITableView.automaticDimension
        }
        else if(indexPath.section == 1)
        {
            return 320
        }
        else if(indexPath.section == 2)
        {
            return UITableView.automaticDimension
        }
        else if(indexPath.section == 3)
        {
            return UITableView.automaticDimension
        }
        else if(indexPath.section == 4)
        {
            return UITableView.automaticDimension
        }
        else
        {
           return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(getReservationArray.listData?.city != nil)
        {
        return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItenaryListCell", for: indexPath)as! ItenaryListCell
            cell.locationLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"yougoing"))!) \(getReservationArray.listData?.city != nil ? ((getReservationArray.listData?.city!)!) : "")!"
            cell.reservationCodeLAbel.text = " \((Utility.shared.getLanguage()?.value(forKey:"reservationcode"))!)  #\(getReservationArray.confirmationCode != nil ? getReservationArray.confirmationCode! : 0 )"
            cell.selectionStyle = .none
            return cell
        }
        if(indexPath.section == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItenaryImageCell", for: indexPath)as! ItenaryImageCell
            cell.selectionStyle = .none
            
            if let listimage = (getReservationArray.listData?.listPhotoName) {
            cell.listImage.sd_setImage(with: URL(string: "\(IMAGE_LISTING_MEDIUM)\(String(describing: listimage))"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
            } else {
                cell.listImage.image = #imageLiteral(resourceName: "placeholderimg")
            }
            cell.heightConstant.constant = 22
            cell.topConstant.constant = 18
            cell.listTitleLabel.text = getReservationArray.listData?.title ?? ""
            
            cell.listLocationLabel.text = "\(getReservationArray.listData?.city ?? ""), \(getReservationArray.listData?.state ?? ""), \(getReservationArray.listData?.country ?? "")"
            
            if(((getReservationArray.listData?.reviewsCount!)! > 0) && ((getReservationArray.listData?.reviewsStarRating!)! > 0) ) {
            
            if((getReservationArray.listData?.reviewsCount!)! > 0)
            {
                if((getReservationArray.listData?.reviewsCount!)! == 1) {
                    cell.ratingLabel.text = " \(getReservationArray.listData?.reviewsCount ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"review"))!)"
                }
                else {
                cell.ratingLabel.text = "\(getReservationArray.listData?.reviewsCount ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)"
                }
            }
            else
            {
                cell.ratingLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"delete_no"))!) \((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)"
                
            }

                let reviewsCount = getReservationArray.listData?.reviewsCount ?? 0
                let ratings = getReservationArray.listData?.reviewsStarRating ?? 0
                
                let value1 = Float("\(reviewsCount)") ?? 0.0
                let value2 = Float("\(ratings)") ?? 0.0
                if(value2 != 0.0){
                    let divideValue = value2/value1
                
                    cell.ratingCountLabel.text = "\(Int(divideValue.rounded())) \u{2022} "
                    cell.ratingLabel.isHidden = false
                    cell.ratingCountLabel.isHidden = false
                    
                }else{
                    cell.ratingCountLabel.text = " 0.0 "
                    cell.ratingLabel.isHidden = true
                    cell.ratingCountLabel.isHidden = true
                   
                    
                }
            }
            else {
                cell.heightConstant.constant = 0
                cell.topConstant.constant = 0
                cell.ratingView.isHidden = true
            }
            
           
            if let listowner = getReservationArray.listData?.isListOwner {

                    if(getReservationArray.listData?.wishListStatus == false){
                        cell.likeBtn.setImage(#imageLiteral(resourceName: "Heart"), for: .normal)
                    }else{
                        cell.likeBtn.setImage(#imageLiteral(resourceName: "like"), for: .normal)
                    }
                    cell.likeBtn.isHidden = true

                    cell.likeBtn.addTarget(self, action: #selector(likeBtnTapped), for: .touchUpInside)

           }
           
            let attributes = [
                NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 12),
                NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
            ]
                
            var listTypeString = ""
            listTypeString = "\(getReservationArray.listData?.roomType ?? "")"
            if ((getReservationArray.listData?.beds ?? 0) > 1){
                listTypeString = listTypeString + " / " + "\(getReservationArray.listData?.beds ?? 0)" + " Beds"
            }else if ((getReservationArray.listData?.beds ?? 0) == 1){
                listTypeString = listTypeString + " / " + "\(getReservationArray.listData?.beds ?? 0)" + " Bed"
            }
            cell.listLocationLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            
            cell.listLocationLabel.text = listTypeString
            return cell
        }
        if(indexPath.section == 2)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItenarycheckCell", for: indexPath)as! ItenarycheckCell
            cell.selectionStyle = .none
            if(getReservationArray.checkIn != nil)
            {
                let day = getdayValue(timestamp:(getReservationArray.checkIn!))
                let date = getdateValue(timestamp:(getReservationArray.checkIn!))
                let endDay = getdayValue(timestamp:(getReservationArray.checkOut!))
                let endDate = getdateValue(timestamp:(getReservationArray.checkOut!))
               
            cell.checkinLabel.text = "\(day), \(date) "
            cell.checkoutLabel.text = "\(endDay), \(endDate)"
            }
            else
            {
                cell.checkinLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"flexible"))!)"
                cell.checkoutLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"flexible"))!)"
            }

            if(getReservationArray.checkInStart != "" && getReservationArray.checkInStart != ""){
            if (getReservationArray.checkInStart == "Flexible" && getReservationArray.checkInEnd == "Flexible") {
                       
                                          cell.checkinTimeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "checkintimesmal"))!)"
                           
                       } else if (getReservationArray.checkInStart != "Flexible" && getReservationArray.checkInEnd == "Flexible") {
                           let date = conversionRailwaytime(time:(getReservationArray.checkInStart!))
                
                           cell.checkinTimeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "from"))!) \(date)"
                           
                       } else if (getReservationArray.checkInStart == "Flexible" && getReservationArray.checkInEnd != "Flexible") {
                           let date = conversionRailwaytime(time:(getReservationArray.checkInEnd!))
                                          cell.checkinTimeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "upto"))!) \(date)"
                           
                       } else if (getReservationArray.checkInStart != "Flexible" && getReservationArray.checkInEnd != "Flexible") {
                           let date = conversionRailwaytime(time:(getReservationArray.checkInStart!))
                           let date1 = conversionRailwaytime(time:(getReservationArray.checkInEnd!))
                           cell.checkinTimeLabel.text = "\(date) - \(date1)"
                }}else{
                cell.checkinTimeLabel.text = ""
            }

            cell.checkouttimeLabel.text = ""
            return cell
        }
        if indexPath.section == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItenaryBillingCell", for: indexPath)as! ItenaryBillingCell
            cell.selectionStyle = .none
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
            {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                
                let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:getReservationArray.currency!, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:getReservationArray.totalWithGuestServiceFee != nil ? getReservationArray.totalWithGuestServiceFee! : 0)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                
                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                
                
                
            }
            else
            {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                
                let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:getReservationArray.currency!, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate: Utility.shared.currency_Dict, amount:getReservationArray.totalWithGuestServiceFee != nil ? getReservationArray.totalWithGuestServiceFee! : 0)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
            }
            
            
            if getReservationArray.nights ?? 0 > 1{
                cell.stayLabel.text = "\(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
            }else{
                cell.stayLabel.text = "\(getReservationArray.nights!) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
            }
        
            
            
            cell.viewReceiptBtn.addTarget(self, action: #selector(ReceiptBtnTapped), for: .touchUpInside)
            
            cell.viewReceiptBtn.backgroundColor = .clear
            
           
            cell.viewReceiptBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "viewreceipt")) ?? "View Receipt")", for: .normal)
            cell.viewReceiptBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
            cell.viewReceiptBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 13)
            if #available(iOS 15.0, *) {
                cell.viewReceiptBtn.configuration?.titleAlignment = Utility.shared.isRTLLanguage() ? .trailing : .leading
            } else {
                cell.viewReceiptBtn.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            }
            
            return cell
        }
        if(indexPath.section == 4)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItenaryaddressCell", for: indexPath)as! ItenaryaddressCell
            cell.selectionStyle = .none
            cell.addressLabel.text = "\(getReservationArray.listData?.street != nil ? ((getReservationArray.listData?.street!)!) : ""), \(getReservationArray.listData?.city != nil ? ((getReservationArray.listData?.city!)!) : ""), \(getReservationArray.listData?.state != nil ? ((getReservationArray.listData?.state!)!) : "")-\(getReservationArray.listData?.zipcode != nil ? ((getReservationArray.listData?.zipcode!)!) : ""), \(getReservationArray.listData?.country != nil ? ((getReservationArray.listData?.country!)!) : "")"
            cell.viewListingBtn.tag = indexPath.row
            cell.viewListingBtn.addTarget(self, action: #selector(viewListingBtnTapped), for: .touchUpInside)
            
            cell.btnGetDirection.tag = indexPath.row
            cell.btnGetDirection.addTarget(self, action: #selector(getDirectionBtnTapped), for: .touchUpInside)
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItenaryHostCell", for: indexPath)as! ItenaryHostCell
            if(getReservationArray.hostData?.picture != nil)
            {
            let listimage = (getReservationArray.hostData?.picture!)!
            cell.hostImage.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_MEDIUM)\(String(describing: listimage))"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
            }
            cell.hostNameLabel.text = (getReservationArray.hostData?.firstName != nil ? getReservationArray.hostData?.firstName! : "")
            cell.selectionStyle = .none
            cell.btnPhone.tag = indexPath.row
            cell.btnPhone.addTarget(self, action: #selector(phoneBtnTapped), for: .touchUpInside)
            if getReservationArray.hostData?.phoneNumber != nil && getReservationArray.hostData?.phoneNumber != "" {
                cell.btnPhone.isHidden = false
                cell.btnPhone.setTitle("\(getReservationArray.hostData?.phoneNumber ?? "XXX")", for: .normal)
            } else {
                cell.btnPhone.isHidden = true
                cell.btnPhone.setTitle("XXX", for: .normal)
            }
            
            cell.messageHostBtn.tag = indexPath.row
           
                if Utility.shared.getCurrentUserID()! as String == getReservationArray.hostData?.userId {
                cell.messageHostBtn.isHidden = true
            }
            else {
                cell.messageHostBtn.isHidden = false
            }
            
            cell.messageHostBtn.addTarget(self, action: #selector(hostBtnTapped), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1)
        {
            let viewListing = UpdatedViewListing()
            if(Utility.shared.isfromTripsPage || self.isFromReviewPage)
            {
             
            }
            else{
           
                Utility.shared.host_message_isfromHost = false
                Utility.shared.host_message_isfrommessage = false
                Utility.shared.isfromfloatmap_Page = false
                Utility.shared.locationfromSearch  = ""
                Utility.shared.TotalFilterCount = 0
                if(Utility.shared.searchLocationDict.count > 0)
                {
                    Utility.shared.searchLocationDict.setValue(nil, forKey: "lat")
                    Utility.shared.searchLocationDict.setValue(nil, forKey: "lon")
                }
                Utility.shared.instantBook = ""
                Utility.shared.roomtypeArray.removeAllObjects()
                Utility.shared.amenitiesArray.removeAllObjects()
                Utility.shared.priceRangeArray.removeAllObjects()
                Utility.shared.facilitiesArray.removeAllObjects()
                Utility.shared.houseRulesArray.removeAllObjects()
                Utility.shared.beds_count = 0
                Utility.shared.bedrooms_count = 0
                Utility.shared.bathroom_count = 0
                if(Utility.shared.isSwitchEnable)
                {
                    Utility.shared.isSwitchEnable = false
                }
                Utility.shared.isfromGuestProfile = false
                Utility.shared.setopenTabbar(iswhichtabbar: false)

               
            Utility.shared.selectedstartDate = ""
            Utility.shared.selectedEndDate = ""
         
            Utility.shared.selectedstartDate_filter = ""
            Utility.shared.selectedEndDate_filter = ""
            
            Utility.shared.unpublish_preview_check = false
            }
            viewListing.listID = getReservationArray.listId ?? 0
            viewListing.modalPresentationStyle = .fullScreen
            self.present(viewListing, animated: true, completion: nil)
        }
    }
    @objc func getDirectionBtnTapped(_ sender: UIButton) {
        print("\(getReservationArray.listData?.lat ?? 0.0), \(getReservationArray.listData?.lng ?? 0.0)")
        
        guard let latitude = getReservationArray.listData?.lat,
              let longitude = getReservationArray.listData?.lng else {
            print("Invalid coordinates")
            return
        }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Destination"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    @objc func viewListingBtnTapped(_ sender: UIButton)
    {
        let viewListing = UpdatedViewListing()
        
        if(Utility.shared.isfromTripsPage || self.isFromReviewPage)
        {
         
        }
        else{
      
            Utility.shared.host_message_isfromHost = false
            Utility.shared.host_message_isfrommessage = false
            Utility.shared.isfromfloatmap_Page = false
            Utility.shared.locationfromSearch  = ""
            Utility.shared.TotalFilterCount = 0
            if(Utility.shared.searchLocationDict.count > 0)
            {
                Utility.shared.searchLocationDict.setValue(nil, forKey: "lat")
                Utility.shared.searchLocationDict.setValue(nil, forKey: "lon")
            }
            Utility.shared.instantBook = ""
            Utility.shared.roomtypeArray.removeAllObjects()
            Utility.shared.amenitiesArray.removeAllObjects()
            Utility.shared.priceRangeArray.removeAllObjects()
            Utility.shared.facilitiesArray.removeAllObjects()
            Utility.shared.houseRulesArray.removeAllObjects()
            Utility.shared.beds_count = 0
            Utility.shared.bedrooms_count = 0
            Utility.shared.bathroom_count = 0
            if(Utility.shared.isSwitchEnable)
            {
                Utility.shared.isSwitchEnable = false
            }
            Utility.shared.isfromGuestProfile = false
            Utility.shared.setopenTabbar(iswhichtabbar: false)

            
        Utility.shared.selectedstartDate = ""
        Utility.shared.selectedEndDate = ""
      
        Utility.shared.selectedstartDate_filter = ""
        Utility.shared.selectedEndDate_filter = ""
       
        Utility.shared.unpublish_preview_check = false
        }
        viewListing.listID = getReservationArray.listId ?? 0
        viewListing.modalPresentationStyle = .fullScreen
        self.present(viewListing, animated: true, completion: nil)
    }
    @objc func ReceiptBtnTapped()
    {
        if #available(iOS 11.0, *) {
            
            let receiptPageObj = ReceiptVC()
             Utility.shared.host_isfrom_hostRecipt = false
            receiptPageObj.viewListingArray = self.viewListingArray
            receiptPageObj.getReservationArrayyy = self.getReservationArrayyy
            receiptPageObj.getReservationArray = getReservationArray
            receiptPageObj.getReservation_currencyArray = getReservation_currencyArray
            receiptPageObj.getbillingArray = getbillingArray
            receiptPageObj.currencyvalue_from_API_base = currencyvalue_from_API_base
            receiptPageObj.modalPresentationStyle = .overFullScreen
            self.view.window?.rootViewController?.present(receiptPageObj, animated:false, completion: nil)

        } else {

        }
        
        
    }
    
    @objc func likeBtnTapped(_ sender: UIButton!)
    {
        if Utility().isConnectedToNetwork(){
            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
            {
                let welcomeObj = WelcomePageVC()
                welcomeObj.modalPresentationStyle = .fullScreen
                self.present(welcomeObj, animated:false, completion: nil)
            }
            else
            {
               
                    wishlistIndex = sender.tag
                    let headerView = WhishlistPageVC()
                    headerView.listID = getReservationArray.id ?? 0
                headerView.listimage = getReservationArray.listData?.listPhotoName ?? "-"
                    headerView.senderID = sender.tag
                    headerView.delegate = self
                    headerView.modalPresentationStyle = .overFullScreen
                    self.present(headerView, animated: false, completion: nil)
                
            }
        }else{
           
        }
    }

    
    @objc func phoneBtnTapped(_ sender: UIButton) {
        let phoneNumber = "\(getReservationArray.hostData?.phoneNumber ?? "")"
        let numberUrl = URL(string: "tel://\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(numberUrl) {
            UIApplication.shared.open(numberUrl)
        }
    }
    
    @objc func hostBtnTapped(_ sender: UIButton)
    {
            if Utility().isConnectedToNetwork(){
            if(getReservationArray.messageData?.id != nil)
            {
            let InboxListingObj = InboxListingVC()
            Utility.shared.ListID = "\(getReservationArray.listId!)"
            InboxListingObj.threadId = (getReservationArray.messageData?.id!)!
                InboxListingObj.isFromItinerary = true
            InboxListingObj.getMessageListAPICall(threadId:(getReservationArray.messageData?.id!)!)
              InboxListingObj.modalPresentationStyle = .fullScreen
            self.present(InboxListingObj, animated: true, completion: nil)
            }
            }
            else{
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)")
        }
    }

    func getdateValue(timestamp:String) -> String
    {
         if(Int(timestamp) != nil ) {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter = DateFormatter()
             
        dateFormatter.dateFormat = itenararyReceiptDateFormat
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
             dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter1.dateFormat = itenarayReceiptDayFormat
             if(Utility.shared.isRTLLanguage()) {
        dateFormatter1.locale = NSLocale(localeIdentifier:"en") as Locale
             }
             else {
                 dateFormatter1.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
             }
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



public final class GetReservationQueryy: GraphQLQuery {
  public let operationDefinition =
    "query getReservation($reservationId: Int!, $convertCurrency: String) {\n  getReservation(reservationId: $reservationId, convertCurrency: $convertCurrency) {\n    __typename\n    status\n    errorMessage\n    results {\n      __typename\n      id\n      nights\n      pets\n      infants\n      visitors\n      additionalGuest\n      visitorsPrice\n      infantPrice\n      petPrice\n      additionalPrice\n      listId\n      hostId\n      guestId\n      checkIn\n      checkOut\n      guests\n      message\n      basePrice\n      cleaningPrice\n      taxPrice\n      currency\n      discount\n      checkInStart\n      checkInEnd\n      discountType\n      isSpecialPriceAverage\n      guestServiceFee\n      hostServiceFee\n      total\n      totalWithGuestServiceFee\n      confirmationCode\n      paymentState\n      payoutId\n      paymentMethodId\n      reservationState\n      createdAt\n      updatedAt\n      listData {\n        __typename\n        id\n        title\n        beds\n        street\n        city\n        lat\n        lng\n        state\n        country\n        zipcode\n        reviewsCount\n        reviewsStarRating\n        roomType\n        bookingType\n        wishListStatus\n        listPhotoName\n        isListOwner\n        listPhotos {\n          __typename\n          id\n          name\n        }\n        listingData {\n          __typename\n          checkInStart\n          checkInEnd\n        }\n        settingsData {\n          __typename\n          id\n          listsettings {\n            __typename\n            id\n            itemName\n          }\n        }\n      }\n      messageData {\n        __typename\n        id\n      }\n      hostData {\n        __typename\n        userId\n        profileId\n        displayName\n        firstName\n        phoneNumber\n        picture\n      }\n      guestData {\n        __typename\n        userId\n        profileId\n        displayName\n        firstName\n        phoneNumber\n        picture\n      }\n      hostUser {\n        __typename\n        email\n      }\n      guestUser {\n        __typename\n        email\n      }\n    }\n    convertedBasePrice\n    convertedHostServiceFee\n    convertedGuestServicefee\n    convertedIsSpecialAverage\n    convertedTotalNightsAmount\n    convertTotalWithGuestServiceFee\n    convertedTotalWithHostServiceFee\n    convertedCleaningPrice\n    convertedTaxPrice\n    convertedDiscount\n  }\n}"

  public var reservationId: Int
  public var convertCurrency: String?

  public init(reservationId: Int, convertCurrency: String? = nil) {
    self.reservationId = reservationId
    self.convertCurrency = convertCurrency
  }

  public var variables: GraphQLMap? {
    return ["reservationId": reservationId, "convertCurrency": convertCurrency]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getReservation", arguments: ["reservationId": GraphQLVariable("reservationId"), "convertCurrency": GraphQLVariable("convertCurrency")], type: .object(GetReservation.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getReservation: GetReservation? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getReservation": getReservation.flatMap { (value: GetReservation) -> ResultMap in value.resultMap }])
    }

    public var getReservation: GetReservation? {
      get {
        return (resultMap["getReservation"] as? ResultMap).flatMap { GetReservation(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getReservation")
      }
    }

    public struct GetReservation: GraphQLSelectionSet {
      public static let possibleTypes = ["Reservationlist"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("status", type: .scalar(Int.self)),
        GraphQLField("errorMessage", type: .scalar(String.self)),
        GraphQLField("results", type: .object(Result.selections)),
        GraphQLField("convertedBasePrice", type: .scalar(Double.self)),
        GraphQLField("convertedHostServiceFee", type: .scalar(Double.self)),
        GraphQLField("convertedGuestServicefee", type: .scalar(Double.self)),
        GraphQLField("convertedIsSpecialAverage", type: .scalar(Double.self)),
        GraphQLField("convertedTotalNightsAmount", type: .scalar(Double.self)),
        GraphQLField("convertTotalWithGuestServiceFee", type: .scalar(Double.self)),
        GraphQLField("convertedTotalWithHostServiceFee", type: .scalar(Double.self)),
        GraphQLField("convertedCleaningPrice", type: .scalar(Double.self)),
        GraphQLField("convertedTaxPrice", type: .scalar(Double.self)),
        GraphQLField("convertedDiscount", type: .scalar(Double.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(status: Int? = nil, errorMessage: String? = nil, results: Result? = nil, convertedBasePrice: Double? = nil, convertedHostServiceFee: Double? = nil, convertedGuestServicefee: Double? = nil, convertedIsSpecialAverage: Double? = nil, convertedTotalNightsAmount: Double? = nil, convertTotalWithGuestServiceFee: Double? = nil, convertedTotalWithHostServiceFee: Double? = nil, convertedCleaningPrice: Double? = nil, convertedTaxPrice: Double? = nil, convertedDiscount: Double? = nil) {
        self.init(unsafeResultMap: ["__typename": "Reservationlist", "status": status, "errorMessage": errorMessage, "results": results.flatMap { (value: Result) -> ResultMap in value.resultMap }, "convertedBasePrice": convertedBasePrice, "convertedHostServiceFee": convertedHostServiceFee, "convertedGuestServicefee": convertedGuestServicefee, "convertedIsSpecialAverage": convertedIsSpecialAverage, "convertedTotalNightsAmount": convertedTotalNightsAmount, "convertTotalWithGuestServiceFee": convertTotalWithGuestServiceFee, "convertedTotalWithHostServiceFee": convertedTotalWithHostServiceFee, "convertedCleaningPrice": convertedCleaningPrice, "convertedTaxPrice": convertedTaxPrice, "convertedDiscount": convertedDiscount])
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

      public var results: Result? {
        get {
          return (resultMap["results"] as? ResultMap).flatMap { Result(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "results")
        }
      }

      public var convertedBasePrice: Double? {
        get {
          return resultMap["convertedBasePrice"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "convertedBasePrice")
        }
      }

      public var convertedHostServiceFee: Double? {
        get {
          return resultMap["convertedHostServiceFee"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "convertedHostServiceFee")
        }
      }

      public var convertedGuestServicefee: Double? {
        get {
          return resultMap["convertedGuestServicefee"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "convertedGuestServicefee")
        }
      }

      public var convertedIsSpecialAverage: Double? {
        get {
          return resultMap["convertedIsSpecialAverage"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "convertedIsSpecialAverage")
        }
      }

      public var convertedTotalNightsAmount: Double? {
        get {
          return resultMap["convertedTotalNightsAmount"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "convertedTotalNightsAmount")
        }
      }

      public var convertTotalWithGuestServiceFee: Double? {
        get {
          return resultMap["convertTotalWithGuestServiceFee"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "convertTotalWithGuestServiceFee")
        }
      }

      public var convertedTotalWithHostServiceFee: Double? {
        get {
          return resultMap["convertedTotalWithHostServiceFee"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "convertedTotalWithHostServiceFee")
        }
      }

      public var convertedCleaningPrice: Double? {
        get {
          return resultMap["convertedCleaningPrice"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "convertedCleaningPrice")
        }
      }

      public var convertedTaxPrice: Double? {
        get {
          return resultMap["convertedTaxPrice"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "convertedTaxPrice")
        }
      }

      public var convertedDiscount: Double? {
        get {
          return resultMap["convertedDiscount"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "convertedDiscount")
        }
      }

      public struct Result: GraphQLSelectionSet {
        public static let possibleTypes = ["Reservation"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(Int.self)),
          GraphQLField("nights", type: .scalar(Int.self)),
          GraphQLField("pets", type: .scalar(Int.self)),
          GraphQLField("infants", type: .scalar(Int.self)),
          GraphQLField("visitors", type: .scalar(Int.self)),
          GraphQLField("additionalGuest", type: .scalar(Int.self)),
          GraphQLField("visitorsPrice", type: .scalar(Double.self)),
          GraphQLField("infantPrice", type: .scalar(Double.self)),
          GraphQLField("petPrice", type: .scalar(Double.self)),
          GraphQLField("additionalPrice", type: .scalar(Double.self)),
          GraphQLField("listId", type: .scalar(Int.self)),
          GraphQLField("hostId", type: .scalar(String.self)),
          GraphQLField("guestId", type: .scalar(String.self)),
          GraphQLField("checkIn", type: .scalar(String.self)),
          GraphQLField("checkOut", type: .scalar(String.self)),
          GraphQLField("guests", type: .scalar(Int.self)),
          GraphQLField("message", type: .scalar(String.self)),
          GraphQLField("basePrice", type: .scalar(Double.self)),
          GraphQLField("cleaningPrice", type: .scalar(Double.self)),
          GraphQLField("taxPrice", type: .scalar(Double.self)),
          GraphQLField("currency", type: .scalar(String.self)),
          GraphQLField("discount", type: .scalar(Double.self)),
          GraphQLField("checkInStart", type: .scalar(String.self)),
          GraphQLField("checkInEnd", type: .scalar(String.self)),
          GraphQLField("discountType", type: .scalar(String.self)),
          GraphQLField("isSpecialPriceAverage", type: .scalar(Double.self)),
          GraphQLField("guestServiceFee", type: .scalar(Double.self)),
          GraphQLField("hostServiceFee", type: .scalar(Double.self)),
          GraphQLField("total", type: .scalar(Double.self)),
          GraphQLField("totalWithGuestServiceFee", type: .scalar(Double.self)),
          GraphQLField("confirmationCode", type: .scalar(Int.self)),
          GraphQLField("paymentState", type: .scalar(String.self)),
          GraphQLField("payoutId", type: .scalar(Int.self)),
          GraphQLField("paymentMethodId", type: .scalar(Int.self)),
          GraphQLField("reservationState", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .scalar(String.self)),
          GraphQLField("updatedAt", type: .scalar(String.self)),
          GraphQLField("listData", type: .object(ListDatum.selections)),
          GraphQLField("messageData", type: .object(MessageDatum.selections)),
          GraphQLField("hostData", type: .object(HostDatum.selections)),
          GraphQLField("guestData", type: .object(GuestDatum.selections)),
          GraphQLField("hostUser", type: .object(HostUser.selections)),
          GraphQLField("guestUser", type: .object(GuestUser.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: Int? = nil, nights: Int? = nil, pets: Int? = nil, infants: Int? = nil, visitors: Int? = nil, additionalGuest: Int? = nil, visitorsPrice: Double? = nil, infantPrice: Double? = nil, petPrice: Double? = nil, additionalPrice: Double? = nil, listId: Int? = nil, hostId: String? = nil, guestId: String? = nil, checkIn: String? = nil, checkOut: String? = nil, guests: Int? = nil, message: String? = nil, basePrice: Double? = nil, cleaningPrice: Double? = nil, taxPrice: Double? = nil, currency: String? = nil, discount: Double? = nil, checkInStart: String? = nil, checkInEnd: String? = nil, discountType: String? = nil, isSpecialPriceAverage: Double? = nil, guestServiceFee: Double? = nil, hostServiceFee: Double? = nil, total: Double? = nil, totalWithGuestServiceFee: Double? = nil, confirmationCode: Int? = nil, paymentState: String? = nil, payoutId: Int? = nil, paymentMethodId: Int? = nil, reservationState: String? = nil, createdAt: String? = nil, updatedAt: String? = nil, listData: ListDatum? = nil, messageData: MessageDatum? = nil, hostData: HostDatum? = nil, guestData: GuestDatum? = nil, hostUser: HostUser? = nil, guestUser: GuestUser? = nil) {
          self.init(unsafeResultMap: ["__typename": "Reservation", "id": id, "nights": nights, "pets": pets, "infants": infants, "visitors": visitors, "additionalGuest": additionalGuest, "visitorsPrice": visitorsPrice, "infantPrice": infantPrice, "petPrice": petPrice, "additionalPrice": additionalPrice, "listId": listId, "hostId": hostId, "guestId": guestId, "checkIn": checkIn, "checkOut": checkOut, "guests": guests, "message": message, "basePrice": basePrice, "cleaningPrice": cleaningPrice, "taxPrice": taxPrice, "currency": currency, "discount": discount, "checkInStart": checkInStart, "checkInEnd": checkInEnd, "discountType": discountType, "isSpecialPriceAverage": isSpecialPriceAverage, "guestServiceFee": guestServiceFee, "hostServiceFee": hostServiceFee, "total": total, "totalWithGuestServiceFee": totalWithGuestServiceFee, "confirmationCode": confirmationCode, "paymentState": paymentState, "payoutId": payoutId, "paymentMethodId": paymentMethodId, "reservationState": reservationState, "createdAt": createdAt, "updatedAt": updatedAt, "listData": listData.flatMap { (value: ListDatum) -> ResultMap in value.resultMap }, "messageData": messageData.flatMap { (value: MessageDatum) -> ResultMap in value.resultMap }, "hostData": hostData.flatMap { (value: HostDatum) -> ResultMap in value.resultMap }, "guestData": guestData.flatMap { (value: GuestDatum) -> ResultMap in value.resultMap }, "hostUser": hostUser.flatMap { (value: HostUser) -> ResultMap in value.resultMap }, "guestUser": guestUser.flatMap { (value: GuestUser) -> ResultMap in value.resultMap }])
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

        public var nights: Int? {
          get {
            return resultMap["nights"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "nights")
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
          
          public var additionalGuest: Int? {
            get {
              return resultMap["additionalGuest"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "additionalGuest")
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
          
          public var infantPrice: Double? {
            get {
              return resultMap["infantPrice"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "infantPrice")
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
          
          public var additionalPrice: Double? {
            get {
              return resultMap["additionalPrice"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "additionalPrice")
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

        public var taxPrice: Double? {
          get {
            return resultMap["taxPrice"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "taxPrice")
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

        public var discountType: String? {
          get {
            return resultMap["discountType"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "discountType")
          }
        }

        public var isSpecialPriceAverage: Double? {
          get {
            return resultMap["isSpecialPriceAverage"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "isSpecialPriceAverage")
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

        public var totalWithGuestServiceFee: Double? {
          get {
            return resultMap["totalWithGuestServiceFee"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "totalWithGuestServiceFee")
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

        public var paymentState: String? {
          get {
            return resultMap["paymentState"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "paymentState")
          }
        }

        public var payoutId: Int? {
          get {
            return resultMap["payoutId"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "payoutId")
          }
        }

        public var paymentMethodId: Int? {
          get {
            return resultMap["paymentMethodId"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "paymentMethodId")
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

        public var createdAt: String? {
          get {
            return resultMap["createdAt"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String? {
          get {
            return resultMap["updatedAt"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var listData: ListDatum? {
          get {
            return (resultMap["listData"] as? ResultMap).flatMap { ListDatum(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "listData")
          }
        }

        public var messageData: MessageDatum? {
          get {
            return (resultMap["messageData"] as? ResultMap).flatMap { MessageDatum(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "messageData")
          }
        }

        public var hostData: HostDatum? {
          get {
            return (resultMap["hostData"] as? ResultMap).flatMap { HostDatum(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "hostData")
          }
        }

        public var guestData: GuestDatum? {
          get {
            return (resultMap["guestData"] as? ResultMap).flatMap { GuestDatum(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "guestData")
          }
        }

        public var hostUser: HostUser? {
          get {
            return (resultMap["hostUser"] as? ResultMap).flatMap { HostUser(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "hostUser")
          }
        }

        public var guestUser: GuestUser? {
          get {
            return (resultMap["guestUser"] as? ResultMap).flatMap { GuestUser(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "guestUser")
          }
        }

        public struct ListDatum: GraphQLSelectionSet {
          public static let possibleTypes = ["ShowListing"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("beds", type: .scalar(Int.self)),
            GraphQLField("street", type: .scalar(String.self)),
            GraphQLField("lat", type: .scalar(Double.self)),
            GraphQLField("lng", type: .scalar(Double.self)),
            GraphQLField("city", type: .scalar(String.self)),
            GraphQLField("state", type: .scalar(String.self)),
            GraphQLField("country", type: .scalar(String.self)),
            GraphQLField("zipcode", type: .scalar(String.self)),
            GraphQLField("reviewsCount", type: .scalar(Int.self)),
            GraphQLField("reviewsStarRating", type: .scalar(Int.self)),
            GraphQLField("roomType", type: .scalar(String.self)),
            GraphQLField("bookingType", type: .scalar(String.self)),
            GraphQLField("wishListStatus", type: .scalar(Bool.self)),
            GraphQLField("listPhotoName", type: .scalar(String.self)),
            GraphQLField("isListOwner", type: .scalar(Bool.self)),
            GraphQLField("listPhotos", type: .list(.object(ListPhoto.selections))),
            GraphQLField("listingData", type: .object(ListingDatum.selections)),
            GraphQLField("settingsData", type: .list(.object(SettingsDatum.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int? = nil, title: String? = nil, beds: Int? = nil, street: String? = nil, lng: Double? = nil, lat: Double? = nil, city: String? = nil, state: String? = nil, country: String? = nil, zipcode: String? = nil, reviewsCount: Int? = nil, reviewsStarRating: Int? = nil, roomType: String? = nil, bookingType: String? = nil, wishListStatus: Bool? = nil, listPhotoName: String? = nil, isListOwner: Bool? = nil, listPhotos: [ListPhoto?]? = nil, listingData: ListingDatum? = nil, settingsData: [SettingsDatum?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "ShowListing", "id": id, "title": title, "beds": beds, "street": street, "lng": lng, "lat": lat, "city": city, "state": state, "country": country, "zipcode": zipcode, "reviewsCount": reviewsCount, "reviewsStarRating": reviewsStarRating, "roomType": roomType, "bookingType": bookingType, "wishListStatus": wishListStatus, "listPhotoName": listPhotoName, "isListOwner": isListOwner, "listPhotos": listPhotos.flatMap { (value: [ListPhoto?]) -> [ResultMap?] in value.map { (value: ListPhoto?) -> ResultMap? in value.flatMap { (value: ListPhoto) -> ResultMap in value.resultMap } } }, "listingData": listingData.flatMap { (value: ListingDatum) -> ResultMap in value.resultMap }, "settingsData": settingsData.flatMap { (value: [SettingsDatum?]) -> [ResultMap?] in value.map { (value: SettingsDatum?) -> ResultMap? in value.flatMap { (value: SettingsDatum) -> ResultMap in value.resultMap } } }])
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

          public var title: String? {
            get {
              return resultMap["title"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "title")
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

          public var street: String? {
            get {
              return resultMap["street"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "street")
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

          public var zipcode: String? {
            get {
              return resultMap["zipcode"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "zipcode")
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

          public var wishListStatus: Bool? {
            get {
              return resultMap["wishListStatus"] as? Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "wishListStatus")
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

          public var isListOwner: Bool? {
            get {
              return resultMap["isListOwner"] as? Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "isListOwner")
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

          public var listingData: ListingDatum? {
            get {
              return (resultMap["listingData"] as? ResultMap).flatMap { ListingDatum(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "listingData")
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

          public struct ListingDatum: GraphQLSelectionSet {
            public static let possibleTypes = ["listingData"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("checkInStart", type: .scalar(String.self)),
              GraphQLField("checkInEnd", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(checkInStart: String? = nil, checkInEnd: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "listingData", "checkInStart": checkInStart, "checkInEnd": checkInEnd])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
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
          }

          public struct SettingsDatum: GraphQLSelectionSet {
            public static let possibleTypes = ["userListingData"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(Int.self)),
              GraphQLField("listsettings", type: .object(Listsetting.selections)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: Int? = nil, listsettings: Listsetting? = nil) {
              self.init(unsafeResultMap: ["__typename": "userListingData", "id": id, "listsettings": listsettings.flatMap { (value: Listsetting) -> ResultMap in value.resultMap }])
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
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(id: Int? = nil, itemName: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "singleListSettings", "id": id, "itemName": itemName])
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
            }
          }
        }

        public struct MessageDatum: GraphQLSelectionSet {
          public static let possibleTypes = ["Threads"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "Threads", "id": id])
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
        }

        public struct HostDatum: GraphQLSelectionSet {
          public static let possibleTypes = ["userProfile"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("userId", type: .scalar(String.self)),
            GraphQLField("profileId", type: .scalar(Int.self)),
            GraphQLField("displayName", type: .scalar(String.self)),
            GraphQLField("firstName", type: .scalar(String.self)),
            GraphQLField("phoneNumber", type: .scalar(String.self)),
            GraphQLField("picture", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(userId: String? = nil, profileId: Int? = nil, displayName: String? = nil, firstName: String? = nil, phoneNumber: String? = nil, picture: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "userProfile", "userId": userId, "profileId": profileId, "displayName": displayName, "firstName": firstName, "phoneNumber": phoneNumber, "picture": picture])
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

          public var firstName: String? {
            get {
              return resultMap["firstName"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "firstName")
            }
          }

          public var phoneNumber: String? {
            get {
              return resultMap["phoneNumber"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "phoneNumber")
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
        }

        public struct GuestDatum: GraphQLSelectionSet {
          public static let possibleTypes = ["userProfile"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("userId", type: .scalar(String.self)),
            GraphQLField("profileId", type: .scalar(Int.self)),
            GraphQLField("displayName", type: .scalar(String.self)),
            GraphQLField("firstName", type: .scalar(String.self)),
            GraphQLField("phoneNumber", type: .scalar(String.self)),
            GraphQLField("picture", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(userId: String? = nil, profileId: Int? = nil, displayName: String? = nil, firstName: String? = nil, phoneNumber: String? = nil, picture: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "userProfile", "userId": userId, "profileId": profileId, "displayName": displayName, "firstName": firstName, "phoneNumber": phoneNumber, "picture": picture])
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

          public var firstName: String? {
            get {
              return resultMap["firstName"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "firstName")
            }
          }

          public var phoneNumber: String? {
            get {
              return resultMap["phoneNumber"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "phoneNumber")
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
        }

        public struct HostUser: GraphQLSelectionSet {
          public static let possibleTypes = ["UserType"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("email", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(email: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "UserType", "email": email])
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
        }

        public struct GuestUser: GraphQLSelectionSet {
          public static let possibleTypes = ["UserType"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("email", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(email: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "UserType", "email": email])
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
        }
      }
    }
  }
}
