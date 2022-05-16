//
//  TenantHomeViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 19/4/2022.
//

import UIKit
import Firebase

class TenantHomeViewController: UIViewController {
    
    @IBOutlet weak var propertyImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var numberOfBedsLabel: UILabel!
    @IBOutlet weak var numberOfLivingRoomsLabel: UILabel!
    @IBOutlet weak var numberOfBathroomsLabel: UILabel!
    @IBOutlet weak var leaseTypeTF: UITextField!
    @IBOutlet weak var rentDueTF: UITextField!
    @IBOutlet weak var startDateTF: UITextField!
    @IBOutlet weak var endDateTF: UITextField!
    @IBOutlet weak var rentAmountTF: UITextField!
    
    @IBOutlet weak var landlordTF: UITextField!
    
    @IBOutlet weak var maintenanceButton: UIButton!
    
    
    
    @IBOutlet weak var allrequestsButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var pendingRequestViewStartFrame: CGRect {
        let width = view.frame.width * 0.8
        let height = CGFloat(500)
        let yPos = -CGFloat(500)
        let xPos = (view.frame.width - width) / 2
        return CGRect(x: xPos, y: yPos, width: width, height: height)
    }
    var pendingRequestViewEndFrame: CGRect {
        let width = view.frame.width * 0.8
        let height = CGFloat(500)
        let yPos = (view.frame.height - height) / 2
        let xPos = (view.frame.width - width) / 2
        return CGRect(x: xPos, y: yPos, width: width, height: height)
    }
    
    
  
    var property: Property?
    var propertyRequest: PendingRequests?
    
    var ownerId: String?
    var landlord: UserModel?
//
    lazy var emptyStateView: EmptyStateView = {
        return UINib(nibName: "EmptyStateView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EmptyStateView
    }()
    
    lazy var acceptRequestView: AcceptRequestView = {
        let view = UINib(nibName: "AcceptRequestView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AcceptRequestView
        view.delegate = self
        return view
    }()
    lazy var viewCoverOverlay: UIView = {
        let viewCoverOverlay = UIView()
        viewCoverOverlay.backgroundColor = UIColor.black
        viewCoverOverlay.alpha = 0.0
        viewCoverOverlay.frame = CGRect(x: 0, y: 0, width: (view.window?.rootViewController?.view.frame.width)!, height: (view.window?.rootViewController?.view.frame.height)!)
        viewCoverOverlay.tag = 10110
        let viewOverlayTapped = UITapGestureRecognizer(target: self, action: #selector(dimissRequestViews))
        viewCoverOverlay.addGestureRecognizer(viewOverlayTapped)
        return viewCoverOverlay
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(showLandlordDetail))
        landlordTF.addGestureRecognizer(tap)
        landlordTF.isUserInteractionEnabled = true
        
        Utilities.styleFilledButton(maintenanceButton)
        
        [leaseTypeTF, rentDueTF, startDateTF, endDateTF, rentAmountTF].forEach { textfield in
            textfield?.isEnabled = false
            
        }
        containerView.isHidden = true
        loadData()
        
        
      
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        acceptRequestView.layer.cornerRadius = CGFloat(5)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TenantLandlordDetailsViewController,
           let ownerId = sender as? String {
            destinationVC.ownerId = ownerId
        }
    }
    
    
    func loadData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Property.collection.whereField("tenant_uid", isEqualTo: uid).addSnapshotListener { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let documents = snapshot?.documents else {
                print("no documents")
                return
            }
            if documents.count == 1 {
                strongSelf.property = Property(data: documents[0])
                TenantAccount.shared.property = strongSelf.property
                DispatchQueue.main.async {
                    strongSelf.removeEmptyStateView()
                    strongSelf.displayProperty()
                    
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.displayEmptyStateView()
                    strongSelf.hideProperty()
                   
                }
            }
            strongSelf.checkForPropertyRequest()
        }

    }
    
    
    func checkForPropertyRequest() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        PendingRequests.collection.whereField("tenant_id", isEqualTo: userId).getDocuments { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let documents = snapshot?.documents else {
                return
            }
            let requests = documents.compactMap { snapshot in
                PendingRequests(snapshot: snapshot)
            }
            let unverifiedRequests = requests.filter { request in
                request.isAccepted == nil
            }
            if let firstRequest = unverifiedRequests.first {
                strongSelf.propertyRequest = firstRequest
                PendingRequests.collection.document(strongSelf.propertyRequest!.propertyId).updateData(["is_accepted": false])
                DispatchQueue.main.async {
                    strongSelf.displayPropertyRequestView()
                }
            }
        }
    }
    
