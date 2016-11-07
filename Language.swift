//
//  Language.swift
//  Unitrans
//
//  Created by Kim Rypstra on 29/10/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

class Language: NSObject {
    let englishName: String!
    let localizedName: String!
    let nativeName: String?
    
    let prefersGoogle: Bool!
    let googleCode: String?
    let microsoftCode: String?
    
    init(englishName: String, localizedName: String, nativeName: String?, prefersGoogle: Bool, googleCode: String?, microsoftCode: String?) {
        self.englishName = englishName
        self.localizedName = localizedName
        self.nativeName = nativeName
        self.prefersGoogle = prefersGoogle
        self.googleCode = googleCode
        self.microsoftCode = microsoftCode
    }
    
}
