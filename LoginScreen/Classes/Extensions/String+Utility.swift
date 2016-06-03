//
//  String+Utility.swift
//  LoginScreen
//
//  Created by Oleksandr Nechet on 02.06.16.
//  Copyright © 2016 Oleksandr Nechet. All rights reserved.
//

import Foundation

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
}
