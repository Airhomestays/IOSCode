
import UIKit
import AssetsPickerViewController
import Photos
import Alamofire
import Apollo
import Lottie

class StepTwoVC: BaseHostTableviewController,UICollectionViewDelegate,UICollectionViewDataSource,AssetsPickerViewControllerDelegate{
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet var progressBarWidth: NSLayoutConstraint!
    
    @IBOutlet var tipLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var erroRLabel: UILabel!
    @IBOutlet weak var offlinView: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var photoAddTable: UITableView!
    
    @IBOutlet weak var topView: UIView!
    var addphotoCollection: UICollectionView?
    var longPressGesture = UILongPressGestureRecognizer()
    var saveexit_Activated = String()
    var longPressedEnabled:Bool = false
    
    var assets = [PHAsset]()
    lazy var cellSize: CGSize = {
        return CGSize(width:FULLWIDTH, height: 230)
    }()
    lazy var imageManager = {
        return PHCachingImageManager()
    }()
    var imagesData = [Data]()
    var showListingstepArray = ShowListingStepsQuery.Data.ShowListingStep.Result()
    var showListPhotosArray = [ShowListPhotosQuery.Data.ShowListPhoto.Result]()
    var getListingStep2Array = GetListingDetailsStep2Query.Data.GetListingDetail.Result()
    
