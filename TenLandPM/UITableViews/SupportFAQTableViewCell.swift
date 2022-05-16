//
//  SupportFAQTableViewCell.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 08/05/2022.
//
//
import UIKit

class SupportFAQTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageTableView: UIImageView!
    
    static let identifier = "SupportFAQTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
