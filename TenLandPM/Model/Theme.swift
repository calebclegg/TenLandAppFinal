//
//  Theme.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 28/4/2022.
//

import Foundation
import UIKit

enum Theme: Int, CaseIterable {
    case device
    case light
    case dark
    func getName() -> String {
        switch self {
        case .device:
            return "Device"
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        }
    }
}

extension Theme {
  var userInterfaceStyle: UIUserInterfaceStyle {
    switch self {
      case .device:
        return .unspecified
      case .light:
        return .light
      case .dark:
        return .dark
    }
  }
}

extension UserDefaults {
    var theme: Theme {
        get {
          register(defaults: [#function: Theme.device.rawValue])
          return Theme(rawValue: integer(forKey: #function)) ?? .device
        }
        set {
          set(newValue.rawValue, forKey: #function)
        }
    }
    
}
