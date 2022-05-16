//
//  CookiesViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 07/05/2022.
//

import UIKit

class CookiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var CookiesTableView: UITableView!
    @IBOutlet weak var textField: UITextView!
    

    var titleArr = ["Our Responsibility", "Your Resonsibility", "Your Information", "Marketing Preferences", "Your Usage" , "Preferences" , "Cookies" , "Cookies Cache"]
    var imageArr = ["1","2","3","4","1","2","3","4"]
    
    var selectedIndex = -1
    var isCollapse = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cookies Policy"
        textField.isEditable = false
        // Do any additional setup after loading the view.
        
        CookiesTableView.estimatedRowHeight = 287
        CookiesTableView.rowHeight = UITableView.automaticDimension
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CookiesTableViewCell.identifier) as! CookiesTableViewCell
        
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
}
