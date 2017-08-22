//
//  ModuleDisplayable.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 22/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import ARCDM
import ThunderTable

extension Module: Row {

    public var cellClass: AnyClass? {
        return ModuleTableViewCell.self
    }
    
    public var accessoryType: UITableViewCellAccessoryType? {
        get {
            return UITableViewCellAccessoryType.none
        }
        set {}
    }
    
    public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        if let _cell = cell as? ModuleTableViewCell {
           
            _cell.moduleBackgroundImageView.image = UIImage(named: "module-backdrop-\(hierarchy)")
            _cell.moduleIdentifierLabel.text = String(describing: hierarchy)
        }
    }
}
