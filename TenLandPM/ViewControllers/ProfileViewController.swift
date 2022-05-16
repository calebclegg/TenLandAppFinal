//
//  ProfileViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 7/2/2022.
//
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FirebaseFirestore
import SDWebImage
import UniformTypeIdentifiers
import MessageUI

class ProfileViewController: UIViewController {

    //Declare Variables
    
    //Declare outlets
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var propertiesBtn: UIButton!
    @IBOutlet weak var tenantsBtn: UIButton!
    @IBOutlet weak var propertiesLabel: UILabel!
    @IBOutlet weak var tenantsLabel: UILabel!
    
    
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var documentsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIButton!
    
  

    
    
    var selectedImage: ImageModel = .profile
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
        title = "Profile"
        //setUpElements()
        profileImageView.clipsToBounds = true
        Utilities.roundImage(profileImageView)
//        profileImageView.backgroundColor = UIColor.black
       
        
        //styling
        propertiesLabel.layer.borderWidth = 0.3
        tenantsLabel.layer.borderWidth = 0.3
        
        propertiesBtn.layer.borderWidth = 0.3
        tenantsBtn.layer.borderWidth = 0.3
        
        
        let gesture = UITapGestureRecognizer(target: self, action:#selector(didTapChangeProfilePicture) )
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(gesture)
      
        let gesture2 = UITapGestureRecognizer(target: self, action:#selector(didTapChangeHeader) )
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(gesture2)
        
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
                
                strongSelf.headerImageView.sd_setImage(with: user.headerImage, placeholderImage: UIImage(systemName: "icloud.square"), options: [], completed: nil)
                strongSelf.profileImageView.sd_setImage(with: user.profileImage, placeholderImage: UIImage(systemName: "person.circle.fill"), options: [], completed: nil)

                //strongSelf.headerImageView.sd_setImage(with: user.headerImage, completed: nil)
                //strongSelf.profileImageView.sd_setImage(with: user.profileImage, completed: nil)
                DispatchQueue.main.async {
                    strongSelf.nameLabel.text = user.name
                }
            }
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getProfileCounts()
    }
    
    func getProfileCounts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Property.collection.whereField("owner_uid", isEqualTo: uid).getDocuments { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let documents = snapshot?.documents else {
                print("no documents")
                return
            }
            let properties = documents.compactMap({ snap in
                Property(data: snap)
            })
            
            let propertyCount = properties.count
            
            let propertiesWithTenants = properties.filter { property in
                return property.tenantId != nil
            }
            
            let tenantsCount = propertiesWithTenants.count
            
            DispatchQueue.main.async {
                strongSelf.propertiesBtn.setTitle("\(propertyCount)", for: .normal)
                strongSelf.tenantsBtn.setTitle("\(tenantsCount)", for: .normal)
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
    
    
    //Actions
    
    
    
    
    @IBAction func logoutButton(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            RootManager.shared.logout()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func accTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "acVC", sender: nil)
        //let viewController = AccountViewController(nibName: "AccountViewController", bundle: nil)
        //self.navigationController?.pushViewController(viewController, animated: true)
        
        //let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //let AccountViewController = storyBoard.instantiateViewController(withIdentifier: "AccVC") as! AccountViewController
        //self.present(AccountViewController, animated:true, completion:nil)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
//       performSegue(withIdentifier: "showSettings", sender: nil)
    }
    
    
    @IBAction func documentsTapped(_ sender: Any) {
        
        let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image, UTType.audio])
        importMenu.modalPresentationStyle = .formSheet
        present(importMenu, animated: true, completion: nil)
    }
    
    
    @IBAction func supportTapped(_ sender: Any) {
        
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            self.headerImageView.image = editedImage
        case .profile:
            self.profileImageView.image = editedImage
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


