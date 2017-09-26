//
//  ToolkitTable.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 22/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import ThunderTable
import ARCDM

class ToolkitTableViewController: TableViewController {

    /// Any identifiers in this list are modules that should be expanded. The children of these modules will be included in `displayableModuleObjects`
    var expandedModuleIdentifiers = [Int]()
    //    var expandedSubmoduleIndexes =
    
    /// A dictionary where the key is the module identifier of every module (recursively) through the structure.json and it's value being an integer of what depth level it is app. Zero based.
//    var moduleDepthMap = [Int: Int]()
//
//    func mapTree(for modules: [Module], level: Int) {
//
//        for module in modules {
//
//            if let _moduleID = module.identifier {
//                moduleDepthMap[_moduleID] = level
//            }
//
//            if let _submodules = module.directories {
//                mapTree(for: _submodules, level: level + 1)
//            }
//        }
//    }
    
    /// A compiled array of sections to display. This computed variable works out which sections are collapsed or expanded and arranges the views appropriately
    var displayableModuleObjects: [TableSection]? {
        
        var displayableSections = [TableSection]()
        
        guard let modules = ModuleManager().modules else {
            return displayableSections
        }
        
        for _module in modules {
            
            var rows = [Row]()
            
            //Add top level row
            let moduleView = ModuleView(with: _module)
            rows.append(moduleView)
            
            //Add sub rows if expanded
            if let _moduleChildren = _module.directories, let moduleIdentifier = _module.identifier, expandedModuleIdentifiers.contains(moduleIdentifier) {
                
                for moduleStep in _moduleChildren {
                    
                    let moduleStepView = Step(with: moduleStep)
                    rows.append(moduleStepView)
                    
                    //Check if the step has substeps and add them
                    //TODO: Check for expanding
                    
                    if let _moduleStepChildren = moduleStep.directories {
                        
                        for moduleSubStep in _moduleStepChildren {
                            
                            let moduleSubStepView = SubStep(with: moduleSubStep)
                            rows.append(moduleSubStepView)
                            
                            //Check for tools
                            //TODO: Check for expanding
                            if let _tools = moduleSubStep.directories {
                                
                                for tool in _tools {
                                    let toolView = Tool(with: tool)
                                    rows.append(toolView)
                                }
                            }
                        }
                    }
                }
            }
            
            let moduleSection = TableSection(rows: rows, header: nil, footer: nil, selectionHandler: nil)
            displayableSections.append(moduleSection)
            
        }
        
        return displayableSections
        
        //        let moduleManager = ModuleManager()
        //
        //        if let _modules = moduleManager.modules {
        //            let section = TableSection(rows: _modules)
        //
        //            return [section]
        //        }
        //        return nil
        
    }
    
    //    override var childViewControllerForStatusBarStyle: UIViewController? {
    //        return toolkitTableViewController
    //    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redraw()
    }
    
    func redraw() {
        
        if let _displayableObjects = displayableModuleObjects {
            data = _displayableObjects
        }
    }
    
    func handleToggle(of module: Module) {
        
        guard let moduleID = module.identifier else {
            return
        }
        
        if expandedModuleIdentifiers.contains(moduleID) {
            if let removalIndex = expandedModuleIdentifiers.index(of: moduleID) {
                expandedModuleIdentifiers.remove(at: removalIndex)
            }
        } else {
            expandedModuleIdentifiers.append(moduleID)
        }
        
        redraw()
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Export
        let exportOption = UIContextualAction(style: .normal, title: "EXPORT OR SHARE") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            print("hi")
        }
        exportOption.image = #imageLiteral(resourceName: "workflow-cell-accessory")
        exportOption.backgroundColor = UIColor(red: 237.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        
        //Note
        let noteOption = UIContextualAction(style: .normal, title: "ADD NOTE") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            print("hi")
        }
        noteOption.image = #imageLiteral(resourceName: "workflow-cell-accessory")
        noteOption.backgroundColor = UIColor(red: 237.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        
        //Critical tool
        let toolOption = UIContextualAction(style: .normal, title: "MARK AS CRITICAL TOOL") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            print("hi")
        }
        toolOption.image = #imageLiteral(resourceName: "workflow-cell-accessory")
        toolOption.backgroundColor = UIColor(red: 237.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        
        //Actions
        let swipeActions = UISwipeActionsConfiguration(actions: [exportOption, noteOption, toolOption])
        swipeActions.performsFirstActionWithFullSwipe = false
        
        return swipeActions
    }
}
