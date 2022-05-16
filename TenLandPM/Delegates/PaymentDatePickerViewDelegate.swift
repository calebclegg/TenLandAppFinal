//
//  PaymentDatePickerViewDelegate.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 10/4/2022.
//
//
import Foundation
import UIKit

class PaymentDateDelegate: NSObject, UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PaymentDate.allCases[row].description()
    }
    
}
