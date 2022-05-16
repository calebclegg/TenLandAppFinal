//
//  TenantLandlordDetailsViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 01/05/2022.
//

import UIKit
import SDWebImage
import MessageUI

class TenantLandlordDetailsViewController: UIViewController {
    
    var ownerId: String?
    var landlord: UserModel?
    
    @IBOutlet weak var headerImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var userTF: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Landlord Details"
        fetchData()
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentAlertAction))

        phoneTF.addGestureRecognizer(tap)
        phoneTF.isUserInteractionEnabled = true
        
        emailTF.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
        
        Utilities.roundImage(profileImageView)
//        headerImageView.layer.borderWidth = 3.0
        
    }
    func fetchData() {
        guard let ownerId = ownerId else {
            return
        }
        displayLoadingView()
        UserModel.collection.document(ownerId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.removeLoadingView()
            }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let snapshot = snapshot else {
                return
            }
            guard let landlord = UserModel(snapshot: snapshot) else {
                return
            }
            strongSelf.landlord = landlord
            DispatchQueue.main.async {
                if let headerImage = landlord.headerImage {
                    strongSelf.headerImageView.sd_setImage(with: headerImage)
                }
                if let profileImage = landlord.profileImage {
                    strongSelf.profileImageView.sd_setImage(with: profileImage)
                }
                strongSelf.nameTF.text = landlord.name
                strongSelf.emailTF.text = landlord.email
                strongSelf.phoneTF.text = landlord.phone
            }
        }
    }
//
//    func popup() {
//        guard let landlord = landlord else {
//            return
//        }
//        let landlordEmail = landlord.email
//    }
//
    @objc func presentAlertAction() {
        
         let alert = UIAlertController(title: "Choose Method", message: "Choose mode of contact", preferredStyle: .actionSheet)
  
         alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                 
         
         alert.addAction(UIAlertAction(title: "Message", style: .default, handler: { [weak self] _ in
             
             self?.sendMessage()
         }))
         
         alert.addAction(UIAlertAction(title: "Phone", style: .default, handler: { [weak self] _ in
             
             self?.makeCall()
         }))
         
         present(alert, animated: true, completion: nil)
     }
    
    
         func sendMessage() {
         guard let landlord = landlord,
         let landlordPhone = landlord.phone else {
             return
         }
         if MFMessageComposeViewController.canSendText() == true {
                 let recipients:[String] = [landlordPhone]
                 let messageController = MFMessageComposeViewController()
                 messageController.messageComposeDelegate  = self
                 messageController.recipients = recipients
                 self.present(messageController, animated: true, completion: nil)
                 
             }
     }
     
         func makeCall() {
             guard let landlord = landlord,
             let landlordPhone = landlord.phone else {
                 return
             }
             if let url = URL(string: "tel://\(landlordPhone)"),
                UIApplication.shared.canOpenURL(url) {
                 UIApplication.shared.open(url, options: [:], completionHandler: nil)
             }
         }
 }
    

extension TenantLandlordDetailsViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: nil)
            
             
    }
    
}
