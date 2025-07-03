

import UIKit
import Toast_Swift
import MessageUI
class ShareProductVC: UIViewController,UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate {
    
  

    @IBOutlet weak var shareTable: UITableView!
    
    @IBOutlet weak var backgrndImage: UIImageView!
   
    var TitleArray = NSMutableArray()
    var imageArray = NSMutableArray()
    var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        self.registerCells()
       
    }
    
    func initialSetup()
    {
        self.view.backgroundColor =   UIColor(named: "colorController")
        
        if IS_IPHONE_5{
           
            shareTable.frame = CGRect(x: 0, y:0, width: FULLWIDTH+100, height:FULLHEIGHT+100)
        }
        else if IS_IPHONE_XR
        {
    
        shareTable.frame = CGRect(x: 0, y:0, width: FULLWIDTH-40, height:FULLHEIGHT+100)
            
        }
        
    TitleArray = ["\((Utility.shared.getLanguage()?.value(forKey:"email"))!)","\((Utility.shared.getLanguage()?.value(forKey:"sms"))!)","\((Utility.shared.getLanguage()?.value(forKey:"copylink"))!)","\((Utility.shared.getLanguage()?.value(forKey:"more"))!)"]
    imageArray = [#imageLiteral(resourceName: "msg-50"),#imageLiteral(resourceName: "chat"),#imageLiteral(resourceName: "copy-document"),#imageLiteral(resourceName: "more")]
       
    }
    func registerCells(){
        shareTable.register(UINib(nibName: "ShareProductCell", bundle: nil), forCellReuseIdentifier: "ShareProductCell")
        shareTable.register(UINib(nibName: "ShareListCell", bundle: nil), forCellReuseIdentifier: "ShareListCell")
          let profileimage = viewListingArray.listPhotoName!
        self.backgrndImage.sd_setImage(with: URL(string:"\(IMAGE_LISTING_MEDIUM)\(String(describing: profileimage))"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
    }
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0){
            return 400
        }
        else{
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }
        else{
            return TitleArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShareProductCell", for: indexPath)as! ShareProductCell
            cell.imgBckgrdView.layer.cornerRadius = 5.0
            cell.imgBckgrdView.clipsToBounds = true
            let profileimage = viewListingArray.listPhotoName!
            cell.productImg.sd_setImage(with: URL(string:"\(IMAGE_LISTING_MEDIUM)\(String(describing: profileimage))"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
            cell.productTitleLabel.text = viewListingArray.title!
            cell.productTitleLabel.backgroundColor = UIColor(named: "colorController")
            cell.closeBtn.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShareListCell", for: indexPath)as! ShareListCell
            cell.shareImg.image = (imageArray[indexPath.row] as! UIImage)
            cell.shareTitle.text = (TitleArray[indexPath.row] as! String)
            cell.shareTitle.textColor =  UIColor(named: "searchPlaces_TextColor")
            cell.shareTitle.font = UIFont(name: APP_FONT, size:19)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if indexPath.row == TitleArray.count - 1 {
                cell.lineView.isHidden = true
            }
            else {
                cell.lineView.isHidden = false
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section==1){
            if(indexPath.row == 0){
                let emailTitle = "\((Utility.shared.getLanguage()?.value(forKey:"checkoutplace"))!) \(viewListingArray.title!)"
                let listid = viewListingArray.id != nil ? viewListingArray.id! : 0
                let title = viewListingArray.title != nil ? viewListingArray.title! : ""
                var convertedTitle =  title.replacingOccurrences(of:", ", with:"--")
                convertedTitle = convertedTitle.replacingOccurrences(of:" ", with:"-")
                convertedTitle = convertedTitle.replacingOccurrences(of:"#", with:"-")
                convertedTitle = convertedTitle.replacingOccurrences(of:"/", with:"-")
                convertedTitle = convertedTitle.replacingOccurrences(of:"%", with:"-")
                let profileimage = "\(convertedTitle)" + "-\(listid)"
                let urltoShare =  "\(SHARE_URL)\(String(describing: profileimage.lowercased()))"
                let messageBody = "\((Utility.shared.getLanguage()?.value(forKey:"sharedesc"))!) \(viewListingArray.title!) \((Utility.shared.getLanguage()?.value(forKey:"sharedesc_next"))!) \(urltoShare)"
             
                if MFMailComposeViewController.canSendMail() {
                let mc: MFMailComposeViewController = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.setSubject(emailTitle)
                mc.setMessageBody(messageBody, isHTML: false)
                
               
                self.present(mc, animated: true, completion: nil)
                }
                else
                {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"mailalert"))!)")
                   
                   
                }
                
              
            }
            else if(indexPath.row == 1){
                
                let controller = MFMessageComposeViewController()
                if MFMessageComposeViewController.canSendText() {
                    let listid = viewListingArray.id != nil ? viewListingArray.id! : 0
                    let title = viewListingArray.title != nil ? viewListingArray.title! : ""
                    var convertedTitle =  title.replacingOccurrences(of:", ", with:"--")
                    convertedTitle = convertedTitle.replacingOccurrences(of:" ", with:"-")
                    convertedTitle = convertedTitle.replacingOccurrences(of:"#", with:"-")
                    convertedTitle = convertedTitle.replacingOccurrences(of:"/", with:"-")
                    convertedTitle = convertedTitle.replacingOccurrences(of:"%", with:"-")
                    let profileimage = "\(convertedTitle)" + "-\(listid)"
                    let urltoShare =  "\(SHARE_URL)\(String(describing: profileimage.lowercased()))"
                    
                    controller.body = "\((Utility.shared.getLanguage()?.value(forKey:"sharedesc"))!) \(viewListingArray.title!) \((Utility.shared.getLanguage()?.value(forKey:"sharedesc_next"))!) \(urltoShare)"
                    
                    controller.messageComposeDelegate = self
                    
                    self.present(controller, animated: true, completion: nil)
                }
                else
                {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"mailalert"))!)")
                }
                
               
            }
            else if(indexPath.row == 2){
                let listid = viewListingArray.id != nil ? viewListingArray.id! : 0
                let title = viewListingArray.title != nil ? viewListingArray.title! : ""
                var convertedTitle =  title.replacingOccurrences(of:", ", with:"--")
                convertedTitle = convertedTitle.replacingOccurrences(of:" ", with:"-")
                convertedTitle = convertedTitle.replacingOccurrences(of:"#", with:"-")
                convertedTitle = convertedTitle.replacingOccurrences(of:"/", with:"-")
                convertedTitle = convertedTitle.replacingOccurrences(of:"%", with:"-")
                let profileimage = "\(convertedTitle)" + "-\(listid)"
                let urltoShare =  "\(SHARE_URL)\(String(describing: profileimage.lowercased()))"
                
                UIPasteboard.general.url = URL(string:urltoShare)
                
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"linkcopy"))!)")
            }
            else if(indexPath.row == 3){
                
                let someText:String = "\((Utility.shared.getLanguage()?.value(forKey:"checkoutplace"))!) \(viewListingArray.title!)"
                let listid = viewListingArray.id != nil ? viewListingArray.id! : 0
                let title = viewListingArray.title != nil ? viewListingArray.title! : ""
                var convertedTitle =  title.replacingOccurrences(of:", ", with:"--")
                convertedTitle = convertedTitle.replacingOccurrences(of:" ", with:"-")
                convertedTitle = convertedTitle.replacingOccurrences(of:"#", with:"-")
                convertedTitle = convertedTitle.replacingOccurrences(of:"/", with:"-")
                convertedTitle = convertedTitle.replacingOccurrences(of:"%", with:"-")
                let profileimage = "\(convertedTitle)" + "-\(listid)"
                let urltoShare =  "\(SHARE_URL)\(String(describing: profileimage.lowercased()))"
                let objectsToShare:URL =  URL(string:urltoShare)!
                let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
                let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                
                activityViewController.excludedActivityTypes = [UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail]
                

                self.present(activityViewController, animated: true, completion: nil)
           
                activityViewController.completionWithItemsHandler = { activity, completed, items, error in
                    if !completed {
                       
                        return
                    }else if completed {
                        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"success"))!)")
                        return
                    }
                }
            }
            
        }
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        switch result {
        case MFMailComposeResult.cancelled:
          
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.saved:
           
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent:
            
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"emailalert"))!)")
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed: break
           
        default:
            break
        }
    
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case MessageComposeResult.cancelled:
        controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent:
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"message_alert"))!)")
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed: break
            
        default:
            break
        }
    }
    @objc func closeBtnTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
  
}

