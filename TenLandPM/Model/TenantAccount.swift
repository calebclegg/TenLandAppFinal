//
//  AccountUser.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 26/4/2022.
//

import Foundation

class TenantAccount {
    
    static let shared = TenantAccount()
    
    var property: Property?
    
    private init() {
        
    }
    
}
