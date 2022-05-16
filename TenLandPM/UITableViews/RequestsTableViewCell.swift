//
//  RequestsTableViewCell.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 28/04/2022.
//
//
import UIKit

class RequestsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var requestImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    static let identifier = "RequestsTableViewCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
