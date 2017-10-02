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
import QuickLook

class ToolkitTableViewController: TableViewController {

    /// Any identifiers in this list are modules that should be expanded. The children of these modules will be included in `displayableModuleObjects`
    var expandedModuleIdentifiers = [Int]()
    
    /// A dictionary where the key is the module identifier of every module (recursively) through the structure.json and it's value being an integer of what depth level it is app. Zero based.
    var moduleDepthMap = [Int: Int]()
    
    private var disaplayableURL: URL?

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
            if let _moduleChildren = _module.directories, let moduleIdentifier = _module.identifier, expandedModuleIdentifiers.contains(moduleIdentifier) {
                
                for moduleStep in _moduleChildren {
                    
                    let moduleStepView = Step(with: moduleStep)
                    rows.append(moduleStepView)
                    
                    //Check if the step has substeps and add them
                    
                    if let _moduleStepChildren = moduleStep.directories {
                        
                        for moduleSubStep in _moduleStepChildren {
                            
                            let moduleSubStepView = SubStep(with: moduleSubStep)
                            rows.append(moduleSubStepView)
                            
                            //Check for tools
                            if let _tools = moduleSubStep.directories, let moduleIdentifier = moduleSubStep.identifier, expandedModuleIdentifiers.contains(moduleIdentifier) {
                                
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
    
    func handleLoadMarkdown(for contentPath: String) {
        
        let contentURL = ContentController().fileUrl(from: contentPath)
        
        guard let presentingView = self.parent else {
            return
        }
        
        if let _contentURL = contentURL, let jsonFileData = try? Data(contentsOf: _contentURL) {
            
            let markdown = String(data: jsonFileData, encoding: .utf8)
            
            if let _markdownNavView = UIStoryboard(name: "Document_Viewing", bundle: Bundle.main).instantiateViewController(withIdentifier: "markdownNavigationControllerIdentifier") as? UINavigationController, let markdownView = _markdownNavView.viewControllers.first as? MarkdownViewController {
                
                if let _markdown = markdown {
                    markdownView.loadMarkdown(string: _markdown)
                }
                presentingView.showDetailViewController(_markdownNavView, sender: self)
            }
        }
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if let _displayableModuleObjects = displayableModuleObjects, let _toolDisplayed = _displayableModuleObjects[indexPath.section].rows[indexPath.row] as? Tool, let module = _toolDisplayed.module() {
            
            var actions = [UIContextualAction]()
            
            //Export
            let exportOption = UIContextualAction(style: .normal, title: "EXPORT OR SHARE") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                print("hi")
                print(module)
                
                if let _url = module.attachments?.first?.url {
                    
                    //Load it up if we already have it
                    if let _localFile = ContentController().localFileURL(for: _url) {
                        
                        let quickLookView = QLPreviewController()
                        self.disaplayableURL = _localFile
                        quickLookView.dataSource = self
                        quickLookView.currentPreviewItemIndex = 0
                        
                        OperationQueue.main.addOperation({
                            self.present(quickLookView, animated: true, completion: nil)
                        })
                        
                        return
                    }
                
                    //Download it instead
                    ContentController().downloadDocumentFile(from: _url, progress: { (progress, bytesDownloaded, totalBytes) in
                        
                    }, completion: { (result) in
                        
                        switch result {
                        case .success(let downloadedFileURL):
                            
                            let quickLookView = QLPreviewController()
                            self.disaplayableURL = downloadedFileURL
                                quickLookView.dataSource = self
                            quickLookView.currentPreviewItemIndex = 0
                            
                            OperationQueue.main.addOperation({
                                self.present(quickLookView, animated: true, completion: nil)
                            })
                            
                        case .failure(let error):
                            print(error)
                        }
                    })
                }
            }
            exportOption.image = #imageLiteral(resourceName: "swipe_action_export")
            exportOption.backgroundColor = UIColor(red: 237.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
            actions.append(exportOption)
            
            //Note
            let noteOption = UIContextualAction(style: .normal, title: "ADD NOTE") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                print("hi")
            }
            noteOption.image = #imageLiteral(resourceName: "swipe_action_note_add")
            noteOption.backgroundColor = UIColor(red: 237.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
            actions.append(noteOption)

            //Critical tool
            
            //If it's marked as critical by DMS don't let them change it
            if let _criticalTool = module.metadata?["critical_path"] as? Bool {
                if !_criticalTool {
                    
                    //If its not marked as critical by user, give option
                    //TODO: User critical handling
                    let toolOption = UIContextualAction(style: .normal, title: "MARK AS CRITICAL TOOL") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                        print("hi")
                    }
                    toolOption.image = #imageLiteral(resourceName: "swipe_action_critical_path_enable")
                    toolOption.backgroundColor = UIColor(red: 237.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
                    actions.append(toolOption)
                }
            }

            //Actions
            let swipeActions = UISwipeActionsConfiguration(actions: actions)
            swipeActions.performsFirstActionWithFullSwipe = false
            
            return swipeActions
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [])
        return swipeActions
    }
}

extension ToolkitTableViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        if let _URL = disaplayableURL {
            return _URL as NSURL
        }
        return NSURL(fileURLWithPath: "lol")
    }
}