    var multiimages_Selected:Bool = false
    var multiimages_count:Int = 0
    var selected_Cover_Array =  NSMutableArray()
    var isdelete_API_call:Bool = false
    let appstatechecker = UIApplication.shared.applicationState
    let basecontroller = BaseHostTableviewController()
    
    
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        nextBtn.backgroundColor = Theme.Button_BG
        saveBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = UIColor.white
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "addphotolist") ?? "Add photos to your listing")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        
        self.stepsTitleView.whichStep = 2
        self.stepsTitleView.selectedViewIndex = 0
        self.stepsTitleView.delegateSteps = self
    }
    
    override func setUpUI() {
        self.initialSetup()
    }
    override func setDropdownList() {
        
    }
    override func registerCells() {
        photoAddTable.register(UINib(nibName: "addPhotosCell", bundle: nil), forCellReuseIdentifier: "addPhotosCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        self.isdelete_API_call = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
        progressBarWidth.constant = self.view.frame.size.width/2
    }
   
    func initialSetup() {
        
        bottomView.backgroundColor =  UIColor(named: "colorController")
        curvedView.backgroundColor = UIColor(named: "colorController")
        collectionView.backgroundColor = UIColor(named: "colorController")
        
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.layer.masksToBounds = true
        skipBtn.layer.borderWidth = 2
        skipBtn.layer.borderColor = Theme.Button_BG.cgColor
        skipBtn.backgroundColor = Theme.Button_BG
        skipBtn.setTitleColor(UIColor.white, for: .normal)
        skipBtn.titleLabel?.textColor = UIColor.white
        skipBtn.layer.cornerRadius = skipBtn.frame.size.height / 2
        skipBtn.layer.masksToBounds = true
        skipBtn.isHidden = true
        nextBtn.isHidden = true
        if(saveexit_Activated == "true") {
            saveBtn.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleHeightConstraint.constant = 50
            self.stepTitleTopConstraint.constant = 5
        } else {
            saveBtn.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleHeightConstraint.constant = 0
            self.stepTitleTopConstraint.constant = 0
        }
        self.offlinView.isHidden = true
        erroRLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
        skipBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"skipnow"))!)", for:.normal)
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for:.normal)
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        erroRLabel.textColor =  UIColor(named: "Title_Header")
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        skipBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        saveBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        erroRLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        tipLabel.font = UIFont(name: APP_FONT, size: 12)
        tipLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"photosdesc"))!)"
        tipLabel.textColor =  UIColor(named: "searchPlaces_TextColor")
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "AddphotoCell", bundle: nil), forCellWithReuseIdentifier: "AddphotoCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: ((collectionView.frame.size.width/2)-10), height: 102)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = flowLayout
    }
    @objc func reloadtableView(_ notification: Notification) {
        photoAddTable.setContentOffset(.zero, animated: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
    }
    @objc func scrollToBottom() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row:0,section: 0)
        }
        
    }
    
    func showlistingPhotosAPICall()
    {
        if Utility().isConnectedToNetwork(){
            let showlistingphotosquery = ShowListPhotosQuery(listId: showListingstepArray.listId!)
            super.apollo_headerClient.fetch(query: showlistingphotosquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                guard (result?.data?.showListPhotos?.results) != nil else{
                    self.skipBtn.isHidden = false
                    self.nextBtn.isHidden = true
                    self.showListPhotosArray.removeAll()
                    self.collectionView.reloadData()
                    return
                }
                self.showListPhotosArray = (result?.data?.showListPhotos?.results)! as! [ShowListPhotosQuery.Data.ShowListPhoto.Result]
                if(self.showListPhotosArray.count > 0)
                {
                    self.skipBtn.isHidden = true
                    self.nextBtn.isHidden = false
                } else {
                    self.skipBtn.isHidden = false
                    self.nextBtn.isHidden = true
                }
                
                if(!self.isdelete_API_call) {
                    self.collectionView.reloadData()
                    self.scrollToBottom()
                } else {
                    self.collectionView.reloadData()
                }
            }
        } else {
            self.collectionView.reloadData()
            self.offlineviewShow()
        }
    }
    
    func getListingDetailsStep2() {
        if Utility().isConnectedToNetwork(){
            let getlistingStep2query = GetListingDetailsStep2Query(listId:"\(showListingstepArray.listId!)", preview: true)
            super.apollo_headerClient.fetch(query: getlistingStep2query,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                guard (result?.data?.getListingDetails?.results) != nil else{
                    self.showlistingPhotosAPICall()
                    return
                }
                self.getListingStep2Array = (result?.data?.getListingDetails?.results)!
                Utility.shared.host_step2_isfromEdit = true
                self.showlistingPhotosAPICall()
            }
        } else {
            self.offlineviewShow()
        }
    }
    
    
    func deleteAPICall(name:String) {
        if Utility().isConnectedToNetwork(){
            let RemoveListPhotosmutation = RemoveListPhotosMutation(listId:(showListingstepArray.listId!), name:name)
            apollo_headerClient.perform(mutation: RemoveListPhotosmutation){(result,error) in
                if(result?.data?.removeListPhotos?.status == 200) {
                    self.isdelete_API_call = true
                    self.showlistingPhotosAPICall()
                    
                } else {
                    if(result?.data?.removeListPhotos?.errorMessage != "filename not exist") {
                        if(result?.data?.removeListPhotos?.errorMessage != nil) {
                            self.view.makeToast(result?.data?.removeListPhotos?.errorMessage != nil ? result?.data?.removeListPhotos?.errorMessage! : "")
                        }
                    }
                }
            }
        } else {
            self.offlineviewShow()
        }
    }
    func offlineviewShow() {
        self.offlinView.isHidden = false
        self.nextBtn.isHidden = true
        let shadowSize2 : CGFloat = 3.0
        let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                    y: -shadowSize2 / 2,
                                                    width: self.offlinView.frame.size.width + shadowSize2,
                                                    height: self.offlinView.frame.size.height + shadowSize2))
        
        self.offlinView.layer.masksToBounds = false
        offlinView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.offlinView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.offlinView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.offlinView.layer.shadowOpacity = 0.3
        self.offlinView.layer.shadowPath = shadowPath2.cgPath
        if IS_IPHONE_X || IS_IPHONE_XR{
            offlinView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
        }else{
            offlinView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
        }
    }
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.nextBtn.isHidden = true
            self.offlinView.isHidden = true
            self.showlistingPhotosAPICall()
            
        }
    }
    
    @IBAction func saveexitTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            
            self.view.endEditing(true)
            super.updatelistingStep2APICall{(success) -> Void in
                if success {
                } else {
                    self.goToBecomeAHost()
                }
            }
        }else {
            self.offlineviewShow()
        }
    }
    
    func goToBecomeAHost(){
        let becomeHostObj = BecomeHostVC()
        becomeHostObj.listID = "\(Utility.shared.step2ValuesInfo["id"] != nil ? Utility.shared.step2ValuesInfo["id"] as! Int : 0)"
        becomeHostObj.showListingStepsAPICall(listID:"\(Utility.shared.step2ValuesInfo["id"] != nil ? Utility.shared.step2ValuesInfo["id"] as! Int : 0)")
        becomeHostObj.modalPresentationStyle = .fullScreen
        self.present(becomeHostObj, animated:false, completion: nil)
    }
    
    func updateAPICall() {
        
        if(getListingStep2Array.id != nil) {
            var coverphoto = Int()
            var desc = String()
            var title = String()
            
            if(Utility.shared.host_photo_coverid == 0) {
                if(getListingStep2Array.coverPhoto != nil) {
                    coverphoto = getListingStep2Array.coverPhoto!
                    
                } else {
                    coverphoto = 0
                }
            } else {
                coverphoto = Utility.shared.host_photo_coverid
            }
            
            desc = getListingStep2Array.description != nil ? getListingStep2Array.description! : ""
            
            
            title = getListingStep2Array.title != nil ? getListingStep2Array.title! : ""
            
            let UpdateListingStep2mutation = UpdateListingStep2Mutation(id:getListingStep2Array.id!, description:desc, title:title, coverPhoto:coverphoto)
            apollo_headerClient.perform(mutation: UpdateListingStep2mutation){ (result,error) in
                
                if(result?.data?.updateListingStep2?.status == 200) {
                    let becomeHostObj = BecomeHostVC()
                    becomeHostObj.listID = "\(self.getListingStep2Array.id!)"
                    becomeHostObj.showListingStepsAPICall(listID:"\(self.getListingStep2Array.id!)")
                    becomeHostObj.modalPresentationStyle = .fullScreen
                    self.present(becomeHostObj, animated: false, completion: nil)
                    
                } else {
                    self.view.makeToast(result?.data?.updateListingStep2?.errorMessage)
                }
            }
        }
        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if(saveexit_Activated == "true") {
            self.goToBecomeAHost()
        }else{
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func skipBtnTappe(_ sender: Any) {
    }
    @IBAction func nextBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            let listTitleObj = ListingTitleVC()
            Utility.shared.host_step2_listId = showListingstepArray.listId != nil ? showListingstepArray.listId! : 0
            listTitleObj.saveexit_Activated = saveexit_Activated
            listTitleObj.getListingStep2Array = getListingStep2Array
            listTitleObj.showListingstepArray = showListingstepArray
            self.view.window?.backgroundColor = UIColor.white
            listTitleObj.modalPresentationStyle = .fullScreen
            self.present(listTitleObj, animated:false, completion: nil)
        }else {
            self.offlineviewShow()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if(showListPhotosArray.count > 0) {
            return 1
        }
        else if(multiimages_Selected) {
            return 1
        } else{
            return 0
        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(showListPhotosArray.count > 0 ||  multiimages_Selected) {
            return 1
        }
        return 0
        
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cellIdentifier"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        for subView in (cell?.contentView.subviews)! {
            subView.removeFromSuperview()
        }
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        cell?.backgroundColor = UIColor.clear
        cell?.selectionStyle = .none
        let contentview = UIView()
        let layout = UICollectionViewFlowLayout()
        
        if(!multiimages_Selected) {
            contentview.frame = CGRect(x: 0, y: 10, width: Int(FULLWIDTH), height: (240 * (showListPhotosArray.count)))
            
            addphotoCollection = UICollectionView(frame: CGRect(x: 0, y: 10, width: Int(FULLWIDTH), height: ((showListPhotosArray.count) * 240)),collectionViewLayout: layout)
        } else {
            if(showListPhotosArray.count == 0) {
                contentview.frame = CGRect(x: 0, y: 10, width: Int(FULLWIDTH), height: (240 * (multiimages_count)))
                
                addphotoCollection = UICollectionView(frame: CGRect(x: 0, y: 10, width: Int(FULLWIDTH), height: ((multiimages_count) * 240)),collectionViewLayout: layout)
            } else {
                contentview.frame = CGRect(x: 0, y: 10, width: Int(FULLWIDTH), height: (240 * (showListPhotosArray.count)))
                
                addphotoCollection = UICollectionView(frame: CGRect(x: 0, y: 10, width: Int(FULLWIDTH), height: ((showListPhotosArray.count+multiimages_count) * 240)),collectionViewLayout: layout)
            }
        }
        addphotoCollection?.tag = indexPath.row
        addphotoCollection?.isScrollEnabled = false
        addphotoCollection?.dataSource = self
        addphotoCollection?.delegate = self
        addphotoCollection?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellIdentifier")
        addphotoCollection?.backgroundColor = .clear
        addphotoCollection?.showsHorizontalScrollIndicator = false
        if let aView = addphotoCollection {
            contentview.addSubview(aView)
        }
        if let flowLayout = addphotoCollection!.collectionViewLayout as? UICollectionViewFlowLayout {
            
            flowLayout.estimatedItemSize = CGSize(width:FULLWIDTH-30, height:230)
        }
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        addphotoCollection?.addGestureRecognizer(longPressGesture)
        addphotoCollection?.register(UINib(nibName: "AddphotoCell", bundle: nil), forCellWithReuseIdentifier: "AddphotoCell")
        
        DispatchQueue.main.async {
            self.addphotoCollection?.reloadData()
        }
        
        cell?.contentView.addSubview(contentview)
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(showListPhotosArray.count > 0) {
            if(!multiimages_Selected) {
                return CGFloat(showListPhotosArray.count * 240)
            } else {
                if(showListPhotosArray.count == 0) {
                    return CGFloat(multiimages_count * 240)
                }
                return CGFloat((showListPhotosArray.count+multiimages_count) * 240)
            }
        }
        return 0
    }
    
    @objc func addbtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            self.isdelete_API_call = false
            let picker = AssetsPickerViewController()
            picker.pickerConfig.assetIsShowCameraButton = false
            picker.pickerDelegate = self
            present(picker, animated: true, completion: nil)
        } else {
            self.offlineviewShow()
        }
        
    }
    
    @objc func longTap(_ gesture: UIGestureRecognizer){
        
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = addphotoCollection!.indexPathForItem(at: gesture.location(in: addphotoCollection)) else {
                return
            }
            addphotoCollection!.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            addphotoCollection!.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            addphotoCollection!.endInteractiveMovement()
            
            longPressedEnabled = true
            self.addphotoCollection!.reloadData()
        default:
            addphotoCollection!.cancelInteractiveMovement()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(!multiimages_Selected) {
            return (showListPhotosArray.count + 1)
        } else {
            if(showListPhotosArray.count == 0) {
                return (multiimages_count + 1)
            } else {
                return (showListPhotosArray.count + multiimages_count + 1)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddphotoCell", for: indexPath) as! AddphotoCell
        cell.tag = indexPath.row + 2000
        
        if indexPath.row == 0{
            cell.addNewPhotoView.isHidden = false
            cell.addphotoimage.backgroundColor = UIColor(named: "becomeAHostStep_Color")
            cell.addphotoimage.cornerRadius = 5.0
            cell.addphotoimage.image = #imageLiteral(resourceName: "dashview")
            cell.addphotoimage.contentMode  = .scaleToFill
            cell.addPhotoBtn.addTarget(self, action: #selector(addbtnTapped), for: .touchUpInside)
            
            cell.coverLabel.isHidden = true
            cell.coverbutton.isHidden = true
            cell.closebtn.isHidden = true
            cell.lottieView.isHidden = true
            cell.checkimg.isHidden = true
            collectionView.isUserInteractionEnabled = true
        }else{
            
            cell.addNewPhotoView.isHidden = true
            cell.addphotoimage.backgroundColor = .clear
            cell.addphotoimage.contentMode  = .scaleAspectFill
            cell.coverLabel.isHidden = false
            cell.coverbutton.isHidden = false
            cell.closebtn.isHidden = false
            cell.coverbutton.backgroundColor = Theme.photo_color
            cell.coverLabel.backgroundColor = UIColor.clear
            cell.checkimg.isHidden = true
            cell.closebtn.tag = (indexPath.row-1)
            cell.closebtn.addTarget(self, action: #selector(deleteBtnTapped), for: .touchUpInside)
            if(showListPhotosArray.count > (indexPath.row-1)) {
                cell.lottieView.isHidden = true
                collectionView.isUserInteractionEnabled = true
                if(showListPhotosArray[indexPath.row-1].name != nil) {
                    let profImage = showListPhotosArray[indexPath.row-1].name!
                    cell.addphotoimage.sd_setImage(with: URL(string:"\(IMAGE_LISTING_MEDIUM)\(profImage)"), completed: nil)
                } else {
                    cell.addphotoimage.image = #imageLiteral(resourceName: "box-with-like")
                }
                if(selected_Cover_Array.contains(showListPhotosArray[indexPath.row-1].id) || showListPhotosArray.count == 1) {
                    cell.coverbutton.backgroundColor = Theme.PRIMARY_COLOR
                    cell.coverLabel.backgroundColor = UIColor.clear
                    cell.checkimg.isHidden = false
                    
                } else {
                    if(Utility.shared.host_step2_isfromEdit) {
                        if(getListingStep2Array.coverPhoto != nil) {
                            if((getListingStep2Array.coverPhoto! == showListPhotosArray[indexPath.row-1].id) && (selected_Cover_Array.count == 0)) {
                                
                                cell.coverbutton.backgroundColor = Theme.PRIMARY_COLOR
                                cell.coverLabel.backgroundColor = UIColor.clear
                                cell.checkimg.isHidden = false
                            } else {
                                cell.coverbutton.backgroundColor = Theme.photo_color
                                cell.coverLabel.backgroundColor = UIColor.clear
                                cell.checkimg.isHidden = true
                            }
                        }
                    } else {
                        cell.coverbutton.backgroundColor = Theme.photo_color
                        cell.coverLabel.backgroundColor = UIColor.clear
                        cell.checkimg.isHidden = true
                    }
                }
                
                cell.coverbutton.tag = (indexPath.row-1)
                cell.coverbutton.addTarget(self, action: #selector(CoverbtnTapped), for: .touchUpInside)
                
            } else {
                if(multiimages_Selected) {
                    cell.addphotoimage.image = nil
                    cell.closebtn.isHidden = true
                    cell.coverLabel.isHidden = true
                    cell.coverbutton.isHidden = true
                    cell.coverbutton.backgroundColor = .clear
                    cell.lottieAnimation()
                    collectionView.isUserInteractionEnabled = false
                    
                } else {
                    cell.lottieView.isHidden = true
                    collectionView.isUserInteractionEnabled = true
                }
            }
            
            
            if(selected_Cover_Array.count == 0 && !Utility.shared.host_step2_isfromEdit && showListPhotosArray.count != 0) {
                Utility.shared.host_photo_coverid = showListPhotosArray[0].id
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        
        let tmp = showListPhotosArray[sourceIndexPath.item]
        showListPhotosArray[sourceIndexPath.item] = showListPhotosArray[destinationIndexPath.item]
        showListPhotosArray[destinationIndexPath.item] = tmp
        
        addphotoCollection?.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:((collectionView.frame.size.width/2)-10), height:102)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = view.viewWithTag(indexPath.row + 2000) as? AddphotoCell
    }
    @objc func CoverbtnTapped(_ sender: UIButton){
        if Utility().isConnectedToNetwork(){
            
            if(showListPhotosArray.count > 1) {
                Utility.shared.host_step2_isfromEdit = true
                if selected_Cover_Array.contains(showListPhotosArray[sender.tag].id){
                    selected_Cover_Array.remove(showListPhotosArray[sender.tag].id)
                }else{
                    selected_Cover_Array.removeAllObjects()
                    selected_Cover_Array.add(showListPhotosArray[sender.tag].id)
                    Utility.shared.host_photo_coverid = showListPhotosArray[sender.tag].id
                    Utility.shared.step2ValuesInfo.updateValue(showListPhotosArray[sender.tag].id, forKey: "coverPhoto")
                }
                collectionView.reloadData()
            }
        }
        
    }
    @objc func deleteBtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            if((showListPhotosArray.count > sender.tag) && showListPhotosArray[sender.tag].name != nil) {
                self.deleteAPICall(name:showListPhotosArray[sender.tag].name!)
            }
        } else {
            self.offlineviewShow()
        }
    }
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        
        if Utility.shared.isConnectedToNetwork(){
            self.offlinView.isHidden = true
            if(showListPhotosArray.count > 0) {
                self.ScrolltoBottom()
            }
            self.assets = assets
            self.imagesData.removeAll()
            for asset in self.assets {
                
                let image =  self.getAssetThumbnail(asset: asset)
                if((image.jpegData(compressionQuality:0.0)) != nil ) {
                    self.imagesData.append((image.jpegData(compressionQuality:0.0))!)
                }
            }
            multiimages_count = imagesData.count
            self.multiimages_Selected = true
            self.collectionView.reloadData()
            DispatchQueue.global(qos: .background).async {
                
                self.uploadProfilePic(profileimage: self.imagesData,onSuccess:{response in
                })
            }
        }else{
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)")
        }
        
        
    }
    func getUIImage(asset: PHAsset) -> UIImage? {
        
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img!
    }
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width:FULLWIDTH, height:500), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
            if(result != nil) {
                thumbnail = result!
            } else {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"somethingwrong"))!)")
            }
        })
        return thumbnail
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
    func ScrolltoBottom() {
        DispatchQueue.main.async {
            if(self.showListPhotosArray.count > 0) {
                let indexPath = IndexPath(row:0,section:1)
            }
        }
    }
    func Scrolltoup() {
        DispatchQueue.main.async {
            if(self.showListPhotosArray.count > 0) {
                let indexPath = IndexPath(row:0,section:1)
            }
        }
    }
    
    func uploadProfilePic(profileimage:[Data],onSuccess success: @escaping (NSDictionary) -> Void) {
        if Utility().isConnectedToNetwork(){
            let BaseUrl = URL(string: LISTINGIMAGE_UPLOAD)
            let header = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
            let parameters = ["listId": "\(showListingstepArray.listId!)"]
            
            
            AF.upload(multipartFormData: { (multipartFormData) in
                for imageData in self.imagesData {
                    multipartFormData.append(imageData, withName: "file", fileName: "file.jpeg", mimeType: "image/jpeg")
                }
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
                
            },to: BaseUrl!, usingThreshold: UInt64.init(),
                      method: .post,
                      headers: HTTPHeaders.init(header)).responseData(completionHandler: { [self] responseData in
                if(responseData.error == nil){
                    checkUploadStatus(rseposneData: responseData.data!)
                    
                }else{
                    self.lottieView.isHidden = true
                    self.collectionView.isUserInteractionEnabled = true
                }
            })
        } else {
            self.offlineviewShow()
        }
        
    }
    
    func checkUploadStatus(rseposneData: Data) {
        do {
            let obj = try JSONSerialization.jsonObject(with: rseposneData, options: .mutableContainers) as! NSDictionary
            if obj.value(forKey: "status") as! Int == 200 {
                self.multiimages_Selected = false
                self.getListingDetailsStep2()
            } else {
                self.view.makeToast(obj.value(forKey: "errorMessage") as? String)
            }
            self.lottieView.isHidden = true
            self.collectionView.isUserInteractionEnabled = true
        } catch {
            
        }
    }
}

