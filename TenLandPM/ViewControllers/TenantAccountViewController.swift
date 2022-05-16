//
//  TenantAccountViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 21/04/2022.
//

import UIKit
import Firebase

class TenantAccountViewController: UIViewController, ObservableObject {

    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var usertypeTF: UITextField!
    
    
    
    var listener: ListenerRegistration?
    
    deinit {
        print("Account VC did deinit")
        listener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usertypeTF.isEnabled = false
        emailTF.isEnabled = false
        nameTF.isEnabled = false
        
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
                    strongSelf.usertypeTF.text = user.userType.getDescription()
                }
                
            }
        }
       
    }


    @IBAction func updateDidTouch(_ sender: Any) {
        
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
        guard let emailEntry = emailTF.text,
              !nameEntry.isEmpty else {
                  //TODO: - Create error alert here
                  return
              }
        
        guard let phoneEntry = phoneTF.text,
              !phoneEntry.isEmpty else {
                  //TODO: - Create error alert here
                  return
              }
        

        
        UserModel.collection.document(userId).updateData(["name": nameEntry, "phone": phoneEntry, "email":emailEntry]) { error in
            if let error = error {
                //TODO: - Create alert to say update did not succeed
                print(error.localizedDescription)
                return
            }
            //TODO: - Create alert to say update successful
        }
    }
    
    

}
