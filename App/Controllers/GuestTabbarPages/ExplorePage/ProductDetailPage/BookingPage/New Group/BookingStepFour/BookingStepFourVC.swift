
import UIKit
import Apollo
import Lottie
import SwiftyJSON
import MKToolTip


class BookingStepFourVC: UIViewController,UITableViewDataSource,UITableViewDelegate{
   
    struct specialPrice: Codable {
        let blockedDates: String
        let isSpecialPrice: Double
    }
    

    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var offlineView: UIView!
    
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bookingStepFourTable: UITableView!
    
    @IBOutlet weak var paymentBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    var currencyvalue_from_API_base = String()
    var totalPriceLabel = String()
    var totalAmount = ""
    var getbillingArray = GetBillingCalculationQueryy.Data.GetBillingCalculation.Result()
     var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    var attdList : JSON = [:]
    var JSON_obj = [GetBillingCalculationQueryy.Data.GetBillingCalculation.Result.SpecialPricing]()
    var lottieWholeView = UIView()
    var lottieView =  LottieAnimationView()
    var array = NSMutableArray()
    
    
    var error: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")

        currencyvalue_from_API_base = Utility.shared.passCurrencyvaluefromAPI
        self.initialsetup()
        errorLabel.font = UIFont(name: APP_FONT, size: 15)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        paymentBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size:18)
        if(Utility.shared.isRTLLanguage()) {
            backBtn.rotateImageViewofBtn()
        }
    }
    
   
     func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
          
        }
        
        return ""
    }

    func initialsetup()
    {
        if IS_IPHONE_XR
        {
            self.topView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH-40, height: 80)
            bookingStepFourTable.frame = CGRect(x: 0, y: 85, width: FULLWIDTH-40, height: FULLHEIGHT-400)
            
        }
        bookingStepFourTable.register(UINib(nibName: "BookingFourCell", bundle: nil), forCellReuseIdentifier: "BookingFourCell")
        bookingStepFourTable.register(UINib(nibName: "AgreetermsCell", bundle: nil), forCellReuseIdentifier: "AgreetermsCell")
        bookingStepFourTable.register(UINib(nibName: "RequestBookcellTableViewCell", bundle: nil), forCellReuseIdentifier: "RequestBookcellTableViewCell")
        bookingStepFourTable.register(UINib(nibName: "ReservationCell", bundle: nil), forCellReuseIdentifier: "ReservationCell")
        bookingStepFourTable.register(UINib(nibName: "BookingTotalCell", bundle: nil), forCellReuseIdentifier: "BookingTotalCell")
        bookingStepFourTable.register(UINib(nibName: "bookcancellationCell", bundle: nil), forCellReuseIdentifier: "bookcancellationCell")
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
        paymentBtn.backgroundColor = Theme.SECONDARY_COLOR
        
        let shadowPath1 = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                    y: -shadowSize / 2,
                                                    width: self.topView.frame.size.width+40 + shadowSize,
                                                    height: self.topView.frame.size.height + shadowSize))
        
        self.topView.layer.masksToBounds = false
        self.topView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.topView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.topView.layer.shadowOpacity = 0.3
        self.topView.layer.shadowPath = shadowPath1.cgPath
        paymentBtn.layer.cornerRadius = 5.0
        paymentBtn.layer.masksToBounds = true
        self.lottieWholeView.isHidden = true
        self.lottieView.isHidden = true
        self.offlineView.isHidden = true
        lottieView = LottieAnimationView.init(name: "loading_qwe")
        paymentBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"addpayment"))!)", for: .normal)
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
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

    @IBAction func backbtntapped(_ sender: Any) {
       
       self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func retryBtnTappped(_ sender: Any) {
        self.offlineView.isHidden = true
    }

    @IBAction func addPaymentTapped(_ sender: Any) {
        
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
//            let navigationController = UINavigationController(rootViewController: self)
//            keyWindow.rootViewController = navigationController
//            
//            let paymentSelectionPage = PaymentSelectionPage()
//            paymentSelectionPage.currencyvalue_from_API_base = self.currencyvalue_from_API_base
//            paymentSelectionPage.getbillingArray = self.getbillingArray
//            paymentSelectionPage.viewListingArray = self.viewListingArray
//
//            // Push the view controller onto the navigation stack
//            self.navigationController?.pushViewController(paymentSelectionPage, animated: true)
//        }


        
        let paymentSelectionPage = PaymentSelectionPage()
        paymentSelectionPage.currencyvalue_from_API_base = self.currencyvalue_from_API_base
        paymentSelectionPage.getbillingArray = self.getbillingArray
        paymentSelectionPage.viewListingArray = self.viewListingArray
        paymentSelectionPage.modalPresentationStyle = .fullScreen
        self.present(paymentSelectionPage, animated: true, completion: nil)
        return
    }

    


    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    @objc func dismissController()
    {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 2)
        {
            if(getbillingArray.cleaningPrice == 0)
            {
                if(getbillingArray.discountLabel != nil && getbillingArray.discount != 0)
                {
                    return 3
                }
                return 2
                
            }
            else
            {
                if(getbillingArray.discountLabel != nil && getbillingArray.discount != 0)
                {
                    return 4
                }
                return 3
            }
            
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0)
        {
            return 215
        }
        else if(indexPath.section == 1)
        {
            return  45
        }
        else if(indexPath.section == 2)
        {
            return 55
        }
        else if(indexPath.section == 3)
        {
            return 100
        }
            else if(indexPath.section == 4)
        {
            return 160
        }
            
        else{
            return 135
        }
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "BookingFourCell", for: indexPath)as! BookingFourCell
            cell.listnameLabel.text = Utility.shared.bookingListname
            cell.dateLabel.text = Utility.shared.bookingdateLabel
            let listimage = Utility.shared.bookingListimage
            cell.listImage.layer.cornerRadius = 6.0
            cell.selectionStyle = .none
            if(Utility.shared.isprofilepictureVerified)
            {
                cell.stepLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"step4of4"))!)"
                
            }
            else
            {
                cell.stepLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"step3of3"))!)"
            }
            cell.listImage.layer.masksToBounds = true
            cell.listImage.sd_setImage(with: URL(string:"\(IMAGE_LISTING_MEDIUM)\(String(describing: listimage))"),placeholderImage: #imageLiteral(resourceName: "unknown"))
            cell.listBtn.tag = indexPath.row
            cell.listBtn.addTarget(self, action: #selector(listBtnTapped), for: .touchUpInside)
            return cell
        }
        else if(indexPath.section == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCell", for: indexPath)as! ReservationCell
            cell.selectionStyle = .none
            return cell
        }
        else if(indexPath.section == 2)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestBookcellTableViewCell", for: indexPath)as! RequestBookcellTableViewCell
            cell.selectionStyle = .none
            var currencysymbol = String()
            cell.specialImage.isHidden = true
             cell.specialImage.addTarget(self, action: #selector(tooltipBtnTapped),for:.touchUpInside)
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
            {
                currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)!
            }
            else
            {
                currencysymbol = Utility.shared.getSymbol(forCurrencyCode:self.currencyvalue_from_API_base)!
            }
            
            if(getbillingArray.cleaningPrice == 0)
            {
                if(getbillingArray.discountLabel != nil && getbillingArray.discount != 0)
                {
                    if(indexPath.row == 0)
                    {

                        
                        if Utility.shared.numberofnights_Selected > 1{
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                  
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? getbillingArray.priceForDays!.clean : "")"
                        cell.priceLabel.sizeToFit()
                        if(getbillingArray.isSpecialPriceAssigned == true)
                        {
                            cell.specialImage.isHidden = false
                             cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                        
                    }
                    else if(indexPath.row == 1)
                    {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.guestServiceFee != nil ? getbillingArray.guestServiceFee!.clean : "")"
                    }
                    else{
                        cell.priceLabel.text =  getbillingArray.discountLabel!.capitalized
                        
                        cell.priceLeftLabel.text = "-\(currencysymbol)\(getbillingArray.discount != nil ? getbillingArray.discount!.clean : "")"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                }
                else
                {
                    if(indexPath.row == 0)
                    {
           
                        if Utility.shared.numberofnights_Selected > 1 {
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                        
                        let calculated_Price = Double(String(format: "%.2f",(getbillingArray.basePrice! * Double(Utility.shared.numberofnights_Selected))))as! Double
                        cell.priceLabel.sizeToFit()
                        if(getbillingArray.isSpecialPriceAssigned == true)
                        {
                            cell.specialImage.isHidden = false
                             cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? getbillingArray.priceForDays!.clean : "")"
                    }
                    else if(indexPath.row == 1)
                    {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.guestServiceFee != nil ? getbillingArray.guestServiceFee!.clean : "")"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                    
                }
                
            }
            else{
                
                if(getbillingArray.discountLabel != nil && getbillingArray.discount != 0)
                {
                    if(indexPath.row == 0)
                    {

                        
                        if Utility.shared.numberofnights_Selected > 1 {
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                        
                        let calculated_Price = Double(String(format: "%.2f",(getbillingArray.basePrice! * Double(Utility.shared.numberofnights_Selected))))as! Double
                        cell.priceLabel.sizeToFit()
                        if(getbillingArray.isSpecialPriceAssigned == true)
                        {
                            cell.specialImage.isHidden = false
                             cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? getbillingArray.priceForDays!.clean : "")"
                    }
                    else if(indexPath.row == 1)
                    {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.cleaningPrice != nil ? getbillingArray.cleaningPrice!.clean : "")"
                    }
                    else if(indexPath.row == 2)
                    {
                        cell.priceLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.guestServiceFee != nil ? getbillingArray.guestServiceFee!.clean : "")"
                    }
                    else{
                        cell.priceLabel.text =  getbillingArray.discountLabel != nil ? getbillingArray.discountLabel!.capitalized : ""
                        
                        cell.priceLeftLabel.text = "-\(currencysymbol)\((getbillingArray.discount != nil ? getbillingArray.discount!.clean : ""))"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                }
                    
                else{
                    if(indexPath.row == 0)
                    {

                        
                        if Utility.shared.numberofnights_Selected > 1 {
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                        }else{
                            cell.priceLabel.text =  "\(currencysymbol)\(getbillingArray.averagePrice!.clean) x \(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                        }
                        
                        let calculated_Price = Double(String(format: "%.2f",(getbillingArray.basePrice! * Double(Utility.shared.numberofnights_Selected))))as! Double
                        cell.priceLabel.sizeToFit()
                        if(getbillingArray.isSpecialPriceAssigned == true)
                        {
                            cell.specialImage.isHidden = false
                             cell.specialImage.frame = CGRect(x: cell.priceLabel.frame.size.width+cell.priceLabel.frame.origin.x+5, y:17, width: 20, height: 20)
                        }
                       
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.priceForDays != nil ? getbillingArray.priceForDays!.clean : "")"
                    }
                    else if(indexPath.row == 1)
                    {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cleaningfee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.cleaningPrice != nil ? getbillingArray.cleaningPrice!.clean : "")"
                    }
                    else if(indexPath.row == 2)
                    {
                        cell.priceLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"servicefee"))!)"
                        
                        cell.priceLeftLabel.text = "\(currencysymbol)\(getbillingArray.guestServiceFee != nil ? getbillingArray.guestServiceFee!.clean : "")"
                    }
                    cell.priceLabelLeadingConstraint.constant = cell.specialImage.isHidden ? -20 : 5
                    return cell
                }
                
                
            }
            
            
        }
       else if(indexPath.section == 3)
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
            cell.totalPriceLabel.text = "\(currencysymbol)\(getbillingArray.total != nil ? getbillingArray.total!.clean : "")"
            totalPriceLabel = "\(currencysymbol)\(getbillingArray.total != nil ? getbillingArray.total!.clean : "")"
            totalAmount = "\(getbillingArray.total != nil ? getbillingArray.total!.clean : "")"
            if Utility.shared.isRTLLanguage(){
                cell.totalPriceLabel.textAlignment = .left
            }else{
                cell.totalPriceLabel.textAlignment = .right
            }
            return cell
        }
        else if(indexPath.section == 4)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookcancellationCell", for: indexPath) as! bookcancellationCell
            cell.cancelpolicyLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"cancellationPolicy"))!): \(Utility.shared.cancelpolicy)"
            cell.cancelpolicycontentLabel.text = "\(Utility.shared.cancelpolicy_content)"
            cell.selectionStyle = .none
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AgreetermsCell", for: indexPath)as! AgreetermsCell
            cell.selectionStyle = .none
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
        preference.drawing.bubble.border.color = UIColor(red: 0.768, green: 0.843, blue: 0.937, alpha: 1.000)
        preference.drawing.bubble.border.width = 1
        preference.drawing.arrow.tipCornerRadius = 5
        preference.drawing.message.color = UIColor.white
        preference.drawing.message.font = UIFont(name: APP_FONT, size:15)!
        preference.drawing.button.color = UIColor(red: 0.074, green: 0.231, blue: 0.431, alpha: 1.000)
        preference.drawing.button.font = UIFont(name: APP_FONT, size:15)!
        sender.showToolTip(identifier: "", message:"\((Utility.shared.getLanguage()?.value(forKey:"specialtooltip"))!)", button:nil, arrowPosition: .bottom, preferences: preference, delegate: nil)
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
    
    
    
  
}




