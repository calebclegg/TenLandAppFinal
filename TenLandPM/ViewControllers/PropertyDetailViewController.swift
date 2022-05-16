//
//  PropertyDetailViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 11/4/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

protocol PropertyDetailDelegate: AnyObject {
    func getTenantDetails(tenantId: String, isPending: Bool)
}


class PropertyDetailViewController: UIViewController {

    var property: Property?
    
    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var numberBedsLabel: UILabel!
    @IBOutlet weak var numberLivingRoomsLabel: UILabel!
    @IBOutlet weak var numberBathroomsLabel: UILabel!
    
    @IBOutlet weak var leasetypeTF: UITextField!
    @IBOutlet weak var rentdueTF: UITextField!
    @IBOutlet weak var startdateTF: UITextField!
    @IBOutlet weak var enddateTF: UITextField!
    @IBOutlet weak var rentamountTF: UITextField!
    @IBOutlet weak var tenantNameTF: UITextField!
    @IBOutlet weak var assignTenantButton: UIButton!
    
    
    var isTenantPending = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        let tap = UITapGestureRecognizer(target: self, action: #selector(showTenantDetail))
        tenantNameTF.addGestureRecognizer(tap)
        tenantNameTF.isUserInteractionEnabled = true
        
        [leasetypeTF, rentdueTF, startdateTF, enddateTF, rentamountTF].forEach { textfield in
            textfield?.isEnabled = false}
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if let tenantId = property?.tenantId {
//            getTenantDetails(tenantId: tenantId)
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? LandlordTenantDetailsViewController,
           let tenantId = sender as? String {
            destinationVC.tenantId = tenantId
        }
        if let destinationVC = segue.destination as? SearchTenantsViewController {
            if let property = property {
                destinationVC.propertyId = property.id
            }
            destinationVC.delegate = self
        }
    }
    
    func setup() {
        //tenantPropertyStatusLabel.text = ""
        guard let property = property else {
            return
        }
        propertyImage.sd_setImage(with: property.propertyImage)
        addressLabel.text = property.addressLine1
        numberBedsLabel.text = "\(property.numberOfBeds)"
        numberLivingRoomsLabel.text = "\(property.numberOfLivingRooms)"
        numberBathroomsLabel.text = "\(property.numberOfBathrooms)"
        
        rentdueTF.text = "\(property.paymentDate)"
        leasetypeTF.text = "\(property.leaseType)"
        
        startdateTF.text = property.startDate.getDateString()
        enddateTF.text = property.endDate.getDateString()
        
        rentamountTF.text = "€\(property.rentAmount)"
        
        if let tenantId = property.tenantId {
            getTenantDetails(tenantId: tenantId)
        } else {
            checkForPendingRequest()
        }
        Utilities.styleFilledButton(assignTenantButton)
        
    }
    
    func checkForPendingRequest() {
        guard let property = property else {
            return
        }
        PendingRequests.collection.whereField("property_id", isEqualTo: property.id).getDocuments { [weak self] query, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let query = query else {
                return
            }
            let requests = query.documents.compactMap { document in
                PendingRequests(snapshot: document)
            }
            if requests.count > 1 {
                DispatchQueue.main.async {
                    strongSelf.tenantNameTF.text = "\(requests.count) tenants pending approval"
                    strongSelf.tenantNameTF.textColor = UIColor.gray
                    //strongSelf.tenantPropertyStatusLabel.text = "Pending..."
                }
            } else {
                if let request = requests.first {
                    DispatchQueue.main.async {
                        strongSelf.getTenantDetails(tenantId: request.tenantId, isPending: true)
                    }
                }
            }
        }
    }
    
    @IBAction func assignTenantButtonDidTouch(_ sender: Any) {
        performSegue(withIdentifier: "SearchTenantsSegue", sender: nil)
    }
    
    @objc func showTenantDetail() {
        if isTenantPending {
            return
        }
        if let tenantId = property?.tenantId {
            performSegue(withIdentifier: "ShowTenantDetailSegue", sender: tenantId)
        }
    }

}

extension PropertyDetailViewController: PropertyDetailDelegate {
    
    func getTenantDetails(tenantId: String, isPending: Bool = false) {
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
            guard let user = UserModel(snapshot: snapshot) else {
                return
            }
            strongSelf.property?.tenantId = tenantId
            DispatchQueue.main.async {
                strongSelf.tenantNameTF.text = user.name
            }
            if isPending {
                strongSelf.isTenantPending = true
                DispatchQueue.main.async {
                    strongSelf.tenantNameTF.textColor = UIColor.gray
                    strongSelf.tenantNameTF.text = "\(user.name) (pending)"
                }
                //strongSelf.tenantPropertyStatusLabel.text = "Pending Tenant Approval..."
            } else {
                strongSelf.isTenantPending = false
                strongSelf.tenantNameTF.textColor = UIColor.black
                //strongSelf.tenantPropertyStatusLabel.text = ""
            }
        }
    }
    
}
