//
//  BadgedButtonItem.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 11/05/2022.
//
import Foundation
import UIKit

class BadgedButtonItem: UIBarButtonItem {
    
    func setBadge(with value: Int) {
        self.badgeValue = value
    }
    
    var badgeValue: Int? {
        didSet {
            if let value = badgeValue,
               value > 0 {
                lblBadge.isHidden = false
                lblBadge.text = "\(value)"
            } else {
                lblBadge.isHidden = true
            }
        }
    }
    
    private let filterBtn = UIButton()
    private let lblBadge = UILabel()
    
    var tapAction: (() -> Void)?
    
    init(with image: UIImage) {
        super.init()
        setup(image: image)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup(image: UIImage? = nil) {
        
        self.filterBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.filterBtn.setImage(image, for: .normal)
        self.filterBtn.tintColor = UIColor.black
        self.filterBtn.addTarget(self, action: #selector(buttonDidTouch), for: .touchUpInside)
        
        self.lblBadge.frame = CGRect(x: 20, y: 0, width: 15, height: 15)
        self.lblBadge.backgroundColor = UIColor.red
        self.lblBadge.clipsToBounds = true
        self.lblBadge.layer.cornerRadius = 7
        self.lblBadge.textColor = UIColor.white
        self.lblBadge.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        self.lblBadge.textAlignment = .center
        self.lblBadge.isHidden = true
        self.lblBadge.minimumScaleFactor = 0.1
        self.lblBadge.adjustsFontSizeToFitWidth = true
        
        self.filterBtn.addSubview(lblBadge)
        self.customView = filterBtn
        
    }
    
    @objc func buttonDidTouch() {
        if let tapAction = tapAction {
            tapAction()
        }
    }
    
}
