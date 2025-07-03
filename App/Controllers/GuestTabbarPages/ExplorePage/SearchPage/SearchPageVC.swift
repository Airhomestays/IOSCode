

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftMessages

protocol searchPageProtocol{
    func callSearchAPI()
}
class SearchPageVC: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet var placesTable: UITableView!
    
    @IBOutlet weak var offlineView: UIView!
    
    var locationManager = CLLocationManager()
    var fetcher: GMSAutocompleteFetcher?
    var locationArray = NSMutableArray()
    var delegate: searchPageProtocol?
    var isResetTapped = false
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var searchTextField: CustomUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        fetcher = GMSAutocompleteFetcher.init()
        fetcher?.delegate = self
        
        if Utility.shared.isRTLLanguage() {
            searchTextField.setLeftPadding()
        } else {
            searchTextField.setRightPadding()
        }
       
        
        nodataLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "notfound") ?? "Result Not Found")"
        nodataLbl.textColor =  UIColor(named: "Title_Header")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        placesTable.register(UINib(nibName: "SearchPalceCell", bundle: nil), forCellReuseIdentifier: "SearchPalceCell")
        placesTable.separatorColor = UIColor.clear
        placesTable.estimatedRowHeight = UITableView.automaticDimension
        placesTable.reloadData()
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLabel.font = UIFont(name: APP_FONT, size: 15)
        
        self.setUpdatedView()
    }
    
    func setUpdatedView(){
        
        self.topView.backgroundColor =  UIColor(named: "becomeAHostStep_Color")
        
        self.backBtn.backgroundColor = UIColor.white
        self.backBtn.layer.cornerRadius = 20
        self.backBtn.clipsToBounds = true
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.resetBtn.backgroundColor = .clear
        self.resetBtn.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .leading : .trailing
        self.resetBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "reset") ?? "Reset")", for: .normal)
        self.resetBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        self.searchTextField.placeholder = "\(Utility.shared.getLanguage()?.value(forKey: "losangeles") ?? "Where do you go?")"
        self.searchTextField.delegate = self
        self.searchTextField.font = UIFont(name: APP_FONT, size: 14)
        self.searchTextField.textColor =  UIColor(named: "Title_Header")
        self.searchTextField.becomeFirstResponder()
        self.searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.searchTextField.backgroundColor = UIColor(named: "colorController")
        
        self.view.backgroundColor = UIColor(named: "colorController")
        
        let searchIconView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let searchIcon = UIImageView()
        searchIcon.frame = CGRect(x: 22, y: 18, width: 15, height: 15)
        searchIcon.image = UIImage(named: "search_icon")
        searchIcon.contentMode = .scaleAspectFit
        searchIconView.addSubview(searchIcon)
        
        if Utility.shared.isRTLLanguage(){
            self.searchTextField.rightView = searchIconView
            self.searchTextField.rightViewMode = .always
            self.searchTextField.textAlignment = .right
        }else{
            self.searchTextField.leftView = searchIconView
            self.searchTextField.leftViewMode = .always
            self.searchTextField.textAlignment = .left
        }
        
        self.searchTextField.layer.cornerRadius = 10
        self.searchTextField.clipsToBounds = true
        self.searchTextField.layer.masksToBounds = false
        self.searchTextField.layer.shadowColor = Theme.TextLightColor.cgColor
        self.searchTextField.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.searchTextField.layer.shadowOpacity = 0.3
        
        if(Utility.shared.locationfromSearch != "" && Utility.shared.locationfromSearch != nil){
            self.searchTextField.text = Utility.shared.locationfromSearch
            fetcher?.sourceTextHasChanged(searchTextField.text!)
            self.resetBtn.isHidden = false
        } else {
            self.searchTextField.text = ""
            self.resetBtn.isHidden = true
        }
        
        self.isResetTapped = false
    }
    
    @IBAction func onClickBackBtn(_ sender: UIButton) {
        if isResetTapped{
            Utility.shared.locationfromSearch = "empty"
            self.delegate?.callSearchAPI()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickResetBtn(_ sender: UIButton) {
        self.locationArray.removeAllObjects()
        self.resetBtn.isHidden = true
        self.placesTable.reloadData()
        Utility.shared.locationfromSearch = ""
        self.searchTextField.text = ""
        self.isResetTapped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.offlineView.isHidden = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        fetcher?.sourceTextHasChanged(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.getLocationDetails(address: textField.text!, primary_text: textField.text!)
        Utility.shared.locationfromSearch = textField.text
        Utility.shared.roomtypeArray.removeAllObjects()

        return true
    }
    

    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
            placesTable.reloadData()
        }
    }
    
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let locationObj = tableView.dequeueReusableCell(withIdentifier: "SearchPalceCell", for: indexPath) as! SearchPalceCell
        locationObj.selectionStyle = .none
        if(self.locationArray.count != 0) {
            let locationDict:NSDictionary =  self.locationArray.object(at: indexPath.row) as! NSDictionary
            locationObj.configCell(locationDict: locationDict)
            locationObj.locationLbl.frame = CGRect(x: 60, y: 20, width: FULLWIDTH-70, height: 20)
        }
        return locationObj
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Utility().isConnectedToNetwork() {
            if(self.locationArray.count > 0) {
                let aString = ((self.locationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "address_full") as! String)
                let bString = ((self.locationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "address_first") as? String)!
                let cString = bString.replacingOccurrences(of: "&", with: "", options: .literal, range: nil)
                Utility.shared.locationfromSearch = aString.replacingOccurrences(of: "&", with: "", options: .literal, range: nil)
                self.getLocationDetails(address:Utility.shared.locationfromSearch!, primary_text:cString)
            }
            else
            {
                Utility.shared.locationfromSearch = ""
                self.dismiss(animated: true, completion: nil)
            }
        }else{
            self.offlineView.isHidden = false
            self.searchTextField.resignFirstResponder()
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-75, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return locationArray.count > 0 ? 50 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let googleImg = UIImageView()
        googleImg.backgroundColor = UIColor(named: "colorController")
        googleImg.image = UIImage(named: "PoweredByGoogleWB")
        googleImg.contentMode = .center
        return googleImg
    }
    
    
    func getLocationDetails(address:String,primary_text:String) {
        let locationObj  = GoogleLocationService()
        locationObj.getlocationFromAddress(address: address, onSuccess: {response in
            if response{
                if( Utility.shared.locationfromSearch == ""){
                    Utility.shared.locationfromSearch = "empty"
                }
                self.delegate?.callSearchAPI()
                self.dismiss(animated: true, completion: nil)
            }else{
            }
        })
    }
    @objc func keyboardWillHide(sender: NSNotification) {
    }
    
}


extension SearchPageVC: GMSAutocompleteFetcherDelegate {
    func didFailAutocompleteWithError(_ error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        self.locationArray.removeAllObjects()
        if predictions.isEmpty {
            if searchTextField.text!.isEmpty {
                nodataLbl.isHidden = true
                placesTable.isHidden = false
            } else {
                nodataLbl.isHidden = false
                placesTable.isHidden = true
            }
            placesTable.reloadData()
        }
        for prediction in predictions {
            let mutableDict = NSMutableDictionary()
            mutableDict.setValue(prediction.attributedPrimaryText.string, forKey: "address_first")
            mutableDict.setValue(prediction.attributedSecondaryText?.string, forKey: "address_second")
            mutableDict.setValue(prediction.attributedFullText.string, forKey: "address_full")
            self.locationArray.addObjects(from: [mutableDict])
            placesTable.isHidden = false
            nodataLbl.isHidden = true
            self.resetBtn.isHidden = false
            placesTable.reloadData()
            placesTable.separatorColor = UIColor.lightGray
        }
    }
}

