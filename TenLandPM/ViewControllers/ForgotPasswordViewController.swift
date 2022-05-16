//
//  ForgotPasswordViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 08/05/2022.
//

import UIKit
import Firebase
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var sendLinkBtn: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Forgot Password"
        //style the elements for curved button
        Utilities.styleFilledButton(sendLinkBtn)
        
        
    }
 
    
    @IBAction func emailTapped(_ sender: Any) {
    }
    
    @IBAction func sendLinkTapped(_ sender: Any) {
        
        Auth.auth().sendPasswordReset(withEmail: emailTF.text!){ (error) in
            // Check for errors
            let alert = UIAlertController(title: "Splendid", message: "A link has been sent to your email", preferredStyle: .alert)
                           
                           alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            let alert2 = UIAlertController(title: "Oops", message: "Theres a problem with your email", preferredStyle: .alert)
                           
                           alert2.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

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
