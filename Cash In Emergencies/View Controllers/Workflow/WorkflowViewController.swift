//
//  WorkflowViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 22/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import ARCDM
import ThunderTable

class WorkflowViewController: UIViewController {
    
    @IBOutlet weak var toolkitButton: UIButton!
    @IBOutlet weak var criticalToolsButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var toolkitTableViewController: ToolkitTableViewController? {
        return childViewControllers.first as? ToolkitTableViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        toolkitTableViewController?.tableView.contentOffset = CGPoint(x: 0, y: 44)
        
        toolkitButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        toolkitButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        
        criticalToolsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        criticalToolsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)

        if !UserDefaults.standard.bool(forKey: "CIEHasDoneOnboarding") {
            let onboarding = UIStoryboard(name: "Onboarding", bundle: Bundle.main).instantiateInitialViewController()
            
            if let onboarding = onboarding {
                present(onboarding, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleFilterButton(_ sender: UIButton) {
        
        toolkitButton.isSelected = !toolkitButton.isSelected
        criticalToolsButton.isSelected = !criticalToolsButton.isSelected
        
        toolkitButton.backgroundColor = toolkitButton.isSelected ? UIColor(hexString: "ed1b2e") : UIColor.clear
        toolkitButton.tintColor = toolkitButton.isSelected ? UIColor.white : UIColor(hexString: "9f9fa3")
        
        criticalToolsButton.backgroundColor = criticalToolsButton.isSelected ? UIColor(hexString: "ed1b2e") : UIColor.clear
        criticalToolsButton.tintColor = criticalToolsButton.isSelected ? UIColor.white : UIColor(hexString: "9f9fa3")
        
        if criticalToolsButton.isSelected {
            toolkitTableViewController?.showCriticalToolsOnly()
        } else {
            toolkitTableViewController?.redraw()
        }
    }
}
