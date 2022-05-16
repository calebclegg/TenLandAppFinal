//
//  LandlordThemeViewController.swift
//  TenLandPM
//
//  Created by Caleb Clegg on 01/05/2022.
//

import UIKit

class LandlordThemeViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Theme"
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureStyle(for theme: Theme) {
      view.window?.overrideUserInterfaceStyle = theme.userInterfaceStyle
    }

}

extension LandlordThemeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Theme.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theme = Theme.allCases[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "basicStyle") else {
            fatalError()
        }
        cell.textLabel!.text = theme.getName()
        cell.textLabel?.textColor = UIColor.label
        if theme == UserDefaults.standard.theme {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.backgroundColor = UIColor.secondarySystemGroupedBackground
        return cell
    }
    
}

extension LandlordThemeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theme = Theme.allCases[indexPath.row]
        configureStyle(for: theme)
        UserDefaults.standard.theme = theme
        tableView.reloadData()
    }
    
}

