
import UIKit
import IQKeyboardManagerSwift
import Lottie
import SwiftMessages

protocol CountryDelegate {
    func setSelectedCountry(selectedCountry : String, selectedcountryCode : String,selectdialcode : String)
}

class CountrycodeVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
   
    var completionHandlerGoToPayoutDetailss:((Int)->())?
    @IBOutlet var viewContainer: UIView!
    @IBOutlet weak var countryTable: UITableView!
    @IBOutlet weak var searchTF: CustomUITextField!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var label: UILabel!
     @IBOutlet var bottomConstraint: NSLayoutConstraint!
   
    var countrycodeArray = [GetCountrycodeQuery.Data.GetCountry.Result]()
    var titleForHeader = "\((Utility.shared.getLanguage()?.value(forKey:"selectcountry"))!)"
    var tabFilterData = [[String : Any]]()
    var countryStringArr = [String]()
    var lottieView: LottieAnimationView!
    var delegate : CountryDelegate?
    var isFromPayoutRefrence : Bool = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        searchTF.font = UIFont(name: APP_FONT, size: 14)
        
        searchTF.tintColor = UIColor(named: "Title_Header")
        searchTF.addTarget(self, action: #selector(CountrycodeVC.textFieldDidChange(_:)),
        for: UIControl.Event.editingChanged)
        self.initialSetup()
        self.CountryAPICAll()
         self.lottieAnimation()
    }
    @objc func dismissview() {
           view.endEditing(true)
           
       }
    
    func initialSetup()
    {
        self.topView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 64)
        self.countryTable.frame = CGRect(x: 0, y: 64, width: FULLWIDTH, height: FULLHEIGHT-64)
        countryTable.register(UINib(nibName: "EditAboutCell", bundle: nil), forCellReuseIdentifier: "EditAboutCell")
        viewContainer.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        viewContainer.layer.borderWidth = 1.0
        viewContainer.layer.cornerRadius = 5.0
        viewContainer.layer.masksToBounds = true
        
        self.view.backgroundColor = UIColor(named: "colorController")
        
        
        countryTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        searchTF.delegate = self
        searchTF.keyboardType = .asciiCapable
        searchTF.autocorrectionType = .no
        
        searchTF.textColor =  UIColor(named: "Title_Header")
       
        IQKeyboardManager.shared.enable = true
         IQKeyboardManager.shared.enableAutoToolbar = false
        searchTF.placeholder = "\((Utility.shared.getLanguage()?.value(forKey:"searchcountry"))!)"
        if(Utility.shared.isRTLLanguage())
        {
            searchTF.textAlignment = .right
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchTF.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
         let info = sender.userInfo!
         let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
         let keyboardHeight = keyboardFrame.height
      bottomConstraint.constant = keyboardHeight
         
     }
     
     @objc func keyboardWillHide(sender: NSNotification) {
    
         
     }

    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            self.completionHandlerGoToPayoutDetailss?(1)
        }
    }
    
    
    func CountryAPICAll()
    {
        let getcountrycodeQuery = GetCountrycodeQuery()
        apollo.fetch(query: getcountrycodeQuery){(result,error) in
            guard (result?.data?.getCountries?.results) != nil else{
                return
            }
            self.countrycodeArray =  ((result?.data?.getCountries?.results)!) as! [GetCountrycodeQuery.Data.GetCountry.Result]
             self.lottieView.isHidden = true
            self.countryTable.reloadData()
           
            
        }
    }
    
    @objc func dismissPicker()
    {
        self.dismiss(animated: true, completion: nil)
        
        
    }
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-150, width:100, height:100)
        self.countryTable.addSubview(self.lottieView)
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
    func numberOfSections(in tableView: UITableView) -> Int {
        if(countrycodeArray.count > 0)
        {
            return 1
        }
        else{
            return 0
        }
        
    }
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String?
    {
        if(section == 0)
        {
            if(countrycodeArray.count > 0)
            {
                if !Utility.shared.isPhonenumberCountrycode
                {
                    return titleForHeader
                }
                return "\((Utility.shared.getLanguage()?.value(forKey:"regionnumber"))!)"
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        
       
        if(Utility.shared.isRTLLanguage())
        {
            let headerLabel = UILabel(frame: CGRect(x:(FULLWIDTH/4.5), y: 10, width: FULLWIDTH,height: 40))
            headerLabel.font = UIFont(name: APP_FONT_MEDIUM, size:24)
            headerLabel.textColor =  UIColor(named: "Title_Header")
            headerLabel.numberOfLines = 4
            headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
            headerLabel.textAlignment = .right
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }else
        {
            let headerLabel = UILabel(frame: CGRect(x:20, y:10, width:FULLWIDTH-35, height: 40))
            headerLabel.font = UIFont(name: APP_FONT_MEDIUM, size:24)
            headerLabel.textColor =  UIColor(named: "Title_Header")
            headerLabel.numberOfLines = 4
            headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
            headerLabel.textAlignment = .left
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
        }
        
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section==0){
            
            if(countrycodeArray.count > 0)
            {
                if titleForHeader == "\((Utility.shared.getLanguage()?.value(forKey:"selectcountry"))!)"
                               {
            return 0
                }
                else
                {
                    return 80
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !(searchTF.text!.isEmpty) && tabFilterData.count > 0
        {
            return tabFilterData.count
        }
        if(countrycodeArray.count > 0)
        {
            return countrycodeArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditAboutCell", for: indexPath)as! EditAboutCell
        cell.phoneLabel.isHidden = true
        cell.appearanceImg.isHidden = true
        cell.height.constant = 0
        cell.width.constant = 0
        cell.rightArrowimg.isHidden = true
        cell.editLabel.isHidden = true
        cell.selectionStyle = .none
        cell.aboutLabel.font = UIFont(name: APP_FONT, size: 14)
        if titleForHeader == "\((Utility.shared.getLanguage()?.value(forKey:"selectcountry"))!)"
        {
            if !(searchTF.text!.isEmpty) && tabFilterData.count > 0 && (indexPath.row < tabFilterData.count)
            {
               
                cell.aboutLabel.text = "\(tabFilterData[indexPath.row]["countryName"] ?? "")"
                
            }else{
                cell.aboutLabel.text = "\(countrycodeArray[indexPath.row].countryName != nil ? countrycodeArray[indexPath.row].countryName! : "")"
            }
        }else{
            cell.aboutLabel.text = "\(countrycodeArray[indexPath.row].countryName != nil ? countrycodeArray[indexPath.row].countryName! : "")"
        }
        cell.aboutLabel.textColor =  UIColor(named: "Title_Header")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if titleForHeader == "\((Utility.shared.getLanguage()?.value(forKey:"selectcountry"))!)"
        {
            if !(searchTF.text!.isEmpty) && tabFilterData.count > 0
            {
                delegate?.setSelectedCountry(selectedCountry: tabFilterData[indexPath.row]["countryName"] as! String, selectedcountryCode: tabFilterData[indexPath.row]["countryCode"] as! String, selectdialcode: tabFilterData[indexPath.row]["countrydialcode"] as! String)
                
                
                if(isFromPayoutRefrence) {
                let payaddressObj = PayoutAddressVC()
                    
//                    payaddressObj.completionHandlerGoToPayoutDetails = { result in
//                        DispatchQueue.main.async {
//                            self.goToPayout()
//                        }
//                    }
                    
                payaddressObj.countryText = tabFilterData[indexPath.row]["countryName"] as! String
                payaddressObj.modalPresentationStyle = .fullScreen
                self.present(payaddressObj, animated: true, completion: nil)
                }
            }else{
                delegate?.setSelectedCountry(selectedCountry: countrycodeArray[indexPath.row].countryName!, selectedcountryCode: countrycodeArray[indexPath.row].countryCode!, selectdialcode: countrycodeArray[indexPath.row].dialCode!)
                if(isFromPayoutRefrence) {
                let payaddressObj = PayoutAddressVC()
                    
//                    payaddressObj.completionHandlerGoToPayoutDetails = { result in
//                        DispatchQueue.main.async {
//                            self.goToPayout()
//                        }
//                    }
                    
                payaddressObj.countryText = countrycodeArray[indexPath.row].countryName!
                payaddressObj.modalPresentationStyle = .fullScreen
                self.present(payaddressObj, animated: true, completion: nil)
                }
                
            }
            if(!isFromPayoutRefrence) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
          if !(searchTF.text!.isEmpty) && tabFilterData.count > 0
            {
                delegate?.setSelectedCountry(selectedCountry: tabFilterData[indexPath.row]["countryName"] as! String, selectedcountryCode: tabFilterData[indexPath.row]["countryCode"] as! String, selectdialcode:  tabFilterData[indexPath.row]["countrydialcode"] as! String)
            }else{
            delegate?.setSelectedCountry(selectedCountry: countrycodeArray[indexPath.row].countryName!, selectedcountryCode: countrycodeArray[indexPath.row].countryCode!, selectdialcode: countrycodeArray[indexPath.row].dialCode!)
                
            }
        }
    }
    
    
//    func goToPayout() {
//        DispatchQueue.main.async {
//           // self.completionHandlerGoToPayoutDetailss?(1)
//            self.dismiss(animated: true)
//        }
//    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if(textField.text!.count == 0)
        {
         countryTable.isHidden = false
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText  = (textField.text?.trimmingCharacters(in: .whitespaces))! + string
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
       
             tabFilterData.removeAll()
        
        if !(newString.count <= 0) {
            countryTable.isHidden = false
            
            for index in 0..<countrycodeArray.count
            {
                if ((countrycodeArray[index].countryName!).lowercased().contains(searchText) || (countrycodeArray[index].countryName!).contains(searchText))
                {
                    var countryInfo = [String : Any]()
                    countryInfo.updateValue(countrycodeArray[index].countryName!, forKey: "countryName")
                    countryInfo.updateValue(countrycodeArray[index].countryCode!, forKey: "countryCode")
                    countryInfo.updateValue(countrycodeArray[index].dialCode!, forKey: "countrydialcode")
                    tabFilterData.append(countryInfo)
                    countryTable.isHidden = false
                       lottieView.isHidden = true
                }
            }
            
            if tabFilterData.count == 0 && newString.isBlank == false
            {
                     lottieView.isHidden = true
                countryTable.isHidden = true
                label.text = "\((Utility.shared.getLanguage()?.value(forKey:"notfound"))!)"
                if(Utility.shared.isRTLLanguage())
                {
                    label.textAlignment = .right
                }
            }
            countryTable.reloadData()
        }
        else{
            tabFilterData = []
            countryTable.reloadData()
        }
        return true
    }
    

}
extension UITextField {
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

        if action == #selector(UIResponderStandardEditActions.select(_:)) ||  action == #selector(UIResponderStandardEditActions.selectAll(_:))  || action == #selector(UIResponderStandardEditActions.cut(_:))  ||  action == #selector(UIResponderStandardEditActions.copy(_:))  || action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.responds(to:)) {
            return false
        }else{
            return super.canPerformAction(action, withSender: sender)
        }
    }
    var noText: Bool {
          return text?.isEmpty ?? true
      }
    
}

