//
//  TenantMaintenanceDetailViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 27/04/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage


class TenantMaintenanceListViewController: UIViewController {


    

    @IBOutlet weak var requestsTableView: UITableView!
    
    var maintenance: [Maintenance] = [Maintenance]()
    lazy var emptyStateView: EmptyStateView = {
        return UINib(nibName: "EmptyStateView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EmptyStateView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Maintenance Requests"
        requestsTableView.dataSource = self
        requestsTableView.delegate = self
        requestsTableView.isHidden = true
        loadData()

        // Do any additional setup after loading the view.
    }
    
    
    
    func loadData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        displayLoadingView()
        Maintenance.collection.whereField("tenant_uid", isEqualTo: uid).addSnapshotListener { [weak self] snapshot, error in
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
            strongSelf.maintenance = documents.compactMap({ snap in
                Maintenance(snapshot: snap)
            })
            if strongSelf.maintenance.count > 0 {
                DispatchQueue.main.async {
                    strongSelf.removeEmptyStateView()
                    strongSelf.requestsTableView.isHidden = false
                    strongSelf.requestsTableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.requestsTableView.isHidden = true
                    strongSelf.displayEmptyStateView()
                }
            }
        }
        
    }
    func displayEmptyStateView() {
        emptyStateView.emptyStateLabel.text = "You have not created any properties yet!"
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
    
}
    
    extension TenantMaintenanceListViewController: UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return maintenance.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let maintenance = maintenance[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: RequestsTableViewCell.identifier) as! RequestsTableViewCell
            cell.titleLabel.text =  maintenance.maintenanceType
            cell.requestImageView.sd_setImage(with: maintenance.addImage)
            cell.dateLabel.text = maintenance.dor.getDateString()
            cell.selectionStyle = .none
            return cell
        }
        
    }


extension TenantMaintenanceListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(120)
    }
}
