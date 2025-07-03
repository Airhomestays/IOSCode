
import UIKit
import SwiftMessages

protocol CalendarDetailVCDelegate {
    func BlockedlistAPICall(listId:Int)
    func APICall(listImage:String,title:String,entireTitle:String,listId:Int)
    
}

class CalendarDetailVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "CalendarDetailVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    @IBOutlet weak var nodetailLabel: UILabel!
    @IBOutlet weak var noView: UIView!
    @IBOutlet weak var calendarDetailTable: UITableView!
    @IBOutlet weak var topView: UIView!
    var listId = Int()
    var listImage = String()
    var title_val = String()
    var entireTitle = String()
    var delegate:CalendarDetailVCDelegate!
    
    
    @IBOutlet var backBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialsetup()
    }
    
    func initialsetup() {
        self.view.backgroundColor =  UIColor(named: "colorController")
        noView.backgroundColor = UIColor(named: "colorController")
        topView.backgroundColor =  UIColor(named: "colorController")
        self.calendarDetailTable.backgroundColor = UIColor(named: "colorController")
        self.calendarDetailTable.register(UINib(nibName: "CalendardetailCell", bundle: nil), forCellReuseIdentifier: "CalendardetailCell")
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        if(Utility.shared.host_blockedDates_Array.count == 0 && Utility.shared.host_bookedPricing_Array.count == 0 && Utility.shared.host_specialPricing_Array.count == 0) {
            self.noView.isHidden = false
        } else {
            self.noView.isHidden = true
        }
        nodetailLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"dontcalendardetail"))!)"
        nodetailLabel.font = UIFont(name: APP_FONT, size: 17)
        nodetailLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        
    }
    @IBAction func closeBtnTapped(_ sender: Any) {
        
        Utility.shared.isfrom_availability_calendar_date = true
        Utility.shared.isfrom_availability_calendar = true
        self.delegate?.BlockedlistAPICall(listId: self.listId)
        self.delegate?.APICall(listImage: self.listImage, title: self.title_val, entireTitle: self.entireTitle, listId: self.listId)
        self.dismiss(animated: true, completion: nil)
        
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            if(Utility.shared.host_bookedPricing_Array.count > 0)
            {
                return Utility.shared.host_bookedPricing_Array.count
            }
            return 0
        } else if(section == 1) {
            if(Utility.shared.host_specialPricing_Array.count > 0)
            {
                return Utility.shared.host_specialPricing_Array.count
            }
            return 0
        } else {
            if(Utility.shared.host_blockedDates_Array.count > 0) {
                return Utility.shared.host_blockedDates_Array.count
            }
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String?{
        if(section == 0){
            if(Utility.shared.host_bookedPricing_Array.count > 0) {
                return "\((Utility.shared.getLanguage()?.value(forKey:"bookeddates"))!)"
            }
            return ""
        } else if(section == 1 ){
            if(Utility.shared.host_specialPricing_Array.count > 0) {
                return "\((Utility.shared.getLanguage()?.value(forKey:"splprice"))!)"
            }
            return ""
        } else if(section == 2){
            if(Utility.shared.host_blockedDates_Array.count > 0) {
                return "\((Utility.shared.getLanguage()?.value(forKey:"notavailabledates"))!)"
            }
            return ""
        }
        
        return ""
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if(Utility.shared.host_blockedDates_Array.count > 0 || Utility.shared.host_bookedPricing_Array.count > 0 || Utility.shared.host_specialPricing_Array.count > 0) {
            return 3
        }
        return 0
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if(section == 0) {
            if(Utility.shared.host_bookedPricing_Array.count > 0)
            {
                return 30
            } else {
                return CGFloat.leastNormalMagnitude
            }
            
        } else if(section == 1) {
            if(Utility.shared.host_specialPricing_Array.count > 0)
            {
                return 25
            } else {
                return CGFloat.leastNormalMagnitude
            }
            
        } else {
            if(Utility.shared.host_blockedDates_Array.count > 0)
            {
                return 25
            } else {
                return CGFloat.leastNormalMagnitude
            }
            
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x:10, y:0, width:
                                                tableView.bounds.size.width, height:50))
        headerView.backgroundColor = UIColor.clear
        let headerLabel = UILabel(frame: CGRect(x:25, y:10, width:
                                                    tableView.bounds.size.width-50, height:30))
        
        headerLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        headerLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size:18)
        headerLabel.textColor = UIColor(named: "Title_Header")
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendardetailCell", for: indexPath) as! CalendardetailCell
            
            cell.dateLabel.text = "\(Utility.shared.host_bookedPricing_Array[indexPath.row])(\(Utility.shared.host_bookDay_Array[indexPath.row]))"
            cell.priceLabel.text = ""
            cell.priceLabel.textColor = Theme.PRIMARY_COLOR
            
            cell.dateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            cell.priceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            return cell
        } else if(indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendardetailCell", for: indexPath) as! CalendardetailCell
            
            cell.priceLabel.isHidden = false
            cell.dateLabel.text = "\(Utility.shared.host_specialPricing_Array[indexPath.row]) (\(Utility.shared.host_specialDay_Array[indexPath.row]))"
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "") {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                let from_currency = "\(Utility.shared.host_currency_Array[indexPath.row])"
                let currency_amount = Utility.shared.host_specialPrice_value_Array[indexPath.row]
                let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:currency_amount as! Double)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                cell.priceLabel.text =  "\(currencysymbol!)\(restricted_price!.clean)"
                cell.priceLabel.textColor = Theme.PRIMARY_COLOR
                cell.dateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
                cell.priceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            } else {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.host_currency_Array[indexPath.row] as! String)
                let from_currency = "\(Utility.shared.host_currency_Array[indexPath.row])"
                let currency_amount = Utility.shared.host_specialPrice_value_Array[indexPath.row]
                let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate:Utility.shared.currency_Dict, amount:currency_amount as! Double)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                cell.priceLabel.textColor = Theme.PRIMARY_COLOR
                cell.dateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
                cell.priceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendardetailCell", for: indexPath) as! CalendardetailCell
            cell.dateLabel.text = "\(Utility.shared.host_blockedDates_Array[indexPath.row]) (\(Utility.shared.hosr_blockDay_Array[indexPath.row]))"
            cell.priceLabel.text = ""
            cell.priceLabel.textColor = Theme.PRIMARY_COLOR
            cell.dateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            cell.priceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            return cell
        }
    }
}
