

import UIKit
import IQKeyboardManagerSwift

protocol CancelTextviewCellDelegate: class {
    func didChangeText(text: String?, cell: CancelTextviewCell)
    func textendEditing(text:String?, cell:CancelTextviewCell)
}
class CancelTextviewCell: UITableViewCell,UITextViewDelegate {
weak var delegate: CancelTextviewCellDelegate?
    @IBOutlet weak var checkTxtView: UITextView!
    
     @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        checkTxtView.delegate = self
        checkTxtView.isEditable = true
        checkTxtView.isScrollEnabled = true
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
      
        placeholderLabel.font = checkTxtView.font
        placeholderLabel.numberOfLines = 0
        placeholderLabel.sizeToFit()

        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !checkTxtView.text.isEmpty
        placeholderLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        checkTxtView.font = UIFont(name: APP_FONT, size: 18)
    }
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        delegate?.didChangeText(text: textView.text, cell: self)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textendEditing(text: textView.text, cell: self)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            IQKeyboardManager.shared.enable = true
            IQKeyboardManager.shared.enableAutoToolbar = true
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
