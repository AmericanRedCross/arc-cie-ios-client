//
//  ARCTabBarViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 22/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit

class ARCNavigationController: UINavigationController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        
        // Add Export and Settings options on our two main view controllers
        if let topVc = topViewController, topVc is WorkflowViewController || topVc is ProgressTableViewController {
            let exportButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "workflow-navigation-download-icon"), style: .done, target: self, action: #selector(showExportOptions))
            
            let settingsButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "workflow-navigation-settings-icon"), style: .done, target: self, action: #selector(showSettings))
            
            self.topViewController?.navigationItem.rightBarButtonItems = [settingsButtonItem, exportButtonItem]
        }
    }
    
    // Presents the settings view controller
    @objc func showSettings() {
        
        if let settingsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() {
            
            self.present(settingsViewController, animated: true, completion: nil)
        }
    }
    
    // Presents the export options view controller
    @objc func showExportOptions() {
        
        if let exportOptionsViewController = UIStoryboard(name: "Export", bundle: nil).instantiateInitialViewController() {
            
            self.present(exportOptionsViewController, animated: true, completion: nil)
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
}
