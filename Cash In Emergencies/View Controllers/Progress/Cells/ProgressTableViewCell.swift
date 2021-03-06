//
//  ProgressTableViewCell.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 10/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import ThunderBasics

// Cell for displaying module progress
class ProgressTableViewCell: UITableViewCell {
    
    // Containing view which allows for padding and cornerRadius
    @IBOutlet weak var containerView: UIView!
    
    // Circleview containing the hierarchyLabel
    @IBOutlet weak var hierarchyView: TSCView!
    
    // Label displaying the numerical hierarchy of the module
    @IBOutlet weak var hierarchyLabel: UILabel!
    
    // The title label of module
    @IBOutlet weak var moduleLabel: UILabel!
    
    // A label displaying the percentage of the completion of the module, currently this is just the percentge of compleetd critical tools
    @IBOutlet weak var overallPercentageCompleteLabel: UILabel!
    
    // A progress bar at the bottom of the view
    @IBOutlet weak var moduleProgressView: ModuleProgressView!
    
    /// Label displaying the word for "Sub-steps"
    @IBOutlet weak var subStepsTitleLabel: UILabel!
    
    // Label displaying the score of completed substeps
    @IBOutlet weak var subStepsValueLabel: UILabel!
    
    /// Label displaying the word for "Critical tools"
    @IBOutlet weak var criticalToolsTitleLabel: UILabel!
    
    // Label displaying the score of critical tools
    @IBOutlet weak var criticalToolsValueLabel: UILabel!
}
