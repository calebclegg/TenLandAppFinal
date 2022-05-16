//
//  RegisterViewController.swift
//  tenlandpm
//
//  Created by Caleb Clegg on 25/01/2022.
//
//
//
import UIKit
import Firebase
import FirebaseAuth
import FlagPhoneNumber

class RegisterViewController: UIViewController, UITextViewDelegate{
    
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: FPNTextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var asiButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var userType: UserType = UserType.landlord
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .touchUpInside)
        setUpElements()
        //setting up delegate text fields to only allow numbers
        phoneTextfield.delegate = self
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)

    }

    func setUpElements() {
        //error messsge hidden
        errorLabel.alpha = 0
        //style the elements for curved button
        Utilities.styleFilledButton(signupButton)
        
    }
    //delegate text fields can only be numbers
    
    
    //check all fields & validate data is correctly formatted
    //if the format is not correct, ErrorLabel is displayed
    func validateFields() -> String? {
        //check all fields are not empty
        if  nameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            phoneTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            //if any areas are empty, show an error
            return "Please fill in all fields"
        }
        //check password is secure
//        let securePassword =  passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        //check if the password matches the criteria in the "Utilities.swift" file
//        if Utilities.isPasswordValid(securePassword) == false {
//        //password isn't secure enough
//            return " min 6 characters, special character and a number."
//        }
        return nil
    }
//Onboarding for landlord or Tenenant
//    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
//        if sender.selectedSegmentIndex == 0 {
//            print("now landlord")
//            userType = .landlord
//        } else if sender.selectedSegmentIndex == 1 {
//            print("now tenant")
//            userType = .tenant
//        }
//    }
    @IBAction func segmentControlDidChange(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            userType = .landlord
        } else if segmentedControl.selectedSegmentIndex == 1 {
            userType = .tenant
        }
    }
    
    //Button actions
    @IBAction func signupTapped(_ sender: Any) {
        view.endEditing(true)
        //button toggle when sign in is tapped
        UIView.animate(withDuration: 0.15,
            animations: {
                self.signupButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.signupButton.transform = CGAffineTransform.identity
                }
            })
        //validate all fields
        let error = validateFields()
        if error != nil {
            //problem with fields, show error message
            showError(error!)
        }
        else {
            //create validated versions of data
            let name = nameTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let phone = phoneTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            displayLoadingView()
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, err) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.removeLoadingView()
                }
                // Check for errors
                if let error = err {
                    var errorTitle = "There was a problem"
                    var errorMessage = "We could not sign you up"
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .emailAlreadyInUse:
                            errorTitle = "Email In Use"
                            errorMessage = "The email you set is already in use"
                        case .weakPassword:
                            errorTitle = "Weak Password"
                            errorMessage = "Please improve your password strength"
                        case .invalidEmail:
                            errorTitle = "Wrong Email"
                            errorMessage = "You entered a wrong email message"
                        default:
                            break
                        }
                    }
                    let alert = Utilities.getAlert(title: errorTitle, message: errorMessage)
                    DispatchQueue.main.async {
                        strongSelf.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                // User was created successfully, now store the first name and last name
                let db = Firestore.firestore()
                db.collection("users").document(result!.user.uid).setData(["name": name,"phone": phone, "email": email, "uid": result!.user.uid, "user_type": strongSelf.userType.getDescription()]) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        let alert = Utilities.getAlert(title: "Sign Up Error", message: "There was a problem signing you up")
                        DispatchQueue.main.async {
                            strongSelf.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    RootManager.shared.login(userType: strongSelf.userType)
                }
//                db.collection("users").addDocument(data:["name": name,"phone": phone, email:"email", "uid": result!.user.uid, "user_type": strongSelf.userType.getDescription()]) { (error) in
//                    //if an error occurs, return an error message
//                    if error != nil {
//                        // Show error message
//                        strongSelf.showError("Error saving user data")
//                    }
//                }
//                // Transition to the profile screen
//                RootManager.shared.login()
            }
        
        }
        
    }
    
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    
    
    @IBAction func asiTapped(_ sender: Any) {
        
        asiButton.animateButton { success in
            self.performSegue(withIdentifier: "AsiVC", sender: nil)
        }
        
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
        if textField == phoneTextfield {
            let allowedCharacters = CharacterSet(charactersIn:"+0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
}
