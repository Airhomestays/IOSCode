

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class MapPageVC: UIViewController,GMSMapViewDelegate {

    @IBOutlet weak var locationTitleLabel: UILabel!
    
    var mapView: GMSMapView!
    var cirlce: GMSCircle!
    var mapArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var HeadlocationLabel: UILabel!
    
    @IBOutlet weak var bookingLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let lat = mapArray.lat!
        let long = mapArray.lng!
        let camera = GMSCameraPosition.camera(withLatitude: lat,
                                                          longitude: long, zoom:15)
        
        HeadlocationLabel.textColor = UIColor(named: "Title_Header")
        locationTitleLabel.textColor = UIColor(named: "Title_Header")
        bookingLabel.textColor = UIColor(named: "Title_Header")
        self.view.backgroundColor = UIColor(named: "colorController")
        bottomView.backgroundColor = UIColor(named: "colorController")
        headerView.backgroundColor = UIColor(named: "colorController")
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.view = mapView
         headerView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 80)
        mapView.addSubview(headerView)
       
        bottomView.frame = CGRect(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 100)
        mapView.addSubview(bottomView)
        mapView.delegate = self
      
        locationTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
         HeadlocationLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
         bookingLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)

        if Utility.shared.getAppTheme() == "dark" {
        
            do {
                 
                  if let styleURL = Bundle.main.url(forResource: "mapstyle", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                  } else {
                    NSLog("Unable to find style.json")
                  }
                } catch {
                  NSLog("One or more of the map styles failed to load. \(error)")
                }
            
        }
        else if Utility.shared.getAppTheme() == nil || Utility.shared.getAppTheme() == "auto"{
           
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    do {
                         
                          if let styleURL = Bundle.main.url(forResource: "mapstyle", withExtension: "json") {
                              mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                          } else {
                            NSLog("Unable to find style.json")
                          }
                        } catch {
                          NSLog("One or more of the map styles failed to load. \(error)")
                        }
                } else {
                    
                }
            } else {
               
            }
        }
        cirlce = GMSCircle(position: camera.target, radius:400)
        cirlce.fillColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.3)
        cirlce.strokeColor = Theme.PRIMARY_COLOR
        cirlce.strokeWidth = 2.5;
        cirlce.map = mapView
        HeadlocationLabel.text = "\(mapArray.title != nil ? mapArray.title! : "") in \(mapArray.city != nil ? mapArray.city! : ""),\(mapArray.state != nil ? mapArray.state! : ""),\(mapArray.country != nil ? mapArray.country! : "")"
        locationTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"location"))!)"
        bookingLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"exactlocation"))!)"
    }
    
    private func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        cirlce.position = position.target
    }
func initialSetup()
{
   
    
    }
  

    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if traitCollection.userInterfaceStyle == .dark {
                    do {
                          if let styleURL = Bundle.main.url(forResource: "mapstyle", withExtension: "json") {
                              mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                          } else {
                            NSLog("Unable to find style.json")
                          }
                        } catch {
                          NSLog("One or more of the map styles failed to load. \(error)")
                        }
                }
                else {
                   
                }
            }
        } else {
           
        }
    }

}

