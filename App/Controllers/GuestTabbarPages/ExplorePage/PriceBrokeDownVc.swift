
import UIKit

class PriceBrokeDownVc: UIViewController {
    @IBOutlet weak var containerVw: UIView!
    
    @IBOutlet weak var closeImg: UIImageView!
    @IBOutlet weak var closeVw: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var nightsLbl: UILabel!
    @IBOutlet weak var nightsRateLbl: UILabel!
    
    @IBOutlet weak var cleaningLbl: UILabel!
    @IBOutlet weak var cleaningRateLbl: UILabel!
    
    @IBOutlet weak var servicelbl: UILabel!
    @IBOutlet weak var serviceRateLbl: UILabel!
    
    @IBOutlet weak var totalRateLbl: UILabel!
    @IBOutlet weak var totalPriceLbl: UILabel!
    
    @IBOutlet weak var disVw: UIView!
    @IBOutlet weak var disLbl: UILabel!
    @IBOutlet weak var disRateLbl: UILabel!
    
    var filterData = SearchListingQueryy.Data.SearchListing.Result()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.contentView.halfroundedCorners(corners: [.topLeft, .topRight], radius: 20.0)
        self.contentView.backgroundColor = .appColor()
        
        [nightsRateLbl, cleaningRateLbl, serviceRateLbl, totalRateLbl, titleLbl, cleaningLbl, servicelbl, totalPriceLbl, nightsLbl, disLbl].forEach { labels in
            labels?.textColor = .textColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    fileprivate func setupUI() {
        contentView.halfroundedCorners(corners: [.topLeft, .topRight], radius: 20.0)
        
        [closeVw, containerVw].forEach { vws in
            vws?.addTap {
                self.dismiss(animated: true)
            }
        }
        containerVw.addTap {
            self.dismiss(animated: true)
        }
        
        titleLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "price_break_down") ?? "Price breakdown")"
        cleaningLbl.text =  "\(Utility.shared.getLanguage()?.value(forKey: "cleaning_fee") ?? "Cleaning fee")"
        servicelbl.text =  "\(Utility.shared.getLanguage()?.value(forKey: "service_fee") ?? "Service fee")"
        totalPriceLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "tot_before_tax") ?? "Total before taxes")".capitalized
        disLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "dis_count") ?? "Discounts")"
        
        if Utility.shared.isRTLLanguage() {
            
            [nightsRateLbl, cleaningRateLbl, serviceRateLbl, totalRateLbl, disRateLbl].forEach { labels in
                labels?.textAlignment = .left
            }
            
            [titleLbl, cleaningLbl, servicelbl, totalPriceLbl, nightsLbl, disLbl].forEach { labels in
                labels?.textAlignment = .right
            }
        } else {
            [nightsRateLbl, cleaningRateLbl, serviceRateLbl, totalRateLbl, disRateLbl].forEach { labels in
                labels?.textAlignment = .right
            }
            
            [titleLbl, cleaningLbl, servicelbl, totalPriceLbl, nightsLbl, disLbl].forEach { labels in
                labels?.textAlignment = .left
            }
        }
    }
    
    func setupData() {
        guard let oneTotPri = filterData.listingData?.oneTotalPrice else { return }
        guard let curreny = filterData.listingData?.currency else { return }
       
        let days = oneTotPri.dayDifference ?? 0
        
        var currency = String()
        if(Utility.shared.getPreferredCurrency() == nil)
        {
            currency = Utility.shared.currencyvalue_from_API_base
        }
        else{
            currency = Utility.shared.getPreferredCurrency()!
        }
        
        let tot_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:curreny, toCurrency: currency, CurrencyRate:Utility.shared.currency_Dict, amount:oneTotPri.oneTotalPrice!)
        let total_price =  Double(String(format: "%.2f",tot_value))
        
        let average = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:curreny, toCurrency: currency, CurrencyRate:Utility.shared.currency_Dict, amount: oneTotPri.isAverage!)
        let average_price =  Double(String(format: "%.2f",average))
        
        let service = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:curreny, toCurrency: currency, CurrencyRate:Utility.shared.currency_Dict, amount: oneTotPri.serviceFee!)
        let service_price =  Double(String(format: "%.2f",service))
        
        let cleaning = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:curreny, toCurrency: currency, CurrencyRate:Utility.shared.currency_Dict, amount: oneTotPri.cleaningPrice!)
        let cleaning_price =  Double(String(format: "%.2f",cleaning))
        
        let night = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:curreny, toCurrency: currency, CurrencyRate:Utility.shared.currency_Dict, amount: oneTotPri.isDayTotal!)
        let night_price =  Double(String(format: "%.2f",night))
        
        let discount = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:curreny, toCurrency: currency, CurrencyRate:Utility.shared.currency_Dict, amount: oneTotPri.discount!)
        let discount_price =  Double(String(format: "%.2f",discount))
        
        if(Utility.shared.getPreferredCurrency() != nil &&  Utility.shared.getPreferredCurrency() != "") {
            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
            if days == 1 {
                nightsLbl.text = "\(currencysymbol!)\(average_price!.clean) x \(days) \(Utility.shared.getLanguage()?.value(forKey: "night") ?? "nights")"
            } else {
                nightsLbl.text = "\(currencysymbol!)\(average_price!.clean) x \(days) \(Utility.shared.getLanguage()?.value(forKey: "nights") ?? "nights")"
            }
            nightsRateLbl.text = "\(currencysymbol!)\(night_price!.clean)"
            cleaningRateLbl.text = "\(currencysymbol!)\(cleaning_price!.clean)"
            serviceRateLbl.text = "\(currencysymbol!)\(service_price!.clean)"
            totalRateLbl.text  =  "\(currencysymbol!)\(total_price!.clean)"
            if Utility.shared.isRTLLanguage() {
                disRateLbl.text = "\(currencysymbol!) \(discount_price!.clean)   -"
            } else {
                disRateLbl.text = "-   \(currencysymbol!) \(discount_price!.clean)"
            }
        } else {
            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
            if days == 1 {
                nightsLbl.text = "\(currencysymbol!)\(average_price!.clean) x \(days) \(Utility.shared.getLanguage()?.value(forKey: "night") ?? "nights")"
            } else {
                nightsLbl.text = "\(currencysymbol!)\(average_price!.clean) x \(days) \(Utility.shared.getLanguage()?.value(forKey: "nights") ?? "nights")"
            }
            nightsRateLbl.text = "\(currencysymbol!)\(night_price!.clean)"
            cleaningRateLbl.text = "\(currencysymbol!)\(cleaning_price!.clean)"
            serviceRateLbl.text = "\(currencysymbol!)\(service_price!.clean)"
            totalRateLbl.text  =  "\(currencysymbol!)\(total_price!.clean)"
            if Utility.shared.isRTLLanguage() {
                disRateLbl.text = "\(currencysymbol!) \(discount_price!.clean)   -"
            } else {
                disRateLbl.text = "-   \(currencysymbol!) \(discount_price!.clean)"
            }
        }

        disVw.isHidden = oneTotPri.discount ?? 0 == 0 ? true : false
    }
}
