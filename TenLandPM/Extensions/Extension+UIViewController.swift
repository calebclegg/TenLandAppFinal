//
//  Extension+UIViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 11/05/2022.
//
//
import Foundation
import UIKit

extension UIViewController {
    
    func displayLoadingView() {
        let loadingView = UINib(nibName: "LoadingView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! LoadingView
        loadingView.tag = 10101
        loadingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(loadingView)
        loadingView.activityIndicator.startAnimating()
    }
    
    func removeLoadingView() {
        if let loadingView = view.viewWithTag(10101) {
            loadingView.removeFromSuperview()
        }
    }
    
    
}
