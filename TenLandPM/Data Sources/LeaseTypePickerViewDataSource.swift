//
//  LeaseTypePickerViewDataSource.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 10/4/2022.
//

import Foundation
import UIKit

class LeaseTypePickerViewDataSource: NSObject, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return LeaseType.allCases.count
    }
    
}


