//
//  ModuleConformable+Views.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 04/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import DMSSDK
import ThunderTable

protocol ModuleConformable {
    func module() -> Directory?
}

// Wrapping Module class, provides ThunderTable Conformance
class ModuleView: ModuleConformable, Row {
    
    // The module data the wrapper is representing
    var internalModule: Directory?
    
    // Tableviewcontroller the module is being represented in
    private var toolkitTableViewController: ToolkitTableViewController?
    
    // If the cell should show the module roadmap button
    var shouldShowModuleRoadmap: Bool = false
    
    func module() -> Directory? {
        return internalModule
    }
    
    //INIT
    init(with module: Directory) {
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
    
    @objc func handleToggle(of button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let _module = internalModule {
            
            _tableView.handleToggle(of: _module)
        }
    }
    
    @objc func handleRoadmap(button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let _moduleContent = internalModule?.content {
            
            _tableView.handleLoadMarkdown(for: _moduleContent)
        }
    }
    
    public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        toolkitTableViewController = tableViewController as? ToolkitTableViewController
        
        if let _cell = cell as? ModuleTableViewCell {
            
            if let _module = internalModule {
                _cell.moduleTitleLabel.text = _module.directoryTitle
                _cell.moduleBackgroundImageView.image = UIImage(named: "module-backdrop-\(_module.order)")
                _cell.moduleChevronButton.removeTarget(nil, action: nil, for: .allEvents)
                _cell.moduleChevronButton.addTarget(self, action: #selector(handleToggle(of:)), for: .primaryActionTriggered)
                
                _cell.moduleIdentifierLabel.backgroundColor = ModuleColourUtility.colour(for: _module)
                
                _cell.moduleRoadmapButton.isHidden = !shouldShowModuleRoadmap
                _cell.moduleRoadmapButton.removeTarget(nil, action: nil, for: .allEvents)
                _cell.moduleRoadmapButton.addTarget(self, action: #selector(handleRoadmap(button:)), for: .primaryActionTriggered)
                
                if let _hierarchy = _module.metadata?["hierarchy"] as? String {
                    _cell.moduleIdentifierLabel.text = _hierarchy
                }
            }
        }
    }
}

// Wrapper module respresenting a Step which is a child of the Module class, conforms to ThunderTable
class Step: ModuleConformable, Row {
    
    // The module data the wrapper is representing
    var internalModule: Directory?
    
    // Tableviewcontroller the module is being represented in
    private var toolkitTableViewController: ToolkitTableViewController?
    
    func module() -> Directory? {
        return internalModule
    }
    
    //INIT
    init(with module: Directory) {
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
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        toolkitTableViewController = tableViewController as? ToolkitTableViewController
        
        if let _cell = cell as? ModuleStepTableViewCell {
            
            _cell.stepHierarchyLabel.text = internalModule?.metadata?["hierarchy"] as? String
            _cell.stepTitleLabel.text = internalModule?.directoryTitle
            _cell.stepRoadmapButton.isHidden = internalModule?.content == nil
            
            _cell.stepRoadmapButton.removeTarget(nil, action: nil, for: .allEvents)
            _cell.stepRoadmapButton.addTarget(self, action: #selector(handleRoadmap(button:)), for: .primaryActionTriggered)
        }
    }
    
    //Actions
    @objc func handleRoadmap(button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let _moduleContent = internalModule?.content {
            
            _tableView.handleLoadMarkdown(for: _moduleContent)
        }
    }
}

// Wrapper module respresenting a SubStep which is a child of the Module class, conforms to ThunderTable
class SubStep: ModuleConformable, Row {
    
    private var toolkitTableViewController: ToolkitTableViewController?
    
    private var cellIndexPath: IndexPath?
    
    var internalModule: Directory?
    
    func module() -> Directory? {
        return internalModule
    }
    
    var shouldShowAddNoteButton: Bool = false
    
    //INIT
    init(with module: Directory) {
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
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        toolkitTableViewController = tableViewController as? ToolkitTableViewController
        cellIndexPath = indexPath
        
        if let _cell = cell as? ModuleSubStepTableViewCell {
            
            _cell.substepHierarchyLabel.text = internalModule?.metadata?["hierarchy"] as? String
            _cell.substepTitleLabel.text = internalModule?.directoryTitle
            _cell.moduleSubstepChevronButton.addTarget(self, action: #selector(handleToggle(of:)), for: .primaryActionTriggered)
 
            _cell.substepAddNoteButton.removeTarget(nil, action: nil, for: .allEvents)
            _cell.substepCheckableButton.removeTarget(nil, action: nil, for: .allEvents)
            _cell.substepAddNoteButton.addTarget(self, action: #selector(handleAddNote(button:)), for: .primaryActionTriggered)
            _cell.substepCheckableButton.addTarget(self, action: #selector(handleChecking(of:)), for: .primaryActionTriggered)
            
            
            _cell.substepAddNoteButton.setTitle("Add Note", for: .normal)
            
            if let moduleIdentifier = internalModule?.identifier {
                if ProgressManager().note(for: moduleIdentifier) != nil {
                     _cell.substepAddNoteButton.setTitle("Edit Note", for: .normal)
                }
            }
            
            _cell.substepAddNoteButton.isHidden = !shouldShowAddNoteButton
            _cell.substepButtonContainerStackView.isHidden = !shouldShowAddNoteButton
            
            if let _moduleIdentifier = internalModule?.identifier {
                _cell.substepCheckableButton.isSelected = ProgressManager().checkState(for: _moduleIdentifier)
            }
        }
    }
    
    @objc func handleToggle(of button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let _module = internalModule {
            
            _tableView.handleToggle(of: _module)
        }
    }
    
    @objc func handleChecking(of checkView: UIButton) {
        
        if let _moduleIdentifier = internalModule?.identifier {
            ProgressManager().toggle(moduleIdentifier: _moduleIdentifier)
            
            checkView.isSelected = !checkView.isSelected
        }
    }
    
    //Actions
    @objc func handleRoadmap(button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let _moduleContent = internalModule?.content {
            
            _tableView.handleLoadMarkdown(for: _moduleContent)
        }
    }
    
    @objc func handleAddNote(button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let internalModule = internalModule {
            
            _tableView.addNote(for: internalModule, completion: { [weak self] in
                guard let indexPath = self?.cellIndexPath else { return }
                DispatchQueue.main.async {
                    _tableView.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            })
        }
    }
}

class Tool: ModuleConformable, Row {
    
    var internalModule: Directory?
    
    lazy var progressManager = ProgressManager()
    
    var isCriticalTool: Bool {
        return internalModule?.metadata?["critical_path"] as? Bool ?? false
    }
    
    var isUserMarkedCriticalTool: Bool {
        guard let moduleIdentifier = internalModule?.identifier else {
            return false
        }
        return progressManager.userCriticalTool(for: moduleIdentifier)
    }
    
    var hasNoteAdded: Bool {
        guard let moduleIdentifier = internalModule?.identifier else {
            return false
        }
        return progressManager.note(for: moduleIdentifier) != nil
    }
    
    var hasBeenExported: Bool {
        let exportFile = internalModule?.attachments?.first?.url.flatMap({ (url) -> URL? in
            return ContentManager().localFileURL(for: url)
        })
        
        return exportFile != nil
    }
    
    func module() -> Directory? {
        return internalModule
    }
    
    //INIT
    init(with module: Directory) {
        internalModule = module
    }
    
    var cellClass: AnyClass? {
        return ToolTableViewCell.self
    }
    
    var accessoryType: UITableViewCellAccessoryType? {
        get {
            return UITableViewCellAccessoryType.none
        }
        set {}
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        if let _cell = cell as? ToolTableViewCell {
            
            _cell.toolTitleLabel.text = internalModule?.directoryTitle
            
            if let _firstAttachment = internalModule?.attachments?.first {
                _cell.toolDescriptionLabel.text = _firstAttachment.description
                _cell.toolImageView.image = _firstAttachment.mimeImage()
            }
            
            _cell.toolImageView.tintColor = UIColor(hexString: "ED1B2D")
            
            _cell.criticalToolStackView.isHidden = true
            _cell.toolCriticalToolButton.isHidden = true
            _cell.userMarkedCriticalButton.isHidden = true
            _cell.criticalToolStackView.isHidden = true
            _cell.noteAddedButton.isHidden = true
            _cell.exportedButton.isHidden = true
            
            if isCriticalTool {
                _cell.criticalToolStackView.isHidden = false
                _cell.toolCriticalToolButton.isHidden = false
            }
            
            if isUserMarkedCriticalTool {
                _cell.criticalToolStackView.isHidden = false
                _cell.userMarkedCriticalButton.isHidden = false
            }
            
            if hasNoteAdded {
                _cell.criticalToolStackView.isHidden = false
                _cell.noteAddedButton.isHidden = false
            }
            
            if hasBeenExported {
                _cell.criticalToolStackView.isHidden = false
                _cell.exportedButton.isHidden = false
            }
            
            _cell.toolCheckableButton.removeTarget(nil, action: nil, for: .allEvents)
            _cell.toolCheckableButton.addTarget(self, action: #selector(handleChecking(of:)), for: .primaryActionTriggered)
            
            if let _moduleIdentifier = internalModule?.identifier {
                _cell.toolCheckableButton.isSelected = progressManager.checkState(for: _moduleIdentifier)
            }
            
            // Hack, however if we don't call this the cells appear at the wrong height and we get graphical layout bugs :(
            // TODO: Find fix for this
            _cell.layoutSubviews()
        }
    }
    
    @objc func handleChecking(of checkView: UIButton) {
        
        if let _moduleIdentifier = internalModule?.identifier {
            progressManager.toggle(moduleIdentifier: _moduleIdentifier)
            
            checkView.isSelected = !checkView.isSelected
        }
    }
}
