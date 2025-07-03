
import UIKit

class SwitchTravelAndHostVC: UIViewController {
    
    @IBOutlet weak var SwitchTravelAndHostImage: UIImageView!
    @IBOutlet weak var switchTravelAndHostLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ChangeTiming = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor =   UIColor(named: "colorController")
        switchTravelAndHostLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 36)
        switchTravelAndHostLabel.textColor = UIColor(named: "Title_Header")
        switchTravelAndHostLabel.textAlignment = .center
        
        if Utility.shared.isfromHost == false   {
            switchTravelAndHostLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"Switchhosting"))!)"
        } else {
            switchTravelAndHostLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"switchtraveling"))!)"
        }
        ChangeTiming = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(actionTime), userInfo: nil, repeats: false)
    }
    
    private func rotateView(targetView: UIView, duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .transitionFlipFromTop, animations: {
            targetView.transform = targetView.transform.rotated(by: CGFloat((180.0 * .pi) / 180.0))
        }) { finished in
            self.rotateView(targetView: targetView, duration: duration)
        }
    }
    
    @objc func actionTime(){
        if Utility.shared.isfromHost == false{
            Utility.shared.setopenTabbar(iswhichtabbar: true)
            appDelegate.addingElementsToObjects()
            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
            Utility.shared.setHostTab(index: 0)
            appDelegate.HostTabbarInitialize(initialView: CustomHostTabbar())
        } else {
            if Utility.shared.isfromSavedShortcut == true {
                Utility.shared.setTab(index: 1)
                appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
                Utility.shared.isfromSavedShortcut = false
                Utility.shared.isfromHost = true
            } else {
                Utility.shared.setopenTabbar(iswhichtabbar:false)
                self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
                appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
            }
        }
    }
}
