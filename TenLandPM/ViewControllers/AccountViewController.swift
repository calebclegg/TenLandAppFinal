//
//  AccountViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 22/02/2022.
//
//
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FirebaseFirestore
import UniformTypeIdentifiers
import MessageUI

class AccountViewController: UIViewController, ObservableObject, MFMailComposeViewControllerDelegate{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var userTF: UITextField!
    
    @IBOutlet weak var updateBtn: UIButton!
    
    var listener: ListenerRegistration?
    
    deinit {
        print("Account VC did deinit")
        listener?.remove()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Account Information"
        userTF.isEnabled = false
        emailTF.isEnabled = false
        nameTF.isEnabled = false
        
        Utilities.styleFilledButton(updateBtn)
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)

        
        if let userId = Auth.auth().currentUser?.uid {
            listener = UserModel.collection.document(userId).addSnapshotListener { [weak self] snapshot, error in
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
                
                DispatchQueue.main.async {
                    strongSelf.nameTF.text = user.name
                    strongSelf.phoneTF.text = user.phone
                    strongSelf.emailTF.text = user.email
                    strongSelf.userTF.text = user.userType.getDescription()
                }
                
            }
        }
       
    }
    
    
    @IBAction func updateButtonDidTouch(_ sender: Any) {
        
        let alert = UIAlertController(title: "Splendid", message: "Your number has been updated", preferredStyle: .alert)
                       
                       alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        let alert2 = UIAlertController(title: "Oops", message: "Theres a problem with your number", preferredStyle: .alert)
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        guard let nameEntry = nameTF.text,
              !nameEntry.isEmpty else {
                  //TODO: - Create error alert here
                  return
              }
        guard nameEntry.count > 5 else {
            //TODO: - Alert to say name was too short
            return
        }
        
        guard let phoneEntry = phoneTF.text,
              !phoneEntry.isEmpty else {
            let alert = Utilities.getAlert(title: "Mandatory", message: "A phone number must be provided")
            present(alert, animated: true)

                  return
              }
        
        UserModel.collection.document(userId).updateData(["name": nameEntry, "phone": phoneEntry]) { error in
//            if let error = error {
//                //TODO: - Create alert to say update did not succeed
//                print(error.localizedDescription)
//                return
//            }
//            //TODO: - Create alert to say update successful
//        }
            if error == nil {
                
                self.present(alert, animated: true, completion: nil)
                print("sent")
                
               
            }else{
            
                self.present(alert2, animated: true, completion: nil)
             print ("Failed")
            }
        }
       
    }
        
    
}
    
    
    
