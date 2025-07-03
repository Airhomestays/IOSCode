
import UIKit

class CCSwipBackPresentationController: UIPresentationController {
    
    var transitionDidEndCallBack : ((_ containerView : UIView?) -> Swift.Void)?
    
    convenience init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, transitionDidEnd : @escaping (_ containerView : UIView?) -> Swift.Void) {
        
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.transitionDidEndCallBack = transitionDidEnd
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        self.transitionDidEndCallBack?(self.containerView)
    }
}
