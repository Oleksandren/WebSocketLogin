//
//  LoginVC.swift
//  LoginScreen
//
//  Created by Oleksandr Nechet on 09.11.15.
//  Copyright © 2015 Oleksandr Nechet. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    //MARK: - Properties
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassw: UITextField!
    @IBOutlet weak var labelErrorMessage: UILabel!
    private let segueToLoginSuccesVC = "SegueToLoginSuccessVC"
    private let segueToLoginSuccesVCWithoutAnimation = "SegueToLoginSuccesVCWithoutAnimation"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if OLNWebSocketManager.sharedManager.isCurrentlyLoged() {
            self.performSegueWithIdentifier(segueToLoginSuccesVCWithoutAnimation, sender: nil)
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(textField: UITextField) {
        labelErrorMessage.text = nil
    }
    
    //MARK: - IBActions
    @IBAction func didLogin(sender: UIButton) {
        guard validateEmail() else {
            return
        }
        
        guard let pass = textFieldPassw.text where !pass.isEmpty else {
            labelErrorMessage.text = "Password field is empty"
            return
        }
        
        labelErrorMessage.text = nil
        
        sender.enabled = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        OLNWebSocketManager.sharedManager.login(email: textFieldEmail.text!,
                                                password: textFieldPassw.text!) { [unowned self] (success, errorMessage) in
                                                    sender.enabled = true
                                                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                                    if success {
                                                        self.performSegueWithIdentifier(self.segueToLoginSuccesVC, sender: nil)
                                                    }
                                                    else {
                                                        self.labelErrorMessage.text = errorMessage
                                                    }
        }
    }
    
    @IBAction func endEditing(_: AnyObject) {
            self.view.endEditing(true)
    }
    
    //MARK: - Helpers
    func validateEmail() -> Bool {
        guard let email = textFieldEmail.text where !email.isEmpty else {
            labelErrorMessage.text = "Email address field is empty"
            return false
        }
        
        if !email.isValidEmail() {
            labelErrorMessage.text = "Email address is invalid"
        }
        return email.isValidEmail()
    }
}
