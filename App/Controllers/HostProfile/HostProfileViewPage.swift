//
//  HostProfileViewPage.swift
//  Rent_All
//
//  Created by RadicalStart on 28/11/19.
//  Copyright © 2019 RADICAL START. All rights reserved.
//

import UIKit
import Apollo
import Lottie

class HostProfileViewPage: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var topView: UIView!
    @IBOutlet var backBtn: UIButton!
    var profileid = Int()
    var profilename = String()
    
    var lottieView: LOTAnimationView!
    
    @IBOutlet var hostprofileTable: UITableView!
    
    let apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        // Add additional headers as needed
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"] // Replace `<token>`
        
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
        
    }()
    
    var showuserprofileArray = ShowUserProfileQuery.Data.ShowUserProfile.Result()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        hostprofileTable.estimatedRowHeight = 50
        hostprofileTable.rowHeight = UITableView.automaticDimension

        // Do any additional setup after loading the view.
    }
  func registerCell()
  {
    hostprofileTable.register(UINib(nibName: "HostprofileviewCell", bundle: nil), forCellReuseIdentifier: "HostprofileviewCell")
    hostprofileTable.register(UINib(nibName: "AboutDynamicCell", bundle: nil), forCellReuseIdentifier: "AboutDynamicCell")
    hostprofileTable.register(UINib(nibName: "ReportuserCell", bundle: nil), forCellReuseIdentifier: "ReportuserCell")
    hostprofileTable.register(UINib(nibName: "ReviewUserCell", bundle: nil), forCellReuseIdentifier: "ReviewUserCell")
    }
    func lottieanimation()
    {
        
        lottieView = LOTAnimationView.init(name: "animation_white")
        
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:100, height:100)
        self.view.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.play()
        // animation_white.json
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    func showprofileAPICall(profileid:Int)
    {
        if Utility().isConnectedToNetwork(){
        self.lottieanimation()
        let showprofileQuery = ShowUserProfileQuery(profileId:profileid, isUser:false)
        apollo_headerClient.fetch(query:showprofileQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            
            guard (result?.data?.showUserProfile?.results) != nil else
            {
                self.lottieView.isHidden = true
               
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"somethingwrong"))!)")
                return
            }
            
              self.lottieView.isHidden = true
            self.showuserprofileArray = ((result?.data?.showUserProfile?.results)!)
           // self.hostprofileTable.separatorStyle = .singleLine
            self.hostprofileTable.reloadData()
            //  }
            
        }
        }
        else
        {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)")
        }
        
        
    }
    
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if(showuserprofileArray.userId != nil)
        {
           if(Utility.shared.unpublish_preview_check)
            {
//                if(showuserprofileArray.info == nil || showuserprofileArray.info == "" || showuserprofileArray.location == nil || showuserprofileArray.location == "" || showuserprofileArray.reviewsCount == 0)
//                {
//                    return 1
//                }
        return 4
            }
           else if((Utility.shared.getCurrentUserID() != nil) && ("\(self.showuserprofileArray.userId!)" == "\(String(describing: Utility.shared.getCurrentUserID()!))"))
           {
//            if(showuserprofileArray.info == nil || showuserprofileArray.info == "" || showuserprofileArray.location == nil || showuserprofileArray.location == "" || showuserprofileArray.reviewsCount == 0)
//            {
//                return 1
//            }
            return 4
           }
            else
            {
//                if(showuserprofileArray.info == nil || showuserprofileArray.info == "" || showuserprofileArray.location == nil || showuserprofileArray.location == "" || showuserprofileArray.reviewsCount == 0)
//                {
//                    return 1
//                }
              return 5
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(showuserprofileArray.userId != nil)
        {
        
        if(section == 1)
        {
            if(showuserprofileArray.location != nil && showuserprofileArray.location != "")
            {
                return 1
            }
            else
            {
            return 0
            }
        }
        if(section == 2)
        {
            if(showuserprofileArray.info != nil && showuserprofileArray.info != "")
            {
                return 1
            }
            else
            {
                return 0
            }
        }
        if(section == 3)
        {
            if(showuserprofileArray.reviewsCount != 0)
            {
                return 1
            }
            else
            {
                return 0
            }
        }
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HostprofileviewCell", for: indexPath)as! HostprofileviewCell
            
            if(profilename != nil)
            {
                cell.nameLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"hi,im"))!) \(profilename)"
            }
            if showuserprofileArray.picture != nil
            {
                let profImage = showuserprofileArray.picture!
              cell.profileImage.sd_setImage(with: URL(string:"\(IMAGE_AVATAR_MEDIUM)\(profImage)"), completed: nil)
                
            }
            else
            {
               cell.profileImage.image  = #imageLiteral(resourceName: "unknown")
            }
            cell.memberLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"member"))!) \(getdayValue(timestamp: (showuserprofileArray.createdAt!)))"
            cell.selectionStyle = .none
            return cell

        }
        else if(indexPath.section == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutDynamicCell", for: indexPath)as! AboutDynamicCell
            if(showuserprofileArray.location != nil)
            {
            cell.aboutLabel.text = showuserprofileArray.location!
            }
            cell.selectionStyle = .none
            return cell
        }
        else if(indexPath.section == 2)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutDynamicCell", for: indexPath)as! AboutDynamicCell
            if(showuserprofileArray.info != nil)
            {
            cell.aboutLabel.text = showuserprofileArray.info!
            }
            cell.selectionStyle = .none
            return cell
        }
        else if(indexPath.section == 3)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewUserCell", for: indexPath)as! ReviewUserCell
            if(showuserprofileArray.reviewsCount != nil)
            {
            if(showuserprofileArray.reviewsCount! > 1)
            {
                  cell.reviewBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"read"))!) \(showuserprofileArray.reviewsCount!) \((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)", for: .normal)
            }
            else{
                  cell.reviewBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"read"))!) \(showuserprofileArray.reviewsCount!) \((Utility.shared.getLanguage()?.value(forKey:"review"))!)", for: .normal)
            }
            }
          
            cell.selectionStyle = .none
            return cell
            
        }
        else 
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportuserCell", for: indexPath)as! ReportuserCell
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 4)
        {
            if Utility().isConnectedToNetwork(){
            let reportPageObj = ReportuserPage()
            reportPageObj.profileid = profileid
            self.present(reportPageObj, animated: false, completion: nil)
            }
            else
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)")
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func getdayValue(timestamp:String) -> String
    {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MMMM YYYY"
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
