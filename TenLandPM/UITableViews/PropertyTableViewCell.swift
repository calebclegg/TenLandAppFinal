//
//  PropertyTableViewCell.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 05/04/2022.
//
//
import UIKit

class PropertyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var propertyImageView: UIImageView!
    @IBOutlet weak var addressLine1Label: UILabel!
    @IBOutlet weak var numberOfBedsLabel: UILabel!
    @IBOutlet weak var numberOfLivingRoomsLabel: UILabel!
    @IBOutlet weak var numberOfBathsLabel: UILabel!
    
    @IBOutlet weak var rentamountTF: UILabel!
    
    static let identifier = "PropertyTableViewCell"

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
