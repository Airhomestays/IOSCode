

import UIKit
import Alamofire
import AVFoundation
import SwiftyJSON
import Lottie
import Apollo
import IQKeyboardManagerSwift
import SwiftMessages
import GoogleSignIn
import Apollo
import FirebaseCore

class EditProfileVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate{
   

    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var editProfileTable: UITableView!
    
    @IBOutlet weak var emailWrongView: UIView!
    @IBOutlet weak var emailexistView: UIView!
    @IBOutlet weak var emailAlertview: UIView!
    @IBOutlet weak var profileAlertView: UIView!
    @IBOutlet weak var offlineView: UIView!
    
    var google_btn_title = String()
    var facebook_btn_title = String()
    var email_btn_title = String()
    var is_fb_verify = Bool()
    var is_google_verify = Bool()
    var is_email_verify = Bool()
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var updateerrorLabel: UILabel!
    @IBOutlet weak var emailexistLabel: UILabel!
    @IBOutlet weak var emailrequireLabel: UILabel!
    @IBOutlet weak var profilerequireLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var editprofileTitleLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var imageData = NSData()
    var imgChanged:Bool = false
    var imgGalleryChanged:Bool = false
    var isFromFn:Bool = false
    var isFromln:Bool = false
    
    var pickedImage_profile = UIImage()
    let dateInputView = UIView()
    let genderInputView = UIView()
    var genderArray = [String]()
    var genderNewArray = [String]()
    let genderPicker = UIPickerView()
    var textfieldValueArray = NSMutableArray()
    var pickedimageString = String()
    var datePickerView = UIDatePicker()
    var date_value = Date()
   
    var lottieWholeView = UIView()
    var lottieView: LottieAnimationView!
    
    var DatePickerSender: Bool = false
    
    let apollo_headerClient: ApolloClient = {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
    let url = URL(string:graphQLEndpoint)!
        
    return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
        
    }()
    
     var EditProfileArray = GetProfileQuery.Data.UserAccount.Result()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.initialSetup()

