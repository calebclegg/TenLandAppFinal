//
//  TenantProfileViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 05/04/2022.
//
//
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FirebaseFirestore
import SDWebImage
import UniformTypeIdentifiers
import MessageUI

class TenantProfileViewController: UIViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var documentButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    
    var  selectedImage: ImageModel = .profile
    var uploadTask: StorageUploadTask?
    
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //setUpElements()
        profileImage.clipsToBounds = true
        Utilities.roundImage(profileImage)
//        profileImage.backgroundColor = UIColor.black

        let gesture = UITapGestureRecognizer(target: self, action:#selector(didTapChangeProfilePicture) )
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(gesture)
      
        let gesture2 = UITapGestureRecognizer(target: self, action:#selector(didTapChangeHeader) )
        headerImage.isUserInteractionEnabled = true
        headerImage.addGestureRecognizer(gesture2)
        
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
        
        if let userId = Auth.auth().currentUser?.uid {
            UserModel.collection.document(userId).addSnapshotListener { [weak self] snapshot, error in
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
                //person.circle.fill
                
                strongSelf.headerImage.sd_setImage(with: user.headerImage, placeholderImage: UIImage(systemName: "icloud.square"), options: [], completed: nil)
                strongSelf.profileImage.sd_setImage(with: user.profileImage, placeholderImage: UIImage(systemName: "person.circle.fill"), options: [], completed: nil)

                //strongSelf.headerImageView.sd_setImage(with: user.headerImage, completed: nil)
                //strongSelf.profileImageView.sd_setImage(with: user.profileImage, completed: nil)
                DispatchQueue.main.async {
                    strongSelf.nameLabel.text = user.name
                }
            }
        }
        
        
    }
        
    //Functions
    @objc private func didTapChangeProfilePicture() {
        print("Change Pic")
        selectedImage = .profile
        presentPhotoActionSheet()
    }
    
    @objc private func didTapChangeHeader() {
        
        selectedImage = .header
        presentPhotoActionSheet()
    }
    
    @objc func cancelUpload() {
        uploadTask?.cancel()
        progressIndicator.isHidden = true
        cancelButton.isHidden = true
    }
    
    func uploadImage(data: Data) {
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
                    UserModel.collection.document(user.uid).updateData([strongSelf.selectedImage.firebaseEntryName(): url.absoluteString])
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
    
    @IBAction func accountDidTouch(_ sender: Any) {
        
        self.performSegue(withIdentifier: "accVC", sender: nil)
        
    }
    
    
    @IBAction func logoutButtonDidTouch(_ sender: Any) {
        try? Auth.auth().signOut()
        RootManager.shared.logout()
        }
    
    
    @IBAction func documentsTapped(_ sender: Any) {
        let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image, UTType.audio])
        importMenu.modalPresentationStyle = .formSheet
        present(importMenu, animated: true, completion: nil)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        
    }
    
    
    @IBAction func supportTapped(_ sender: Any) {
    }
    
    
}




    
    extension TenantProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        //Profile Pic pop up permissions message
        func presentPhotoActionSheet() {
            
            let actionSheet = UIAlertController(title: "\(selectedImage) Picture",
                                                message: "How would you like to select a picture",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                                style: .default,
                                                handler: { [weak self] _ in
                                            
                                                self?.presentCamera()
                
            }))
            actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                                style: .default,
                                                handler: { [weak self] _ in
                                                
                                                self?.presentPhotoPicker()
            }))
            
            present(actionSheet, animated: true, completion: nil)
        }
        //Header pop up permissions message
        
        func presentCamera(){
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.delegate = self
            vc.allowsEditing = true
            present(vc, animated: true)
        }
        func presentPhotoPicker(){
            let vc = UIImagePickerController()
            vc.sourceType = .photoLibrary
            vc.delegate = self
            vc.allowsEditing = true
            present(vc, animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
            //profile pic
            guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                return
            }
            switch selectedImage {
            case .header:
                self.headerImage.image = editedImage
            case .profile:
                self.profileImage.image = editedImage
            default:
                return
            }
            guard let imageData = editedImage.jpegData(compressionQuality: 0.75) else {
                return
            }
            self.uploadImage(data: imageData)
        }
            
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
            picker.dismiss(animated: true, completion: nil)
        }
    
    }

