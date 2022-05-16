//
//  SettingsList.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 30/04/2022.
//

import Foundation

enum SettingsList: Int, CaseIterable {
    case Theme
    case Terms
    case Privacy
    case Cookies
    case Feedback
    func getName() -> String {
        switch self {
        case .Theme: return "Theme Settings"
        case .Terms: return "Terms of Use"
        case .Privacy: return "Privacy Settings"
        case .Cookies: return "Cookie Policy"
        case .Feedback: return "Send Feedback"
       
            
        }
        
    }
    
}
