//
//  TenantMaintenanceViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 19/4/2022.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SDWebImage


class TenantMaintenanceViewController: UIViewController {
    
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var maintenancetypeTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var dorPicker: UIDatePicker!
    @IBOutlet weak var daPicker: UIDatePicker!
    
    
    @IBOutlet weak var maintenanceButton: UIButton!
    
    
    var uploadTask: StorageUploadTask?
    var maintenanceImage: UIImage?
    
    var progressIndicator: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = UIColor.lightGray
        view.progressTintColor = UIColor.black
        view.progress = Float(0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel Upload", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(cancelUpload), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    struct MaintenanceFields {
        var maintenanceType: String
        var description: String
        var requestDate: Double
        var dateAvailable: Double
    }
    
    var maintenanceFields: MaintenanceFields?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Add Maintenance"
        
        Utilities.styleFilledButton(maintenanceButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(addMaintenanceImage))
        addImage.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap2)
        
        addImage.isUserInteractionEnabled = true
        view.addSubview(progressIndicator)
        view.addSubview(cancelButton)
        let constraints: [NSLayoutConstraint] = [
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 5),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        progressIndicator.isHidden = true
        cancelButton.isHidden = true
    }
    
    func uploadImage(data: Data) {
        guard let maintenanceFields = maintenanceFields,
              let property = TenantAccount.shared.property else {
            return
        }
        guard let user = Auth.auth().currentUser else { return }
        progressIndicator.isHidden = false
        cancelButton.isHidden = false
        progressIndicator.progress = Float(0)
        let imageId: String = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "_")
        let imageName: String = "\(imageId).jpg"
        let pathToPic = "images/\(user.uid)/\(imageName)"
        let storageRef = Storage.storage().reference(withPath: pathToPic)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        uploadTask = storageRef.putData(data, metadata: metaData, completion: { [weak self] metaData, error in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.progressIndicator.isHidden = true
                strongSelf.cancelButton.isHidden = true
            }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            storageRef.downloadURL { url, error in
                if let url = url,
                   error == nil {
                    
                    let document = Maintenance.collection.addDocument(data: [
                        "maintenance_type": maintenanceFields.maintenanceType,
                        "description": maintenanceFields.description,
                        "request_date": maintenanceFields.requestDate,
                        "available_date": maintenanceFields.dateAvailable,
                        ImageModel.maintenance.firebaseEntryName(): url.absoluteString,
                        "tenant_uid": user.uid
                    ])
                    MaintenanceNotification.collection.addDocument(data: [
                        "property_id": property.id,
                        "landlord_uid": property.ownerId,
                        "tenant_uid": user.uid,
                        "is_read": false,
                        "maintenance_id": document.documentID,
                        "title": maintenanceFields.maintenanceType,
                        "image": url.absoluteString
                    ])
                    DispatchQueue.main.async {
                        strongSelf.dismiss(animated: true)
                    }
                }
            }
            
        })
        uploadTask!.observe(.progress) { snapshot in
            let percentComplete = 100.0 * (Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount))
            DispatchQueue.main.async {
                self.progressIndicator.setProgress(Float(percentComplete), animated: true)
            }
        }
    }
    
    func validateFields() -> Bool {
        guard let maintenanceType = maintenancetypeTF.text,
                !maintenanceType.isEmpty else {
            return false
        }
        guard let description = descriptionTF.text,
                !description.isEmpty else {
            return false
        }
        let requestDate = dorPicker.date.timeIntervalSince1970
        let dateAvailable = daPicker.date.timeIntervalSince1970
        let maintenanceFields = MaintenanceFields(
            maintenanceType: maintenanceType,
            description: description,
            requestDate: requestDate,
            dateAvailable: dateAvailable)
        self.maintenanceFields = maintenanceFields
        return true
    }
    
    @objc func addMaintenanceImage() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @objc func cancelUpload() {
        
    }
    
    @IBAction func addMaintenanceButtonDidTouch(_ sender: Any) {
        guard let _ = TenantAccount.shared.property else {
            let alert = Utilities.getAlert(title: "Error", message: "You must have a property before you can add a maintenance request")
            present(alert, animated: true)
            return
        }
        guard let maintenanceImage = maintenanceImage else {
            return
        }
        guard let imageData = maintenanceImage.jpegData(compressionQuality: 0.75) else {
            return
        }
        if validateFields() {
            uploadImage(data: imageData)
        }
    }

}

extension TenantMaintenanceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        addImage.image = editedImage
        maintenanceImage = editedImage
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
}
