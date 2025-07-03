//
//  GoogleLocationService.swift
//  App


import UIKit
import Alamofire


class GoogleLocationService: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    public func getlocationFromAddress(address:String, onSuccess success: @escaping (Bool) -> Void)
    {
        let urlString:String = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=\(address)&key=\(GOOGLE_API_KEY)"
        let finalURL =  urlString.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
        let GetBaseUrl = URL(string: finalURL!)!
        
        if Utility().isConnectedToNetwork(){
            
            let request = AF.request(GetBaseUrl).validate()
            
            request.responseDecodable(of: GooglePlacesResult.self) { (response) in
                guard let placesResult = response.value else {  let locDict = NSMutableDictionary()
                    locDict.setValue(nil, forKey: "lat")
                    locDict.setValue(nil, forKey: "lon")
                    Utility.shared.searchLocationDict = locDict
                    success(true)
                    return
                }
                if placesResult.status == "OK"{
                    let latitude = placesResult.results.first?.geometry.location.lat
                    let longitude = placesResult.results.first?.geometry.location.lng
                    let locDict = NSMutableDictionary()
                    locDict.setValue(latitude, forKey: "lat")
                    locDict.setValue(longitude, forKey: "lon")
                    Utility.shared.searchLocationDict = locDict
                    success(true)
                }else{
                    let locDict = NSMutableDictionary()
                    locDict.setValue(nil, forKey: "lat")
                    locDict.setValue(nil, forKey: "lon")
                    Utility.shared.searchLocationDict = locDict
                    success(true)
                }
              }
        }
    }
}
