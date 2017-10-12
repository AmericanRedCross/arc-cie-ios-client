//
//  ModuleTableViewCell.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 22/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit

class ModuleTableViewCell: UITableViewCell {

    @IBOutlet weak var moduleTitleLabel: UILabel!
    @IBOutlet weak var moduleIdentifierLabel: UILabel!
    @IBOutlet weak var moduleBackgroundImageView: GradientImageView!
    @IBOutlet weak var moduleChevronButton: UIButton!
    
    @IBOutlet weak var moduleRoadmapButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
