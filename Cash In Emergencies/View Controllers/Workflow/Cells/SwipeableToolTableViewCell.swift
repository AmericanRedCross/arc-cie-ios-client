//
//  SwipeableToolTableViewCell.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 19/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol ToolTableCellShared {
    
    var toolImageView: UIImageView! { get set }
    var toolTitleLabel: UILabel! { get set }
    var toolDescriptionLabel: UILabel! { get set }
    var toolCriticalToolButton: UIButton! { get set }
    var toolCheckableButton: UIButton! { get set }
    var criticalToolStackView: UIStackView! { get set }
    var userMarkedCriticalButton: UIButton! { get set }
    var noteAddedButton: UIButton! { get set }
    var exportedButton: UIButton! { get set }
    
    
}

class SwipeableToolTableViewCell: SwipeTableViewCell, ToolTableCellShared {

    @IBOutlet weak var toolImageView: UIImageView!
    @IBOutlet weak var toolTitleLabel: UILabel!
    @IBOutlet weak var toolDescriptionLabel: UILabel!
    @IBOutlet weak var toolCriticalToolButton: UIButton!
    @IBOutlet weak var toolCheckableButton: UIButton!
    @IBOutlet weak var criticalToolStackView: UIStackView!
    @IBOutlet weak var userMarkedCriticalButton: UIButton!
    @IBOutlet weak var noteAddedButton: UIButton!
    @IBOutlet weak var exportedButton: UIButton!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Hide description label if theres no content so the other label is centered
        toolDescriptionLabel.isHidden = (toolDescriptionLabel.text == nil)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        toolCriticalToolButton.isHidden = true
        criticalToolStackView.isHidden = true
        userMarkedCriticalButton.isHidden = true
        noteAddedButton.isHidden = true
        exportedButton.isHidden = true
    }
}