        self.view.backgroundColor = UIColor(named: "colorController")
        if EditProfileArray.gender == "Male" {
            EditProfileArray.gender = "\(Utility.shared.getLanguage()?.value(forKey:"gender_male") ?? "Male")"
        }else if EditProfileArray.gender == "Female" {
            EditProfileArray.gender = "\(Utility.shared.getLanguage()?.value(forKey:"gender_female") ?? "Female")"
        }else if EditProfileArray.gender == "Other" {
            EditProfileArray.gender = "\(Utility.shared.getLanguage()?.value(forKey:"gender_other") ?? "Other")"
        }
        else {
            EditProfileArray.gender = ""
        }

        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = Theme.ButtonBack_BG
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if Utility().isConnectedToNetwork(){
        imgChanged = false
        self.imagePicker.setNavigationBarHidden(false, animated:false)
        DispatchQueue.main.async {
            if(!Utility.shared.isfromPhoneVC)
            {
                self.lottieAnimation()
                self.EdiprofileAPICall()

            }
            else
            {
                self.scrollToBottom()
               self.editProfileTable.reloadData()
            }

            }
        }
        else {
            
            self.lottieView.isHidden = true
            self.lottieWholeView.isHidden = true
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
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
        
    }
     func scrollToBottom() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row:0,section: 0)
            self.editProfileTable.scrollToRow(at: indexPath, at:.top, animated:false)
        }
        
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
        if Utility.shared.isConnectedToNetwork(){
            self.lottieView.play()
        }else{
            self.lottieView.isHidden = true
            self.lottieWholeView.isHidden = true
        }
        
    }
    
    func initialSetup()
    {
        self.offlineView.isHidden = true
        self.emailexistView.isHidden = true
        self.emailWrongView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        editProfileTable.register(UINib(nibName: "EditImageCell", bundle: nil), forCellReuseIdentifier: "EditImageCell")
        editProfileTable.register(UINib(nibName: "EditFirstLastName", bundle: nil), forCellReuseIdentifier: "editFirstLastName")
        editProfileTable.register(UINib(nibName: "UpdatedEditAboutCell", bundle: nil), forCellReuseIdentifier: "updatedEditAboutCell")
        editProfileTable.register(UINib(nibName: "EditnameCell", bundle: nil), forCellReuseIdentifier: "EditnameCell")
        editProfileTable.register(UINib(nibName: "VerifiedInfoCell", bundle: nil), forCellReuseIdentifier: "verifiedInfoCell")
        editProfileTable.register(UINib(nibName: "EditAboutCell", bundle: nil), forCellReuseIdentifier: "EditAboutCell")
         lottieView = LottieAnimationView.init(name: "loading_qwe")
        self.imagePicker.delegate = self
        self.emailAlertview.isHidden = true
        self.profileAlertView.isHidden = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
         self.datePickerInputView()
        if EditProfileArray.gender != nil && EditProfileArray.gender != ""

        {
            let index = genderArray.firstIndex(where: { (item) -> Bool in
                item == EditProfileArray.gender!
            })
            genderPicker.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            
        }else{
        }
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
    
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        updateerrorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"profileupdate_error"))!)"
         emailexistLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"emailexistserror"))!)"
         emailrequireLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"emailrequire"))!)"
         profilerequireLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"profilerequire"))!)"
         editprofileTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"editprofile"))!)"
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
       editprofileTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
    }
    
    func EdiprofileAPICall()
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
                    self.view.makeToast(result?.data?.userAccount?.errorMessage!)
                return
                }
            }
            
            Utility.shared.EditProfileArray  = ((result?.data?.userAccount?.result)!)
            self.EditProfileArray = ((result?.data?.userAccount?.result)!)

            if(self.EditProfileArray.preferredCurrency != nil){
                         Utility.shared.selectedCurrency = self.EditProfileArray.preferredCurrency!
                       }
        
            if self.EditProfileArray.gender == "Male" {
                self.EditProfileArray.gender = "\(Utility.shared.getLanguage()?.value(forKey:"gender_male") ?? "Male")"
            }else if self.EditProfileArray.gender == "Female" {
                self.EditProfileArray.gender = "\(Utility.shared.getLanguage()?.value(forKey:"gender_female") ?? "Female")"
            }else if self.EditProfileArray.gender == "Other" {
                self.EditProfileArray.gender = "\(Utility.shared.getLanguage()?.value(forKey:"gender_other") ?? "Other")"
            }
            else {
                self.EditProfileArray.gender = ""
            }

            self.lottieView.isHidden = true
            self.lottieWholeView.isHidden = true
            
            if self.isFromFn {
                self.isFromFn = false
                let indexPaths = IndexPath(row: 1, section: 0)
                self.editProfileTable.reloadRows(at:[indexPaths] , with: .none)
            }
           else if self.isFromln {
                self.isFromln = false
               let indexPaths = IndexPath(row: 2, section: 0)
               self.editProfileTable.reloadRows(at:[indexPaths] , with: .none)
            }
            else {
            self.editProfileTable.reloadData()
            }
        }
        
        
    }
    @IBAction func retryBtnTapped(_ sender: Any) {
        
        if Utility.shared.isConnectedToNetwork(){
            self.offlineView.isHidden = true
            self.uploadProfileimageService(imageBase64: self.imageData as Data)
        }
       
    }
    
    
    func datePickerInputView()
    {
        
        dateInputView.frame = CGRect(x: 0, y: FULLHEIGHT-200, width:FULLWIDTH, height: 200)
        genderInputView.frame = CGRect(x: 0, y: FULLHEIGHT-200, width: FULLWIDTH, height: 200)
        genderPicker.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 200)
        genderInputView.addSubview(genderPicker)
        genderArray.append("Male")
        genderArray.append("Female")
        genderArray.append("Other")
        genderNewArray.append("\(Utility.shared.getLanguage()?.value(forKey: "gender_male") ?? "Male")")
        genderNewArray.append("\(Utility.shared.getLanguage()?.value(forKey: "gender_female") ?? "Female")")
        genderNewArray.append("\(Utility.shared.getLanguage()?.value(forKey: "gender_other") ?? "Other")")
        genderPicker.delegate = self
        genderPicker.tintColor = Theme.PRIMARY_COLOR
        genderPicker.backgroundColor = UIColor(named: "colorController")
        genderPicker.reloadAllComponents()
        datePickerView.frame = CGRect(x: 0, y: 0, width:FULLWIDTH, height: 200)
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        if #available(iOS 14.0, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        } else {
        }

        dateInputView.addSubview(datePickerView)
        datePickerView.maximumDate = NSCalendar.current.date(byAdding: .year, value: -18, to: NSDate() as Date)
       
        dateInputView.isHidden = true
    }

    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            datePickerView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 200)
            datePickerView.layoutIfNeeded()
    }

    
    @IBAction func saveBtnTapped(_ sender: Any) {
        
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        if(self.profileAlertView.isHidden && self.emailAlertview.isHidden)
        {
        Utility.shared.selectedphoneNumber  = ""
            self.view.window?.rootViewController?.dismiss(animated:false, completion: nil)
        }
        else
        {
            
        }
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        date_value = sender.date
        EditProfileArray.iosDob = dateFormatter.string(from: sender.date)
       DatePickerSender = true
    }
    
    func EditProfileAPICall(fieldName:String,fieldValue:String)
    {
        let editprofileMutation = EditProfileMutation(userId:(Utility.shared.getCurrentUserID()! as String), fieldName: fieldName, fieldValue: fieldValue, deviceType: "iOS", deviceId:Utility.shared.pushnotification_devicetoken)
        apollo_headerClient.perform(mutation: editprofileMutation){ (result,error) in
            
            if(result?.data?.userUpdate?.status == 200)
            {
                self.EdiprofileAPICall()
            }
            else {
                
                if result?.data?.userUpdate?.status == 500{
                    let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message:result?.data?.userUpdate?.errorMessage, preferredStyle: .alert)
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
                }
              self.view.makeToast(result?.data?.userUpdate?.errorMessage)
            }
        }
      }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String?
    {
        if(section == 0){
            return ""
        }
        else if(section == 1 ){
            return "\(Utility.shared.getLanguage()?.value(forKey:"privatedetails") ?? "Personal info")"
        }
        else if(section == 2)
        {
            return "\((Utility.shared.getLanguage()?.value(forKey:"verfiediinfo"))!)"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 0, width:FULLWIDTH - 40, height: 30))
        headerLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        headerLabel.textColor = UIColor(named: "Title_Header")
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.numberOfLines = 0
        
        let headerView = UIView(frame: CGRect(x: 20, y: 0, width:FULLWIDTH - 40, height: 30))
        headerView.backgroundColor =  UIColor(named: "colorController")
        headerView.addSubview(headerLabel)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section==0){
            return CGFloat.leastNormalMagnitude
        }else if section == 1{
            return 30
        }else if section == 2{
            return 50
        }
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return 4
        }
        else if(section == 1)
        {
            return 5
        }
        else if(section == 2)
        {
            return 3
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                return 200
            }
            else {
                return UITableView.automaticDimension
            }
        }
        else if(indexPath.section == 1)
        {
            return UITableView.automaticDimension
        }
        else if(indexPath.section == 2)
        {
           return 70
        }
        else if(indexPath.section == 3)
        {
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0)
        {
        if(indexPath.row == 0)
        {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditImageCell", for: indexPath) as! EditImageCell
            cell.selectionStyle = .none
            cell.tag = 2000
            
            cell.uploadBtn.addTarget(self, action: #selector(UploadBtnTapped),for:.touchUpInside)
        
            if(imgChanged)
            {
                if(imgGalleryChanged)
                {
                  cell.editProfileimage.image = pickedImage_profile
                }
                else {
                    cell.editProfileimage.sd_setImage(with: URL(string:"\(IMAGE_AVATAR_MEDIUM)\(pickedimageString)"), completed: nil)
                }
            }

            else{
                
                if(Utility.shared.EditProfileArray.picture != nil)
                {
                    let profImage = Utility.shared.EditProfileArray.picture!
                    cell.editProfileimage.sd_setImage(with: URL(string:"\(IMAGE_AVATAR_MEDIUM)\(profImage)"), completed: nil)
                }
            }
        return cell
        }
        else if(indexPath.row == 1)
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "editFirstLastName") as! EditFirstLastName
            cell.selectionStyle = .none
            
            cell.txtField.delegate = self
            cell.txtField.inputAccessoryView = nil
            cell.txtField.inputView = nil
            cell.titleLabel.text =  "\(Utility.shared.getLanguage()?.value(forKey:"firstname") ?? "First name")"
            cell.txtField.autocorrectionType = .no
            cell.txtField.placeholder = "\(Utility.shared.getLanguage()?.value(forKey:"firstname") ?? "First name")"
            let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissName))
            toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
            cell.txtField.inputAccessoryView = toolBar
            cell.txtField.text = EditProfileArray.firstName ?? ""
            cell.txtField.tag = 0
            cell.lineView.isHidden = true
            
            return cell
        }else if(indexPath.row == 2)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "editFirstLastName") as! EditFirstLastName
            cell.selectionStyle = .none
            
            cell.txtField.delegate = self
            cell.txtField.inputAccessoryView = nil
            cell.txtField.inputView = nil
            cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"LastName") ?? "Last name")"
            cell.txtField.autocorrectionType = .no
            cell.txtField.placeholder = "\(Utility.shared.getLanguage()?.value(forKey:"LastName") ?? "Last name")"
            let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissName))
            toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
            cell.txtField.inputAccessoryView = toolBar
            
            if EditProfileArray.lastName == nil || EditProfileArray.lastName == "" {
                cell.txtField.text =  EditProfileArray.firstName
            }
            else {
                cell.txtField.text =  EditProfileArray.lastName
            }
            cell.txtField.tag = 1
            cell.lineView.isHidden = false
            
            return cell
        }
            else
            {
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "updatedEditAboutCell", for: indexPath)as! UpdatedEditAboutCell
                cell.selectionStyle = .none
                
                cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"aboutme") ?? "About")"
                cell.descLabel.text = EditProfileArray.info ?? ""
                cell.actionTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"Edit about me") ?? "Edit about me")"
                cell.actionBtn.addTarget(self, action: #selector(onClickAboutMe), for: .touchUpInside)
                
                
                return cell
            
            }
            
        }
            else if(indexPath.section == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditnameCell") as! EditnameCell
            
            cell.selectionStyle = .none
            cell.EditProfileTF.isUserInteractionEnabled = true
            cell.EditProfileTF.delegate = self
            cell.EditProfileTF.inputAccessoryView = nil
            cell.EditProfileTF.inputView = nil
                
            if(indexPath.row == 0)
            {
                cell.textfieldNameLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"gender"))!)"
                cell.EditProfileTF.tintColor = UIColor.clear
                cell.EditProfileTF.textColor = Theme.PRIMARY_COLOR
                cell.EditProfileTF.placeholder = "\((Utility.shared.getLanguage()?.value(forKey:"selectgender"))!)"
                cell.EditProfileTF.tintColor = .clear
                    cell.EditProfileTF.text = EditProfileArray.gender != nil ? EditProfileArray.gender! : ""
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell.EditProfileTF.tag = 2
                cell.EditProfileTF.inputAccessoryView = toolBar
                cell.EditProfileTF.inputView = genderInputView
                if cell.EditProfileTF.text!.trimmingCharacters(in: .whitespaces).isEmpty {
                    cell.arrowView.isHidden = false
                    cell.tfTrailing.constant = 35
                }
                else {
                    cell.arrowView.isHidden = true
                    cell.tfTrailing.constant = 20
                   
                }
            }
            else if(indexPath.row == 1)
            {
                
                cell.textfieldNameLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"birthdate"))!)"
                cell.EditProfileTF.tintColor = UIColor.clear
                cell.EditProfileTF.placeholder = "\((Utility.shared.getLanguage()?.value(forKey:"selectbirthday"))!)"
                cell.EditProfileTF.tintColor = .clear
                cell.EditProfileTF.tag = 3
                if(EditProfileArray.iosDob != nil)
                {
                if(EditProfileArray.iosDob == "-undefined-undefined")
                {
                    cell.EditProfileTF.text = ""
                    cell.arrowView.isHidden = false
                    cell.tfTrailing.constant = 35
                    
                
                }
                    else
                {
                    cell.EditProfileTF.text = EditProfileArray.iosDob != nil ? EditProfileArray.iosDob! : ""
                        
                        cell.arrowView.isHidden = true
                        cell.tfTrailing.constant = 20
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat =  "MM/dd/yyyy"
                        if(EditProfileArray.iosDob != nil) {
                            if(dateFormatter.date(from: EditProfileArray.iosDob!) != nil) {
                            datePickerView.date = dateFormatter.date(from: EditProfileArray.iosDob!)!
                            }
                            else {
                                dateFormatter.dateFormat =  "MM/yyyy/dd"
                                datePickerView.date = dateFormatter.date(from: EditProfileArray.iosDob!)!
                            }
                        }
                    }
                }
                else
                {
                 cell.EditProfileTF.text = ""
                }
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissdatePicker))
                cell.EditProfileTF.inputAccessoryView = toolBar
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell.EditProfileTF.inputView = dateInputView
            }
            else if(indexPath.row == 2)
            {
                cell.textfieldNameLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"emailreadonly"))!)"
                cell.EditProfileTF.placeholder = "\((Utility.shared.getLanguage()?.value(forKey:"enteremail"))!)"
                cell.EditProfileTF.tag = 4
                textfieldValueArray.add(EditProfileArray.email ?? "")
                cell.EditProfileTF.isUserInteractionEnabled = false
                cell.EditProfileTF.text = EditProfileArray.email ?? ""
                cell.arrowView.isHidden = true
                cell.tfTrailing.constant = 20
               
            }
            else if indexPath.row == 3{
                cell.textfieldNameLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"phonenumber") ?? "Phone Number")"
                cell.EditProfileTF.placeholder = "Enter Phone number"
                cell.EditProfileTF.tag = 6
                cell.EditProfileTF.isUserInteractionEnabled = false
                cell.EditProfileTF.inputAccessoryView = nil
                cell.EditProfileTF.inputView = nil
                cell.EditProfileTF.text = "\(self.EditProfileArray.countryCode ?? "") " + "\(self.EditProfileArray.phoneNumber ?? "")"
                
                if(cell.EditProfileTF.text != "" || cell.EditProfileTF.text != " "  ){
                    if cell.EditProfileTF.text!.trimmingCharacters(in: .whitespaces).isEmpty {
                        cell.arrowView.isHidden = false
                        cell.tfTrailing.constant = 35
                    }
                    else {
                        cell.arrowView.isHidden = true
                        cell.tfTrailing.constant = 20
                       
                    }
                }
                else {
                    cell.arrowView.isHidden = false
                    cell.tfTrailing.constant = 35
                }
                
               
            }else{
                    cell.textfieldNameLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"location"))!)"
                    cell.EditProfileTF.placeholder = "\((Utility.shared.getLanguage()?.value(forKey:"enterlocation"))!)"
                    cell.EditProfileTF.tag = 5
                    let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissLocation))
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                    cell.EditProfileTF.inputAccessoryView = toolBar
                    cell.EditProfileTF.tintColor = Theme.PRIMARY_COLOR
                    cell.EditProfileTF.text = self.EditProfileArray.location != nil ? self.EditProfileArray.location! : ""
                    
                    
                   
                        cell.arrowView.isHidden = true
                        cell.tfTrailing.constant = 20
                    
                }
            return cell
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "verifiedInfoCell", for: indexPath)as! VerifiedInfoCell
            cell.selectionStyle = .none
            
            if(indexPath.row == 0)
            {
                cell.imgLeftIcon.image = UIImage(named: "Verify_email")
                
                if((EditProfileArray.verification?.isEmailConfirmed != nil && EditProfileArray.verification?.isEmailConfirmed == true)){
                    cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"confirmedemail") ?? "Email confirmed")"
                    cell.imgRightView.image = UIImage(named: "redtick")
                    email_btn_title = "\((Utility.shared.getLanguage()?.value(forKey:"verified"))!)"
                    cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"verified"))!)"
                    cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                   
                }else{
                    email_btn_title = "\((Utility.shared.getLanguage()?.value(forKey:"Verify"))!)"
                    cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"confirmemail") ?? "Confirm your email")"
                    cell.imgRightView.image = #imageLiteral(resourceName: "next_green")
                    cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"Verify"))!)"
                    cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                    
                     if(Utility.shared.isRTLLanguage()) {
                        cell.imgRightView.performRTLTransform()
                     }
                   
                }
                cell.info_button.addTarget(self, action: #selector(emailInfoTapped), for: .touchUpInside)
            }
            else if(indexPath.row == 1)
            {
               
                cell.imgLeftIcon.image = UIImage(named: "Verify_Google")
                if((EditProfileArray.verification?.isGoogleConnected != nil && EditProfileArray.verification?.isGoogleConnected == true)){
                    google_btn_title = "\((Utility.shared.getLanguage()?.value(forKey:"disconnect"))!)"
                    cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"connectedgoogle") ?? "Google Connected")"
                    cell.imgRightView.image = UIImage(named: "redtick")
                    cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"disconnect"))!)"
                    cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                }else{
                    cell.imgRightView.image = #imageLiteral(resourceName: "next_green")
                    cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"connectgoogle") ?? "Connect your Google")"
                    google_btn_title = "\((Utility.shared.getLanguage()?.value(forKey:"connect"))!)"
                    cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"connect"))!)"
                    cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                    
                     if(Utility.shared.isRTLLanguage()) {
                        cell.imgRightView.performRTLTransform()
                     }
                }
                cell.info_button.addTarget(self, action: #selector(googleInfoTapped), for: .touchUpInside)
            }else{
                cell.imgLeftIcon.image = UIImage(named: "Phone")
                if((EditProfileArray.verification?.isPhoneVerified != nil && EditProfileArray.verification?.isPhoneVerified == true)){
                    cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"Verified_Phone") ?? "Phone number verified")"
                    cell.imgRightView.image = UIImage(named: "redtick")
                    cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"verified"))!)"
                    cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                }else{
                    cell.imgRightView.image = #imageLiteral(resourceName: "next_green")
                    cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"Verify_Phone") ?? "Verify phone number")"
                    cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"connect"))!)"
                    cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                    
                     if(Utility.shared.isRTLLanguage()) {
                        cell.imgRightView.performRTLTransform()
                     }
                }
                cell.info_button.addTarget(self, action: #selector(phoneInfoTapped), for: .touchUpInside)
            }
            cell.leadingConstraints.constant = 20
            cell.trailingConstraints.constant = 20
             return cell
        }
                
       
    }
    
    @objc func UploadBtnTapped(_ sender: UIButton)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title:"\((Utility.shared.getLanguage()?.value(forKey:"camera"))!)", style: .default) { (action) in
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                self.moveToCamera()
            } else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        self.moveToCamera()
                    } else {
                        DispatchQueue.main.async {
                            self.cameraPermissionAlert()
                        }
                    }
                })
            }
        }
        let gallery = UIAlertAction(title: "\((Utility.shared.getLanguage()?.value(forKey:"gallery"))!)", style: .default) { (action) in
            self.imagePicker.allowsEditing = false
            self.imgGalleryChanged = true
            self.imagePicker.sourceType = .photoLibrary
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title:"\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)", style: .cancel)
        alertController.addAction(camera)
        alertController.addAction(gallery)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @objc func emailInfoTapped(sender : UIButton)
    {
        let  menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"emailverify"))!)"]
     
       let configuration = FTConfiguration()
       configuration.backgoundTintColor = UIColor(named: "colorController")!
       configuration.menuSeparatorColor = UIColor(named: "colorController")!
        configuration.textColor =  UIColor(named: "Title_Header")!
        configuration.cornerRadius = 4
         configuration.borderColor = Theme.descriptionBorder_Color

        configuration.menuWidth = Utility.shared.isRTLLanguage() ? 150 : 150
        configuration.menuRowHeight = 50
        configuration.menuIconSize = 0.0


  
       FTPopOverMenu.showForSender(sender: sender,
                                   with: menuOptionNameArray, menuImageArray: nil,
                                   config: configuration,
                                   done: { (selectedIndex) in


       },
                                   cancel: {
       })
        
    }
    @objc func facebookInfoTapped(sender : UIButton)
    {
        let  menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"connect_facebook"))!)"]
     
       let configuration = FTConfiguration()
       configuration.backgoundTintColor = UIColor(named: "colorController")!
       configuration.menuSeparatorColor = UIColor(named: "colorController")!
        configuration.textColor =  UIColor(named: "Title_Header")!
        configuration.cornerRadius = 4
         configuration.borderColor = Theme.descriptionBorder_Color

        configuration.menuWidth = Utility.shared.isRTLLanguage() ? 180 : 180
        configuration.menuRowHeight = 100
        configuration.menuIconSize = 0.0


  
       FTPopOverMenu.showForSender(sender: sender,
                                   with: menuOptionNameArray, menuImageArray: nil,
                                   config: configuration,
                                   done: { (selectedIndex) in


       },
                                   cancel: {
       })
        
      
    }
    @objc func googleInfoTapped(sender : UIButton)
    {
        let  menuOptionNameArray =  ["\((Utility.shared.getLanguage()?.value(forKey:"connect_google"))!)"]
     
       let configuration = FTConfiguration()
       configuration.backgoundTintColor = UIColor(named: "colorController")!
       configuration.menuSeparatorColor = UIColor(named: "colorController")!
        configuration.textColor =  UIColor(named: "Title_Header")!
        configuration.cornerRadius = 4
         configuration.borderColor = Theme.descriptionBorder_Color

        configuration.menuWidth = Utility.shared.isRTLLanguage() ? 180 : 180
        configuration.menuRowHeight = 80
        configuration.menuIconSize = 0.0


  
       FTPopOverMenu.showForSender(sender: sender,
                                   with: menuOptionNameArray, menuImageArray: nil,
                                   config: configuration,
                                   done: { (selectedIndex) in

           

       },
                                   cancel: {
       })
    }
    @objc func phoneInfoTapped(sender : UIButton)
    {
        let  menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"Verify_Phone"))!)"]
     
       let configuration = FTConfiguration()
       configuration.backgoundTintColor = UIColor(named: "colorController")!
       configuration.menuSeparatorColor = UIColor(named: "colorController")!
        configuration.textColor =  UIColor(named: "Title_Header")!
       configuration.cornerRadius = 4
        configuration.borderColor = Theme.descriptionBorder_Color

       configuration.menuWidth = Utility.shared.isRTLLanguage() ? 150 : 150
       configuration.menuRowHeight = 38
       configuration.menuIconSize = 0.0


  
       FTPopOverMenu.showForSender(sender: sender,
                                   with: menuOptionNameArray, menuImageArray: nil,
                                   config: configuration,
                                   done: { (selectedIndex) in


       },
                                   cancel: {
       })
    }
    
    
    
    @objc func onClickAboutMe(){
        let aboutobj  = AboutmeVC()
        aboutobj.aboutvaluArray = EditProfileArray
         aboutobj.modalPresentationStyle = .fullScreen
        self.present(aboutobj, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let camera = UIAlertAction(title:"\((Utility.shared.getLanguage()?.value(forKey:"camera"))!)", style: .default) { (action) in
                    if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                        self.moveToCamera()
                    } else {
                        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                            if granted {
                                self.moveToCamera()
                            } else {
                                DispatchQueue.main.async {
                                    self.cameraPermissionAlert()
                                }
                            }
                        })
                    }
                }
                let gallery = UIAlertAction(title: "\((Utility.shared.getLanguage()?.value(forKey:"gallery"))!)", style: .default) { (action) in
                    self.imagePicker.allowsEditing = false
                    self.imgGalleryChanged = true
                    self.imagePicker.sourceType = .photoLibrary
                    
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
                let cancel = UIAlertAction(title:"\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)", style: .cancel)
                alertController.addAction(camera)
                alertController.addAction(gallery)
                alertController.addAction(cancel)
                self.present(alertController, animated: true, completion: nil)
            }
        }else if indexPath.section == 1{
            if indexPath.row == 3{
                let phoneNumberObj = PhonekitVC()
                phoneNumberObj.userphonekitArray = EditProfileArray
                  phoneNumberObj.modalPresentationStyle = .fullScreen
               self.present(phoneNumberObj, animated: true, completion: nil)
            }
        }
        else if(indexPath.section == 2)
        {
            if indexPath.row == 0{
                if Utility.shared.isConnectedToNetwork(){
               
                    if(self.email_btn_title
                       == "\((Utility.shared.getLanguage()?.value(forKey:"Verify"))!)")
                    {
                    self.emailAPICall()
                        
                    }
                }
               
            }

      
          else  if indexPath.row == 1{
                if(self.google_btn_title == "\((Utility.shared.getLanguage()?.value(forKey:"connect"))!)")
                {
                    URLCache.shared.removeAllCachedResponses()
                    
                    if let cookies = HTTPCookieStorage.shared.cookies {
                        for cookie in cookies {
                            HTTPCookieStorage.shared.deleteCookie(cookie)
                        }
                    }
                    GIDSignIn.sharedInstance.signOut()
                    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                    let config = GIDConfiguration(clientID: clientID)
                    GIDSignIn.sharedInstance.configuration = config

                    GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
                        guard error == nil else { return }

                        self.googleAPICall()
                      }
                    
                   
                }
                else{
                    self.googleAPICall()
                }
                
            }
           else if indexPath.row == 2{
                let phoneNumberObj = PhonekitVC()
                phoneNumberObj.userphonekitArray = EditProfileArray
                phoneNumberObj.modalPresentationStyle = .fullScreen
               self.present(phoneNumberObj, animated: true, completion: nil)
            }else{
                let verifyObj = EmailGoogleFBViewController()
                verifyObj.is_fb_verify = (EditProfileArray.verification?.isFacebookConnected != nil ? ((EditProfileArray.verification?.isFacebookConnected!)!) : false)
                verifyObj.is_google_verify = (EditProfileArray.verification?.isGoogleConnected != nil ? ((EditProfileArray.verification?.isGoogleConnected!)!) : false)
                verifyObj.is_email_verify = (EditProfileArray.verification?.isEmailConfirmed != nil ? ((EditProfileArray.verification?.isEmailConfirmed!)!) : false)
                verifyObj.modalPresentationStyle = .fullScreen
                self.present(verifyObj, animated: true, completion: nil)
            }
        }
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderArray.count
    }
    
   func pickerView( _ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = genderNewArray[row]
    
        let myTitle = NSAttributedString(string: titleData as! String, attributes: [NSAttributedString.Key.font:UIFont(name: APP_FONT_MEDIUM, size: 15.0)!,NSAttributedString.Key.foregroundColor:Theme.PRIMARY_COLOR])
        return myTitle
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        EditProfileArray.gender = (genderNewArray[row] as! String)
    }
    @objc func dismissdatePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy-dd"
        let dob = dateFormatter.string(from:date_value)
        if DatePickerSender == false{
            
        }else{
            self.EditProfileAPICall(fieldName: "dateOfBirth", fieldValue:dob)
            
            editProfileTable.reloadData()
        }

        view.endEditing(true)
        
    }
    @objc func dismissgenderPicker() {
        if(EditProfileArray.gender != nil)
        {
            if EditProfileArray.gender == "\(Utility.shared.getLanguage()?.value(forKey:"gender_male") ?? "Male")" ||  EditProfileArray.gender == "Male" {
                EditProfileArray.gender = "Male"
            }else if EditProfileArray.gender == "\(Utility.shared.getLanguage()?.value(forKey:"gender_female") ?? "Female")"  ||  EditProfileArray.gender == "Female"{
                EditProfileArray.gender = "Female"
            }
            else if EditProfileArray.gender == ""{
                EditProfileArray.gender = "Male"
            }
            else{
                EditProfileArray.gender = "Other"
            }
            self.EditProfileAPICall(fieldName: "gender", fieldValue: "\(EditProfileArray.gender != nil ? EditProfileArray.gender! : "")")
        }
        else{
            EditProfileArray.gender = "\((Utility.shared.getLanguage()?.value(forKey:"gender_male"))!)"
            self.EditProfileAPICall(fieldName: "gender", fieldValue: "Male")
        }
        if self.EditProfileArray.gender == "Male" {
            self.EditProfileArray.gender = "\(Utility.shared.getLanguage()?.value(forKey:"gender_male") ?? "Male")"
        }else if self.EditProfileArray.gender == "Female" {
            self.EditProfileArray.gender = "\(Utility.shared.getLanguage()?.value(forKey:"gender_female") ?? "Female")"
        }else{
            self.EditProfileArray.gender = "\(Utility.shared.getLanguage()?.value(forKey:"gender_other") ?? "Other")"
        }
        editProfileTable.reloadData()
        view.endEditing(true)
        
    }
    @objc func dismissLocation() {
        
        view.endEditing(true)
        
    }
     @objc func dismissName() {
        
        self.view.endEditing(true)
        
    }
    
    func moveToCamera()   {
        
        DispatchQueue.main.async {
            self.imagePicker.allowsEditing = false
            self.imgGalleryChanged = false
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }

        }
    
    func cameraPermissionAlert(){
        AJAlertController.initialization().showAlert(aStrMessage: "\((Utility.shared.getLanguage()?.value(forKey:"camerapermission"))!)", aCancelBtnTitle:"\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)", aOtherBtnTitle: "\((Utility.shared.getLanguage()?.value(forKey:"settings"))!)", completion: { (index, title) in
            if index == 1{
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
     
        if Utility.shared.isConnectedToNetwork() {
            let cell = view.viewWithTag(2000) as? EditImageCell
            if let pickedImage = info[.originalImage] as? UIImage {
                self.pickedImage_profile = pickedImage
                self.lottieAnimation()
                if(!imgGalleryChanged)
                {
                    
                    let orientedimage = fixOrientation(img: pickedImage)
                    self.imageData = orientedimage.jpegData(compressionQuality: 0.0)! as NSData
                } else {
                    self.imageData = pickedImage.jpegData(compressionQuality: 0.0)! as NSData
                }
                
                self.uploadProfileimageService(imageBase64: self.imageData as Data)
                
            }
            self.dismiss(animated: true, completion: nil)
        }else{
            self.view.makeToast("Please connect to intenet and try again")
        }

       
        
    }

   func googleBtnTapped(sender : UIButton)
    {
        if Utility.shared.isConnectedToNetwork(){
            if(sender.tag == 2)
            {
                if(self.google_btn_title == "\((Utility.shared.getLanguage()?.value(forKey:"connect"))!)")
                {
                    URLCache.shared.removeAllCachedResponses()
                    
                    if let cookies = HTTPCookieStorage.shared.cookies {
                        for cookie in cookies {
                            HTTPCookieStorage.shared.deleteCookie(cookie)
                        }
                    }
                    GIDSignIn.sharedInstance.signOut()
                  
                    guard let clientID = FirebaseApp.app()?.options.clientID else { return }

                  
                    let config = GIDConfiguration(clientID: clientID)
                    GIDSignIn.sharedInstance.configuration = config

                    
                    GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
                        guard error == nil else { return }
                        self.googleAPICall()
                      }
                }
                else{
                    self.googleAPICall()
                }
            }
        } else {
         self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)")
        }
    }
        
    func emailAPICall()
    {
        let resendAPIquery = ResendConfirmEmailQuery()
        apollo_headerClient.fetch(query: resendAPIquery,cachePolicy: .fetchIgnoringCacheData){(result,error) in
            if(result?.data?.resendConfirmEmail?.status == 200)
            {
                self.view.makeToast("Confirmation link is sent to your email")
                self.EdiprofileAPICall()
                self.editProfileTable.reloadData()
                
            }
            else
            {
                self.view.makeToast(result?.data?.resendConfirmEmail?.errorMessage != nil ? result?.data?.resendConfirmEmail?.errorMessage! : "")
              
            }
        }
    }
    func googleAPICall()
    {
        var actiontype = String()
        if(google_btn_title == "\((Utility.shared.getLanguage()?.value(forKey:"connect"))!)")
        {
            actiontype = "true"
        } else {
            actiontype = "false"
        }
        let socialloginverifyMutation = SocialLoginVerifyMutation(verificationType:"google", actionType:actiontype)
        apollo_headerClient.perform(mutation:socialloginverifyMutation){(result,error) in
            if(result?.data?.socialVerification?.status == 200)
            {
                if(self.google_btn_title == "\((Utility.shared.getLanguage()?.value(forKey:"connect"))!)")
                {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"googleconnected"))!)")
                   
                    self.google_btn_title = "\((Utility.shared.getLanguage()?.value(forKey:"disconnect"))!)"
                } else {
                   
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"googledisconnected"))!)")
                    self.google_btn_title = "\((Utility.shared.getLanguage()?.value(forKey:"connect"))!)"
                }
                self.EdiprofileAPICall()
                self.editProfileTable.reloadData()
            }
            else
            {
                self.view.makeToast(result?.data?.socialVerification?.errorMessage != nil ? result?.data?.socialVerification?.errorMessage! : "")
            }
            
            
        }
        
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if(error == nil)
        {
        self.googleAPICall()
        } else{
          
        }
        
    }
    func faceBookLogin(viewC: UIViewController)
    {
        
    }
    
    func facebookVerifyAPICall()
    {
    
                var actiontype = String()
                if(facebook_btn_title == "\((Utility.shared.getLanguage()?.value(forKey:"connect"))!)")
                {
                    actiontype = "true"
                } else {
                
                   actiontype = "false"
                }
                let socialloginverifyMutation = SocialLoginVerifyMutation(verificationType:"facebook", actionType: actiontype)
                self.apollo_headerClient.perform(mutation:socialloginverifyMutation){(result,error) in
                    if(result?.data?.socialVerification?.status == 200)
                    {
                        if(self.facebook_btn_title == "\((Utility.shared.getLanguage()?.value(forKey:"connect"))!)")
                        {
                          
                            self.facebook_btn_title = "\((Utility.shared.getLanguage()?.value(forKey:"disconnect"))!)"
                            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"facebookconnected"))!)")
                           
                        } else {
                        
                        
                         
                            self.facebook_btn_title = "\((Utility.shared.getLanguage()?.value(forKey:"connect"))!)"
                            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"facebookdisconnected"))!)")
                            
                        }
                        self.EdiprofileAPICall()
                        self.editProfileTable.reloadData()
                        
                    }
                    else
                    {
                        
                        
                        self.view.makeToast(result?.data?.socialVerification?.errorMessage != nil ? result?.data?.socialVerification?.errorMessage! : "")
                    }
                    
                    
                }
                
                
            }

    
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {0
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePicker.setNavigationBarHidden(false, animated:false)
        self.dismiss(animated: true, completion: nil)
    }
    
    func uploadProfileimageService(imageBase64:Data)
    {
        
        if Utility().isConnectedToNetwork(){
            
       self.uploadProfilePic(profileimage:imageBase64,onSuccess:{response in
        })
        }
        else
        {
            self.lottieView.isHidden = true
            self.lottieWholeView.isHidden = true
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
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
      
        
    }
    
    
    
    
    
    
    
    
    
    func uploadProfilePic(profileimage:Data,onSuccess success: @escaping (NSDictionary) -> Void) {
        if Utility().isConnectedToNetwork(){
            let BaseUrl = URL(string: IMAGE_UPLOAD_PHOTO)
            let header = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
            
            
            AF.upload(multipartFormData: { (multipartFormData) in

                multipartFormData.append(profileimage, withName: "file", fileName: "file.jpeg", mimeType: "image/jpeg")
                    
                    
            },to: BaseUrl!, usingThreshold: UInt64.init(),
                  method: .post,
                      headers: HTTPHeaders.init(header)).responseData(completionHandler: { responseData in
                if(responseData.error == nil){
                    self.checkUploadStatus(rseposneData: responseData.data!)
                }else{
                    self.lottieView.isHidden = true
                    self.lottieWholeView.isHidden = true
                }
            })
        }
        else {
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
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    
    func checkUploadStatus(rseposneData: Data) {
        do {
            let obj = try JSONSerialization.jsonObject(with: rseposneData, options: .mutableContainers) as! NSDictionary
            if obj.value(forKey: "status") as! Int == 200 {
                DispatchQueue.global(qos: .background).async {
                    self.EdiprofileAPICall()
                }
                 DispatchQueue.main.async {
                     self.editProfileTable.reloadData()
                }
                
            }
            else {
                self.view.makeToast(obj.value(forKey: "errorMessage") as? String)
            }
        
        }
         catch {
            
        }
        
       
    self.lottieView.isHidden = true
    self.lottieWholeView.isHidden = true
       
    
           
    }
    
    func checkexistingemailAPI(currentTF:UITextField)
    {

       self.lottieAnimation()
        let checkemail = CheckEmailExistsQuery(email:currentTF.text!)
        apollo.fetch(query: checkemail){ (result,error) in
            
            if(result?.data?.validateEmailExist?.status == 200){
                self.emailexistView.isHidden = true
                self.EditemailAPICall(fieldName: "email", fieldValue:currentTF.text!)
                self.lottieView.isHidden = true
                self.lottieWholeView.isHidden = true
            }
            else{
                
                self.lottieView.isHidden = true
                self.lottieWholeView.isHidden = true
                self.emailWrongView.isHidden = true
                self.emailexistView.isHidden = false
                if IS_IPHONE_X || IS_IPHONE_XR{
                    self.emailexistView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
                }else{
                    self.emailexistView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
                }
            }
        }
        
        
    }
    
    func EditemailAPICall(fieldName:String,fieldValue:String)
    {
        let editprofileMutation = EditProfileMutation(userId: (Utility.shared.getCurrentUserID()! as String), fieldName: fieldName, fieldValue: fieldValue, deviceType: "iOS", deviceId:Utility.shared.pushnotification_devicetoken)
        apollo_headerClient.perform(mutation: editprofileMutation){ (result,error) in
            
            if(result?.data?.userUpdate?.status == 200)
            {
                self.EdiprofileAPICall()
                if(result?.data?.userUpdate?.userToken != nil)
                {
                Utility.shared.setUserToken(userID: (result?.data?.userUpdate?.userToken as AnyObject) as! NSString)
                }
                self.emailWrongView.isHidden = true
                self.lottieView.isHidden = true
                self.lottieWholeView.isHidden = true
            }
            else {
                self.lottieView.isHidden = true
                self.lottieWholeView.isHidden = true
                self.emailWrongView.isHidden = false
                if IS_IPHONE_X || IS_IPHONE_XR{
                    self.emailWrongView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
                }else{
                    self.emailWrongView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
                }
            }
        }
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if((!emailWrongView.isHidden))
        {
              self.emailWrongView.frame.origin.y = FULLHEIGHT - 90
        }
        else if(!emailexistView.isHidden)
        {
             self.emailexistView.frame.origin.y = FULLHEIGHT - 90
        }
        else if(!emailAlertview.isHidden)
        {
            self.emailAlertview.frame.origin.y = FULLHEIGHT - 90
        }
        else if(!profileAlertView.isHidden)
        {
            self.profileAlertView.frame.origin.y = FULLHEIGHT - 90
        }
        else if(!offlineView.isHidden)
        {
            self.offlineView.frame.origin.y = FULLHEIGHT - 90
        }
        
    }
}
extension UILabel {
    func addCharacterSpacing(kernValue: Double = 1.15) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
extension UIToolbar {
    
    func ToolbarPikerSelect(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Theme.PRIMARY_COLOR
        toolBar.sizeToFit()
        toolBar.backgroundColor = UIColor(named: "colorController")
        
        let doneButton = UIBarButtonItem(title: "\((Utility.shared.getLanguage()?.value(forKey:"done"))!)", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        doneButton.setTitleTextAttributes([kCTForegroundColorAttributeName as NSAttributedString.Key: Theme.PRIMARY_COLOR], for: .normal)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}
extension EditProfileVC:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let charsLimit = 25
        if textField.tag == 0 || textField.tag == 1 {
        let startingLength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace =  range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
       
        
        return newLength <= charsLimit
        
        }
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        dateInputView.isHidden = false
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {

         if(textField.tag == 0)
        {
            if(textField.text!.count>0)
            {
                self.profileAlertView.isHidden = true
                let arrayOfString = ["\(textField.text ?? "")","\(EditProfileArray.lastName ?? "")"]
                if let valueTobeSend = json(from: arrayOfString){
                    isFromFn = true
                    self.EditProfileAPICall(fieldName: "firstName", fieldValue: valueTobeSend)
                }else{
                    self.view.makeToast("Something went wrong")
                }
            }
            else{
                self.profileAlertView.isHidden = false
                if IS_IPHONE_X || IS_IPHONE_XR {
                    profileAlertView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
                }else{
                    profileAlertView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
                }
            }
            
            
        }else if(textField.tag == 1)
        {
            if(textField.text!.count>0)
            {
                self.profileAlertView.isHidden = true
                let arrayOfString = ["\(EditProfileArray.firstName ?? "")","\(textField.text ?? "")"]
                if let valueTobeSend = json(from: arrayOfString){
                    isFromln = true
                    self.EditProfileAPICall(fieldName: "firstName", fieldValue: valueTobeSend)
                }else{
                    self.view.makeToast("Something went wrong")
                }
            }
            else{
                self.profileAlertView.isHidden = false
                if IS_IPHONE_X || IS_IPHONE_XR {
                    profileAlertView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
                }else{
                    profileAlertView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
                }
            }
            
        }
            
        else if(textField.tag == 4)
        {
             if (textField.text?.isValidEmail())! {
                self.emailAlertview.isHidden = true
                self.EditemailAPICall(fieldName: "email", fieldValue:textField.text!)
            }
            else{
                
                self.emailAlertview.isHidden = false
                if IS_IPHONE_X || IS_IPHONE_XR {
                    emailAlertview.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
                }else{
                    emailAlertview.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
                }
                textField.resignFirstResponder()
            }
            
        }
         else if(textField.tag == 5)
         {
                self.EditProfileArray.location = textField.text!
                self.EditProfileAPICall(fieldName: "location", fieldValue:textField.text!)
                Utility.shared.isfromPhonePage = false

        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return true
     }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }

}
