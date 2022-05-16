//
//  NotificationDetailViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 27/4/2022.
//

import UIKit
import Firebase
import SDWebImage

class NotificationDetailViewController: UIViewController {
    
    @IBOutlet weak var maintenanceImageView: UIImageView!
    @IBOutlet weak var tenantProfileImageView: UIImageView!
    @IBOutlet weak var tenantNameLabel: UILabel!
    @IBOutlet weak var maintenanceTitleLabel: UILabel!
    @IBOutlet weak var maintenanceDescriptionLabel: UILabel!
    @IBOutlet weak var propertyAddressLabel: UILabel!
    
    @IBOutlet weak var dateofrequestLabel: UILabel!
    @IBOutlet weak var dateavailableTF: UITextField!
    
    
    var maintenanceId: String?
    var tenantId: String?
    var propertyId: String?
    var notificationId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tenantProfileImageView.image = UIImage(named: "profile")
        fetchTenantData()
        fetchMaintenanceData()
        fetchPropertyData()
        notificationIsRead()
        dateavailableTF.isEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(showTenantDetail))
        tenantNameLabel.addGestureRecognizer(tap)
        tenantProfileImageView.addGestureRecognizer(tap)
        tenantNameLabel.isUserInteractionEnabled = true
        tenantProfileImageView.isUserInteractionEnabled = true

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tenantProfileImageView.layer.cornerRadius = tenantProfileImageView.frame.height / 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? LandlordTenantDetailsViewController,
            let tenantId = sender as? String {
            destinationVC.tenantId = tenantId
        }
    }
    
    func notificationIsRead() {
        guard let notificationId = notificationId else {
            return
        }
        MaintenanceNotification.collection.document(notificationId).updateData([
            "is_read": true
        ])
    }
    
    func fetchPropertyData() {
        guard let propertyId = propertyId else {
            return
        }
        Property.collection.document(propertyId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let document = snapshot else {
                print("no documents")
                return
            }
            guard let property = Property(document: document) else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.propertyAddressLabel.text = property.addressLine1
            }
        }
    }
    
    func fetchMaintenanceData() {
        guard let maintenanceId = maintenanceId else {
            return
        }
        Maintenance.collection.document(maintenanceId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print("error \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else {
                return
            }
            guard let maintenanceRequest = Maintenance(snapshot: snapshot) else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.maintenanceImageView.sd_setImage(with: maintenanceRequest.addImage)
                strongSelf.maintenanceTitleLabel.text = maintenanceRequest.maintenanceType
                strongSelf.maintenanceDescriptionLabel.text = maintenanceRequest.description
                strongSelf.dateofrequestLabel.text = maintenanceRequest.dor.getDateString()
                strongSelf.dateavailableTF.text = maintenanceRequest.da.getDateString()
            }
        }
    }
    
    func fetchTenantData() {
        guard let tenantId = tenantId else {
            return
        }
        UserModel.collection.document(tenantId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let snapshot = snapshot else {
                print("no data")
                return
            }
            guard let tenant = UserModel(snapshot: snapshot) else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.tenantProfileImageView.sd_setImage(with: tenant.profileImage, placeholderImage: UIImage(named: "profile"))
                strongSelf.tenantNameLabel.text = tenant.name
            }
        }
    }
    @objc func showTenantDetail() {
        guard let tenantId = tenantId else {
            return
        }
        performSegue(withIdentifier: "NotificationToTenantSegue", sender: tenantId)
    }


        
    
    

}
