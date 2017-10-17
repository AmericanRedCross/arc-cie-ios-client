//
//  ProgressViewModel.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 10/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation
import ThunderTable

// View Model containing all the data needed to display progress information in the ProgressTableViewController
struct ProgressViewModel {
    
    // A number representing the hierarchy of a module
    var moduleHierarchy: String
    
    // A short title of a module
    var moduleTitle: String?
    
    // The total number of substeps for a given module
    var numberOfSubSteps: Int
    
    // The number of substeps the user has checked as completed
    var numberOfCompletedSubSteps: Int
    
    // The total number of critical tools for a given module
    var numberOfCriticalTools: Int
    
    // The total number of critical tools the user has checked as completed
    var numberOfCompletedCriticalTools: Int
    
    // The overall compeltion of a module, the value is between 0 and 100
    // At the moment only critical tools count towards the overall total
    var percentageComplete: Int {
        return Int((Float(numberOfCompletedCriticalTools) / Float(numberOfCriticalTools)) * 100.0)
    }
}


// MARK: - ThunderTable Conformance
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
        progressCell.hierarchyView.backgroundColor = ModuleColourUtility.colour(for: moduleHierarchy)
        
        let hierarchyColor = ModuleColourUtility.colour(for: moduleHierarchy)
        progressCell.moduleProgressView.barColour = hierarchyColor
        progressCell.moduleProgressView.backgroundColor = hierarchyColor.withAlphaComponent(0.2)
    }
}