extension StepTwoVC: stepsUpdateProtocol{
    func selectedPage(step: Int, selectedPageIndex: Int) {
        if step == 2{
            switch selectedPageIndex{
            case 0:
                break
            case 1:
                let listTitleObj = ListingTitleVC()
                Utility.shared.host_step2_listId = showListingstepArray.listId != nil ? showListingstepArray.listId! : 0
                listTitleObj.saveexit_Activated = saveexit_Activated
                listTitleObj.getListingStep2Array = getListingStep2Array
                listTitleObj.showListingstepArray = showListingstepArray
                self.view.window?.backgroundColor = UIColor.white
                listTitleObj.modalPresentationStyle = .fullScreen
                self.present(listTitleObj, animated:false, completion: nil)
                break
            case 2:
                let listingDescriptionObj = ListingDescriptionVC()
                if let title = Utility.shared.step2ValuesInfo["title"] as? String{
                    Utility.shared.host_step2_title = title
                }
                listingDescriptionObj.saveexit_Activated = saveexit_Activated
                listingDescriptionObj.getListingStep2Array = getListingStep2Array
                listingDescriptionObj.showListingstepArray = showListingstepArray
                listingDescriptionObj.modalPresentationStyle = .fullScreen
                self.present(listingDescriptionObj, animated:false, completion: nil)
                break
            default:
                break
            }
        }
    }
}
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

