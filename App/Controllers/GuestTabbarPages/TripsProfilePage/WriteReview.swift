
import UIKit
import Cosmos
import IQKeyboardManagerSwift
import Apollo
import Lottie

protocol WriteReviewProtocol{
    func reloadPendingReviews()
}

class WriteReview: UIViewController {
    
    
    @IBOutlet var lineview1: UIView!
    
    @IBOutlet var heightConstant: NSLayoutConstraint!
    
    @IBOutlet var lblReview: UILabel!
    @IBOutlet weak var topNavigationView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ListingImageView: UIImageView!
    @IBOutlet weak var ListingTitleName: UILabel!
    @IBOutlet weak var ListingAddressLabel: UILabel!
    @IBOutlet weak var starRatingView: CosmosView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var firstSectionLineView: UIView!
    @IBOutlet weak var DescribeExperienceLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewPlaceholder: UILabel!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var lblReviewCount: UILabel!
    
    @IBOutlet weak var overALLRatingLabel: UILabel!
    @IBOutlet weak var overALLRatingView: CosmosView!
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var offlineText: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet weak var ErrorView: UIView!
    @IBOutlet weak var Uh0hLabel: UILabel!
    @IBOutlet weak var errorDescLabel: UILabel!
    @IBOutlet weak var errorCodeLabel: UILabel!
    
    @IBOutlet var btnRating: UIButton!
    var lottieView: LottieAnimationView!
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    var reservationID = 0
    var listID = 0
    var pendingReviewListData = GetPendingUserReviewQuery.Data.GetPendingUserReview.Result()
    
    var delegate: WriteReviewProtocol?
    var isFromEmailNavigation = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnRating.setTitle("\(String())", for: .normal)
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.view.backgroundColor =   UIColor(named: "colorController")
        
