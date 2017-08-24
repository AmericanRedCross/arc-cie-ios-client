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
    
    var expandedModuleIndexes = [Int]()
//    var expandedSubmoduleIndexes = 
    
    /// A compiled array of sections to display. This computed variable works out which sections are collapsed or expanded and arranges the views appropriately
    var displayableModuleObjects: [TableSection]? {
        
        var displayableRows = [Row]()
    
        let moduleManager = ModuleManager()
        
        if let _modules = moduleManager.modules {
            let section = TableSection(rows: _modules)
            
            return [section]
        }
        return nil
        
    }
    
    //    override var childViewControllerForStatusBarStyle: UIViewController? {
//        return toolkitTableViewController
//    }
    
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

        if let _displayableObjects = displayableModuleObjects {
            toolkitTableViewController?.data = _displayableObjects
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