    func displayPropertyRequestView() {
        guard let propertyRequest = propertyRequest else {
            return
        }
        acceptRequestView.viewCover.isHidden = false
        Property.collection.document(propertyRequest.propertyId).getDocument { [weak self] document, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let document = document,
                let property = Property(document: document) else {
                return
            }
            UserModel.collection.document(propertyRequest.landlordId).getDocument { document, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let document = document,
                    let landlord = UserModel(snapshot: document) else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.acceptRequestView.viewCover.isHidden = true
                    strongSelf.acceptRequestView.activityIndicator.stopAnimating()
                    strongSelf.acceptRequestView.propertyImageView.sd_setImage(with: property.propertyImage)
                    strongSelf.acceptRequestView.requestLabel.text = "\(landlord.name) has requested you to accept the property at \(property.addressLine1)."
                }
            }
        }
        view.window?.rootViewController?.view.addSubview(viewCoverOverlay)
        acceptRequestView.alpha = 0
        acceptRequestView.frame = self.pendingRequestViewStartFrame
        view.window?.rootViewController?.view.addSubview(self.acceptRequestView)
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn]) {
            self.acceptRequestView.alpha = 1
            self.acceptRequestView.frame = self.pendingRequestViewEndFrame
            self.viewCoverOverlay.alpha = 0.6
        } completion: { success in
            
        }
    }
    
    
    func displayEmptyStateView() {
        emptyStateView.emptyStateLabel.text = "You do not have a property yet!"
        let width = view.frame.width * 0.8
        let height = width
        let yPos = (view.frame.height - height) / 2
        let xPos = (view.frame.width - width) / 2
        emptyStateView.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        view.addSubview(emptyStateView)
    }
    
    func removeEmptyStateView() {
        emptyStateView.removeFromSuperview()
    }
    
    func displayProperty() {
        guard let property = property else {
            return
        }
        propertyImageView.sd_setImage(with: property.propertyImage)
        addressLabel.text = property.addressLine1
        numberOfBedsLabel.text = "\(property.numberOfBeds)"
        numberOfLivingRoomsLabel.text = "\(property.numberOfLivingRooms)"
        numberOfBathroomsLabel.text = "\(property.numberOfBathrooms)"
        leaseTypeTF.text = property.leaseType.description()
        rentDueTF.text = property.paymentDate.description()
        startDateTF.text = property.startDate.getDateString()
        endDateTF.text = property.endDate.getDateString()
        rentAmountTF.text = "€\(property.rentAmount)"
        landlordTF.text = "Fetching..."
        containerView.isHidden = false
        fetchLandlordName(ownerId: property.ownerId)
        
     
    }


    func fetchLandlordName(ownerId: String) {
        UserModel.collection.document(ownerId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    strongSelf.landlordTF.text = "Name not found"
                }
                return
            }
            guard let snapshot = snapshot else {
                DispatchQueue.main.async {
                    strongSelf.landlordTF.text = "Name not found"
                }
                return
            }
            guard let landlord = UserModel(snapshot: snapshot) else {
                DispatchQueue.main.async {
                    strongSelf.landlordTF.text = "Name not found"
                }
                return
            }
            DispatchQueue.main.async {
                strongSelf.landlordTF.text = landlord.name
            }
        }
    }

    

    func hideProperty() {
        containerView.isHidden = true
    }

    @objc func dimissRequestViews() {
        viewCoverOverlay.removeFromSuperview()
        acceptRequestView.removeFromSuperview()
    }
    
    @IBAction func logoutButtonDidTouch(_ sender: Any) {
        try? Auth.auth().signOut()
        RootManager.shared.logout()
    }
    
    @objc func showLandlordDetail() {
     
        if let ownerId = property?.ownerId {
            performSegue(withIdentifier: "ShowLandlordDetailSegue", sender: ownerId)
        
        }

    }
}
    


extension TenantHomeViewController: AcceptRequestDelegate {
    
    func propertyRequestAccepted() {
        guard let propertyRequest = propertyRequest else {
            return
        }
        PendingRequests.collection.document(propertyRequest.id).updateData(["is_accepted": true])
        UserModel.collection.document(propertyRequest.tenantId).updateData(["property_id": propertyRequest.propertyId])
        Property.collection.document(propertyRequest.propertyId).updateData(["tenant_uid": propertyRequest.tenantId]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        dimissRequestViews()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Property.collection.whereField("tenant_uid", isEqualTo: uid).getDocuments { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let documents = snapshot?.documents else {
                print("no documents")
                return
            }
            if documents.count == 1 {
                strongSelf.property = Property(data: documents[0])
                TenantAccount.shared.property = strongSelf.property
                DispatchQueue.main.async {
                    strongSelf.removeEmptyStateView()
                    strongSelf.displayProperty()
                }
            }
        }
    }
    
    func propertyRequestDeclined() {
        guard let propertyRequest = propertyRequest else {
            return
        }
        PendingRequests.collection.document(propertyRequest.id).updateData(["is_accepted": false])
        dimissRequestViews()
        }
}

