//
//  LoginSuccessVC.swift
//  LoginScreen
//
//  Created by Oleksandr Nechet on 03.06.16.
//  Copyright © 2016 Oleksandr Nechet. All rights reserved.
//

import UIKit

class LoginSuccessVC: UIViewController {
    //MARK: - Properties
    private static let dateFormatterForPresenting: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = NSTimeZone.localTimeZone()
        return formatter
    }()
    @IBOutlet weak var labelExpirationMessage: UILabel!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let expDate = OLNWebSocketManager.sharedManager.tokenExpirationDate {
            labelExpirationMessage.text = "The token expires at \(LoginSuccessVC.dateFormatterForPresenting.stringFromDate(expDate))"
        }
        else {
            self.navigationController?.popViewControllerAnimated(false)
        }
    }
    
}
