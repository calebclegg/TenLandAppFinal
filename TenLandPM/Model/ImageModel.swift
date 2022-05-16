//
//  ImageModel.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 24/03/2022.
//

import Foundation

enum ImageModel: String {
    
    case header = "Header", profile = "Profile", property = "Property", maintenance = "Maintenance"
    func description() -> String {
        switch self {
        case .header:
            return "Header"
        case .profile:
            return "Profile"
        case .property:
            return "Property"
        case .maintenance:
            return "Maintenance"
        }
    }
    func firebaseEntryName() -> String {
        switch self {
        case .header:
            return "header_image"
        case .profile:
            return "profile_image"
        case .property:
            return "property_image"
        case .maintenance:
            return "property_maintenance"
        }
    }
    
}
