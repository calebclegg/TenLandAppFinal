//
//  LeaseType.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 6/4/2022.
//
//
import Foundation

enum LeaseType: Int, CaseIterable {
    
    case freeHold, leaseHold
    
    func description() -> String {
        switch self {
        case .freeHold:
            return "Freehold"
        case .leaseHold:
            return "Leasehold"
        }
    }
    
}
