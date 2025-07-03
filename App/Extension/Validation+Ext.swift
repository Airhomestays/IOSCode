
import Foundation


extension SignUpViewController {
    func validation() -> Bool {
        if firstNametxtField.isEmpty() {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"validation_first_name"))!)")
            return true
        } else if lastNameTxtField.isEmpty() {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"validation_last_name"))!)")
            return true
        } else if !isValidEmail(EmailTxtField.text!) {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"email_validalert"))!)")
            return true
        } else if EmailTxtField.text!.isEmpty {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"validation_email"))!)")
            return true
        } else if passwordTxtField.isEmpty() {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"validation_password"))!)")
            return true
        } else if passwordTxtField.text!.count < 8 {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"validation_pwd_character"))!)")
            return true
        } else if birthdayTxtField.text!.isEmpty {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"validation_birthDay"))!)")
            return true
        }
        return false
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
