

import Foundation
import UIKit
import Apollo



let FULLWIDTH  = UIScreen.main.bounds.width

let FULLHEIGHT = UIScreen.main.bounds.height

let OFFLINEY = FULLHEIGHT - 150

let DEFAULT_LANGUAGE = "English"

let Currency_Symbol = "$"


enum Environment: String {
    case development = "dev"
    case production = "production"
    case localhost = "localhost"
}


let environment = Environment.production
var BASE_URL : String {
    get {
         switch environment {
                case .development:
                        return "<development_baseurl>"
                    case .production:
                        return "https://www.airhomestays.com"
                    case .localhost:
                        return "<local_baseurl>"
         }
    }
}


let IMAGE_AVATAR_MEDIUM = "\(BASE_URL)/images/avatar/medium_"
let IMAGE_AVATAR_SMALL = "\(BASE_URL)/images/avatar/medium_"
let IMAGE_AVATAR_URL = "\(BASE_URL)/images/avatar/"
let IMAGE_LISTING_MEDIUM = "\(BASE_URL)/images/upload/x_medium_"
let IMAGE_LISTING_SMALL = "\(BASE_URL)/images/upload/x_medium_"
let POPULAR_LOCATION_IMAGE = "\(BASE_URL)/images/popularLocation/"
let amenitiesIcons = "\(BASE_URL)/images/amenities/"
let IMAGE_UPLOAD_PHOTO = "\(BASE_URL)/uploadPhoto"
let LISTINGIMAGE_UPLOAD = "\(BASE_URL)/uploadListPhoto"
let WHY_HOST_IMG = "\(BASE_URL)/images/whyhost/"
let SAFETY_URL = "\(BASE_URL)/safety/"
let SHARE_URL = "\(BASE_URL)/rooms/"
let ABOUT_URL = "\(BASE_URL)/about"
let TERMS_URL = "\(BASE_URL)/privacy"
let HELP_URL = "\(BASE_URL)/contact"
let Banner_URL = "\(BASE_URL)/images/banner/"
let GUEST = "guest"
let HOST = "host"
let SECURE_KEY = "JjQI:gHf+^=D"


//MARK: - Font

let APP_FONT = "BeVietnamPro-Regular"
let APP_FONT_MEDIUM = "BeVietnamPro-Medium"
let APP_FONT_SEMIBOLD = "BeVietnamPro-SemiBold"
let APP_FONT_BOLD = "BeVietnamPro-Bold"

//MARK: Device Models
let IS_IPHONE_XR = UIDevice().userInterfaceIdiom == .phone && (UIScreen.main.nativeBounds.height == 1792 || UIScreen.main.nativeBounds.height == 2688)
let IS_IPHONE_X = UIDevice().userInterfaceIdiom == .phone && (UIScreen.main.nativeBounds.height == 2436)
let IS_IPHONE_PLUS = UIDevice().userInterfaceIdiom == .phone && (UIScreen.main.nativeBounds.height == 2208 || UIScreen.main.nativeBounds.height == 1920)
let IS_IPHONE_678 = UIDevice().userInterfaceIdiom == .phone && (UIScreen.main.nativeBounds.height == 1334)
let IS_IPHONE_5 = UIDevice().userInterfaceIdiom == .phone && (UIScreen.main.nativeBounds.height == 1136)
let IS_IPHONE_XS_MAX = UIDevice().userInterfaceIdiom == .phone && (UIScreen.main.nativeBounds.height == 2688)

let categoryIdentifier = "myNotificationCategory"



var GOOGLE_API_KEY : String{
    get{
        switch environment{
        case .development:
            return "map_key"
        case .production:
            return "AIzaSyADTR96YfGXPY-xRgGNk9CaR5AObraLF18"
            
        case .localhost:
            return ""
        }
    }
}

var STRIPE_PUBLISHABLE_KEY : String{
    get{
        switch environment{
        case .development:
            return "test_stripekey"
        case .production:
            return "live_stripekey"
        case .localhost:
            return "test_stripekey"
        }
    }
}

var PayPal_Client_ID : String{
    get{
        switch environment{
        case .development:
            return "YOUR_PAYPAL_CLIENT"
        case .production:
            return "YOUR_PAYPAL_CLIENT"
        case .localhost:
            return ""
        }
    }
}

var graphQLEndpoint : String {
    get {
            switch environment {
                 case .development:
                            return "<development_graphQLEndpoint>"
                        case .production:
                            return "https://www.airhomestays.com/api/graphql"
                        case .localhost:
                            return "<local_graphQLEndpoint>"
                  }
    }
}

let GOOGLE_CLIENT_ID = "445200847344-5o1ubikc2nihep6m4b869avvb8vmie2a.apps.googleusercontent.com"
let apollo = ApolloClient(url: URL(string:graphQLEndpoint)!)


func convertToDictionary(text: String) -> [[String: Any]]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
        } catch {
        }
    }
    return nil
}

let inboxDateFormat = "MM-dd-yyyy"
let guestTripsDateFormat = "MM/dd/YYYY"
let itenarayReceiptDayFormat = "EEE"
let itenararyReceiptDateFormat = "MMM dd yyyy"
let receiptformat = "MMM dd yyyy"
let kEmptyString = ""
