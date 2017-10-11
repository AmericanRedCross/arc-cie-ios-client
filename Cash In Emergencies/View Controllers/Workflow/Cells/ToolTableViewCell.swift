//
//  ToolTableViewCell.swift
//  ARCDM
//
//  Created by Matthew Cheetham on 22/09/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit

class ToolTableViewCell: UITableViewCell {

    @IBOutlet weak var toolImageView: UIImageView!
    @IBOutlet weak var toolTitleLabel: UILabel!
    @IBOutlet weak var toolDescriptionLabel: UILabel!
    @IBOutlet weak var toolCriticalToolButton: UIButton!
    @IBOutlet weak var toolCheckableButton: UIButton!
    
    @IBOutlet weak var criticalToolStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Hide description label if theres no content so the other label is centered
        toolDescriptionLabel.isHidden = (toolDescriptionLabel.text == nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
