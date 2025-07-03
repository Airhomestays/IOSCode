

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

struct State {
    let name: String
    let long: CLLocationDegrees
    let lat: CLLocationDegrees
}

class SearchResuktsMapPeage: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var locationDetailArray = NSMutableArray()
    var markerPriceLblArray = NSMutableArray()
    var markerImageArray = NSMutableArray()
    @IBOutlet var listCollectionView: UICollectionView!
    
    var imageArray = [#imageLiteral(resourceName: "maps_location"),#imageLiteral(resourceName: "fb_logo"),#imageLiteral(resourceName: "settings")]

    var mapView = GMSMapView()
    
    let states = [
        State(name: "$23.25", long: -87.67404850000003, lat: 41.88024427395285),
        State(name: "$34.54", long: 77.20902120000005, lat: 28.613637708026058),
        State(name: "$52.35", long: 106.86484399999995, lat: -6.159638670368251),
        State(name: "$47.87", long: -122.44458377724607, lat: 37.786934018630014),
        State(name: "$35.67", long: -3.947513830688422, lat: 56.1235511889461),
      
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureGoogleMap()
        

        let backBtn = UIButton()
        backBtn.frame = CGRect(x: 20, y: 30, width: 20, height: 20)
        let image = UIImage(named: "close.png") as UIImage?
        backBtn.setImage(image, for: UIControl.State.normal)
        backBtn.addTarget(self, action: #selector(backBtnTapped), for: .touchUpInside)
        self.view .addSubview(backBtn)
        performSelector(inBackground: #selector(addingPin), with: nil)

    }
    @objc func backBtnTapped(_ sender: UIButton!)
    {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func addingPin()
    {
        var firstFlage : Bool = true
        var selectedIndex : Int = 0
        for state in states
        {
            let state_marker = GMSMarker()
            
            state_marker.position = CLLocationCoordinate2D(latitude: state.lat, longitude: state.long)
            state_marker.userData = selectedIndex
         
            var customImage = UIImage(named: "price_tag.png") as UIImage?

            let nameLbl = UILabel()
            nameLbl.textAlignment = .center
            nameLbl.textColor = Theme.TextDarkColor
          
            nameLbl.text = "$234.0"
            nameLbl.frame = CGRect(x: 0, y: 4, width: nameLbl.intrinsicContentSize.width+20, height: 20)

            nameLbl.backgroundColor = UIColor.clear
            
            let markerImage = UIImageView()
            markerImage.frame = CGRect(x: 0, y: 0, width: nameLbl.intrinsicContentSize.width+20, height: 40)
            if firstFlage
            {
                firstFlage = false
                 customImage = UIImage(named: "price_tag_color.svg") as UIImage?
                nameLbl.textColor = UIColor.white
            }
            markerImage.image = customImage
            
            let customView = UIView()
            customView.frame = CGRect(x: 0, y: 0, width: nameLbl.intrinsicContentSize.width+20, height: 40)
            customView.backgroundColor = UIColor.clear
            customView.addSubview(markerImage)
            customView.addSubview(nameLbl)
            state_marker.iconView = customView
        
            markerPriceLblArray.add(nameLbl as UILabel)
            markerImageArray.add(markerImage as UIImageView)
            
            state_marker.map = mapView
            selectedIndex += 1
            let camera = GMSCameraPosition.camera(withLatitude: state.lat, longitude: state.long, zoom: 1.0)
            self.mapView.animate(to: camera)
        }

    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        
        let markerIndex : Int = marker.userData as! Int
        
        let count = self.states.count
        for i in 0..<count
        {
            let dummyMarkerImage  = markerImageArray.object(at: i) as! UIImageView
            let dummyPriceLbl = markerPriceLblArray.object(at: i) as! UILabel
            dummyPriceLbl.textColor = Theme.TextDarkColor
            
            var customImage = UIImage(named: "price_tag.png") as UIImage?
            if i == markerIndex
            {
                customImage = UIImage(named: "price_tag_color.svg") as UIImage?
                dummyPriceLbl.textColor = UIColor.white
            }
            dummyMarkerImage.image = customImage
        }
        return true
    }
    
    @objc internal func locationBtnTapped(_ sender: UIButton)
    {
     
    }

    func configureGoogleMap(){
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT-200), camera: camera)
        mapView.isMyLocationEnabled = false
        mapView.settings.myLocationButton = false
        mapView.padding = UIEdgeInsets.init(top: 0, left: 0, bottom: 5, right: 5)
        mapView.mapType = .terrain
        mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.view.addSubview(mapView)
        do {
            if let styleURL = Bundle.main.url(forResource: "mapstyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
               
            }
        } catch {
            
        }
    }
}




