
import UIKit
import Apollo
import IQKeyboardManagerSwift
import Toast_Swift

protocol AvailabilityHostVCDelegate {
    func BlockedlistAPICall(listId:Int)
    func APICall(listImage:String,title:String,entireTitle:String,listId:Int)
}


class AvailabilityHostVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,SpecialTextFieldCellDelegate {
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var errorLabel : UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet weak var calenadarAvailableTable: UITableView!
    @IBOutlet weak var topView: UIView!
    var listId = Int()
    var listImage = String()
    var title_val = String()
    var entireTitle = String()
    var titleArray = NSMutableArray()
    var selected:Bool = false
    var specialPrice = Double()
    var startDate = String()
    var endDate = String()
    var special = String()
    var currency = String()
    let characterset = NSCharacterSet(charactersIn: "0123456789.")
    
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var delegate:AvailabilityHostVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    func initialSetup() {
        calenadarAvailableTable.register(UINib(nibName:"BlockCalendarCell", bundle: nil), forCellReuseIdentifier: "BlockCalendarCell")
        calenadarAvailableTable.register(UINib(nibName: "SpecialTextFieldCell", bundle: nil), forCellReuseIdentifier: "SpecialTextFieldCell")
        calenadarAvailableTable.register(UINib(nibName: "HostAvailCell", bundle: nil), forCellReuseIdentifier: "HostAvailCell")
        titleArray = ["\(Utility.shared.getLanguage()?.value(forKey:"Make_Available") ?? "Make Available")","\(Utility.shared.getLanguage()?.value(forKey:"Block_selected_date") ?? "Block selected dates")"]
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        nextBtn.backgroundColor = Theme.Button_BG
        self.offlineView.isHidden = true
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        
        self.view.backgroundColor =   UIColor(named: "colorController")
        
        IQKeyboardManager.shared.enable = true
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"save"))!)", for:.normal)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_SEMIBOLD, size: 16)
        
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            if(( special == "." || special.rangeOfCharacter(from: characterset.inverted) != nil ) && !selected) {
                if(special == "." || special.rangeOfCharacter(from: characterset.inverted) != nil) {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"valid_special"))!)")
                }else{
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"specialpricealert"))!)")
                }
                
            } else {
                if(!selected) {
                    if(specialPrice == 0.0){
                        SaveAPICall(listid: listId, blockedDates: Utility.shared.host_selected_dates_Array as! [String], calendarStatus: "available")
                    }else{
                        SaveAPICall(listid: listId, blockedDates:Utility.shared.host_selected_dates_Array as! [String], calendarStatus: "available",isSpecialPrice:specialPrice)
                    }
                } else {
                    SaveAPICall(listid: listId, blockedDates:Utility.shared.host_selected_dates_Array as! [String], calendarStatus: "blocked", isSpecialPrice:0.0)
                    
                    
                }
                
            }
        } else {
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    func SaveAPICall(listid:Int,blockedDates:[String],calendarStatus:String,isSpecialPrice:Double) {
        let updateSpecialPriceMutation = UpdateSpecialPriceMutation(listId: listid, blockedDates: blockedDates, calendarStatus: calendarStatus, isSpecialPrice: isSpecialPrice)
        apollo_headerClient.perform(mutation: updateSpecialPriceMutation){(result,error) in
            if(result?.data?.updateSpecialPrice?.status == 200) {
                
                Utility.shared.isfrom_availability_calendar_date = true
                Utility.shared.isfrom_availability_calendar = true
                self.delegate?.BlockedlistAPICall(listId: self.listId)
                self.delegate?.APICall(listImage: self.listImage, title: self.title_val, entireTitle: self.entireTitle, listId: self.listId)
                self.dismiss(animated: true, completion: nil)
                
            } else {
                self.view.makeToast(result?.data?.updateSpecialPrice?.errorMessage)
            }
        }
    }
    func SaveAPICall(listid:Int,blockedDates:[String],calendarStatus:String) {
        let updateSpecialPriceMutation = UpdateSpecialPriceMutation(listId: listid, blockedDates: blockedDates, calendarStatus: calendarStatus, isSpecialPrice: nil)
        apollo_headerClient.perform(mutation: updateSpecialPriceMutation){(result,error) in
            if(result?.data?.updateSpecialPrice?.status == 200) {
                Utility.shared.isfrom_availability_calendar_date = true
                Utility.shared.isfrom_availability_calendar = true
                self.delegate?.BlockedlistAPICall(listId: self.listId)
                self.delegate?.APICall(listImage: self.listImage, title: self.title_val, entireTitle: self.entireTitle, listId: self.listId)
                self.dismiss(animated: true, completion: nil)
                
            } else {
                self.view.makeToast(result?.data?.updateSpecialPrice?.errorMessage)
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        
    }
    
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            Utility.shared.isfrom_availability_calendar_date = true
            Utility.shared.isfrom_availability_calendar = true
            self.dismiss(animated: true, completion: nil)
        } else {
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
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
    
    func numberOfSections(in tableView: UITableView) -> Int{
        if(selected == true) {
            return 2
        }
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(selected == true)
        {
            if(section == 0){return 1}
            if(section == 1){return 2}
        } else {
            if(section == 0){return 1}
            if(section == 1){return 2}
            if(section == 2){return 1}
            
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HostAvailCell", for: indexPath) as! HostAvailCell
            cell.selectionStyle = .none
            if(startDate == endDate) {
                cell.dateLabel.text = "\(startDate)"
            } else {
                cell.dateLabel.text = "\(startDate) - \(endDate)"
            }
            return cell
        } else if(indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlockCalendarCell", for: indexPath) as! BlockCalendarCell
            cell.selectionStyle = .none
            if(startDate == endDate) {
                if(indexPath.row == 1) {
                    cell.titleLabel.text = "Block selected date"
                } else {
                    cell.titleLabel.text = (titleArray[indexPath.row] as! String)
                }
            } else {
                cell.titleLabel.text = (titleArray[indexPath.row] as! String)
            }
            if(indexPath.row == 0){
                cell.lineLabel.isHidden = false
                if(selected == true)
                {
                    cell.verifyImg.image = #imageLiteral(resourceName: "price_unclick")
                } else {
                    
                    cell.verifyImg.image = #imageLiteral(resourceName: "verify-round")
                }
            } else {
                cell.lineLabel.isHidden = true
                if(selected == true)
                {
                    cell.verifyImg.image = #imageLiteral(resourceName: "verify-round")
                } else {
                    cell.verifyImg.image = #imageLiteral(resourceName: "price_unclick")
                }
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialTextFieldCell", for:indexPath) as! SpecialTextFieldCell
            cell.selectionStyle = .none
            cell.delegate = self
            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:self.currency)
            cell.currencyLabel.text = "\(currencysymbol ?? "$")"
            cell.specialTF.autocorrectionType = UITextAutocorrectionType.no
            cell.specialTF.addTarget(self, action: #selector(specialPricing(field:)), for: .editingDidEnd)
            let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
            cell.specialTF.inputAccessoryView = toolBar
            toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
            cell.specialTF.delegate = self
            return cell
        }
        
    }
    @objc func dismissgenderPicker() {
        view.endEditing(true)
        
    }
    @objc func specialPricing(field: UITextField){
        
        if ((field.text?.containsNonEnglishNumbersChecking) != nil) {
            field.text = field.text?.english.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if(field.text == "." || field.text?.rangeOfCharacter(from: characterset.inverted) != nil || field.text?.containsNothing == true)
            {
                self.view.endEditing(true)
                
            }else{
                specialPrice = Double(field.text!) as! Double
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1) {
            if(indexPath.row == 0) {
                selected = false
            } else {
                selected = true
            }
        }
        calenadarAvailableTable.reloadData()
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        special = textField.text!
        if(textField.text == "") {
            specialPrice = 0.0
        } else{
            if(textField.text != ".") {
                
                if textField.text!.rangeOfCharacter(from: characterset.inverted) != nil || textField.text!.isEmpty{
                    
                    if textField.text!.isEmpty{
                        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"specialpricealert"))!)")
                    }else{
                        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"valid_special"))!)")
                    }
                    
                }else{
                    specialPrice = Double("\(textField.text!)") as! Double
                }
                
            } else {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"valid_special"))!)")
            }
            
            
        }
    }
    
    func didChangeText(text: String?, cell: SpecialTextFieldCell) {
        if(text == "") {
            specialPrice = 0.0
        } else {
            if text!.rangeOfCharacter(from: characterset.inverted) != nil || text!.isEmpty{
            }else{
                specialPrice = Double("\(text!)") as! Double
            }
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if(textField.text!.contains(".") && string == ".") || range.length + range.location > currentCharacterCount
        {
            return false
        } else {
            let newlength = currentCharacterCount + string.count - range.length
            return newlength <= 6
        }
    }
}
