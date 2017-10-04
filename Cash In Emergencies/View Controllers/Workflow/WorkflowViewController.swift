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
    
}
