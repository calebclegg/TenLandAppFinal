//
//  LoginViewController.swift
//  tenlandpm
//
//  Created by Caleb Clegg on 25/01/2022.
//
//
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var dsuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(viewTap)
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)

    }
    
    func setUpElements() {
        //error message hidden
        errorLabel.alpha = 0
        //style the elements for curved button
        Utilities.styleFilledButton(signinButton)
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    //Buttons Tap Action
    @IBAction func signinTapped(_ sender: Any) {
        //button toggle when sign in is tapped
        UIView.animate(withDuration: 0.15,
            animations: {
                self.signinButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.signinButton.transform = CGAffineTransform.identity
                }
            })
        // Create cleaned versions of the text field
        let email = emailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        // Signing in the user
        displayLoadingView()
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.removeLoadingView()
            }
            if let error = error {
                var errorTitle = "There was a problem"
                var errorMessage = "We could not sign you in"
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .wrongPassword:
                        errorTitle = "Wrong Password"
                        errorMessage = "You got your password wrong"
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
            guard let uid = result?.user.uid else { return }
            UserModel.collection.document(uid).addSnapshotListener { snapshot, error in
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
                    RootManager.shared.login(userType: user.userType)
                }
            }
        }
            
    }
     
    @IBAction func dsuTapped(_ sender: Any) {
        dsuButton.animateButton { success in
            self.performSegue(withIdentifier: "DsuVC", sender: nil)
        }
    }
    
}
