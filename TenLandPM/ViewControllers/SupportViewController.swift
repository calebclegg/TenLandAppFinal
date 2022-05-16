//
//  SupportViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 08/05/2022.
//
//
import UIKit
import MessageUI

class SupportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textField: UITextView!
    
    @IBOutlet weak var emailBtn: UIButton!
    
    var titleArr = ["Our Responsibility", "Your Resonsibility", "Your Information", "Marketing Preferences", "Your Usage" , "Preferences" , "Cookies" , "Cookies Cache"]
    var imageArr = ["1","2","3","4","1","2","3","4"]
    
    var selectedIndex = -1
    var isCollapse = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FAQ"
        textField.isEditable = false
        // Do any additional setup after loading the view.
        
        tableView.estimatedRowHeight = 287
        tableView.rowHeight = UITableView.automaticDimension
        Utilities.styleFilledButton(emailBtn)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectedIndex == indexPath.row && isCollapse == true
        {
            return 270
            
        }else {
            
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SupportFAQTableViewCell.identifier) as! SupportFAQTableViewCell
        
        cell.titleLabel.text! = titleArr[indexPath.row]
        cell.imageTableView.image = UIImage (named: "\(imageArr[indexPath.row])")
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                     
        if selectedIndex == indexPath.row
            
        {
            if self.isCollapse == false
            {
                self.isCollapse = true
            } else{
                
                self.isCollapse = false
                }
            }else
            {
                
                self.isCollapse = true
            }
            self.selectedIndex = indexPath.row
            tableView.reloadRows(at: [indexPath], with: .automatic)
        
            }
    
    
    @IBAction func emailSupportBtn(_ sender: Any) {
        
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["appsupport@tenpm.com"])
        composer.setSubject("App Support")
        composer.setMessageBody("<p> Hi there, I seem to be having a problem with </p>", isHTML: true)
        present(composer, animated: true)
        
    }
    
    
}

extension SupportViewController: MFMailComposeViewControllerDelegate {
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


    
    

