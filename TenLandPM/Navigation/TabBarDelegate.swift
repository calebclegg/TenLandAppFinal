//
//  TabBarDelegate.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 9/4/2022.
//
//
import Foundation
import UIKit

class LandlordTabBarDelegate: NSObject, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let navigationController = viewController as? UINavigationController
        _ = navigationController?.popToRootViewController(animated: false)
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let selectedViewController = tabBarController.selectedViewController
        guard let _selectedViewController = selectedViewController else {
            return false
        }
        if viewController == _selectedViewController {
            return false
        }
        
        guard let controllerIndex = tabBarController.viewControllers?.index(of: viewController) else {
            return true
        }
        if controllerIndex == 1 {
            let main = UIStoryboard(name: "LandlordMain", bundle: nil)
            let newPostVC = main.instantiateViewController(withIdentifier: "postsVC") as! AddPropertyViewController
            let navController = UINavigationController(rootViewController: newPostVC)
            _selectedViewController.present(navController, animated: true, completion: nil)
            return false
        }
        let navigationController = viewController as? UINavigationController
        _ = navigationController?.popToRootViewController(animated: false)
        return true
        
    }
    
}

class TenantTabBarDelegate: NSObject, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let navigationController = viewController as? UINavigationController
        _ = navigationController?.popToRootViewController(animated: false)
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let selectedViewController = tabBarController.selectedViewController
        guard let _selectedViewController = selectedViewController else {
            return false
        }
        if viewController == _selectedViewController {
            return false
        }
        
        guard let controllerIndex = tabBarController.viewControllers?.index(of: viewController) else {
            return true
        }
        if controllerIndex == 1 {
            let main = UIStoryboard(name: "TenantMain", bundle: nil)
            let newPostVC = main.instantiateViewController(withIdentifier: "maintenanceVC") as! TenantMaintenanceViewController
            let navController = UINavigationController(rootViewController: newPostVC)
            _selectedViewController.present(navController, animated: true, completion: nil)
            return false
        }
        let navigationController = viewController as? UINavigationController
        _ = navigationController?.popToRootViewController(animated: false)
        return true
        
    }
    
}
