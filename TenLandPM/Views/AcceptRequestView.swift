//
//  AcceptRequestView.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 1/5/2022.
//

import UIKit

protocol AcceptRequestDelegate: AnyObject {
    func propertyRequestAccepted()
    func propertyRequestDeclined()
}

class AcceptRequestView: UIView {

    @IBOutlet weak var propertyImageView: UIImageView!
    @IBOutlet weak var requestLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewCover: UIView!
    
    weak var delegate: AcceptRequestDelegate?
    
    @IBAction func acceptButtonDidTouch(_ sender: Any) {
        delegate?.propertyRequestAccepted()
    }
    
    @IBAction func declineButtonDidTouch(_ sender: Any) {
        delegate?.propertyRequestDeclined()
    }
    
    
}
