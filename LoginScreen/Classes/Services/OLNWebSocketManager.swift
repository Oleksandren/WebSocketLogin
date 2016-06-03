//
//  OLNWebSocketManager.swift
//  LoginScreen
//
//  Created by Oleksandr Nechet on 02.06.16.
//  Copyright © 2016 Oleksandr Nechet. All rights reserved.
//

import Foundation
import SocketRocket
import SwiftyJSON
import EZAlertController

enum SocketMessageType: String {
    case LoginSuccess = "CUSTOMER_API_TOKEN"
    case LoginFail = "CUSTOMER_ERROR"
}

@objc
class OLNWebSocketManager: NSObject, SRWebSocketDelegate {
    //MARK: - Properties
    static let sharedManager = OLNWebSocketManager()
    private let wsURL = NSURL(string: "ws://52.29.182.220:8080/customer-gateway/customer")!
    private var _webSocket: SRWebSocket?
    private var _sequenceId: String!
    private var completionHandlerLogin: ((success: Bool, errorMessage: String?) -> Void)?
    private var loginMessage: String?
    private static let dateFormatterForParsing: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"
        return formatter
    }()
    private static let kToken = "Token"
    private static let kTokenExpirationDate = "TokenExpirationDate"
    
    func login(email email: String, password: String, completionHandler:(success: Bool, errorMessage: String?) -> Void) {
        _sequenceId = NSUUID().UUIDString
        let credentialsData = ["email":email,
                               "password":password]
        let loginData = ["type": "LOGIN_CUSTOMER",
                            "sequence_id":_sequenceId,
                            "data":credentialsData]
        if let stringJSON = JSON(loginData).rawString(NSUTF8StringEncoding, options: []) {
            completionHandlerLogin = completionHandler
            loginMessage = stringJSON
            _webSocket = SRWebSocket(URLRequest: NSURLRequest(URL: wsURL))
            _webSocket!.delegate = self
            _webSocket!.open()
        }
        else {
            _sequenceId = nil
            completionHandler(success: false, errorMessage: "Something wrong")
        }
    }
    
    func disconnect() {
        if _webSocket != nil {
            _webSocket!.close()
            _webSocket = nil
        }
    }
    
    var tokenExpirationDate: NSDate? {
        if let tokenExpirationDate =  NSUserDefaults.standardUserDefaults().valueForKey(OLNWebSocketManager.kTokenExpirationDate) {
            return tokenExpirationDate as? NSDate
        }
        return nil
    }
    
    func isCurrentlyLoged() -> Bool {
        if let expDate = self.tokenExpirationDate {
            return expDate.compare(NSDate()) == NSComparisonResult.OrderedDescending
        }
        else {
            return false
        }
    }

    //MARK: - SRWebSocket Delegate
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        disconnect()

        if let responseString = message as? String {
            let responseJSON = JSON.parse(responseString)
            if let messageType = responseJSON.dictionaryValue["type"]?.stringValue,
                let type = SocketMessageType(rawValue: messageType) {
                switch type {
                case .LoginSuccess:
                    if let data = responseJSON.dictionaryValue["data"]?.dictionaryValue,
                        let token = data["api_token"]?.stringValue,
                        let tokenExpirationDateString = data["api_token_expiration_date"]?.stringValue,
                        let tokenExpirationDate =  OLNWebSocketManager.dateFormatterForParsing.dateFromString(tokenExpirationDateString) {
                        
                        if tokenExpirationDate.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                            NSUserDefaults.standardUserDefaults().setValue(tokenExpirationDate, forKey: OLNWebSocketManager.kTokenExpirationDate)
                            NSUserDefaults.standardUserDefaults().setValue(token, forKey: OLNWebSocketManager.kToken)
                            NSUserDefaults.standardUserDefaults().synchronize()
                            invokeCompletionHandlerLogin(success: true, errorMessage: nil)
                            return
                        }
                    }
                    else {
                        invokeCompletionHandlerLogin(success: false, errorMessage: "Error. Invalid token")
                    }
                case .LoginFail:
                    let errorMessage = responseJSON.dictionaryValue["data"]?.dictionaryValue["error_description"]?.stringValue
                    invokeCompletionHandlerLogin(success: false, errorMessage: errorMessage)
                    return
                }
            }
        }
        
        invokeCompletionHandlerLogin(success: false, errorMessage: "Error. Unexpected server response")
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        webSocket.send(loginMessage)
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        invokeCompletionHandlerLogin(success: false, errorMessage: error.localizedDescription)
        disconnect()
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        invokeCompletionHandlerLogin(success: false, errorMessage: reason)
        disconnect()
    }
    
    //MARK: - Helpers
    func invokeCompletionHandlerLogin(success success: Bool, errorMessage: String?) {
        if completionHandlerLogin != nil {
            completionHandlerLogin!(success: success, errorMessage: errorMessage)
            completionHandlerLogin = nil
        }
    }
}