//
//  PaymentDate.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 6/4/2022.
//
//
import Foundation

enum PaymentDate: Int, CaseIterable {
    
    case beginningOfMonth, midMonth, endOfMonth
    
    func description() -> String {
        switch self {
        case .beginningOfMonth:
            return "Beginning of Month"
        case .midMonth:
            return "Mid Month"
        case .endOfMonth:
            return "End of Month"
        }
    }
    
}
