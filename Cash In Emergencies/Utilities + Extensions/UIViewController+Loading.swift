//
//  UIViewController+Loading.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 24/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func toggleUserInteraction(on: Bool) {
        self.view.isUserInteractionEnabled = on
        self.parent?.view.isUserInteractionEnabled = on
        self.navigationController?.view.isUserInteractionEnabled = on
        self.tabBarController?.view.isUserInteractionEnabled = on
    }
}
