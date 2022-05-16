//
//  HomeViewController.swift
//  tenlandpm
//
//  Created by Caleb Clegg on 25/01/2022.
//
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class HomeViewController: UIViewController {

    @IBOutlet weak var propertyTableView: UITableView!
    var properties: [Property] = [Property]()
    lazy var emptyStateView: EmptyStateView = {
        return UINib(nibName: "EmptyStateView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EmptyStateView
    }()
    let notificationsButton = BadgedButtonItem(with: UIImage(systemName: "bell.fill")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Properties"
        propertyTableView.dataSource = self
        propertyTableView.delegate = self
        propertyTableView.isHidden = true
        self.navigationItem.rightBarButtonItem = notificationsButton
        notificationsButton.tapAction = {
            self.performSegue(withIdentifier: "MaintenanceNotificationsSegue", sender: nil)
        }
        
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? PropertyDetailViewController,
           let property = sender as? Property {
            destinationVC.property = property
        }
    }
    
    
    
    func loadData() {
        fetchProperties()
        fetchNotificationsCount()
    }
    
    func fetchProperties() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        displayLoadingView()
        Property.collection.whereField("owner_uid", isEqualTo: uid).addSnapshotListener { [weak self] snapshot, error in
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
            strongSelf.properties = documents.compactMap({ snap in
                Property(data: snap)
            })
            if strongSelf.properties.count > 0 {
                DispatchQueue.main.async {
                    strongSelf.removeEmptyStateView()
                    strongSelf.propertyTableView.isHidden = false
                    strongSelf.propertyTableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.propertyTableView.isHidden = true
                    strongSelf.displayEmptyStateView()
                }
            }
        }
    }
    
    func fetchNotificationsCount() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        MaintenanceNotification.collection.whereField("landlord_uid", isEqualTo: uid).addSnapshotListener { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let documents = snapshot?.documents else {
                return
            }
            let notifications = documents.compactMap({ snap in
                MaintenanceNotification(data: snap)
            })
            
            let unreadNotifications = notifications.filter { notification in
                notification.isRead == false
            }.count
            
            DispatchQueue.main.async {
                strongSelf.notificationsButton.setBadge(with: unreadNotifications)
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
//
//    @IBAction func maintenanceRequestsButtonDidTouch(_ sender: Any) {
//        performSegue(withIdentifier: "MaintenanceNotificationsSegue", sender: nil)
//    }
//

}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let property = properties[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyTableViewCell.identifier) as! PropertyTableViewCell
        cell.addressLine1Label.text = property.addressLine1
        cell.numberOfBedsLabel.text = "\(property.numberOfBeds)"
        cell.numberOfLivingRoomsLabel.text = "\(property.numberOfLivingRooms)"
        cell.numberOfBathsLabel.text = "\(property.numberOfBathrooms)"
        cell.propertyImageView.sd_setImage(with: property.propertyImage)
        cell.rentamountTF.text = "€\(property.rentAmount)"
        cell.selectionStyle = .none
        return cell
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let property = properties[indexPath.row]
        performSegue(withIdentifier: "ShowPropertyDetailSegue", sender: property)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(250)
    }
    
}
