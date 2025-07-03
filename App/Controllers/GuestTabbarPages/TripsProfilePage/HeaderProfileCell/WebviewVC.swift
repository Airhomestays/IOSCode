

import UIKit
import WebKit
import Lottie
import Apollo

protocol WebviewVCDelegate {
    func setPayoutCall(accountid:String)
    func onSuccessPayPalPayment(isSuccess: Bool, toastermsg: String, successURL: URL?)
}

class WebviewVC: UIViewController,WKNavigationDelegate {
    @IBOutlet var lblContent: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn:UIButton!
     var webview = WKWebView()
    @IBOutlet var scrollView: UIScrollView!
    var lottieView: LottieAnimationView!
    var webstring = String()
    var succesURL = String()
    var failureURL = String()
    var preferences = WKPreferences()
    var delegate:WebviewVCDelegate!
    var accountID = String()
    var isFromStaticContent : Bool = false
    @IBOutlet weak var pageTitleLabel: UILabel!
    var pageTitle = ""
    var isForPayPal: Bool = false
    var id:Int = 0
    var staticContentArray = [GetStaticPageContentQuery.Data.GetStaticPageContent.Result]()
    
    @IBOutlet var textContent: UITextView!
    
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor =   UIColor(named: "colorController")
        scrollView.showsVerticalScrollIndicator = false
        lottieView = LottieAnimationView.init(name:"animation")
        if IS_IPHONE_XR
        {
            webview.frame = CGRect(x: 0, y:(self.topView.frame.maxY+(UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20.0)), width: FULLWIDTH, height: FULLHEIGHT-60)
        }
        else{
            webview.frame = CGRect(x: 0, y:(self.topView.frame.maxY+(UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20.0)), width: FULLWIDTH, height: FULLHEIGHT-60)
        }
        
        if(!isFromStaticContent) {
            scrollView.isHidden = true
        self.view.addSubview(webview)
        }
        else {
            scrollView.isHidden = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            self.staticContentAPICall()
        }
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = Theme.ButtonBack_BG
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if(Utility.shared.isRTLLanguage()) {
            backBtn.imageView?.performRTLTransform()
        }
        
        self.pageTitleLabel.text = pageTitle
        self.pageTitleLabel.textColor = UIColor(named: "Title_Header")
        self.pageTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.pageTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
    }
    func lottieAnimation(){
        
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-150, width:100, height:100)
        self.webview.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
         Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

        if self.isForPayPal{
            delegate.onSuccessPayPalPayment(isSuccess: false, toastermsg: "\(Utility.shared.getLanguage()?.value(forKey: "User_Cancelled") ?? "User Cancelled")", successURL: nil)
        }
    }
    func webviewRedirection(webviewString:String)
    {
        webview.navigationDelegate = self
        let url = URL (string: webviewString)
        let requestObj = URLRequest(url: url!)
        preferences = WKPreferences()
        preferences.javaScriptEnabled = false
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        self.webview.load(requestObj)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        self.lottieAnimation()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        let removeElementIdScript = "javascript:(function() { " + "document.getElementsByClassName('rentAllHeader')[0].style.display='none';})()"
        webView.evaluateJavaScript(removeElementIdScript) { (response, error) in
            
        }

        let elementID = "intercom-container"
        let removeElementIdScript1 = "var element = document.getElementById('\(elementID)'); element.parentElement.removeChild(element);"
        webView.evaluateJavaScript(removeElementIdScript1) { (response, error) in
        }
      
        lottieView.isHidden = true
       
       
    }
  func webView(
             _ webView: WKWebView,
             decidePolicyFor navigationAction: WKNavigationAction,
             decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

             guard let url = navigationAction.request.url else {
                 decisionHandler(.allow)
                 return
             }
    
    if self.isForPayPal{
        if url.absoluteString.contains("/success?"){
            decisionHandler(.cancel)
            self.dismiss(animated: true, completion: nil)
            delegate.onSuccessPayPalPayment(isSuccess: true,toastermsg: "", successURL: url.absoluteURL)
        }else if url.absoluteString.contains("/cancel"){
            decisionHandler(.cancel)
            self.dismiss(animated: true, completion: nil)
            delegate.onSuccessPayPalPayment(isSuccess: false,toastermsg: "\(Utility.shared.getLanguage()?.value(forKey: "somethingwrong") ?? "Something went wrong")", successURL: nil)
        }else{
            decisionHandler(.allow)
        }
    }else{
             let Cur_URL = URL(fileURLWithPath: succesURL)
            if url.absoluteString.contains("/payout/success") {
                 decisionHandler(.cancel)
                let accountIDVal = self.getQueryStringParameter(url:succesURL, param: "account")

                delegate?.setPayoutCall(accountid:accountIDVal!)
                _ = self.dismiss(animated: true, completion: nil)
             }
            else if url.absoluteString.contains("/payout/failure"){
                   
                  decisionHandler(.cancel)
                   
                      let alert = UIAlertController(title: "Oops", message: "\((Utility.shared.getLanguage()?.value(forKey:"stripe_connection_failed"))!)", preferredStyle: .alert)
                      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        let accountIDVal = self.getQueryStringParameter(url:self.failureURL, param: "account")
                        let payoutObj = PayoutPreferenceVC()
                                                                                          Utility.shared.isfrom_payoutcurrency = true
                                                                                           payoutObj.modalPresentationStyle = .fullScreen
                                                                                          self.present(payoutObj, animated: true, completion: nil)
                      }))
                      self.present(alert, animated: true) {
                      }
                   
                  
                }
             else {
                 if navigationAction.navigationType == .linkActivated {
                         guard let url = navigationAction.request.url else {return}
                     UIApplication.shared.open(url, options: [:], completionHandler: nil)
                     }
                 decisionHandler(.allow)
             }
    }
         }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    
    func staticContentAPICall()
    {
        if Utility.shared.isConnectedToNetwork(){
            let staticContentQuery = GetStaticPageContentQuery(id: self.id)
            apollo_headerClient.fetch(query:staticContentQuery,cachePolicy: .fetchIgnoringCacheData){ [self](result,error) in
                if(result?.data?.getStaticPageContent?.status == 200)
                {
                    let content = result?.data?.getStaticPageContent?.result?.content
                    textContent.attributedText = content?.htmlToAttributedString
                    textContent.font = UIFont(name: APP_FONT, size: 15)
                    textContent.textColor = UIColor(named: "searchPlaces_TextColor")
                    textContent.showsVerticalScrollIndicator = false
                    textContent.showsHorizontalScrollIndicator = false
                   
                }
                else {
                    self.view.makeToast(result?.data?.getStaticPageContent?.errorMessage!)
                }
            }
        }
    }

}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
