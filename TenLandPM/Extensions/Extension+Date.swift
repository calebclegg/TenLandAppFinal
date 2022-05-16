//
//  Extension+Date.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 25/4/2022.
//

import Foundation

extension Date {
    
    func getDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YY"
        let convertedDate = dateFormatter.string(from: self)
        return convertedDate
    }
    
}
