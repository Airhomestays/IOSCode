
import UIKit
import Lottie
import Alamofire
import SwiftyJSON
import AVFoundation
import Apollo

class BookingStepThreeVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bookingStepthreeTable: UITableView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var backBtn: UIButton!
    var pickedImage_profile = UIImage()
     var imgGalleryChanged:Bool = false
    let imagePicker = UIImagePickerController()
    var imageData = NSData()
    var imgChanged:Bool = false
    var lottieWholeView = UIView()
     var pickedimageString = String()
    var lottieView: LottieAnimationView!
    var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    var ProfileAPIArray = GetProfileQuery.Data.UserAccount.Result()
    var currencyvalue_from_API_base = ""
    var getbillingArray = GetBillingCalculationQueryy.Data.GetBillingCalculation.Result()
    
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
       
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.initialsetup()
        backBtn.layer.cornerRadius = backBtn.frame.size.height / 2
        backBtn.layer.masksToBounds = true
        self.profileAPICall()
        if(Utility.shared.isRTLLanguage()) {
            backBtn.rotateImageViewofBtn()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    func initialsetup()
    {
        if IS_IPHONE_XR
        {
            self.topView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH-40, height: 80)
            bookingStepthreeTable.frame = CGRect(x: 0, y: 85, width: FULLWIDTH-40, height: FULLHEIGHT-300)
            
        }
        nextBtn.backgroundColor = Theme.PRIMARY_COLOR
        bookingStepthreeTable.register(UINib(nibName: "BookingthreeCell", bundle: nil), forCellReuseIdentifier: "BookingthreeCell")
        bookingStepthreeTable.register(UINib(nibName: "EditImageCell", bundle: nil), forCellReuseIdentifier: "EditImageCell")
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.layer.masksToBounds = true
        nextBtn.backgroundColor = Theme.Button_BG
        self.imagePicker.delegate = self
        self.offlineView.isHidden = true
        lottieView = LottieAnimationView.init(name: "loading_qwe")
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for:.normal)
//        self.lottieView.isHidden = true
//        self.lottieWholeView.isHidden = true
        errorLabel.font = UIFont(name: APP_FONT, size: 15)
         retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        
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
    @IBAction func nextBtnTapped(_ sender: Any) {
        if(pickedimageString == "" && ProfileAPIArray.picture == nil)
        {
            
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"uploadprofile"))!)")
        }
        else{
            
            
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
//                let navigationController = UINavigationController(rootViewController: self)
//                keyWindow.rootViewController = navigationController
//                
//                let paymentSelectionPage = PaymentSelectionPage()
//                paymentSelectionPage.currencyvalue_from_API_base = self.currencyvalue_from_API_base
//                paymentSelectionPage.getbillingArray = self.getbillingArray
//                paymentSelectionPage.viewListingArray = self.viewListingArray
//
//                // Push the view controller onto the navigation stack
//                self.navigationController?.pushViewController(paymentSelectionPage, animated: true)
//            }
            
            
            let paymentSelectionPage = PaymentSelectionPage()
            paymentSelectionPage.currencyvalue_from_API_base = self.currencyvalue_from_API_base
            paymentSelectionPage.getbillingArray = self.getbillingArray
            paymentSelectionPage.viewListingArray = self.viewListingArray
            paymentSelectionPage.modalPresentationStyle = .fullScreen
            self.present(paymentSelectionPage, animated: true, completion: nil)
//        let bookingfourObj = BookingStepFourVC()
//        bookingfourObj.viewListingArray = viewListingArray
//         bookingfourObj.modalPresentationStyle = .fullScreen
//        self.present(bookingfourObj, animated: true, completion: nil)
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
     @objc func uploadBtnTapped(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title:"\((Utility.shared.getLanguage()?.value(forKey:"camera"))!)", style: .default) { (action) in
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                //already authorized
                
                self.moveToCamera()
            } else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        //access allowed
                        self.moveToCamera()
                    } else {
                        //access denied
                        DispatchQueue.main.async {
                            self.cameraPermissionAlert()
                        }
                    }
                })
            }
        }
        let gallery = UIAlertAction(title:"\((Utility.shared.getLanguage()?.value(forKey:"gallery"))!)", style: .default) { (action) in
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
    
    //MARK*************************************************** TABLEVIEW DELEGATE & DATASOURCE METHODS *****************************************************************************>
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(ProfileAPIArray != nil)
        {
            return 2
        }
       return 0
    }
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         if(indexPath.row == 0){
        return 100
         }
         return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingthreeCell", for: indexPath)as! BookingthreeCell

        return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditImageCell", for: indexPath) as! EditImageCell
            cell.selectionStyle = .none
            cell.tag = 2000
        
          cell.uploadBtn.addTarget(self, action: #selector(uploadBtnTapped), for: .touchUpInside)
        
        cell.selectionStyle = .none
        if(imgChanged)
        {
        if(imgGalleryChanged)
        {
            cell.editProfileimage.image = pickedImage_profile
        }
        else {
//            let profImage = pickedimageString
//            cell.profileImage.sd_setImage(with: URL(string:"\(IMAGE_AVATAR_MEDIUM)\(profImage)"), completed: nil)
            cell.editProfileimage.image = pickedImage_profile
        }
        }
        else{
            if(ProfileAPIArray.picture != nil)
            {
                let profImage = ProfileAPIArray.picture!
                cell.editProfileimage.sd_setImage(with: URL(string:"\(IMAGE_AVATAR_MEDIUM)\(profImage)"), completed: nil)
            }
            else
            {
            cell.editProfileimage.image = #imageLiteral(resourceName: "unknown")
            }
        }
        
        
        return cell
        
    }
    //move to camera
    func moveToCamera()   {
        DispatchQueue.main.async {
            self.imagePicker.allowsEditing = false
            self.imgGalleryChanged = false
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }

    }
    
    
    //MARK:location restriction alert
    func cameraPermissionAlert(){
        AJAlertController.initialization().showAlert(aStrMessage: "camera_permission", aCancelBtnTitle:"\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)", aOtherBtnTitle: "\((Utility.shared.getLanguage()?.value(forKey:"settings"))!)", completion: { (index, title) in
            if index == 1{
                //open settings page
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
         self.offlineView.isHidden = true
            self.nextBtn.isHidden = false
        }
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        let cell = view.viewWithTag((1) + 1000) as? EditImageCell
        if let pickedImage = info[.originalImage] as? UIImage {
            // self.profilePic.image = pickedImage
            self.pickedImage_profile = pickedImage
            cell?.editProfileimage.image = pickedImage
            if(!imgGalleryChanged)
            {
               self.lottieAnimation()
                let orientedimage = fixOrientation(img: pickedImage)
                self.imageData = orientedimage.jpegData(compressionQuality: 0.0)! as NSData
            } else {
                self.imageData = pickedImage.jpegData(compressionQuality: 0.0)! as NSData
            }
            self.uploadProfileimageService(imageBase64: self.imageData as Data)
            
        }
        self.dismiss(animated: true, completion: nil)
        
        
    }
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
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
            nextBtn.isHidden = true
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-90, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
        
        
    }
    
    func uploadProfilePic(profileimage:Data,onSuccess success: @escaping (NSDictionary) -> Void) {
        if Utility().isConnectedToNetwork(){
            let BaseUrl = URL(string: IMAGE_UPLOAD_PHOTO)
          
            let header = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
            
            
            AF.upload(multipartFormData: { (multipartFormData) in
//                    for img in arrImage {
//                        guard let imgData = img.jpegData(compressionQuality: 1) else { return }
//                        multipartFormData.append(imgData, withName: imageKey, fileName: FuncationManager.getCurrentTimeStamp() + ".jpeg", mimeType: "image/jpeg")
//                    }
                multipartFormData.append(profileimage, withName: "file", fileName: "file.jpeg", mimeType: "image/jpeg")
            },to: BaseUrl!, usingThreshold: UInt64.init(),
                  method: .post,
                      headers: HTTPHeaders.init(header)).responseData(completionHandler: { responseData in
                if(responseData.error == nil){
                        if let jsonData = responseData.data{
                          //
                            
                        //    self.imgChanged = true
                            self.profileAPICall()
                            self.bookingStepthreeTable.reloadData()
                        }
                    self.lottieView.isHidden = true
                    self.lottieWholeView.isHidden = true
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
            if IS_IPHONE_X || IS_IPHONE_XR {
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    func profileAPICall()
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
                    self.view.makeToast(result?.data?.userAccount?.errorMessage)
                return
                }
            }
            self.ProfileAPIArray = ((result?.data?.userAccount?.result)!)
            self.bookingStepthreeTable.reloadData()
        }
        
        
    }
}

