//
//  ToolkitTableViewController+SwipeableCells.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 13/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation
import UIKit
import ARCDM
import QuickLook

@available(iOS 11.0, *)
extension ToolkitTableViewController {
    
    
    func addExportOptionIfAvailible(with module: Module) -> UIContextualAction? {
        //Export
        let exportFile = module.attachments?.first?.url.flatMap({ (url) -> URL? in
            return ContentController().localFileURL(for: url)
        })
        
        let exportTitle = exportFile == nil ? "DOWNLOAD" : "EXPORT"
        let exportOption = UIContextualAction(style: .normal, title: exportTitle) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            if let _url = module.attachments?.first?.url {
                
                //Load it up if we already have it
                if let _localFile = exportFile {
                    
                    let quickLookView = QLPreviewController()
                    self.displayableURL = _localFile
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
                        self.displayableURL = downloadedFileURL
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
        return exportOption
    }
    
    func addNoteOption(for module: Module) -> UIContextualAction {
        //Note
        let noteOptionTitle = (ProgressManager().note(for: module.identifier) != nil) ? "ADD NOTE" : "EDIT NOTE"
        
        let noteOption = UIContextualAction(style: .normal, title: noteOptionTitle) {  [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            self?.addNote(for: module)
        }
        noteOption.image = #imageLiteral(resourceName: "swipe_action_note_add")
        noteOption.backgroundColor = UIColor(red: 237.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        return noteOption
    }
    
    
    func addCriticalToolOption(for module: Module) -> UIContextualAction? {
        //If it's marked as critical by DMS don't let them change it
        let _criticalTool = module.metadata?["critical_path"] as? Bool ?? false
        
        // Only run if block criticalTool is nil or false
        if !_criticalTool  {
            
            //If its not marked as critical by user, give option
            //TODO: User critical handling
            
            let progressManager = ProgressManager()
            
            let toolOptionTitle = progressManager.userCriticalTool(for: module.identifier) ? "UNMARK" : "MARK"
            let toolOption = UIContextualAction(style: .normal, title: toolOptionTitle) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                
                progressManager.toggleMarkToolAsUserCritical(for: module.identifier)
            }
            
            toolOption.image = #imageLiteral(resourceName: "swipe_action_critical_path_enable")
            toolOption.backgroundColor = UIColor(red: 237.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
            return toolOption
        }
        
        return nil
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if let _toolDisplayed = data[indexPath.section].rows[indexPath.row] as? Tool, let module = _toolDisplayed.module() {
            
            var actions = [UIContextualAction]()
            
            // Export
            if let exportOption = self.addExportOptionIfAvailible(with: module) {
                actions.append(exportOption)
            }
            
            // Note
            actions.append(addNoteOption(for: module))
        
            //Critical too
            if let criticalToolOption = addCriticalToolOption(for: module) {
                actions.append(criticalToolOption)
            }

            //Actions
            let swipeActions = UISwipeActionsConfiguration(actions: actions)
            swipeActions.performsFirstActionWithFullSwipe = false
            
            return swipeActions
        }
        
        // Return empty array configuration as retuning nil provides default delete option
        return UISwipeActionsConfiguration(actions: [])
    }
}
