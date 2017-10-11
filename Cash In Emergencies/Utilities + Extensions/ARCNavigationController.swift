//
//  ARCTabBarViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 22/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit

class ARCNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
}
