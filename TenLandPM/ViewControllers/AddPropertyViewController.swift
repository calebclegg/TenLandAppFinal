//
//  AddPropertyViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 9/4/2022.
//
//
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SDWebImage

class AddPropertyViewController: UIViewController {
    
    @IBOutlet weak var addressLine1TextField: UITextField!
    @IBOutlet weak var numberOfBedsTextField: UITextField!
    @IBOutlet weak var numberOfLivingRoomsTextField: UITextField!
    @IBOutlet weak var numberOfBathroomsTextField: UITextField!
    @IBOutlet weak var leaseTypePickerView: UIPickerView!
    @IBOutlet weak var paymentDatePickerView: UIPickerView!
    @IBOutlet weak var startDatePickerView: UIDatePicker!
    @IBOutlet weak var endDatePickerView: UIDatePicker!
    @IBOutlet weak var rentAmountTextField: UITextField!
    @IBOutlet weak var addPropertyButton: UIButton!
    @IBOutlet weak var addPropertyImageView: UIImageView!
    @IBOutlet weak var addImageStackView: UILabel!
    
    @IBOutlet weak var addProperty: UIButton!
    
    let selectedImage: ImageModel = .property
    let imagePicker = UIImagePickerController()
    var propertyImage: UIImage?
    var uploadTask: StorageUploadTask?
    
    struct PropertyFields {
        var addressLine1: String
        var numberOfBeds: Int
        var numberOfLivingRooms: Int
        var numberOfBathrooms: Int
        var leaseType: LeaseType
        var paymentDate: PaymentDate
        var endDate: Double
        var startDate: Double
        var propertyImage: URL?
        var rentAmount: Int
    }
    
    var propertyFields: PropertyFields?
    
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
    
    lazy var viewCoverOverlay: UIView = {
        let viewCoverOverlay = UIView()
        viewCoverOverlay.backgroundColor = UIColor.black
        viewCoverOverlay.alpha = 0.35
        viewCoverOverlay.isHidden = true
        viewCoverOverlay.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        viewCoverOverlay.tag = 10110
        let viewOverlayTapped = UITapGestureRecognizer(target: self, action: #selector(dimissRequestViews))
        viewCoverOverlay.addGestureRecognizer(viewOverlayTapped)
        return viewCoverOverlay
    }()
    
    
    
    let leaseTypeDataSource = LeaseTypePickerViewDataSource()
    let paymentDateDataSource = PaymentDateDataSource()
    let leaseTypeDelegate = LeaseTypePickerViewDelegate()
    let paymentDateDelegate = PaymentDateDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Property"
        let tap = UITapGestureRecognizer(target: self, action: #selector(addPropertyImage))
        addPropertyImageView.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap2)
        
        addPropertyImageView.isUserInteractionEnabled = true
        view.addSubview(viewCoverOverlay)
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
        leaseTypePickerView.dataSource = leaseTypeDataSource
        paymentDatePickerView.dataSource = paymentDateDataSource
        leaseTypePickerView.delegate = leaseTypeDelegate
        paymentDatePickerView.delegate = paymentDateDelegate
        
        Utilities.styleFilledButton(addProperty)
    }
    
    func uploadImage(data: Data) {
        guard let propertyFields = propertyFields else {
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
        viewCoverOverlay.isHidden = false
        uploadTask = storageRef.putData(data, metadata: metaData, completion: { [weak self] metaData, error in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.progressIndicator.isHidden = true
                strongSelf.cancelButton.isHidden = true
                strongSelf.viewCoverOverlay.removeFromSuperview()
            }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            storageRef.downloadURL { url, error in
                if let url = url,
                   error == nil {
                    Property.collection.addDocument(data: [
                        "addressLine1": propertyFields.addressLine1,
                        "numberOfBeds": propertyFields.numberOfBeds,
                        "leaseType": propertyFields.leaseType.rawValue,
                        "numberOfLivingRooms": propertyFields.numberOfLivingRooms,
                        "numberOfBathrooms": propertyFields.numberOfBeds,
                        "paymentDate": propertyFields.paymentDate.rawValue,
                        "endDate": propertyFields.endDate,
                        "startDate": propertyFields.startDate,
                        ImageModel.property.firebaseEntryName(): url.absoluteString,
                        "owner_uid": user.uid,
                        "rentAmount": propertyFields.rentAmount
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
        guard let addressLine1 = addressLine1TextField.text,
                !addressLine1.isEmpty else {
            let alert = Utilities.getAlert(title: "Address Line 1", message: "Address line 1 is required")
            present(alert, animated: true)
            return false
        }
        guard let numberOfBedsText = numberOfBedsTextField.text,
                !numberOfBedsText.isEmpty,
              let numberOfBeds = Int(numberOfBedsText) else {
            let alert = Utilities.getAlert(title: "Number of Beds", message: "Number of beds is required")
            present(alert, animated: true)
            return false
        }
        guard let numberOfLivingRoomsText = numberOfLivingRoomsTextField.text,
                !numberOfLivingRoomsText.isEmpty,
        let numberOfLivingRooms = Int(numberOfLivingRoomsText)  else {
            let alert = Utilities.getAlert(title: "Living Rooms", message: "Number of living rooms is required")
            present(alert, animated: true)
            return false
        }
        guard let numberOfBathroomsText = numberOfBathroomsTextField.text,
                !numberOfBathroomsText.isEmpty,
              let numberOfBathrooms = Int(numberOfBathroomsText) else {
            let alert = Utilities.getAlert(title: "Bathrooms", message: "Number of bathrooms is required")
            present(alert, animated: true)
            return false
        }
        
        guard let rentAmountText = rentAmountTextField.text,
              !rentAmountText.isEmpty,
              let rentAmount = Int(rentAmountText) else {
            let alert = Utilities.getAlert(title: "Rent Amount", message: "Rent amount is required")
            present(alert, animated: true)
            return false
        }
        
        let startDate = startDatePickerView.date.timeIntervalSince1970
        let endDate = endDatePickerView.date.timeIntervalSince1970
        
        guard let leaseType = LeaseType.init(rawValue: leaseTypePickerView.selectedRow(inComponent: 0)) else {
            return false
        }
        
        guard let paymentDate = PaymentDate.init(rawValue: paymentDatePickerView.selectedRow(inComponent: 0)) else {
            return false
        }
        
        let propertyFields = PropertyFields(
            addressLine1: addressLine1,
            numberOfBeds: numberOfBeds,
            numberOfLivingRooms: numberOfLivingRooms,
            numberOfBathrooms: numberOfBathrooms,
            leaseType: leaseType,
            paymentDate: paymentDate,
            endDate: endDate,
            startDate: startDate,
            rentAmount: rentAmount)
        
        self.propertyFields = propertyFields
        
        return true
        
    }
    @objc func dimissRequestViews() {
        viewCoverOverlay.removeFromSuperview()
    }
    
    
    
    @objc func addPropertyImage() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @objc func cancelUpload() {
        
    }
    
    @IBAction func addPropertyButtonDidTouch(_ sender: Any) {
        guard let propertyImage = propertyImage else {
            let alert = Utilities.getAlert(title: "Image", message: "A property image is required")
            present(alert, animated: true)
            return
        }
        guard let imageData = propertyImage.jpegData(compressionQuality: 0.75) else {
            return
        }
        if validateFields() {
            uploadImage(data: imageData)
        }
    }

}

extension AddPropertyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        addPropertyImageView.image = editedImage
        propertyImage = editedImage
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension AddPropertyViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return LeaseType.allCases.count
    }
    
}
