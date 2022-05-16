//
//  SearchTenantsViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 25/4/2022.
//
//
import UIKit
import Firebase

class SearchTenantsViewController: UIViewController {
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    var selectedTenantId: String?
    var availableTenants: [UserModel] = [UserModel]()
    var propertyId: String?
    weak var delegate: PropertyDetailDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tenants"
        
        tableView.dataSource = self
        tableView.delegate = self
        loadData()
        
        Utilities.styleFilledButton(confirmButton)    }
    
    func loadData() {
        guard let propertyId = propertyId else {
            return
        }
        displayLoadingView()
        UserModel.collection.whereField("user_type", isEqualTo: "tenant").getDocuments { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.removeLoadingView()
            }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let documents = snapshot?.documents else {
                print("no documents")
                return
            }
            strongSelf.availableTenants = documents.compactMap({ snap in
                UserModel(snapshot: snap)
            })
            strongSelf.availableTenants = strongSelf.availableTenants.filter({ tenant in
                tenant.propertyId == nil
            })
            PendingRequests.collection.whereField("property_id", isEqualTo: propertyId).getDocuments { querySnapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    return
                }
                let requests = documents.compactMap { snapshot in
                    PendingRequests(snapshot: snapshot)
                }
                print("requests \(requests)")
                if requests.count > 0 {
                    strongSelf.availableTenants = strongSelf.availableTenants.filter({ user in
                        for tenantReqest in requests {
                            if tenantReqest.tenantId == user.id {
                                return false
                            }
                        }
                        return true
                    })
                    
                }
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
                
            }
        }
    
    }
    
    
    @IBAction func confirmSelection(_ sender: Any) {
        guard let propertyId = propertyId,
            let selectedTenantId = selectedTenantId,
              let landlordId = Auth.auth().currentUser?.uid else {
            return
        }
        
        PendingRequests.collection.addDocument(data: [
            "tenant_id": selectedTenantId,
            "landlord_id": landlordId,
            "property_id": propertyId
        ])
        
//        UserModel.collection.document(selectedTenantId).updateData(["property_id": propertyId])
//        Property.collection.document(propertyId).updateData(["tenant_uid": selectedTenantId]) { error in
//            if let error = error {
//                print(error.localizedDescription)
//            }
        DispatchQueue.main.async {
            self.delegate?.getTenantDetails(tenantId: selectedTenantId, isPending: true)
            self.navigationController?.popViewController(animated: true)
        }
        
    }

}

extension SearchTenantsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableTenants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTenantsTableViewCell")!
        let tenant = availableTenants[indexPath.row]
        cell.textLabel?.text = tenant.name
        cell.detailTextLabel?.text = tenant.email
        if let selectedTenantId = selectedTenantId {
            if selectedTenantId == tenant.id {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            cell.accessoryType = .none
        }
        cell.selectionStyle = .none
        return cell
    }
    
}

extension SearchTenantsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTenantId = availableTenants[indexPath.row].id
        tableView.reloadData()
    }
    
}
