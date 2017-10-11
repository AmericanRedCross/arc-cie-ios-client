//
//  ModuleSubStepTableViewCell.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 21/09/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit

class ModuleSubStepTableViewCell: UITableViewCell {
    
    @IBOutlet weak var substepHierarchyLabel: UILabel!
    @IBOutlet weak var substepTitleLabel: UILabel!
    @IBOutlet weak var moduleSubstepChevronButton: UIButton!
    @IBOutlet weak var substepAddNoteButton: UIButton!
    @IBOutlet weak var substepCheckableButton: UIButton!
    
    
    @IBOutlet weak var substepButtonContainerStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
