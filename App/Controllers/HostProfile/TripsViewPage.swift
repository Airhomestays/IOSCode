//
//  TripsViewPage.swift
//  Rent_All
//
//  Created by RadicalStart on 11/09/20.
//  Copyright © 2020 RADICAL START. All rights reserved.
//

import UIKit
import Apollo

class TripsViewPage: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tripViewTable: UITableView!
    @IBOutlet weak var topView: UIView!
    var titleArray = ["Check-in","Check-Out","Guests"]
    var leftArray = ["Mon, 01 Jul 2020","Fri, 05 Jul 2020","1"]
    var getallreservationquery = [GetAllReservationQuery.Data.GetAllReservation.Result]()
       var getpreviousReservationquery = [GetAllReservationQuery.Data.GetAllReservation.Result]()
    var indexVal = Int()
     var apollo_headerClient:ApolloClient!
    var getReservationArray = GetReservationQuery.Data.GetReservation.Result()
    var getReservation_currencyArray = GetReservationQuery.Data.GetReservation()
    override func viewDidLoad() {
        super.viewDidLoad()
        checkApolloStatus()
        topView.backgroundColor = Theme.PRIMARY_COLOR
        tripViewTable.register(UINib(nibName: "StatusCell", bundle: nil), forCellReuseIdentifier: "StatusCell")
        tripViewTable.register(UINib(nibName: "ListiprofileCell", bundle: nil), forCellReuseIdentifier: "ListiprofileCell")
        tripViewTable.register(UINib(nibName: "TripsoptionsCell", bundle: nil), forCellReuseIdentifier: "TripsoptionsCell")
        tripViewTable.register(UINib(nibName: "bookcancellationCell", bundle: nil), forCellReuseIdentifier: "bookcancellationCell")
        tripViewTable.register(UINib(nibName: "CheckingCell", bundle: nil), forCellReuseIdentifier: "CheckingCell")
        tripViewTable.alwaysBounceVertical = false
         
        tripViewTable.bounces = false
        //tripViewTable.isScrollEnabled = false
        //tripViewTable.backgroundColor = Theme.PRIMARY_COLOR
        // Do any additional setup after loading the view.
    }
    func checkApolloStatus()
    {
        if((Utility.shared.getCurrentUserToken()) != nil && (Utility.shared.getCurrentUserToken() != ""))
        {
            apollo_headerClient = {
                let configuration = URLSessionConfiguration.default
                // Add additional headers as needed
                configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"] // Replace `<token>`
                
                let url = URL(string:graphQLEndpoint)!
                
                return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
            }()
        }
        else{
            apollo_headerClient = ApolloClient(url: URL(string:graphQLEndpoint)!)
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
         if((getallreservationquery[indexVal].reservationState! == "cancelled") || (getallreservationquery[indexVal].reservationState! == "declined") || (getallreservationquery[indexVal].reservationState! == "expired"))
                        {
                          return 6
                        }
                        else if((getallreservationquery[indexVal].reservationState! == "pending") &&  ((getallreservationquery[indexVal].listData?.bookingType! == "request") || (getallreservationquery[indexVal].listData?.bookingType! == "instant")))
                        {
                            return 6
                        }
                        else if ((getallreservationquery[indexVal].reservationState! == "completed"))
                            {
                            return 6
        
                            }
                        else
                        {
                         return 7
                        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 2) {
            return titleArray.count
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(getallreservationquery[indexVal].reservationState! == "approved") {
        if(indexPath.section == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath)as! StatusCell
            cell.selectionStyle = .none
            if(getallreservationquery[indexVal].reservationState != nil) {
            cell.statusLabel.text = Utility.shared.getbookingtype(type: getallreservationquery[indexVal].reservationState!)
            } else {
                cell.statusLabel.text = "Approved"
            }
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                                          {
                                              let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                                              let from_currency = getallreservationquery[indexVal].currency!
                                              let total = Double(getallreservationquery[indexVal].total!) + Double(getallreservationquery[indexVal].guestServiceFee!)
                                              let price_value = self.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:total)
                                              let restricted_price =  Double(String(format: "%.2f",price_value))
                                            cell.priceLabel.text = "\(getallreservationquery[indexVal].guests!) Guest\(getallreservationquery[indexVal].guests! > 1 ? "s" : "") . \(currencysymbol!)\(restricted_price!.clean)"
                                            
                                              
                                          }
                                          else
                                          {
                                              let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                                              let from_currency = getallreservationquery[indexVal].currency!
                                              let total = Double(getallreservationquery[indexVal].total!) + Double(getallreservationquery[indexPath.row].guestServiceFee!)
                                              let price_value = self.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate: Utility.shared.currency_Dict, amount:total)
                                              let restricted_price =  Double(String(format: "%.2f",price_value))
                                            cell.priceLabel.text = "\(getallreservationquery[indexVal].guests!) Guests\(getallreservationquery[indexVal].guests! > 1 ? "s" : "") . \(currencysymbol!)\(restricted_price!.clean)"
                                             
                                          }
            
            return cell
        }
         else if(indexPath.section == 1) {
                   
                   let cell = tableView.dequeueReusableCell(withIdentifier: "ListiprofileCell", for: indexPath)as! ListiprofileCell
            cell.listBtn.setTitle((self.getallreservationquery[indexVal].listData?.title!)!.firstUppercased, for: .normal)
            cell.listBtn.tag = indexVal
            cell.listBtn.addTarget(self, action: #selector(listBtnTapped(_:)), for: .touchUpInside)
            //cell.titleLbel.text = (self.getallreservationquery[indexVal].listData?.title!)!.firstUppercased
            cell.hostedLAbel.text = "Hosted by \((self.getallreservationquery[indexVal].hostData?.displayName!)!)"
            if getallreservationquery[indexVal].hostData?.picture != nil
            {
                let profImage = (getallreservationquery[indexVal].hostData?.picture!)!
              cell.profileImage.sd_setImage(with: URL(string:"\(IMAGE_AVATAR_MEDIUM)\(profImage)"), completed: nil)
                
            } else {
               cell.profileImage.image  = #imageLiteral(resourceName: "unknown")
            }
            cell.profileBtn.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
                   return cell
               } else if(indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath)as! CheckingCell
            cell.selectionStyle = .none
            cell.checkLabel.text = titleArray[indexPath.row]
            let inday = getdayValue(timestamp: getallreservationquery[indexVal].checkIn!)
                                          let indate = getdateValue(timestamp: getallreservationquery[indexVal].checkIn!)
                                          let outday = getdayValue(timestamp: getallreservationquery[indexVal].checkOut!)
                                          let outdate = getdateValue(timestamp: getallreservationquery[indexVal].checkOut!)
                           if(indexPath.row == 0) {
                                          cell.flexLabel.text = "\(indate)"
                           } else if(indexPath.row == 1) {
                                cell.flexLabel.text = "\(outdate)"
                           } else {
                               if(getallreservationquery[indexVal].guests != nil) {
                                   cell.flexLabel.text = "\(getallreservationquery[indexVal].guests!)"
                            }}
            
           // cell.flexLabel.text = leftArray[indexPath.row]
                              return cell
        } else if(indexPath.section == 3) {
                                  
                                  let cell = tableView.dequeueReusableCell(withIdentifier: "TripsoptionsCell", for: indexPath)as! TripsoptionsCell
        //            cell.firstBtn.setImage(#imageLiteral(resourceName: "unknown").withRenderingMode(.alwaysTemplate), for: .normal)
        //            cell.firstBtn.tintColor = .white
                    cell.secondBtn.setImage(#imageLiteral(resourceName: "journey").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.selectionStyle = .none
            cell.firstBtn.setTitle("Message", for: .normal)
                        cell.secondBtn.setTitle("Itinerary", for: .normal)
            cell.firstBtn.tag = indexVal
            cell.secondBtn.tag = indexVal
             cell.firstBtn.addTarget(self, action: #selector(messageBtnTapped), for: .touchUpInside)
            cell.secondBtn.addTarget(self, action: #selector(IteneraryBtnTapped), for: .touchUpInside)
                                  return cell
        }   else if(indexPath.section == 4 ) {
                                                        
         let cell = tableView.dequeueReusableCell(withIdentifier: "TripsoptionsCell", for: indexPath)as! TripsoptionsCell
            cell.firstBtn.setImage(#imageLiteral(resourceName: "bill").withRenderingMode(.alwaysOriginal), for: .normal)
            cell.secondBtn.setImage(#imageLiteral(resourceName: "error-2").withRenderingMode(.alwaysOriginal), for: .normal)
            cell.firstBtn.setTitle("Receipt", for: .normal)
            cell.firstBtn.imageEdgeInsets = UIEdgeInsets(top: -34, left:43, bottom: 0, right: -27)
              cell.firstBtn.titleEdgeInsets = UIEdgeInsets(top: 36, left:-28, bottom: 0, right: 0)
             cell.secondBtn.setTitle("Cancel", for: .normal)
            cell.firstBtn.tag = indexVal
            cell.secondBtn.tag = indexVal
            cell.firstBtn.addTarget(self, action: #selector(ReceiptBtnTapped(_:)), for: .touchUpInside)
            cell.secondBtn.addTarget(self, action: #selector(cancelBtnTapped(_:)), for: .touchUpInside)
                cell.selectionStyle = .none
        return cell
        } else if(indexPath.section == 5) {
            
           let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath)as! CheckingCell
            cell.checkLabel.text = "Price"
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                                                     {
                                                         let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                                                         let from_currency = getallreservationquery[indexVal].currency!
                                                         let total = Double(getallreservationquery[indexVal].total!) + Double(getallreservationquery[indexVal].guestServiceFee!)
                                                         let price_value = self.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:total)
                                                         let restricted_price =  Double(String(format: "%.2f",price_value))
                                                       cell.flexLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                                       
                                                         
                                                     }
                                                     else
                                                     {
                                                         let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                                                         let from_currency = getallreservationquery[indexVal].currency!
                                                         let total = Double(getallreservationquery[indexVal].total!) + Double(getallreservationquery[indexPath.row].guestServiceFee!)
                                                         let price_value = self.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate: Utility.shared.currency_Dict, amount:total)
                                                         let restricted_price =  Double(String(format: "%.2f",price_value))
                                                       cell.flexLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                                        
                                                     }
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
           if((getallreservationquery[indexVal].cancellationPolicy!) == 1)
                {
                  Utility.shared.cancelpolicy = "\((Utility.shared.getLanguage()?.value(forKey:"flexible"))!)"
                
                } else if((getallreservationquery[indexVal].cancellationPolicy!) == 2) {
                  Utility.shared.cancelpolicy = "\((Utility.shared.getLanguage()?.value(forKey:"moderate"))!)"
                    
                } else if((getallreservationquery[indexVal].cancellationPolicy!) == 3) {
                     Utility.shared.cancelpolicy = "\((Utility.shared.getLanguage()?.value(forKey:"strict"))!)"
                    
                }
            
           // Utility.shared.cancelpolicy_content = "Cancel up to 1 day prior to arrival and get a 100% refund."
            cell.checkLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"cancellationPolicy"))!)"
            cell.flexLabel.text = "\(Utility.shared.cancelpolicy)"
            cell.flexLabel.textColor = Theme.PRIMARY_COLOR
            cell.selectionStyle = .none
            return cell
        }
       
        
        } else{
            if(indexPath.section == 0) {
                 
                 let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath)as! StatusCell
                 cell.selectionStyle = .none
                 if(getallreservationquery[indexVal].reservationState != nil) {
                 cell.statusLabel.text = Utility.shared.getbookingtype(type: getallreservationquery[indexVal].reservationState!)
                 } else {
                     cell.statusLabel.text = "Approved"
                 }
                 if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                                               {
                                                   let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                                                   let from_currency = getallreservationquery[indexVal].currency!
                                                   let total = Double(getallreservationquery[indexVal].total!) + Double(getallreservationquery[indexVal].guestServiceFee!)
                                                   let price_value = self.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:total)
                                                   let restricted_price =  Double(String(format: "%.2f",price_value))
                                                 cell.priceLabel.text = "\(getallreservationquery[indexVal].guests!) Guest\(getallreservationquery[indexVal].guests! > 1 ? "s" : "") . \(currencysymbol!)\(restricted_price!.clean)"
                                                 
                                                   
                                               }
                                               else
                                               {
                                                   let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                                                   let from_currency = getallreservationquery[indexVal].currency!
                                                   let total = Double(getallreservationquery[indexVal].total!) + Double(getallreservationquery[indexVal].guestServiceFee!)
                                                   let price_value = self.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate: Utility.shared.currency_Dict, amount:total)
                                                   let restricted_price =  Double(String(format: "%.2f",price_value))
                                                 cell.priceLabel.text = "\(getallreservationquery[indexVal].guests!) Guest\(getallreservationquery[indexVal].guests! > 1 ? "s" : "") . \(currencysymbol!)\(restricted_price!.clean)"
                                                  
                                               }
                 
                 return cell
             }
              else if(indexPath.section == 1) {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ListiprofileCell", for: indexPath)as! ListiprofileCell
                cell.listBtn.setTitle((self.getallreservationquery[indexVal].listData?.title!)!.firstUppercased, for: .normal)
                cell.listBtn.tag = indexVal
                cell.listBtn.addTarget(self, action: #selector(listBtnTapped(_:)), for: .touchUpInside)
                
             //   cell.titleLbel.text = (self.getallreservationquery[indexVal].listData?.title!)!.firstUppercased
                 cell.hostedLAbel.text = "Hosted by \((self.getallreservationquery[indexVal].hostData?.displayName!)!)"
                 if getallreservationquery[indexVal].hostData?.picture != nil
                 {
                     let profImage = (getallreservationquery[indexVal].hostData?.picture!)!
                   cell.profileImage.sd_setImage(with: URL(string:"\(IMAGE_AVATAR_MEDIUM)\(profImage)"), completed: nil)
                     
                 } else {
                    cell.profileImage.image  = #imageLiteral(resourceName: "unknown")
                 }
                cell.profileBtn.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
                 cell.selectionStyle = .none
                        return cell
                    } else if(indexPath.section == 2) {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath)as! CheckingCell
                 cell.selectionStyle = .none
                 cell.checkLabel.text = titleArray[indexPath.row]
                let inday = getdayValue(timestamp: getallreservationquery[indexVal].checkIn!)
                               let indate = getdateValue(timestamp: getallreservationquery[indexVal].checkIn!)
                               let outday = getdayValue(timestamp: getallreservationquery[indexVal].checkOut!)
                               let outdate = getdateValue(timestamp: getallreservationquery[indexVal].checkOut!)
                if(indexPath.row == 0) {
                               cell.flexLabel.text = "\(indate)"
                } else if(indexPath.row == 1) {
                     cell.flexLabel.text = "\(outdate)"
                } else {
                    if(getallreservationquery[indexVal].guests != nil) {
                        cell.flexLabel.text = "\(getallreservationquery[indexVal].guests!)"
                }
                }
                
                                   return cell
             } else if(indexPath.section == 3) {
                                       
                                       let cell = tableView.dequeueReusableCell(withIdentifier: "TripsoptionsCell", for: indexPath)as! TripsoptionsCell
         
                         cell.firstBtn.tag = indexVal
                         cell.secondBtn.tag = indexVal
                          cell.firstBtn.addTarget(self, action: #selector(messageBtnTapped), for: .touchUpInside)
                         cell.secondBtn.addTarget(self, action: #selector(ReceiptBtnTapped(_:)), for: .touchUpInside)
                         cell.selectionStyle = .none
                                       return cell
             }  else if(indexPath.section == 4) {
                 
                 let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath)as! CheckingCell
                cell.checkLabel.text = "Price"
                if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                                                         {
                                                             let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                                                             let from_currency = getallreservationquery[indexVal].currency!
                                                             let total = Double(getallreservationquery[indexVal].total!) + Double(getallreservationquery[indexVal].guestServiceFee!)
                                                             let price_value = self.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:total)
                                                             let restricted_price =  Double(String(format: "%.2f",price_value))
                                                           cell.flexLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                                           
                                                          
                                                         }
                                                         else
                                                         {
                                                             let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                                                             let from_currency = getallreservationquery[indexVal].currency!
                                                             let total = Double(getallreservationquery[indexVal].total!) + Double(getallreservationquery[indexPath.row].guestServiceFee!)
                                                             let price_value = self.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate: Utility.shared.currency_Dict, amount:total)
                                                             let restricted_price =  Double(String(format: "%.2f",price_value))
                                                           cell.flexLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                                                            
                                                         }
                 return cell
             }
             else{
               let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                   if((getallreservationquery[indexVal].cancellationPolicy!) == 1)
                        {
                          Utility.shared.cancelpolicy = "\((Utility.shared.getLanguage()?.value(forKey:"flexible"))!)"
                        
                        } else if((getallreservationquery[indexVal].cancellationPolicy!) == 2) {
                          Utility.shared.cancelpolicy = "\((Utility.shared.getLanguage()?.value(forKey:"moderate"))!)"
                            
                        } else if((getallreservationquery[indexVal].cancellationPolicy!) == 3) {
                             Utility.shared.cancelpolicy = "\((Utility.shared.getLanguage()?.value(forKey:"strict"))!)"
                            
                        }
                    
                   // Utility.shared.cancelpolicy_content = "Cancel up to 1 day prior to arrival and get a 100% refund."
                    cell.checkLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"cancellationPolicy"))!)"
                    cell.flexLabel.text = "\(Utility.shared.cancelpolicy)"
                cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                    cell.selectionStyle = .none
                    return cell
             }
            
        }
    }
    @objc func profileTapped(_ sender: UIButton)
    {
        if Utility().isConnectedToNetwork(){
      if(((Utility.shared.getCurrentUserToken()) != nil) && (Utility.shared.getCurrentUserToken() != ""))
        {
        let editprofileobj = HostProfileViewPage()
        editprofileobj.profileid = ((self.getallreservationquery[indexVal].hostData?.profileId!)!)
            editprofileobj.profilename = "\((self.getallreservationquery[indexVal].hostData?.displayName!)!)"
        editprofileobj.showprofileAPICall(profileid:((self.getallreservationquery[indexVal].hostData?.profileId!)!))
        editprofileobj.modalPresentationStyle = .fullScreen
        self.present(editprofileobj, animated: true, completion: nil)
        }
        } }
    @objc func cancelBtnTapped(_ sender: UIButton)
    {
         if Utility().isConnectedToNetwork(){
            if(getallreservationquery.count > 0)
            {
            
        let cancelObj = TripsCancelVC()
        cancelObj.listID = getallreservationquery[sender.tag].listId!
        var currency = String()
        
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                {
        currency = Utility.shared.getPreferredCurrency()!
        }
        else{
          currency = Utility.shared.currencyvalue_from_API_base
        }
        cancelObj.checkinDate =  getdateValue(timestamp: getallreservationquery[sender.tag].checkIn!)
        cancelObj.checkoutDate = getdateValue(timestamp: getallreservationquery[sender.tag].checkOut!)
        cancelObj.getcancellationAPICall(reservationId: getallreservationquery[sender.tag].id!, userType: GUEST, currency: currency)
        Utility.shared.host_cancel_isfromCancel = false
        cancelObj.modalPresentationStyle = .fullScreen
        self.present(cancelObj, animated: true, completion: nil)
            }
        }}
    @objc func listBtnTapped(_ sender: UIButton){
           let guestdetailObj = GuestDetailVC()
           if(getallreservationquery.count > 0)
           {
           guestdetailObj.listID = getallreservationquery[sender.tag].listId!
           Utility.shared.unpublish_preview_check = false
           guestdetailObj.currencyvalue_from_API_base = Utility.shared.currencyvalue_from_API_base
           guestdetailObj.currency_Dict = Utility.shared.currency_Dict
             guestdetailObj.modalPresentationStyle = .fullScreen
           self.present(guestdetailObj, animated: true, completion: nil)
           }
       }
   @objc func messageBtnTapped(_ sender: UIButton)
    {
         if Utility().isConnectedToNetwork(){
        if(getallreservationquery.count > 0)
        {
        let InboxListingObj = InboxListingVC()
        Utility.shared.ListID = "\(getallreservationquery[sender.tag].listId!)"
        InboxListingObj.threadId = (getallreservationquery[sender.tag].messageData?.id)!
        InboxListingObj.getmessageListquery.removeAll()
        InboxListingObj.getMessageListAPICall(threadId:(getallreservationquery[sender.tag].messageData?.id)!)
           InboxListingObj.modalPresentationStyle = .fullScreen
        self.present(InboxListingObj, animated: true, completion: nil)
        }
        }
    }
    @objc func IteneraryBtnTapped(_ sender: UIButton)
       {
           Utility.shared.isfromTripsPage = true
           if(getallreservationquery.count > 0)
           {
           self.getReservationAPICall(reservationid:getallreservationquery[sender.tag].id!)
           }
       }
    @objc func ReceiptBtnTapped(_ sender: UIButton)
    {
        sender.isMultipleTouchEnabled = false
        sender.isExclusiveTouch = true
        sender.isUserInteractionEnabled = false
       if(getallreservationquery.count > 0)
       {
        self.createReservationAPICall(reservationid:getallreservationquery[sender.tag].id!)
        }
    }
    func createReservationAPICall(reservationid:Int)
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
        let createReservationquery = GetReservationQuery(reservationId: reservationid,convertCurrency:currency)
        apollo_headerClient.fetch(query: createReservationquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getReservation?.results) != nil else{
                print("Missing Data")
                
                return
            }
            self.getReservationArray = (result?.data?.getReservation?.results)!
            self.getReservation_currencyArray = (result?.data?.getReservation!)!
            if #available(iOS 11.0, *) {
                let receiptPageObj = ReceiptVC()
                 Utility.shared.host_isfrom_hostRecipt = false
                receiptPageObj.getReservation_currencyArray = self.getReservation_currencyArray
                receiptPageObj.getReservationArray = self.getReservationArray
               receiptPageObj.modalPresentationStyle = .overFullScreen
                self.view.window?.rootViewController?.present(receiptPageObj, animated:false, completion: nil)
               // self.present(receiptPageObj, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        }
        
        
    }
    func getReservationAPICall(reservationid:Int)
    {
         if Utility().isConnectedToNetwork(){
        let createReservationquery = GetReservationQuery(reservationId: reservationid)
        apollo_headerClient.fetch(query: createReservationquery){(result,error) in
            guard (result?.data?.getReservation?.results) != nil else{
                print("Missing Data")
                return
            }
            self.getReservationArray = (result?.data?.getReservation?.results)!
            self.getReservation_currencyArray = (result?.data?.getReservation!)!
            if #available(iOS 11.0, *) {
                let receiptPageObj = BookingItenaryVC()
                receiptPageObj.getReservation_currencyArray = self.getReservation_currencyArray
                receiptPageObj.getReservationArray = self.getReservationArray
                  receiptPageObj.modalPresentationStyle = .fullScreen
                self.present(receiptPageObj, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        }
         
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(getallreservationquery[indexVal].reservationState! == "approved") {
            if(indexPath.section == 2 || indexPath.section == 5) {
            return 70
        }  else if(indexPath.section == 6) {
            return 70
        }
            return UITableView.automaticDimension }
        else {
            if(indexPath.section == 2 || indexPath.section == 4) {
                return 70
            }  else if(indexPath.section == 5) {
                return 70
            }
            return UITableView.automaticDimension }
        
    }
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    func getCurrencyRate(basecurrency:String,fromCurrency:String,toCurrency:String,CurrencyRate:NSDictionary,amount:Double) -> Double
    {
        if(!(CurrencyRate.count == 0))
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
        return 0
        
    }
    func getdateValue(timestamp:String) -> String
    {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
        let date = dateFormatter.string(from: showDate)
        return date
    }
    
    func getdayValue(timestamp:String) -> String
    {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "EEE"
        dateFormatter1.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
        let day = dateFormatter1.string(from: showDate)
        return day
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
