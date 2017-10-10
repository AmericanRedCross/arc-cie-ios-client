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

struct ProgressViewModel {
    
    var moduleHierarchy: String
    var moduleTitle: String?
    
    var percentageComplete: Int {
        return Int((Float(numberOfCompletedCriticalTools) / Float(numberOfCriticalTools)) * 100.0)
    }
    
    var numberOfSubSteps: Int
    var numberOfCompletedSubSteps: Int
    
    var numberOfCriticalTools: Int
    var numberOfCompletedCriticalTools: Int
}


extension ProgressViewModel: Row {
    
    var cellClass: AnyClass? {
        return ProgressTableViewCell.self
    }
    
    var accessoryType: UITableViewCellAccessoryType? {
        get {
            return UITableViewCellAccessoryType.none
        }
        set {}
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        guard let progressCell = cell as? ProgressTableViewCell else { return }
        progressCell.criticalToolsValueLabel.text = "\(self.numberOfCompletedCriticalTools)/\(self.numberOfCriticalTools)"
        progressCell.subStepsValueLabel.text = "\(numberOfCompletedSubSteps)/\(self.numberOfSubSteps)"
        progressCell.hierarchyLabel.text = self.moduleHierarchy
        progressCell.overallPercentageCompleteLabel.text = "\(self.percentageComplete)% COMPLETED"
        progressCell.moduleLabel.text = self.moduleTitle
        progressCell.moduleProgressView.progress = Double(self.percentageComplete)
        progressCell.moduleProgressView.barColour = UIColor(hexString: "ed1b2e")
    
    }
}

class ProgressTableViewController: TableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        
        redraw()
    }
    
    func redraw() {
        
        guard let modules = ModuleManager().modules else {
            return
        }
        
        var viewModels: [ProgressViewModel] = []
        
        for module in modules {
            
            let moduleTitle = module.moduleTitle
            guard let hierarchy = module.metadata?["hierarchy"] as? String else { continue }
            
            let subSteps = module.directories?.flatMap({ (step) -> [Module] in
                guard let stepDirectories = step.directories else { return [] }
                return stepDirectories
            }) ?? []
            
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
            
            
            let counterClosure: ((Int, Module) -> Int) = { (completedCount, module) -> Int in
                // Ensure we have an identifier to check the state of our step
                guard let identifier = module.identifier else { return completedCount }
                
                // Check if the state is complete, otherwise return our current count
                guard ProgressManager().checkState(for: identifier) else {
                    return completedCount
                }
                
                // If the state was true lets add on to our count and continue
                return completedCount + 1
                
            }
            
            let completedSubSteps = subSteps.reduce(0, counterClosure)
            let completedCriticalTools = criticalTools.reduce(0, counterClosure)
            
            

           let viewModel = ProgressViewModel(moduleHierarchy: hierarchy, moduleTitle: moduleTitle, numberOfSubSteps: numberOfSubSteps, numberOfCompletedSubSteps: completedSubSteps, numberOfCriticalTools: numberOfCriticalTools, numberOfCompletedCriticalTools: completedCriticalTools)
            
            viewModels.append(viewModel)
        }
        
        
        self.data = [TableSection(rows: viewModels)]
    }
        
        // MARK: - Table view data sourc
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 110
            
        }
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
}
