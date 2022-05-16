//
//  SendFeedbackViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 08/05/2022.
//
import UIKit
import MessageUI


class SettingsListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
    }
    
@IBAction func sendEmail(_ sender: Any) {
            
            guard MFMailComposeViewController.canSendMail() else {
                return
            }
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setToRecipients(["customerexperience@tenpm.com"])
            composer.setSubject("Feedback")
            present(composer, animated: true)
            
        }
        
        
    }

extension SettingsListViewController: MFMailComposeViewControllerDelegate {
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

