//
//  UserType.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 7/2/2022.
//
//
import Foundation


enum UserType: String {
    case landlord, tenant
    func getDescription() -> String {
        switch self {
        case .landlord:
            return "landlord"
        case .tenant:
            return "tenant"
        }
    }
}