        lblReview.text = "\(Utility.shared.getLanguage()?.value(forKey: "Writereviewsmall") ?? "Write a Review")"
        lblReview.font = UIFont(name: APP_FONT_MEDIUM, size:18)
        self.textView.delegate = self
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:100, height:100)
        self.view.addSubview(self.lottieView)
        self.getPendingReviewsListingData()
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.ErrorView.isHidden = true
        self.Uh0hLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "uhoh") ?? "Uh-Oh!")"
        self.errorDescLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "404alert") ?? "We can't seem to find anything that you're looking for!")"
        self.errorCodeLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "errorCode") ?? "Error Code : 404")"
        
        self.submitBtn.isHidden = true
    }

    
    func getPendingReviewsListingData(){
        if Utility.shared.isConnectedToNetwork(){
            self.lottieAnimation()
            self.scrollView.isHidden = true
            self.offlineView.isHidden = true
            
            let getPendingReview = GetPendingUserReviewQuery(reservationId: self.reservationID)
            
                    
            apollo_headerClient.fetch(query:getPendingReview,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                
                self.lottieView.isHidden = true
                self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:0, height:0)
                guard (result?.data?.getPendingUserReview?.result) != nil else{
                   
                    
                self.view.makeToast(result?.data?.getPendingUserReview?.errorMessage)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        if self.isFromEmailNavigation {
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            Utility.shared.setTab(index: 0)
                            appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
                        }else{
                        self.dismiss(animated: true, completion: nil)
                        }
                    })
                return
            }
                self.pendingReviewListData = result?.data?.getPendingUserReview?.result! as! GetPendingUserReviewQuery.Data.GetPendingUserReview.Result
                self.listID = self.pendingReviewListData.listId ?? 0
                if self.pendingReviewListData.listData == nil{
                    self.scrollView.isHidden = true
                    self.ErrorView.isHidden = false
                }else{
                    self.configureLabels()
                }
            }
        }else{
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
            
            
        }
    }
    
    func lottieAnimation(){
           self.lottieView.isHidden = false
           self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:100, height:100)
           self.lottieView.backgroundColor = UIColor.clear
           self.lottieView.layer.cornerRadius = 6.0
           self.lottieView.clipsToBounds = true
           self.lottieView.play()
       }
    
    func configureLabels(){
        self.scrollView.isHidden = false
        self.ErrorView.isHidden = true
        self.submitBtn.isHidden = false
        
        self.ListingImageView.clipsToBounds = true
        self.ListingImageView.sd_setImage(with: URL(string: "\(IMAGE_LISTING_MEDIUM)\(self.pendingReviewListData.listData?.listPhotoName ?? "")"), completed: nil)
        self.ListingImageView.contentMode = .scaleAspectFill
        self.ListingImageView.layer.cornerRadius = 10
        self.ListingImageView.layer.masksToBounds = true
        
        self.ListingAddressLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        
        btnRating.setTitleColor(UIColor(named: "searchPlaces_TextColor"), for: .normal)
        lblReviewCount.textColor = UIColor(named: "searchPlaces_TextColor")
        self.ListingAddressLabel.font = UIFont(name: APP_FONT, size: 12)
        self.ListingAddressLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.ListingAddressLabel.text = self.pendingReviewListData.listData?.roomType ?? " "
        
        self.ListingTitleName.textColor =  UIColor(named: "Title_Header")
        self.ListingTitleName.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        self.ListingTitleName.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.ListingTitleName.text = "\(self.pendingReviewListData.listData?.title ?? " "), \(self.pendingReviewListData.listData?.state ?? " "), \(self.pendingReviewListData.listData?.country ?? " ")"

        let value1 = Float(self.pendingReviewListData.listData?.reviewsCount ?? 0)
        let value2 = Float(self.pendingReviewListData.listData?.reviewsStarRating ?? 0)
        if(value2 != 0.0){
            
            let reviewcount = (value2/value1)

            self.btnRating.setTitle("\(Int(reviewcount.rounded()) ?? Int(0.0))", for: .normal)
            
            if((self.pendingReviewListData.listData?.reviewsCount!)! > 0)
            {
                lblReviewCount.text = "\u{2022} \(self.pendingReviewListData.listData?.reviewsCount! ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)"
            }
            else
            {
                lblReviewCount.text = "\u{2022} \((Utility.shared.getLanguage()?.value(forKey:"delete_no"))!) \((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)"
                
            }
            
            
            self.btnRating.isHidden = false
            heightConstant.constant = 19
        }
        else{
            self.lblReviewCount.isHidden = true
            self.btnRating.setTitle("0", for: .normal)
            heightConstant.constant = 0
            self.btnRating.isHidden = true
        }
        
        self.firstSectionLineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        lineview1.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        self.DescribeExperienceLabel.textColor =  UIColor(named: "Title_Header")
        self.DescribeExperienceLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 14)
        self.DescribeExperienceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.DescribeExperienceLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "Describe_Experience") ?? "Describe your experience (required)")"
        
        self.DescriptionLabel.textColor = UIColor(named: "Title_Header")
        self.DescriptionLabel.font = UIFont(name: APP_FONT, size: 14)
        self.DescriptionLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        if Utility.shared.getCurrentUserID() as String? == self.pendingReviewListData.guestId{
            self.DescriptionLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "Your_Review_host_Description") ?? "Your review will be public on your host profile")"
        }else{
            self.DescriptionLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "yourreview_desc") ?? "Your review will be public on your profile")"
        }
        
        self.textView.layer.cornerRadius = 5
        self.textView.layer.borderColor = UIColor(named: "Review_Page_Line_Color")?.cgColor
        self.textView.layer.borderWidth = 0.5
        self.textView.clipsToBounds = true
        self.textView.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.textView.font = UIFont(name: APP_FONT, size: 12)
        self.view.backgroundColor = UIColor(named: "colorController")
        self.lblReviewCount.font = UIFont(name: APP_FONT, size: 12)
        
        if Utility.shared.getCurrentUserID() as String? == self.pendingReviewListData.guestId{
            self.textViewPlaceholder.text = "\(Utility.shared.getLanguage()?.value(forKey: "reviewplaceholder_guest") ?? "What was it like to stay at this host's property.")"
        }else{
            self.textViewPlaceholder.text = "\(Utility.shared.getLanguage()?.value(forKey: "Review_Placeholder") ?? "What was it like to host this guest")"
        }
        self.textViewPlaceholder.font = UIFont(name: APP_FONT, size: 12)
        self.textViewPlaceholder.textColor = Theme.Review_Page_Placeholder
        self.textViewPlaceholder.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        self.overALLRatingLabel.textColor =  UIColor(named: "Title_Header")
        self.overALLRatingLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        self.overALLRatingLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.overALLRatingLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "OverALL_Reating") ?? "Overall Rating")"
        
        self.overALLRatingView.semanticContentAttribute = Utility.shared.isRTLLanguage() ? .forceRightToLeft : .forceLeftToRight
        self.overALLRatingView.didTouchCosmos = { rating in
            self.overALLRatingView.rating = rating
        }
        self.submitBtn.layer.cornerRadius = self.submitBtn.frame.size.height / 2
        self.submitBtn.clipsToBounds = true
        self.submitBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "submit") ?? "Submit")", for: .normal)
        self.submitBtn.setTitleColor(.white, for: .normal)
        self.submitBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 18)
    }
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
        if self.isFromEmailNavigation {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            Utility.shared.setTab(index: 0)
            appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
        }else{
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        let strings = self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if strings.isEmpty{
            self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey: "Required_description") ?? "Required description")")
        }else{
            if self.overALLRatingView.rating == 0.0{
                self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey: "Required_rating") ?? "Required rating")")
            }else{
                self.submitReview()
            }
        }
    }
    
    func submitReview(){
        if Utility.shared.isConnectedToNetwork(){
            self.lottieAnimation()
            self.offlineView.isHidden = true
            var receiverID = ""
            
            if Utility.shared.getCurrentUserID() as String? == self.pendingReviewListData.guestId{
                receiverID = self.pendingReviewListData.hostId ?? ""
            }else{
                receiverID = self.pendingReviewListData.guestId ?? ""
            }
            
            let submitWriteReview = WriteUserReviewMutation(reservationId: self.reservationID, listId: self.listID, reviewContent: self.textView.text.replacingOccurrences(of: "\\s+", with: " " , options: .regularExpression), rating: self.overALLRatingView.rating, receiverId: receiverID)
            
                    
            apollo_headerClient.perform(mutation: submitWriteReview){(result,error) in
                
                self.lottieView.isHidden = true
                self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:0, height:0)
                guard (result?.data?.writeUserReview?.status) == 200 else{
                    
                self.view.makeToast(result?.data?.writeUserReview?.errorMessage)
                return
            }
                self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey: "Reviewed_Successfully") ?? "Reviewed Successfully!")")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        if self.isFromEmailNavigation {
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            Utility.shared.setTab(index: 0)
                            appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
                        }else{
                            self.view.endEditing(true)
                            self.dismiss(animated: true, completion: nil)
                            self.delegate?.reloadPendingReviews()
                        }
                    })
            }
        }else{
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
            
            
        }
    }
    
    @IBAction func retryBtnClicked(_ sender: UIButton) {
        self.getPendingReviewsListingData()
    }
}

extension WriteReview : UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        self.textViewPlaceholder.isHidden = !textView.text.isEmpty
    }
    
}
