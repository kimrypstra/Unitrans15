//
//  ErrorType.swift
//  UniversalTranslator
//
//  Created by Kim Rypstra on 1/09/2016.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import Foundation

class DSError: Error {
    let domain: String
    let code: Int
    
    init(domain: String, code: Int) {
        self.domain = domain
        self.code = code
    }
}
