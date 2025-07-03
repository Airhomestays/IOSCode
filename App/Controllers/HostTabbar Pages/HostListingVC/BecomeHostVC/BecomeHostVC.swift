

import UIKit
import Apollo
import Lottie

class BecomeHostVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var offlineView: UIView!
    
    @IBOutlet weak var becomeStepsTable: UITableView!
    
    @IBOutlet weak var UHOhLbl: UILabel!
    
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var CantSeeLbl: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorCode404Lbl: UILabel!
    
    var lottieView: LottieAnimationView!
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var showListingstepArray = ShowListingStepsQuery.Data.ShowListingStep.Result()
    var step1ListingDetails = GetStep1ListingDetailsQuery.Data.GetListingDetail.Result()
    var step3ListingDetails = GetListingDetailsStep3Queryy.Data.GetListingDetail.Result()
    var listID = String()
    var ispublishenable:Bool = false
    var siteSettingArray = [GetSecureSiteSettingsQuery.Data.GetSecureSiteSetting.Result]()
    
    var getListingStep2Array = GetListingDetailsStep2Query.Data.GetListingDetail.Result()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.initialSetup()
        siteSettingsAPICall()
        self.lottieAnimation()
    }
    func initialSetup() {
        becomeStepsTable.register(UINib(nibName: "StepOneCell", bundle: nil), forCellReuseIdentifier: "StepOneCell")
        becomeStepsTable.register(UINib(nibName: "StepTwoCell", bundle: nil), forCellReuseIdentifier: "StepTwoCell")
        becomeStepsTable.register(UINib(nibName: "StepPublishCell", bundle: nil), forCellReuseIdentifier: "StepPublishCell")
        UHOhLbl.isHidden = true
        CantSeeLbl.isHidden = true
        errorCode404Lbl.isHidden = true
        self.view.backgroundColor =  UIColor(named: "colorController")!
        self.offlineView.isHidden = true
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        UHOhLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"uhoh"))!)"
        CantSeeLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"404alert"))!)"
        errorCode404Lbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"errorCode"))!)"
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        errorCode404Lbl.font = UIFont(name: APP_FONT, size: 15)
        UHOhLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 29)
        CantSeeLbl.font = UIFont(name: APP_FONT, size: 19)
    }
    
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-150, width:100, height:100)
        self.view.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    
    @objc func autoscroll() {
        self.lottieView.play()
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        if Utility.shared.isfromNotificationHost || Utility.shared.isfromOfflineNotification{
            Utility.shared.isfromNotificationHost = false
            Utility.shared.isfromOfflineNotification = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.addingElementsToObjects()
            Utility.shared.setHostTab(index: 0)
            appDelegate.HostTabbarInitialize(initialView: CustomHostTabbar())
        } else {
            
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func submitForVerification(listID:Int) {
        let submitforverificationmutation = SubmitForVerificationMutation(id:listID, listApprovalStatus:"pending")
        apollo_headerClient.perform(mutation: submitforverificationmutation){(result,error) in
            
            if(result?.data?.submitForVerification?.status == 200) {
                self.showListingStepsAPICall(listID:self.listID)
                
            } else {
                self.view.makeToast(result?.data?.submitForVerification?.errorMessage!)
                
            }
        }
    }
    
    
    
    func showListingStepsAPICall(listID:String) {
        let showListingStepsquery = ShowListingStepsQuery(listId: listID)
        apollo_headerClient.fetch(query: showListingStepsquery,cachePolicy:.fetchIgnoringCacheData){(result,error)in
            guard (result?.data?.showListingSteps?.results) != nil else{
                if let errorMsg = result?.data?.showListingSteps?.errorMessage, let status = result?.data?.showListingSteps?.status, status == 400 || errorMsg  == "Something went wrong" {
                    self.UHOhLbl.isHidden = false
                    self.CantSeeLbl.isHidden = false
                    self.errorCode404Lbl.isHidden = false
                    self.becomeStepsTable.isHidden = true
                }
                return
            }
            self.lottieView.isHidden = true
            self.showListingstepArray = (result?.data?.showListingSteps?.results)!
            if(!self.ispublishenable) {
                self.becomeStepsTable.reloadData()
            } else {
                self.ispublishenable = false
            }
        }
    }
    
    
    func getStep3ListingDetails() {
        let step3ListingDetailsquery = GetListingDetailsStep3Queryy(listId: listID, preview: true)
        apollo_headerClient.fetch(query: step3ListingDetailsquery,cachePolicy:.fetchIgnoringCacheData){(result,error)in
            guard (result?.data?.getListingDetails?.results) != nil else{
                if(result?.data?.getListingDetails?.status == 400) {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"nolist"))!)")
                    self.UHOhLbl.isHidden = false
                    self.CantSeeLbl.isHidden = false
                    self.errorCode404Lbl.isHidden = false
                    self.becomeStepsTable.isHidden = true
                }
                return
            }
            self.step3ListingDetails = (result?.data?.getListingDetails?.results)!
            Utility.shared.selectedRules.removeAllObjects()
            
            if(self.step3ListingDetails.listingData != nil) {
                Utility.shared.step3_Edit = true
                if let id = self.step3ListingDetails.id {
                    Utility.shared.step3ValuesInfo.updateValue(id, forKey: "id")
                    Utility.shared.createId = id
                }
                if let houserules = self.step3ListingDetails.houseRules {
                    Utility.shared.step3ValuesInfo.updateValue(houserules, forKey: "houseRules")
                }
                if(self.step3ListingDetails.listingData?.bookingNoticeTime != nil)
                {
                    Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.bookingNoticeTime!)!, forKey: "bookingNoticeTime")
                }
                if let checkinStart = self.step3ListingDetails.listingData?.checkInStart { Utility.shared.step3ValuesInfo.updateValue(checkinStart, forKey: "checkInStart") }
                if let checkInEnd = self.step3ListingDetails.listingData?.checkInEnd { Utility.shared.step3ValuesInfo.updateValue(checkInEnd, forKey: "checkInEnd")
                }
                if let maxDaysNotice = self.step3ListingDetails.listingData?.maxDaysNotice { Utility.shared.step3ValuesInfo.updateValue(maxDaysNotice, forKey: "maxDaysNotice")
                }
                if let minNight = self.step3ListingDetails.listingData?.minNight {
                    
                    Utility.shared.step3ValuesInfo.updateValue(minNight, forKey: "minNight")
                }
                if let maxNight = self.step3ListingDetails.listingData?.maxNight {
                    
                    Utility.shared.step3ValuesInfo.updateValue(maxNight, forKey: "maxNight")
                }
                if(self.step3ListingDetails.listingData?.basePrice != nil)
                { Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.basePrice!)!, forKey: "basePrice")
                    Utility.shared.host_basePrice = (self.step3ListingDetails.listingData?.basePrice!)!
                }
                
                if(self.step3ListingDetails.listingData?.guestBasePrice != nil)
                { Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.guestBasePrice!)!, forKey: "guestesOnBasePrice")
                    Utility.shared.host_GuestsOnBasePrice = Int((self.step3ListingDetails.listingData?.guestBasePrice!)!)
                }
                
                if(self.step3ListingDetails.listingData?.additionalPrice != nil)
                { Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.additionalPrice!)!, forKey: "extraGuestsPerPerson")
                    Utility.shared.host_GuestsPrice = ((self.step3ListingDetails.listingData?.additionalPrice!)!)
                }
                
                if(self.step3ListingDetails.listingData?.infantLimit != nil)
                { Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.infantLimit!)!, forKey: "infantCount")
                    Utility.shared.host_InfantCount = Int(((self.step3ListingDetails.listingData?.infantLimit!)!))
                }
                
                
                if(self.step3ListingDetails.listingData?.infantPrice != nil)
                { Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.infantPrice!)!, forKey: "infantPrice")
                    Utility.shared.host_InfantPrice = ((self.step3ListingDetails.listingData?.infantPrice!)!)
                }
                
                
                if(self.step3ListingDetails.listingData?.petLimit != nil)
                { Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.petLimit!)!, forKey: "petCount")
                    Utility.shared.host_PetCount = Int(((self.step3ListingDetails.listingData?.petLimit!)!))
                }
                
                if(self.step3ListingDetails.listingData?.petPrice != nil)
                { Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.petPrice!)!, forKey: "petPrice")
                    Utility.shared.host_PetPrice = ((self.step3ListingDetails.listingData?.petPrice!)!)
                }
                
                if(self.step3ListingDetails.listingData?.visitorsLimit != nil)
                { Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.visitorsLimit!)!, forKey: "visitorCount")
                    Utility.shared.host_VisitorCount = Int(((self.step3ListingDetails.listingData?.visitorsLimit!)!))
                }
                
                if(self.step3ListingDetails.listingData?.visitorsPrice != nil)
                { Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.visitorsPrice!)!, forKey: "visitorPrice")
                    Utility.shared.host_VisitorPrice = ((self.step3ListingDetails.listingData?.visitorsPrice!)!)
                }
                
                if(self.step3ListingDetails.listingData?.cleaningPrice != nil) {
                    Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.cleaningPrice!)!, forKey: "cleaningPrice")
                    Utility.shared.host_cleanPrice = (self.step3ListingDetails.listingData?.cleaningPrice!)!
                }
                if(self.step3ListingDetails.listingData?.tax != nil){
                    Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.tax!)!.clean, forKey: "taxesPrice")
                    Utility.shared.host_taxPrice = (self.step3ListingDetails.listingData?.tax!)!
                }
                if let currency = (self.step3ListingDetails.listingData?.currency) { Utility.shared.step3ValuesInfo.updateValue(currency, forKey: "currency")
                }
                if(self.step3ListingDetails.listingData?.weeklyDiscount != nil) {
                    Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.weeklyDiscount!)!, forKey: "weeklyDiscount")
                }
                if(self.step3ListingDetails.listingData?.monthlyDiscount != nil) {
                    Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.monthlyDiscount!)!, forKey: "monthlyDiscount")
                }
                if(self.step3ListingDetails.bookingType != nil) {
                    Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.bookingType!), forKey: "bookingType")
                }
                if(self.step3ListingDetails.listingData?.cancellationPolicy != nil) {
                    Utility.shared.step3ValuesInfo.updateValue((self.step3ListingDetails.listingData?.cancellationPolicy!)!, forKey: "cancellationPolicy")
                }
                
                let StepTwoObj = HouseRulesViewController()
                self.view.window?.backgroundColor = UIColor.white
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
            } else {
                let StepTwoObj = HouseRulesViewController()
                Utility.shared.createId = self.step3ListingDetails.id!
                Utility.shared.step3ValuesInfo.removeAll()
                Utility.shared.step3ValuesInfo.updateValue(self.step3ListingDetails.id!, forKey: "id")
                Utility.shared.selectedRules.removeAllObjects()
                Utility.shared.host_basePrice = 0
                Utility.shared.host_cleanPrice = 0
                self.view.window?.backgroundColor = UIColor.white
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
            }
        }
    }
    
    
    func siteSettingsAPICall() {
        if Utility.shared.isConnectedToNetwork(){
            let siteSettingsquery = GetSecureSiteSettingsQuery(settingsType:"site_settings", securityKey: SECURE_KEY)
            apollo_headerClient.fetch(query:siteSettingsquery,cachePolicy: .fetchIgnoringCacheData){ [self](result,error) in
                if(result?.data?.getSecureSiteSettings?.status == 200) {
                    self.siteSettingArray = result?.data?.getSecureSiteSettings?.results as! [GetSecureSiteSettingsQuery.Data.GetSecureSiteSetting.Result]
                    for i in self.siteSettingArray{
                        if(i.name == "listingApproval") {
                            if(i.value == "1") {
                                Utility.shared.listingApproval = "required"
                            } else {
                                Utility.shared.listingApproval = "optional"
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func getStep1ListingDetails() {
        let step1ListingDetailsquery = GetStep1ListingDetailsQuery(listId: listID, preview: true)
        apollo_headerClient.fetch(query: step1ListingDetailsquery,cachePolicy:.fetchIgnoringCacheData){(result,error)in
            guard (result?.data?.getListingDetails?.results) != nil else{
                if(result?.data?.getListingDetails?.status == 400) {
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"nolist"))!)")
                    self.UHOhLbl.isHidden = false
                    self.CantSeeLbl.isHidden = false
                    self.errorCode404Lbl.isHidden = false
                    self.becomeStepsTable.isHidden = true
                }
                return
            }
            Utility.shared.isfromshowmap = false
            self.step1ListingDetails = (result?.data?.getListingDetails?.results)!
            Utility.shared.selectedAmenityIdList.removeAllObjects()
            Utility.shared.selectedsafetyAmenityIdList.removeAllObjects()
            Utility.shared.selectedspaceAmenityIdList.removeAllObjects()
            
            if (result?.data?.getListingDetails?.results?.id != nil) {
                Utility.shared.step1ValuesInfo.updateValue((result?.data?.getListingDetails?.results?.id!)!, forKey: "listId")
                Utility.shared.createId = (result?.data?.getListingDetails?.results?.id!)!
            }
            
            if let country = (result?.data?.getListingDetails?.results?.country) { Utility.shared.step1ValuesInfo.updateValue(country, forKey: "country") }
            if let street = (result?.data?.getListingDetails?.results?.street) { Utility.shared.step1ValuesInfo.updateValue(street, forKey: "street")
            }
            if (result?.data?.getListingDetails?.results?.buildingName) != nil{
                Utility.shared.step1ValuesInfo.updateValue((result?.data?.getListingDetails?.results?.buildingName!)!, forKey: "buildingName")
            }
            if let city = (result?.data?.getListingDetails?.results?.city) { Utility.shared.step1ValuesInfo.updateValue(city, forKey: "city")
            }
            
            if let state = (result?.data?.getListingDetails?.results?.state) { Utility.shared.step1ValuesInfo.updateValue(state, forKey: "state")
            }
            if let zipcode = (result?.data?.getListingDetails?.results?.zipcode) { Utility.shared.step1ValuesInfo.updateValue(zipcode, forKey: "zipcode")
            }
            if((result?.data?.getListingDetails?.results?.lat != nil) && (result?.data?.getListingDetails?.results?.lng != nil)) {
                Utility.shared.step1ValuesInfo.updateValue((result?.data?.getListingDetails?.results?.lat!)!, forKey: "lat")
                Utility.shared.step1ValuesInfo.updateValue((result?.data?.getListingDetails?.results?.lng!)!, forKey: "lng")
            }
            if let isMapTouched = (result?.data?.getListingDetails?.results?.isMapTouched) { Utility.shared.step1ValuesInfo.updateValue(isMapTouched, forKey: "isMapTouched")
            }
            if let bedrooms = (result?.data?.getListingDetails?.results?.bedrooms) { Utility.shared.step1ValuesInfo.updateValue(bedrooms, forKey: "bedrooms")
            }
            if let residenceType = (result?.data?.getListingDetails?.results?.residenceType) { Utility.shared.step1ValuesInfo.updateValue(residenceType, forKey: "residenceType")
            }
            if let beds = (result?.data?.getListingDetails?.results?.beds) { Utility.shared.step1ValuesInfo.updateValue(beds, forKey: "beds")
            }
            if let userBedsTypes = (result?.data?.getListingDetails?.results?.userBedsTypes) { Utility.shared.step1ValuesInfo.updateValue(userBedsTypes, forKey: "bedTypes") }
            if let personCapacity = (result?.data?.getListingDetails?.results?.personCapacity) { Utility.shared.step1ValuesInfo.updateValue(personCapacity, forKey: "personCapacity") }
            if let bathroomCount = result?.data?.getListingDetails?.results?.bathrooms {
                Utility.shared.step1ValuesInfo.updateValue(bathroomCount, forKey: "bathrooms")
            }
            if let userAmenities = result?.data?.getListingDetails?.results?.userAmenities
            { Utility.shared.step1ValuesInfo.updateValue(userAmenities, forKey: "amenities") }
            
            if let userSafetyAmenities = result?.data?.getListingDetails?.results?.userSafetyAmenities { Utility.shared.step1ValuesInfo.updateValue(userSafetyAmenities, forKey: "safetyAmenities") }
            if let userSpaces = result?.data?.getListingDetails?.results?.userSpaces { Utility.shared.step1ValuesInfo.updateValue(userSpaces, forKey: "spaces")
            }
            for index in (result?.data?.getListingDetails?.results?.settingsData!)! {
                if index?.listsettings?.settingsType?.typeName == "roomType" {
                    Utility.shared.step1ValuesInfo.updateValue((index?.listsettings?.id!)!, forKey: "roomType")
                }
                
                if index?.listsettings?.settingsType?.typeName == "buildingSize" {
                    Utility.shared.step1ValuesInfo.updateValue((index?.listsettings?.id!)!, forKey: "buildingSize")
                }
                if index?.listsettings?.settingsType?.typeName == "bathroomType" {
                    Utility.shared.step1ValuesInfo.updateValue((index?.listsettings?.id!)!, forKey: "bathroomType")
                }
                if index?.listsettings?.settingsType?.typeName == "bedType" {
                    Utility.shared.step1ValuesInfo.updateValue((index?.listsettings?.id!)!, forKey: "bedType")
                }
            }
            if((result?.data?.getListingDetails?.results?.settingsData!.count)! > 0 ) {
                Utility.shared.step1ValuesInfo.updateValue((result?.data?.getListingDetails?.results?.settingsData![1]?.listsettings?.id!)!, forKey: "houseType")
            }
            Utility.shared.createId = Int(self.listID) ?? 0
            if(self.CheckActiveStateStep1() == "\((Utility.shared.getLanguage()?.value(forKey:"change"))!)") {
                Utility.shared.step1_inactivestatus = "completed"
                Utility.shared.isfrombecomehoststep1Edit = true
            } else {
                Utility.shared.step1_inactivestatus = "inactive"
            }
            let StepOne = PlaceListingViewController()
            StepOne.modalPresentationStyle = .fullScreen
            self.present(StepOne, animated:false, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        if(showListingstepArray.listId != nil) {
            if((showListingstepArray.listing?.isReady)! == true) {
                return 3
            }
            return 2
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(showListingstepArray.listId != nil) {
            if(section == 0) {
                return 1
            }
            else if(section == 1){
                return 2
            } else {
                if((showListingstepArray.listing?.isReady)! == true) {
                    return 1
                }
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0) {
            return 255
        }
        else if(indexPath.section == 1) {
            return UITableView.automaticDimension
            
            if (indexPath.row == 0) {
                if(CheckActiveStateStep2() == "" || CheckActiveStateStep2() == "\((Utility.shared.getLanguage()?.value(forKey:"change"))!)")
                {
                    return 100
                }
                return 165
            } else{
                if(CheckActiveStateStep3() == "" || CheckActiveStateStep3() == "\((Utility.shared.getLanguage()?.value(forKey:"change"))!)")
                {
                    return 100
                }
                return 165
            }
        } else{
            return 155
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepOneCell", for: indexPath)as! StepOneCell
            cell.editLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"edit"))!)"
            cell.selectionStyle = .none
            if(CheckActiveStateStep1() == "\((Utility.shared.getLanguage()?.value(forKey:"continue"))!)") {
                cell.hostStepImage.image = #imageLiteral(resourceName: "hoststepimage1")
            } else {
                cell.hostStepImage.image = #imageLiteral(resourceName: "hoststepimage1")
            }
            cell.changeBtn.addTarget(self, action: #selector(step1BtnTapped),for:.touchUpInside)
            return cell
        } else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepTwoCell", for: indexPath)as! StepTwoCell
            cell.selectionStyle = .none
            if(indexPath.row == 0) {
                cell.descriptionLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"photos"))!)"
                cell.titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"setscene"))!)"
                cell.stepLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"step2"))!)"
                cell.stepLabel.textColor = UIColor(named: "Title_Header")
                cell.editLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"edit"))!)"
                if(CheckActiveStateStep2() == "\((Utility.shared.getLanguage()?.value(forKey:"change"))!)") {
                    cell.stepImg.image = #imageLiteral(resourceName: "hoststepimage2")
                    cell.containerView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
                } else if(CheckActiveStateStep2() == "\((Utility.shared.getLanguage()?.value(forKey:"continue"))!)") {
                    cell.titleLabel.isHidden = false
                    cell.stepImg.image = #imageLiteral(resourceName: "hoststepimagetick2")
                    cell.containerView.backgroundColor = UIColor(named: "colorController")!
                    
                } else {
                    cell.titleLabel.isHidden = false
                    cell.stepImg.image = #imageLiteral(resourceName: "hoststepimagetick2")
                    cell.containerView.backgroundColor = UIColor(named: "colorController")!
                }
                cell.changeBtn.tag = indexPath.row
                cell.changeBtn.addTarget(self, action: #selector(step2BtnTapped),for:.touchUpInside)
            } else {
                cell.descriptionLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"bookingsettings"))!)"
                cell.titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"getready"))!)"
                cell.stepLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"step3"))!)"
                cell.stepLabel.textColor = UIColor(named: "Title_Header")
                
                cell.changeBtn.isHidden = false
                cell.arrow_img.isHidden = false
                cell.lineLabel.isHidden = false
                cell.editBottomConstraints.constant = 15;
                cell.editTopConstraints.constant = 15
                
                cell.editLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"edit"))!)"
                if(CheckActiveStateStep3() ==  "\((Utility.shared.getLanguage()?.value(forKey:"continue"))!)") {
                    cell.stepImg.image = #imageLiteral(resourceName: "hoststepimage3")
                    cell.containerView.backgroundColor = UIColor(named: "colorController")!
                    cell.titleLabel.isHidden = false
                    cell.stepImg.image = #imageLiteral(resourceName: "hoststepimagetick3")
                    Utility.shared.step3_Edit = false
                }
                else if(CheckActiveStateStep3() == "\((Utility.shared.getLanguage()?.value(forKey:"change"))!)") {
                    cell.stepImg.image = #imageLiteral(resourceName: "hoststepimage3")
                    cell.containerView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
                    Utility.shared.step3_Edit = true
                } else {
                    cell.stepImg.image = #imageLiteral(resourceName: "hoststepimagetick3")
                    cell.containerView.backgroundColor = UIColor(named: "colorController")!
                    cell.titleLabel.isHidden = false
                    cell.changeBtn.isHidden = true
                    cell.arrow_img.isHidden = true
                    cell.lineLabel.isHidden = true
                    
                    cell.editLbl.text = ""
                    
                    cell.editTrailingConstraints.constant = 0
                    cell.editBottomConstraints.constant = 0
                    
                    
                    cell.editTopConstraints.constant = 0
                    cell.containerView.backgroundColor = UIColor(named: "colorController")!
                    
                }
                cell.changeBtn.tag = indexPath.row
                cell.changeBtn.addTarget(self, action: #selector(step3BtnTapped(_:)), for: .touchUpInside)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepPublishCell", for: indexPath)as! StepPublishCell
            cell.selectionStyle = .none
            cell.publishBtn.tag = indexPath.row
            cell.previewBtn.tag = indexPath.row
            cell.tag = indexPath.row + 2000
            if(Utility.shared.listingApproval == "optional") {
                if(showListingstepArray.listing?.isPublished! == true) {
                    
                    cell.listnameLabel.text = "* \((Utility.shared.getLanguage()?.value(forKey:"listpublish"))!)"
                    cell.publishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"unpublishnow"))!)", for: .normal)
                    cell.publishBtn.isHidden =  false
                    Utility.shared.unpublish_preview_check = false
                    cell.publishBtn.isUserInteractionEnabled = true
                } else {
                    cell.listnameLabel.text = "* \((Utility.shared.getLanguage()?.value(forKey:"readypublish"))!)"
                    cell.publishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"publishnow"))!)", for: .normal)
                    cell.publishBtn.isHidden =  false
                    Utility.shared.unpublish_preview_check = true
                    cell.publishBtn.isUserInteractionEnabled = true
                }
            } else if(Utility.shared.listingApproval == "required" && showListingstepArray.listing?.listApprovalStatus == "approved") {
                if(showListingstepArray.listing?.isPublished! == true) {
                    
                    cell.listnameLabel.text = "* \((Utility.shared.getLanguage()?.value(forKey:"listpublish"))!)"
                    cell.publishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"unpublishnow"))!)", for: .normal)
                    cell.publishBtn.isHidden =  false
                    Utility.shared.unpublish_preview_check = false
                    cell.publishBtn.isUserInteractionEnabled = true
                } else {
                    cell.listnameLabel.text = "* \((Utility.shared.getLanguage()?.value(forKey:"readypublish"))!)"
                    cell.publishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"publishnow"))!)", for: .normal)
                    Utility.shared.unpublish_preview_check = true
                    cell.publishBtn.isHidden =  false
                    cell.publishBtn.isUserInteractionEnabled = true
                }
                
            } else if(Utility.shared.listingApproval == "required" && showListingstepArray.listing?.listApprovalStatus == "declined") {
                
                cell.listnameLabel.text = "* \((Utility.shared.getLanguage()?.value(forKey:"your_listing_ready"))!)"
                cell.publishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"submit_appeal"))!)", for: .normal)
                cell.publishBtn.isUserInteractionEnabled = true
                cell.publishBtn.isHidden =  false
                Utility.shared.unpublish_preview_check = false
            }
            else if(Utility.shared.listingApproval == "required" && showListingstepArray.listing?.listApprovalStatus == "pending") {
                
                cell.listnameLabel.text = "* \((Utility.shared.getLanguage()?.value(forKey:"your_listing_submisison"))!)"
                cell.publishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"waitingforAdmin"))!)", for: .normal)
                cell.publishBtn.isUserInteractionEnabled = false
                Utility.shared.unpublish_preview_check = false
                cell.publishBtn.isHidden =  true
            } else {
                cell.publishBtn.isHidden =  false
                cell.listnameLabel.text = "* \((Utility.shared.getLanguage()?.value(forKey:"your_listing_ready"))!)"
                cell.publishBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"submit_verification"))!)", for: .normal)
                cell.publishBtn.isHidden =  false
                cell.publishBtn.isUserInteractionEnabled = true
            }
            if(cell.publishBtn.titleLabel?.text == "\((Utility.shared.getLanguage()?.value(forKey:"waitingforAdmin"))!)" ) {
                cell.publishBtn.removeTarget(self, action: nil, for: .touchUpInside)
                cell.publishBtn.isUserInteractionEnabled = false
            } else {
                
                cell.publishBtn.addTarget(self, action: #selector(PublishBtnTapped),for:.touchUpInside)
                cell.publishBtn.backgroundColor = Theme.Button_BG.withAlphaComponent(1.0)
                cell.publishBtn.isUserInteractionEnabled = true
            }
            cell.previewBtn.addTarget(self, action: #selector(previewBtnTapped),for:.touchUpInside)
            return cell
        }
    }
    
    func offlineViewShow() {
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
    @objc func step1BtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            getStep1ListingDetails()
        } else {
            self.offlineViewShow()
        }
    }
    
    @objc func step2BtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            self.getListingDetailsStep2()
        } else {
            self.offlineViewShow()
        }
    }
    
    func getListingDetailsStep2() {
        let getlistingStep2query = GetListingDetailsStep2Query(listId:"\(showListingstepArray.listId!)", preview: true)
        apollo_headerClient.fetch(query: getlistingStep2query,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getListingDetails?.results) != nil else{
                self.view.makeToast(result?.data?.getListingDetails?.errorMessage)
                return
            }
            self.getListingStep2Array = (result?.data?.getListingDetails?.results)!
            let StepTwoObj = StepTwoVC()
            if ((!self.showListingstepArray.isPhotosAdded! || self.showListingstepArray.isPhotosAdded!) && (self.showListingstepArray.step2 == "completed")) {
                StepTwoObj.saveexit_Activated = "true"
            }
            if(self.showListingstepArray.step2 == "active") {
                StepTwoObj.saveexit_Activated = "false"
            }
            
            if (result?.data?.getListingDetails?.results?.title != nil) { Utility.shared.step2ValuesInfo.updateValue((result?.data?.getListingDetails?.results?.title!)!, forKey: "title")
                
            }else {
                Utility.shared.step2ValuesInfo.updateValue("", forKey: "title")
            }
            if (result?.data?.getListingDetails?.results?.description != nil) { Utility.shared.step2ValuesInfo.updateValue((result?.data?.getListingDetails?.results?.description!)!, forKey: "description")}
            else {
                Utility.shared.step2ValuesInfo.updateValue("", forKey: "description")
            }
            if (result?.data?.getListingDetails?.results?.coverPhoto != nil) { Utility.shared.step2ValuesInfo.updateValue((result?.data?.getListingDetails?.results?.coverPhoto!)!, forKey: "coverPhoto")}
            if (result?.data?.getListingDetails?.results?.id != nil) { Utility.shared.step2ValuesInfo.updateValue((result?.data?.getListingDetails?.results?.id!)!, forKey: "id")}
            Utility.shared.step2_Title = ""
            Utility.shared.step2_Description = ""
            StepTwoObj.showListingstepArray = self.showListingstepArray
            StepTwoObj.getListingDetailsStep2()
            StepTwoObj.modalPresentationStyle = .fullScreen
            self.present(StepTwoObj, animated:false, completion: nil)
        }
    }
    
    @objc func step3BtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            self.getStep3ListingDetails()
        } else {
            self.offlineViewShow()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func CheckActiveStateStep1()-> String {
        if(showListingstepArray.step1 == "active" && showListingstepArray.step2 == "inactive" && showListingstepArray.step3 == "inactive") {
            return "\((Utility.shared.getLanguage()?.value(forKey:"continue"))!)"
        } else if(showListingstepArray.step1 == "completed" && (showListingstepArray.step2 == "active" || showListingstepArray.step2 == "inactive" || showListingstepArray.step2 == "completed")) {
            return "\((Utility.shared.getLanguage()?.value(forKey:"change"))!)"
        }
        return ""
    }
    
    func CheckActiveStateStep2() ->String {
        if (!showListingstepArray.isPhotosAdded! && (showListingstepArray.step2 == "completed" || showListingstepArray.step2 == "active")) {
            
            return "\((Utility.shared.getLanguage()?.value(forKey:"continue"))!)"
        }
        else{
            if(showListingstepArray.step2 == "completed") {
                return "\((Utility.shared.getLanguage()?.value(forKey:"change"))!)"
            } else if(showListingstepArray.step2 == "active") {
                return "\((Utility.shared.getLanguage()?.value(forKey:"continue"))!)"
            } else {
                return ""
            }
        }
    }
    
    func CheckActiveStateStep3() ->String {
        if (showListingstepArray.step3 == "completed") {
            return "\((Utility.shared.getLanguage()?.value(forKey:"change"))!)"
        } else if(showListingstepArray.step3 == "inactive") {
            return ""
        } else {
            return "\((Utility.shared.getLanguage()?.value(forKey:"continue"))!)"
        }
    }
    
    @objc func PublishBtnTapped(_ sender: UIButton) {
        let cell = view.viewWithTag(sender.tag + 2000) as? StepPublishCell
        let btnsendtag: UIButton = sender
        if(btnsendtag.currentTitle == "\((Utility.shared.getLanguage()?.value(forKey:"publishnow"))!)"){
            Utility.shared.unpublish_preview_check = false
            PublishAPICall(listid:showListingstepArray.listId!, action: "publish",sender:sender,tag:sender.tag)
        } else if(btnsendtag.currentTitle == "\((Utility.shared.getLanguage()?.value(forKey:"submit_appeal"))!)" || btnsendtag.currentTitle == "\((Utility.shared.getLanguage()?.value(forKey:"submit_verification"))!)") {
            submitForVerification(listID: showListingstepArray.listId!)
        } else {
            Utility.shared.unpublish_preview_check = true
            PublishAPICall(listid: showListingstepArray.listId!, action: "unPublish",sender:sender,tag:sender.tag)
        }
    }
    
    func PublishAPICall(listid:Int,action:String,sender:UIButton,tag:Int) {
        let managepublishstatusMutation = ManagePublishStatusMutation(listId: listid, action: action)
        apollo_headerClient.perform(mutation: managepublishstatusMutation){(result,error) in
            let btnsendtag: UIButton = sender
            let cell = self.view.viewWithTag(sender.tag + 2000) as? StepPublishCell
            if(result?.data?.managePublishStatus?.status == 200) {
                self.ispublishenable = true
                self.showListingStepsAPICall(listID:self.listID)
                if(!Utility.shared.unpublish_preview_check) {
                    btnsendtag.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"unpublishnow"))!)", for: .normal)
                    cell!.listnameLabel.text = "* \((Utility.shared.getLanguage()?.value(forKey:"listpublish"))!)"
                    
                } else {
                    btnsendtag.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"publishnow"))!)", for: .normal)
                    cell!.listnameLabel.text = "* \((Utility.shared.getLanguage()?.value(forKey:"readypublish"))!)"
                }
                
            }else {
                self.view.makeToast(result?.data?.managePublishStatus?.errorMessage != nil ? result?.data?.managePublishStatus?.errorMessage! : "")
            }
        }
    }
    
    @objc func previewBtnTapped(_ sender: UIButton) {
        let viewListing = UpdatedViewListing()
        viewListing.listID = showListingstepArray.listId ?? 0
        Utility.shared.unpublish_preview_check = true
        viewListing.modalPresentationStyle = .fullScreen
        self.present(viewListing, animated: true, completion: nil)
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
        }
    }
}


