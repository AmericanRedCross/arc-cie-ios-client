//
//  ProgressManager.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 02/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation

/// Keeps track of the users progress through tools and module steps
class ProgressManager {
    
    /// Private identifier to consistently access checked modules
    private let checkedModulesIdentifier = "CIECheckedModules"
    
    /// Toggles the "checked" state for a module identifier and saves the state of all checked modules to user defaults
    ///
    /// - Parameter moduleIdentifier: The identifier of the module to toggle on/off
    func toggle(moduleIdentifier: Int) {
        
        guard var _checkedModulesArray = UserDefaults.standard.array(forKey: checkedModulesIdentifier) as? [Int] else {
            UserDefaults.standard.set([moduleIdentifier], forKey: checkedModulesIdentifier)
            return
        }
        
        if let moduleIndex = _checkedModulesArray.index(of: moduleIdentifier) {
            _checkedModulesArray.remove(at: moduleIndex)
        } else {
            _checkedModulesArray.append(moduleIdentifier)
        }
        
        UserDefaults.standard.set(_checkedModulesArray, forKey: checkedModulesIdentifier)
    }
    
    /// Determines the current state of a checkable view.
    ///
    /// - Parameter moduleIdentifier: The identifier of the module to check for entries against
    /// - Returns: `true` if the view should be checked
    func checkState(for moduleIdentifier: Int) -> Bool {
        
        guard let _checkedModulesArray = UserDefaults.standard.array(forKey: checkedModulesIdentifier) as? [Int] else {
            return false
        }
        
        if _checkedModulesArray.index(of: moduleIdentifier) != nil {
            return true
        }
        
        return false
    }
}
