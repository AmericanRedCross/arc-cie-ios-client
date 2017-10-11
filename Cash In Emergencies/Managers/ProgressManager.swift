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
    
    /// Private identifier to consistently access module notes
    private let moduleNotesIdentifier = "CIEModuleNotes"
    
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
        
        let notificationName = NSNotification.Name("ModulePropertyChanged")
        NotificationCenter.default.post(name: notificationName, object: self, userInfo: [
            "moduleIdentifier": moduleIdentifier
            ])
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
    
    //MARK: - Notes
    
    /// Saves a note against a module to be viewed later. Overrites existing entries
    ///
    /// - Parameters:
    ///   - note: The note contents to save
    ///   - moduleIdentifier: The identifier of the module to save the note against
    func save(note: String, for moduleIdentifier: Int) {
        
        var noteDictionary: [String: Any]?
        if let storedDictionary = UserDefaults.standard.value(forKey: moduleNotesIdentifier) as? [String: Any] {
            noteDictionary = storedDictionary
        } else {
            noteDictionary = [String: Any]()
        }
        
        if var noteDictionary = noteDictionary {
            noteDictionary[String(moduleIdentifier)] = note
            UserDefaults.standard.set(noteDictionary, forKey: moduleNotesIdentifier)
        }
    }
    
    /// Retrieves the note (if any) that is saved against this module
    ///
    /// - Parameter moduleIdentifier: The identifier of the module you wish to look up notes for
    /// - Returns: A `String` of a note if any has been saved
    func note(for moduleIdentifier: Int) -> String? {
        
        guard let noteDictionary = UserDefaults.standard.value(forKey: moduleNotesIdentifier) as? [String: Any] else {
            return nil
        }
        
        return noteDictionary[String(moduleIdentifier)] as? String
    }
    
    /// Removes a note for a module
    ///
    /// - Parameter moduleIdentifier: The identifier of the module to remove the note (if any) for. If the module identifier provided does not have a note saved then nothing will happen.
    func removeNote(for moduleIdentifier: Int) {
        guard var noteDictionary = UserDefaults.standard.value(forKey: moduleNotesIdentifier) as? [String: Any] else {
            return
        }
        
        noteDictionary[String(moduleIdentifier)] = nil
        
        UserDefaults.standard.set(noteDictionary, forKey: moduleNotesIdentifier)
    }
}
