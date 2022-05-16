//
//  NotificationsViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 26/4/2022.
//
//
import UIKit
import Firebase
import SDWebImage

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var notifications: [MaintenanceNotification] = [MaintenanceNotification]()
    lazy var emptyStateView: EmptyStateView = {
        return UINib(nibName: "EmptyStateView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EmptyStateView
    }()
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let notification = sender as? MaintenanceNotification else {
            return
        }
        guard let destinationVC = segue.destination as? NotificationDetailViewController else {
            return
        }
        destinationVC.propertyId = notification.propertyId
        destinationVC.tenantId = notification.tenantId
        destinationVC.maintenanceId = notification.maintenanceId
        destinationVC.notificationId = notification.id
    }
    
    func fetchData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        displayLoadingView()
        MaintenanceNotification.collection.whereField("landlord_uid", isEqualTo: uid).addSnapshotListener { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.removeLoadingView()
            }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let documents = snapshot?.documents else {
                return
            }
            strongSelf.notifications = documents.compactMap({ snap in
                MaintenanceNotification(data: snap)
            })
            if strongSelf.notifications.count > 0 {
                DispatchQueue.main.async {
                    strongSelf.removeEmptyStateView()
                    strongSelf.tableView.isHidden = false
                    strongSelf.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.displayEmptyStateView()
                    strongSelf.tableView.isHidden = true
                }
            }
        }
    }
    
    func displayEmptyStateView() {
        emptyStateView.emptyStateLabel.text = "You have no maintenance requests from tenants!"
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
extension NotificationsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = notifications[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationsTableViewCell.identifier) as! NotificationsTableViewCell
        cell.notificationImageView.sd_setImage(with: notification.image)
        cell.notificationTitleLabel.text = notification.title
        if notification.isRead {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor(hex: "#f6e58d")
        }
        cell.selectionStyle = .none
        return cell
    }
    
}

extension NotificationsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        notifications[indexPath.row].isRead = true
        performSegue(withIdentifier: "ShowNotificationDetailSegue", sender: notification)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}
