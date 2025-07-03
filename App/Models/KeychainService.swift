//
//  KeychainService.swift
//  App


import UIKit
import Foundation
import Security

// Constant Identifiers
let userAccount = "AuthenticatedUser"
let accessGroup = "SecuritySerivice"


/**
 *  User defined keys for new entry
 *  Note: add new keys for new secure item and use them in load and save methods
 */
// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

let emailKey = "KeyForname"
let usernameKey = "KeyForPassword"
let fnameKey = "KeyForfname"
let lnameKey = "KeyForlname"

class KeychainService: NSObject {
    
    
    public class func saveEmail(email: NSString) {
        self.save(service: emailKey as NSString, data: email)
    }

    public class func loadEmail() -> NSString? {
        return self.load(service: emailKey as NSString)
    }
    
    public class func saveUsername(name: NSString) {
        self.save(service: usernameKey as NSString, data: name)
       }

       public class func loadUsername() -> NSString? {
        return self.load(service: usernameKey as NSString)
       }
    
    public class func savefname(name: NSString) {
        self.save(service: usernameKey as NSString, data: name)
       }

       public class func loadfname() -> NSString? {
        return self.load(service: usernameKey as NSString)
       }
    public class func savelname(name: NSString) {
        self.save(service: lnameKey as NSString, data: name)
       }

       public class func loadlname() -> NSString? {
        return self.load(service: lnameKey as NSString)
       }

    /**
     * Internal methods for querying the keychain.
     */

    private class func save(service: NSString, data: NSString) {
        let dataFromString: NSData =  data.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)! as NSData
       

        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])

        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)

        // Add the new keychain item
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }

    private class func load(service: NSString) -> NSString? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])

        var dataTypeRef :AnyObject?

        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: NSString? = nil

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }

        return contentsOfKeychain
    }

}
