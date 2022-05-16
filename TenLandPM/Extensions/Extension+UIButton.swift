//
//  Extension+UIButton.swift
//  TenPM
//
//  Created by Caleb Clegg on 23/01/2022.
//
//
import Foundation
import UIKit


extension UIButton {
    
    //animates button by changing scale, by the stats below
    func animateButton(completion: @escaping ((_ success: Bool) -> ())){
            
        
        
        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { success in
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform.identity
            } completion: { success in
           completion(true)
            }

            //self.emailButton.transform = CGAffineTransform.identity
        }
        
    }
}

