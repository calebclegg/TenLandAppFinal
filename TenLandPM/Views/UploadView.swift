//
//  UploadView.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 9/4/2022.
//

import UIKit

class UploadView: UIView {
    
    var progressIndicator: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = UIColor.lightGray
        view.progressTintColor = UIColor.black
        view.progress = Float(0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel Upload", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(cancelUpload), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = UIColor(hex: "#000", alpha: 0.25)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func cancelUpload() {
        
    }
    
    
}
