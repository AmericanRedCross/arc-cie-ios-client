//
//  WorkflowViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 22/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import ARCDM
import ThunderTable

protocol ModuleConformable {
    func module() -> Module?
}

class ModuleView: ModuleConformable, Row {
    
    var internalModule: Module?
    
    func module() -> Module? {
        return internalModule
    }
    
    //INIT
    init(with module: Module) {
        internalModule = module
    }
    
    //ROW
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
            
            if let _module = internalModule {
                _cell.moduleTitleLabel.text = _module.moduleTitle
                _cell.moduleBackgroundImageView.image = UIImage(named: "module-backdrop-\(_module.order)")
                
                if let _hierarchy = _module.metadata?["hierarchy"] as? String {
                    _cell.moduleIdentifierLabel.text = _hierarchy
                }
            }
        }
    }
}

class Step: ModuleConformable, Row {
    
    var internalModule: Module?
    
    func module() -> Module? {
        return internalModule
    }
    
    //INIT
    init(with module: Module) {
        internalModule = module
    }
    
    //ROW
    
    var cellClass: AnyClass? {
        return ModuleStepTableViewCell.self
    }
    
    var accessoryType: UITableViewCellAccessoryType? {
        get {
            return UITableViewCellAccessoryType.none
        }
        set {}
    }
}

class SubStep: ModuleConformable, Row {
    
    var internalModule: Module?
    
    func module() -> Module? {
        return internalModule
    }
    
    //INIT
    init(with module: Module) {
        internalModule = module
    }
    
    var cellClass: AnyClass? {
        return ModuleSubStepTableViewCell.self
    }
    
    var accessoryType: UITableViewCellAccessoryType? {
        get {
            return UITableViewCellAccessoryType.none
        }
        set {}
    }
}

class Tool: ModuleConformable, Row {
    
    func module() -> Module? {
        return nil
    }
}

class WorkflowViewController: UIViewController {
    
    @IBOutlet weak var toolkitButton: UIButton!
    @IBOutlet weak var criticalToolsButton: UIButton!
    
    /// Any identifiers in this list are modules that should be expanded. The children of these modules will be included in `displayableModuleObjects`
    var expandedModuleIndexes = [Int]()
//    var expandedSubmoduleIndexes = 
    
    /// A dictionary where the key is the module identifier of every module (recursively) through the structure.json and it's value being an integer of what depth level it is app. Zero based.
    var moduleDepthMap = [Int: Int]()
    
    func mapTree(for modules: [Module], level: Int) {
        
        for module in modules {
            
            if let _moduleID = module.identifier {
                moduleDepthMap[_moduleID] = level
            }
            
            if let _submodules = module.directories {
                mapTree(for: _submodules, level: level + 1)
            }
        }
    }
    
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
                //TODO: Check for expanding
                if let _moduleChildren = _module.directories {
                    
                    for moduleStep in _moduleChildren {
                        
                        let moduleStepView = Step(with: moduleStep)
                        rows.append(moduleStepView)
                        
                        //Check if the step has substeps and add them
                        //TODO: Check for expanding
                        
                        if let _moduleStepChildren = moduleStep.directories {
                            
                            for moduleSubStep in _moduleStepChildren {
                                
                                let moduleSubStepView = SubStep(with: moduleSubStep)
                                rows.append(moduleSubStepView)
                            }
                        }
                    }
                }
                
                let moduleSection = TableSection(rows: rows, header: nil, footer: nil, selectionHandler: nil)
                displayableSections.append(moduleSection)
                
            }
        
        //Update stuff
        moduleDepthMap.removeAll()
        mapTree(for: modules, level: 0)
        
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
    
    var toolkitTableViewController: ToolkitTableViewController? {
        return childViewControllers.first as? ToolkitTableViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        toolkitTableViewController?.tableView.contentOffset = CGPoint(x: 0, y: 44)
        
        toolkitButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        toolkitButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        
        criticalToolsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        criticalToolsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }

        if let _displayableObjects = displayableModuleObjects {
            toolkitTableViewController?.data = _displayableObjects
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
