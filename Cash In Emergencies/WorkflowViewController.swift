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
import Down

protocol ModuleConformable {
    func module() -> Module?
}

class ModuleView: ModuleConformable, Row {
    
    var internalModule: Module?
    
    private var toolkitTableViewController: ToolkitTableViewController?
    
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
    
    @objc func handleToggle(of button: UIButton) {
        
        if let _tableView = toolkitTableViewController, let _module = internalModule {
            
            _tableView.handleToggle(of: _module)
        }
        
    }
    
    public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        toolkitTableViewController = tableViewController as? ToolkitTableViewController
        
        if let _cell = cell as? ModuleTableViewCell {
            
            if let _module = internalModule {
                _cell.moduleTitleLabel.text = _module.moduleTitle
                _cell.moduleBackgroundImageView.image = UIImage(named: "module-backdrop-\(_module.order)")
                _cell.moduleChevronButton.addTarget(self, action: #selector(handleToggle(of:)), for: .primaryActionTriggered)
                
                if let _hierarchy = _module.metadata?["hierarchy"] as? String {
                    _cell.moduleIdentifierLabel.text = _hierarchy
                }
            }
        }
    }
}

class Step: ModuleConformable, Row {
    
    var internalModule: Module?
    
    private var toolkitTableViewController: ToolkitTableViewController?
    
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
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        toolkitTableViewController = tableViewController as? ToolkitTableViewController

        if let _cell = cell as? ModuleStepTableViewCell {
            
            _cell.stepHierarchyLabel.text = internalModule?.metadata?["hierarchy"] as? String
            _cell.stepTitleLabel.text = internalModule?.moduleTitle
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

class SubStep: ModuleConformable, Row {
    
    private var toolkitTableViewController: ToolkitTableViewController?

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
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        toolkitTableViewController = tableViewController as? ToolkitTableViewController

        if let _cell = cell as? ModuleSubStepTableViewCell {
            
            _cell.substepHierarchyLabel.text = internalModule?.metadata?["hierarchy"] as? String
            _cell.substepTitleLabel.text = internalModule?.moduleTitle
            _cell.moduleSubstepChevronButton.addTarget(self, action: #selector(handleToggle(of:)), for: .primaryActionTriggered)
            _cell.substepRoadmapButton.isHidden = internalModule?.content == nil
            _cell.substepRoadmapButton.removeTarget(nil, action: nil, for: .allEvents)
            _cell.substepCheckableButton.removeTarget(nil, action: nil, for: .allEvents)
            _cell.substepRoadmapButton.addTarget(self, action: #selector(handleRoadmap(button:)), for: .primaryActionTriggered)
            _cell.substepCheckableButton.addTarget(self, action: #selector(handleChecking(of:)), for: .primaryActionTriggered)
            
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
}

class Tool: ModuleConformable, Row {
    
    var internalModule: Module?
    
    func module() -> Module? {
        return internalModule
    }
    
    //INIT
    init(with module: Module) {
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
            
            _cell.toolTitleLabel.text = internalModule?.moduleTitle
            
            if let _firstAttachment = internalModule?.attachments?.first {
                _cell.toolDescriptionLabel.text = _firstAttachment.description
                _cell.toolImageView.image = _firstAttachment.mimeImage()
            }
            
            _cell.toolCriticalToolButton.isHidden = true
            
            if let _criticalTool = internalModule?.metadata?["critical_path"] as? Bool {
                if _criticalTool {
                    _cell.toolCriticalToolButton.isHidden = false
                }
            }
            
            _cell.toolCheckableButton.removeTarget(nil, action: nil, for: .allEvents)
            _cell.toolCheckableButton.addTarget(self, action: #selector(handleChecking(of:)), for: .primaryActionTriggered)
            
            if let _moduleIdentifier = internalModule?.identifier {
                _cell.toolCheckableButton.isSelected = ProgressManager().checkState(for: _moduleIdentifier)
            }
        }
    }
    
    @objc func handleChecking(of checkView: UIButton) {
        
        if let _moduleIdentifier = internalModule?.identifier {
            ProgressManager().toggle(moduleIdentifier: _moduleIdentifier)
            
            checkView.isSelected = !checkView.isSelected
        }
    }
}

extension FileDescriptor {
    
    func mimeImage() -> UIImage? {
        
        guard let mimeType = mime else {
            return #imageLiteral(resourceName: "mime_misc")
        }
        
        switch mimeType {
        case "text/plain", "text/richtext", "application/vnd.oasis.opendocument.text", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
            return #imageLiteral(resourceName: "mime_doc")
        case "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet":
            return #imageLiteral(resourceName: "mime_xls")
        case "application/vnd.ms-powerpoint", "application/vnd.openxmlformats-officedocument.presentationml.presentation", "application/vnd.oasis.opendocument.presentation":
            return #imageLiteral(resourceName: "mime_ppt")
        case "application/pdf":
            return #imageLiteral(resourceName: "mime_pdf")
        case "application/zip":
            return #imageLiteral(resourceName: "mime_zip")
        default:
            return #imageLiteral(resourceName: "mime_misc")
        }
    }
}

class WorkflowViewController: UIViewController {
    
    @IBOutlet weak var toolkitButton: UIButton!
    @IBOutlet weak var criticalToolsButton: UIButton!
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
