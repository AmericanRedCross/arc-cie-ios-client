//
//  SettingsTableViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 24/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
    }
    
    /// Resets the user data so that the app works like a fresh install
    func handleResetData() {
        
        let resetDataAlert = UIAlertController(title: "Reset All Data", message: "This will clear all progress and notes recorded in the app", preferredStyle: .alert)
        
        resetDataAlert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: { (action: UIAlertAction) in
            
            //Handle resetting data here when the controller exists
            
        }))
        
        resetDataAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(resetDataAlert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            //Download section
            switch indexPath.row {
            case 0:
                //Perform update
                return
            default:
                return
            }
        case 1:
            switch indexPath.row {
            case 0:
                //Play video
                let onboarding = UIStoryboard(name: "Onboarding", bundle: Bundle.main).instantiateInitialViewController()
                
                if let _onboarding = onboarding {
                    present(_onboarding, animated: true, completion: nil)
                }
                
                return
            case 1:
                handleResetData()
                return
            case 2:
                //Change language
                return
            default:
                return
            }
        default:
            return
        }
        
    }
}
