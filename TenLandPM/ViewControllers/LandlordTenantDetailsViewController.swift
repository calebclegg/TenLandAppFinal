//
//  LandlordTenantDetailsViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 01/05/2022.
//
//
import UIKit
import SDWebImage
import MessageUI

class LandlordTenantDetailsViewController: UIViewController {

    var tenantId: String?
    var tenant: UserModel?
    
    @IBOutlet weak var headerImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var usertypeTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tenant Details"
        
        fetchData()
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentAlertAction))
        phoneNumber.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap2)

        let tap3 = UITapGestureRecognizer(target: self, action: #selector(sendEmail))
        emailTF.addGestureRecognizer(tap3)
        
        
        phoneNumber.isUserInteractionEnabled = true
        
        emailTF.isUserInteractionEnabled = true
        
        nameTF.isUserInteractionEnabled = false
        
        Utilities.roundImage(profileImageView)
        
        // Do any additional setup after loading the view.
    }
    
    func fetchData() {
        guard let tenantId = tenantId else {
            return
        }
        UserModel.collection.document(tenantId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let snapshot = snapshot else {
                return
            }
            guard let tenant = UserModel(snapshot: snapshot) else {
                return
            }
            strongSelf.tenant = tenant
            DispatchQueue.main.async {
                if let headerImage = tenant.headerImage {
                    strongSelf.headerImageView.sd_setImage(with: headerImage)
                }
                if let profileImage = tenant.profileImage {
                    strongSelf.profileImageView.sd_setImage(with: profileImage)
                }
                strongSelf.nameTF.text = tenant.name
                strongSelf.emailTF.text = tenant.email
                strongSelf.phoneNumber.text = tenant.phone
            }
        }
    }
    
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
        guard let tenant = tenant,
        let tenantPhone = tenant.phone else {
            return
        }
        if MFMessageComposeViewController.canSendText() == true {
                let recipients:[String] = [tenantPhone]
                let messageController = MFMessageComposeViewController()
                messageController.messageComposeDelegate  = self
                messageController.recipients = recipients
                self.present(messageController, animated: true, completion: nil)
                
            }
    }
    
        func makeCall() {
            guard let tenant = tenant,
                  let tenantPhone = tenant.phone else {
                return
            }
            
            if let url = URL(string: "tel://\(tenantPhone)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    
    @objc func sendEmail(){
        guard let tenant = tenant else {
            return
        }
        let tenantEmail = tenant.email
    
            if MFMailComposeViewController.canSendMail() == true {
                
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([tenantEmail])
                mail.setSubject("")
                mail.setMessageBody("<p>Hey there, </p>", isHTML: true)
                present(mail, animated: true)
            } else {
                print("Application is not able to send an email")
            
            }
    }
    
}


extension LandlordTenantDetailsViewController: MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: nil)
        
        
        //MARK: MFMail Compose ViewController Delegate method
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let _ = error {
                controller.dismiss(animated: true, completion: nil)
                return
            }
            switch result {
            case .cancelled:
                break
            case .failed:
                break
            case .saved:
                break
            case .sent:
                break
            }
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
            
             
    
    



