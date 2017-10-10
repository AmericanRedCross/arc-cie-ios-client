//
//  ProgressTableViewController.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 10/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import ThunderTable
import ARCDM

class ProgressTableViewController: TableViewController {
    
    var needsReload: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        
        redraw()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needsReload {
            redraw()
        }
    }
    
    // Creates a view model and sets it to the view controllers data source. The method loops through the modules and pulls out all of the required data that needs to be shown into one struct
    func redraw() {
        
        // Get our top level modules
        guard let modules = ModuleManager().modules else {
            return
        }
        
        // Setup empty view model array
        var viewModels: [ProgressViewModel] = []
        
        // Loop through the top level modules
        for module in modules {
            
            // Module title i.e Preparedness
            let moduleTitle = module.moduleTitle
            // Get the hierarchy, i.e 1
            guard let hierarchy = module.metadata?["hierarchy"] as? String else { continue }
            
            // Flatmap all of the module's steps subSteps into one array
            let subSteps = module.directories?.flatMap({ (step) -> [Module] in
                guard let stepDirectories = step.directories else { return [] }
                return stepDirectories
            }) ?? []
            
            // Collect all of the critical tools from our substeps
            let criticalTools = subSteps.flatMap({ (subStep) -> [Module] in
                guard let subStepDirectories = subStep.directories else { return [] }
                return subStepDirectories.flatMap({ (tool) -> Module? in
                    
                    if let isCritical = tool.metadata?["critical_path"] as? Bool,
                        isCritical {
                        return tool
                    }
                    
                    return nil
                })
            })
            
            let numberOfSubSteps = subSteps.count
            let numberOfCriticalTools = criticalTools.count
            
            // Closure which counts the number of completed modules by checking their state, this closure is passed to and ran by a reduce method on the Sub Steps and Critical tools
            let counter: ((Int, Module) -> Int) = { (completedCount, module) -> Int in
                // Ensure we have an identifier to check the state of our step
                guard let identifier = module.identifier else { return completedCount }
                
                // Check if the state is complete, otherwise return our current count
                guard ProgressManager().checkState(for: identifier) else {
                    return completedCount
                }
                
                // If the state was true lets add on to our count and continue
                return completedCount + 1
            }
            
            // Run the counter on each array to get our completed amounts
            let completedSubSteps = subSteps.reduce(0, counter)
            let completedCriticalTools = criticalTools.reduce(0, counter)
            
            // Create the view model using all variables we gathered above
           let viewModel = ProgressViewModel(moduleHierarchy: hierarchy, moduleTitle: moduleTitle, numberOfSubSteps: numberOfSubSteps, numberOfCompletedSubSteps: completedSubSteps, numberOfCriticalTools: numberOfCriticalTools, numberOfCompletedCriticalTools: completedCriticalTools)
            
            viewModels.append(viewModel)
        }
        
        
        self.data = [TableSection(rows: viewModels)]
    }
        
        // MARK: - Table view data source
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 110
            
        }
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
}
