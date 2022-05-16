//
//  RootManager.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 9/2/2022.
//
//
import Foundation
import UIKit
import FirebaseAuth


let landlordTabBarDelegate = LandlordTabBarDelegate()
let tenantTabBarDelegate = TenantTabBarDelegate()

class RootManager {
    
    static let shared = RootManager()
    
    private init() {}
    
    func getLoggedInRoot(userType: UserType) -> UIViewController {
//        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let startVC = mainStoryboard.instantiateViewController(withIdentifier: "StartVC")
//        return UINavigationController(rootViewController: startVC)
        switch userType {
        case .landlord:
            return getLandlordTabController()
        case .tenant:
            return getTenantTabController()
        }
        
    }
    
    func getLoggedOutRoot() -> UIViewController {
        let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
        let landVC = authStoryboard.instantiateViewController(withIdentifier: "LandVC")
        return UINavigationController(rootViewController: landVC)
    }
    
    
    func getSplashScreen() -> UIViewController {
        let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
        let splashVC = authStoryboard.instantiateViewController(withIdentifier: "SplashViewController")
        return splashVC
    }
    
    func signOutAnGetLoggedOutRoot() -> UIViewController {
        try? Auth.auth().signOut()
        let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
        let landVC = authStoryboard.instantiateViewController(withIdentifier: "LandVC")
        return UINavigationController(rootViewController: landVC)
    }
    
    
    func login(userType: UserType) {
//        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let startVC = mainStoryboard.instantiateViewController(withIdentifier: "StartVC")
        switch userType {
        case .landlord:
            let landlordTabBar = getLandlordTabController()
            UIApplication.shared.windows.first?.rootViewController = landlordTabBar
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        case .tenant:
            let tenantTabBar = getTenantTabController()
            UIApplication.shared.windows.first?.rootViewController = tenantTabBar
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        
    }
    
    func logout() {
        let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
        let landVC = authStoryboard.instantiateViewController(withIdentifier: "LandVC")
        let navVC = UINavigationController(rootViewController: landVC)
        UIApplication.shared.windows.first?.rootViewController = navVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func getLandlordTabController() -> UITabBarController {
        let tabController = UITabBarController()
        let main = UIStoryboard(name: "LandlordMain", bundle: nil)
        let homeVC = main.instantiateViewController(withIdentifier: "homeVC") as! HomeViewController
        let postsVC = main.instantiateViewController(withIdentifier: "postsVC") as! AddPropertyViewController
        let profileVC = main.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        
        let vcData: [(UIViewController, UIImage, String)] = [
            (homeVC, UIImage(systemName: "house.fill")!, "Home" ),
            (postsVC, UIImage(systemName: "plus.app.fill")!, "Property"),
            (profileVC, UIImage(systemName: "person.fill")!, "Profile")
        ]
        
        let vcs = vcData.map { (vc, image, title) -> UINavigationController in
            let nav = UINavigationController(rootViewController: vc)
            nav.tabBarItem.image = image
            nav.title = title
            return nav
        }
        tabController.viewControllers = vcs
//        tabController.tabBar.isTranslucent = false
        tabController.delegate = landlordTabBarDelegate
        //tabBarHeight = tabController.tabBar.frame.size.height
        
        if let items = tabController.tabBar.items {
            for item in items {
                if let image = item.image {
                    item.image = image.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//                    item.title = ""
                    item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
                }
            }
        }
        return tabController
    }
    
    func getTenantTabController() -> UITabBarController {
        let tabController = UITabBarController()
        let main = UIStoryboard(name: "TenantMain", bundle: nil)
        let homeVC = main.instantiateViewController(withIdentifier: "homeVC") as! TenantHomeViewController
        let postsVC = main.instantiateViewController(withIdentifier: "maintenanceVC") as! TenantMaintenanceViewController
        let profileVC = main.instantiateViewController(withIdentifier: "profileVC") as! TenantProfileViewController
        
        let vcData: [(UIViewController, UIImage, String)] = [
            (homeVC, UIImage(systemName: "house")!, "Home"),
            (postsVC, UIImage(systemName: "plus.app.fill")!, "Maintenance"),
            (profileVC, UIImage(systemName: "person.fill")!, "Profile")
        ]
       
    
        let vcs = vcData.map { (vc, image, title) -> UINavigationController in
            let nav = UINavigationController(rootViewController: vc)
            nav.tabBarItem.image = image
            nav.title = title
            
            
            return nav
        }
        tabController.viewControllers = vcs
//        tabController.tabBar.isTranslucent = false
        tabController.delegate = tenantTabBarDelegate
        //tabBarHeight = tabController.tabBar.frame.size.height
        
        if let items = tabController.tabBar.items {
            for item in items {
                if let image = item.image {
                    item.image = image.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//                    item.title = ""
                    item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    
                }
            }
        }
        return tabController
    }
    
}
