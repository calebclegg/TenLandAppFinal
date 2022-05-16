//
//  LeaseTypePickerViewDelegate.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 10/4/2022.
//
//

import Foundation
import UIKit

class LeaseTypePickerViewDelegate: NSObject, UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return LeaseType.allCases[row].description()
    }
    
}
