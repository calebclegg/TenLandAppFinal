//
//  NotificationsTableViewCell.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 26/4/2022.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {
    
    static let identifier = "NotificationTableViewCell"
    @IBOutlet weak var notificationImageView: UIImageView!
    @IBOutlet weak var notificationTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    

}
