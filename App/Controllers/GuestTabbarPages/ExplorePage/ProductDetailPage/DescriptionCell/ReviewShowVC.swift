

import UIKit
import Apollo
import Cosmos

class ReviewShowVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var reviewTable: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var reviewHeaderView: UIView!
    @IBOutlet weak var starRatingView: CosmosView!
    @IBOutlet weak var reviewTitleView: UILabel!
    @IBOutlet weak var reviewHeaderHeightConstraint: NSLayoutConstraint!
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
      
        if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
        {
      
        }
        else {
            configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        }
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var reiewListingArray = [UserReviewsQuery.Data.UserReview.Result]()
    var profileID = Int()
    var pageIndex : Int = 1
    var reviewcount = Int()
    var isForProfileReviews = false
    
    var propertyReviewArray = [GetPropertyReviewsQuery.Data.GetPropertyReview.Result]()
    var propertyReviewsCount = 0
    var reviewTitle = ""
    var isMoveToCell = true
    var moveToIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Utility.shared.isRTLLanguage() {
            self.backBtn.imageView?.performRTLTransform()
        }
        
        self.view.backgroundColor =   UIColor(named: "colorController")
                   titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        reviewTable.register(UINib(nibName: "ReviewlistCellTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewlistCellTableViewCell")
        reviewTable.register(UINib(nibName: "PastReviewCells", bundle: nil), forCellReuseIdentifier: "pastReview")
        
        if(reviewcount > 1)
        {
            titleLabel.text = "\(reviewcount) \((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)"
              
        }
        else{
            titleLabel.text = "\(reviewcount) \((Utility.shared.getLanguage()?.value(forKey:"review"))!)"
            
        }
        
        titleLabel.textColor = UIColor(named: "Title_Header")
        self.reviewTitleView.textColor =  UIColor(named: "Title_Header")
        self.reviewTitleView.font = UIFont(name: APP_FONT_BOLD, size: 24)
        self.reviewTitleView.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        
        if isForProfileReviews{
            self.titleLabel.isHidden = false
  self.reviewcountAPICall(profileid:profileID)
            self.reviewHeaderView.isHidden = true
            self.reviewHeaderHeightConstraint.constant = 0
        }else{
            self.titleLabel.isHidden = true
            self.getPropertyReviewsAPICall(lisId: profileID)
            self.reviewHeaderView.isHidden = false
            self.reviewTitleView.text = reviewTitle
            self.reviewHeaderHeightConstraint.constant = 40
        }
    }

    func getPropertyReviewsAPICall(lisId:Int){
        
     let propertyReviewsQuery = GetPropertyReviewsQuery(currentPage: pageIndex, listId: profileID)
        apollo_headerClient.fetch(query: propertyReviewsQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getPropertyReviews?.results) != nil else{
                self.view.makeToast(result?.data?.getPropertyReviews?.errorMessage)
                return
            }
            
            if result?.data?.getPropertyReviews?.currentPage == 1{
                self.propertyReviewArray.removeAll()
            }
            self.propertyReviewsCount = result?.data?.getPropertyReviews?.count ?? 0
            self.propertyReviewArray.append(contentsOf: ((result?.data?.getPropertyReviews?.results)!) as! [GetPropertyReviewsQuery.Data.GetPropertyReview.Result] )
             self.reviewTable.reloadData()
            
            
            if self.isMoveToCell{
                self.reviewTable.scrollToRow(at: IndexPath(row: self.moveToIndex, section: 0), at: .top, animated: true)
            }
        }
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isForProfileReviews ? reiewListingArray.count : propertyReviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isForProfileReviews{
            
                let cell : PastReviewCells = tableView.dequeueReusableCell(withIdentifier: "pastReview", for: indexPath) as! PastReviewCells
                cell.selectionStyle = .none
                
                
                cell.btnRatingProfile.isHidden = true
                cell.btnratingidth.constant = 0
                cell.btnratingLeading.constant = 0
            cell.dateLeading.constant = 16.5
                if !(self.reiewListingArray[indexPath.row].isAdmin ?? true){
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                    NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                ]
                    
                    let authorName = "\(self.reiewListingArray[indexPath.row].authorData?.fragments.profileFields.firstName ?? "")"
                    let attributedString = NSMutableAttributedString(string: authorName , attributes: attributes as [NSAttributedString.Key : Any])
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                    NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                ]
                let attributedString2 = NSMutableAttributedString(string: "'s", attributes: attributes2 as [NSAttributedString.Key : Any])
                let attributes3 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                    NSAttributedString.Key.foregroundColor:  UIColor(named: "Title_Header")
                ]
                let attributedString3 = NSMutableAttributedString(string: " " + "\(Utility.shared.getLanguage()?.value(forKey: "review") ?? "Review")", attributes: attributes3 as [NSAttributedString.Key : Any])
                
                attributedString.append(attributedString2)
                attributedString.append(attributedString3)
                
                    cell.titleLabel.tag = indexPath.row
   
                    cell.titleLabel.isUserInteractionEnabled = true
                    
                    cell.profileBtn.tag = indexPath.row
                    cell.profileBtn.removeTarget(self, action: nil, for: .allEvents)

                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                    cell.titleLabel.tag = indexPath.row
                    cell.titleLabel.addGestureRecognizer(tapGesture)
                    cell.titleLabel.isUserInteractionEnabled = true
                    
                    cell.profileBtn.tag = indexPath.row
                    cell.profileBtn.removeTarget(self, action: nil, for: .allEvents)
                    cell.profileBtn.addTarget(self, action: #selector(upComingProfileBtnTapped), for: .touchUpInside)
                    
                cell.titleLabel.attributedText = attributedString
                    
                    cell.titleLabel.isHidden = false
 
                    cell.profileImageView.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(self.reiewListingArray[indexPath.row].authorData?.fragments.profileFields.picture ?? "")"), placeholderImage: #imageLiteral(resourceName: "adminAvatar"), completed: nil)
                    let value1 = Float("\(self.reiewListingArray[indexPath.row].reviewContent ?? "0.0") ") ?? 0.0
                              let value2 = Float("\(self.reiewListingArray[indexPath.row].rating ?? 0.0)") ?? 0.0
                              if(value2 != 0.0){
                                  cell.btnRating.isHidden = false
                                  if (value1 != 0.0) {
                                  let divideValue = value2/value1
                                      cell.btnRating.setTitle(" \(Int(divideValue.rounded())) ", for: .normal)
                                     
                                  }
                                  else {
                                      cell.btnRating.setTitle(" \(Int(value2)) ", for: .normal)
                                  }
                              }else{
                                  cell.btnRating.isHidden = true
                                  cell.btnRating.setTitle(" 0.0 ", for: .normal)

                              }
  
                    cell.reviewContentLabel.text = self.reiewListingArray[indexPath.row].reviewContent
                    cell.reviewDateLabel.text = self.timestampconvertForAllReview(timestamp: self.reiewListingArray[indexPath.row].createdAt ?? "")
                    
                }else{
                    let attributes = [
                                   NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                                   NSAttributedString.Key.foregroundColor:  UIColor(named: "Title_Header")
                               ]
                                   
                    let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "Verifiedby") ?? "Verified by") \(Utility.shared.getLanguage()?.value(forKey: "appname") ?? "RentALL")" , attributes: attributes as [NSAttributedString.Key : Any])
                    
                    cell.titleLabel.attributedText = attributedString
                    
                    cell.titleLabel.isHidden = false
 
                    cell.titleLabel.tag = indexPath.row
                    cell.titleLabel.isUserInteractionEnabled = false
                    
                    cell.profileBtn.tag = indexPath.row
                    cell.profileBtn.removeTarget(self, action: nil, for: .allEvents)
                    
                    cell.profileImageView.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(self.reiewListingArray[indexPath.row].authorData?.fragments.profileFields.picture ?? "")"), placeholderImage: #imageLiteral(resourceName: "adminAvatar"), completed: nil)
                    
                    let value1 = Float("\(self.reiewListingArray[indexPath.row].reviewContent ?? "0.0") ") ?? 0.0
                              let value2 = Float("\(self.reiewListingArray[indexPath.row].rating ?? 0.0)") ?? 0.0
                              if(value2 != 0.0){
                                  cell.btnRating.isHidden = false
                                  if (value1 != 0.0) {
                                  let divideValue = value2/value1
                                      cell.btnRating.setTitle(" \(Int(divideValue.rounded())) ", for: .normal)
                                  }
                                  else {
                                      cell.btnRating.setTitle(" \(Int(value2)) ", for: .normal)
                                  }
                              }else{
                                  cell.btnRating.isHidden = true
                                  cell.btnRating.setTitle(" 0.0 ", for: .normal)

                              }
   
                    cell.reviewContentLabel.text = self.reiewListingArray[indexPath.row].reviewContent
                    cell.reviewDateLabel.text = self.timestampconvertForAllReview(timestamp: self.reiewListingArray[indexPath.row].createdAt ?? "")
                }

                
                return cell
            
        }else{
            let cell : PastReviewCells = tableView.dequeueReusableCell(withIdentifier: "pastReview", for: indexPath) as! PastReviewCells
            cell.selectionStyle = .none
            
            
            cell.btnRatingProfile.isHidden = true
            cell.btnratingidth.constant = 0
            cell.btnratingLeading.constant = 0
            cell.dateLeading.constant = 16.5
            if !(self.propertyReviewArray[indexPath.row].isAdmin ?? true){
            let attributes = [
                NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
            ]
                
                let authorName = "\(self.propertyReviewArray[indexPath.row].authorData?.fragments.profileFields.firstName ?? "")"
                let attributedString = NSMutableAttributedString(string: authorName , attributes: attributes as [NSAttributedString.Key : Any])
            let attributes2 = [
                NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
            ]
            let attributedString2 = NSMutableAttributedString(string: "'s", attributes: attributes2 as [NSAttributedString.Key : Any])
            let attributes3 = [
                NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                NSAttributedString.Key.foregroundColor:  UIColor(named: "Title_Header")
            ]
            let attributedString3 = NSMutableAttributedString(string: " " + "\(Utility.shared.getLanguage()?.value(forKey: "review") ?? "Review")", attributes: attributes3 as [NSAttributedString.Key : Any])
            
            attributedString.append(attributedString2)
            attributedString.append(attributedString3)

                cell.titleLabel.tag = indexPath.row

                cell.titleLabel.isUserInteractionEnabled = true
                
                cell.profileBtn.tag = indexPath.row
                cell.profileBtn.removeTarget(self, action: nil, for: .allEvents)

                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                cell.titleLabel.tag = indexPath.row
                cell.titleLabel.addGestureRecognizer(tapGesture)
                cell.titleLabel.isUserInteractionEnabled = true
                
                cell.profileBtn.tag = indexPath.row
                cell.profileBtn.removeTarget(self, action: nil, for: .allEvents)
                cell.profileBtn.addTarget(self, action: #selector(upComingProfileBtnTapped), for: .touchUpInside)
                
            cell.titleLabel.attributedText = attributedString
                
                cell.titleLabel.isHidden = false

                cell.profileImageView.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(self.propertyReviewArray[indexPath.row].authorData?.fragments.profileFields.picture ?? "")"), placeholderImage: #imageLiteral(resourceName: "adminAvatar"), completed: nil)
                let value1 = Float("\(self.propertyReviewArray[indexPath.row].reviewContent ?? "0.0") ") ?? 0.0
                          let value2 = Float("\(self.propertyReviewArray[indexPath.row].rating ?? 0.0)") ?? 0.0
                          if(value2 != 0.0){
                              cell.btnRating.isHidden = false
                              if (value1 != 0.0) {
                              let divideValue = value2/value1
                                  cell.btnRating.setTitle(" \(Int(divideValue.rounded())) ", for: .normal)
                                 
                              }
                              else {
                                  cell.btnRating.setTitle(" \(Int(value2)) ", for: .normal)
                              }
                          }else{
                              cell.btnRating.isHidden = true
                              cell.btnRating.setTitle(" 0.0 ", for: .normal)

                          }

                cell.reviewContentLabel.text = self.propertyReviewArray[indexPath.row].reviewContent
                cell.reviewDateLabel.text = self.timestampconvertForAllReview(timestamp: self.propertyReviewArray[indexPath.row].createdAt ?? "")
                
            }else{
                let attributes = [
                               NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                               NSAttributedString.Key.foregroundColor:  UIColor(named: "Title_Header")
                           ]
                               
                let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "Verifiedby") ?? "Verified by") \(Utility.shared.getLanguage()?.value(forKey: "appname") ?? "RentALL")" , attributes: attributes as [NSAttributedString.Key : Any])
                
                cell.titleLabel.attributedText = attributedString
                
                cell.titleLabel.isHidden = false

                cell.titleLabel.tag = indexPath.row
                cell.titleLabel.isUserInteractionEnabled = false
                
                cell.profileBtn.tag = indexPath.row
                cell.profileBtn.removeTarget(self, action: nil, for: .allEvents)
                
                cell.profileImageView.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(self.propertyReviewArray[indexPath.row].authorData?.fragments.profileFields.picture ?? "")"), placeholderImage: #imageLiteral(resourceName: "adminAvatar"), completed: nil)
                
                let value1 = Float("\(self.propertyReviewArray[indexPath.row].reviewContent ?? "0.0") ") ?? 0.0
                          let value2 = Float("\(self.propertyReviewArray[indexPath.row].rating ?? 0.0)") ?? 0.0
                          if(value2 != 0.0){
                              cell.btnRating.isHidden = false
                              if (value1 != 0.0) {
                              let divideValue = value2/value1
                                  cell.btnRating.setTitle(" \(Int(divideValue.rounded())) ", for: .normal)
                              }
                              else {
                                  cell.btnRating.setTitle(" \(Int(value2)) ", for: .normal)
                              }
                          }else{
                              cell.btnRating.isHidden = true
                              cell.btnRating.setTitle(" 0.0 ", for: .normal)

                          }
                

                cell.reviewContentLabel.text = self.propertyReviewArray[indexPath.row].reviewContent
                cell.reviewDateLabel.text = self.timestampconvertForAllReview(timestamp: self.propertyReviewArray[indexPath.row].createdAt ?? "")
            }

            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func reviewcountAPICall(profileid:Int)
      {
          let reviewListquery = UserReviewsQuery(ownerType: "others", currentPage:pageIndex, profileId: profileid)
          
          apollo_headerClient.fetch(query: reviewListquery){(result,error) in
              
              
            guard (result?.data?.userReviews?.results) != nil else{
                 
                  return
              }
            self.reiewListingArray.append(contentsOf: ((result?.data?.userReviews?.results)!) as! [UserReviewsQuery.Data.UserReview.Result])
       
    
            self.reviewTable.reloadData()
          
          }
          
      }
    func timestampconvert(timestamp:String) -> String
      {
          let timestamValue = Int(timestamp)!/1000
          let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "MMMM yyyy"
          
        let reviewDate = dateFormatter.string(from: newTime)
        return reviewDate
      }
    func timestampconvertForAllReview(timestamp:String) -> String
    {
        let timestamValue = Int(timestamp)!/1000
        let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, yyyy"
        
      let reviewDate = dateFormatter.string(from: newTime)
      return reviewDate
    }
      func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
      {
        let totalPages = (reviewcount/10)
               let height = scrollView.frame.size.height
               let contentYoffset = scrollView.contentOffset.y
               let distanceFromBottom = scrollView.contentSize.height - contentYoffset
               if((self.reviewTable.contentOffset.y + self.reviewTable.bounds.height) >= self.reviewTable.contentSize.height)
               {
                  
                   if(totalPages >= pageIndex){
                       self.pageIndex = self.pageIndex + 1
                    if isForProfileReviews{
                        self.reviewcountAPICall(profileid:profileID)
                    }else{
                        self.getPropertyReviewsAPICall(lisId: profileID)
                    }
                       
                   }
               }
    }
    
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
    guard let a = (sender.view as? UILabel)?.text else { return }
        self.goToProfilePage(tag: (sender.view as? UILabel)?.tag ?? 0)
    }
    
    
    @objc func upComingProfileBtnTapped(sender: UIButton){
        self.goToProfilePage(tag: sender.tag)
    }
    
    func goToProfilePage(tag: Int){
        if isForProfileReviews{
            let editprofileobj = HostProfileViewPage()
            editprofileobj.isfromreview = true;
            editprofileobj.profileid = self.reiewListingArray[tag].authorData?.fragments.profileFields.profileId ?? 0
            editprofileobj.profilename = self.reiewListingArray[tag].authorData?.fragments.profileFields.firstName ?? ""
            editprofileobj.showprofileAPICall(profileid:self.reiewListingArray[tag].authorData?.fragments.profileFields.profileId ?? 0)
            editprofileobj.modalPresentationStyle = .fullScreen
            self.present(editprofileobj, animated: true, completion: nil)
        }
        
        else {
        let editprofileobj = HostProfileViewPage()
        editprofileobj.isfromreview = true;
        editprofileobj.profileid = self.propertyReviewArray[tag].authorData?.fragments.profileFields.profileId ?? 0
        editprofileobj.profilename = self.propertyReviewArray[tag].authorData?.fragments.profileFields.firstName ?? ""
        editprofileobj.showprofileAPICall(profileid:self.propertyReviewArray[tag].authorData?.fragments.profileFields.profileId ?? 0)
        editprofileobj.modalPresentationStyle = .fullScreen
        self.present(editprofileobj, animated: true, completion: nil)
        }
    }
   
}

