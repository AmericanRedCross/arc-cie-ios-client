//
//  ToolkitTableViewController+SwipeableCells.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 13/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation
import UIKit
import DMSSDK
import QuickLook
import ThunderBasics

@available(iOS 11.0, *)
extension ToolkitTableViewController {
    
    
    func addExportOptionIfAvailible(with directory: Directory, at indexPath: IndexPath) -> UIContextualAction? {
        //Export
        let exportFile = directory.attachments?.first?.url.flatMap({ (url) -> URL? in
            return ContentManager().localFileURL(for: url)
        })
        
        let exportTitle = exportFile == nil ? NSLocalizedString("WORKFLOW_TOOL_BUTTON_DOWNLOAD", value: "DOWNLOAD", comment: "Button that downloads a tool") : NSLocalizedString("WORKFLOW_TOOL_BUTTON_OPEN", value: "OPEN", comment: "Button that opens a tool that was already downloaded")
        let exportOption = UIContextualAction(style: .normal, title: exportTitle) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: @escaping (Bool) -> Void) in
            
            if let _url = directory.attachments?.first?.url {
                
                //Load it up if we already have it
                if let _localFile = exportFile {
                    
                    let quickLookView = QLPreviewController()
                    self.displayableURL = _localFile
                    quickLookView.dataSource = self
                    quickLookView.currentPreviewItemIndex = 0
                    
                    OperationQueue.main.addOperation({
                        self.present(quickLookView, animated: true, completion: nil)
                    })
                    
                    completionHandler(true)
                    return
                }
                
                // Show a loading indicator
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = false
                    self.parent?.view.isUserInteractionEnabled = false
                    self.navigationController?.view.isUserInteractionEnabled = false
                    self.tabBarController?.view.isUserInteractionEnabled = false
                    MDCHUDActivityView.start(in: self.view.window, text: NSLocalizedString("WORKFLOW_TOOL_INDICATOR_DOWNLOADING", value: "Downloading", comment: "Displayed below a loading indicator while a document is downloading"))
                }
                
                //Download it instead
                ContentManager().downloadDocumentFile(from: _url, progress: { (progress, bytesDownloaded, totalBytes) in
                    
                }, completion: { (result) in
                    
                    // Finish loading indicator
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        self.parent?.view.isUserInteractionEnabled = true
                        self.navigationController?.view.isUserInteractionEnabled = true
                        self.tabBarController?.view.isUserInteractionEnabled = true
                        MDCHUDActivityView.finish(in: self.view.window)
                    }
                    
                    switch result {
                    case .success(let downloadedFileURL):
                        
                        let quickLookView = QLPreviewController()
                        self.displayableURL = downloadedFileURL
                        quickLookView.dataSource = self
                        quickLookView.currentPreviewItemIndex = 0
                        
                        
                        OperationQueue.main.addOperation({
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                            self.present(quickLookView, animated: true, completion: nil)
                        })
                        
                        completionHandler(true)
                        return
                        
                    case .failure(let error):
                        print(error)
                        completionHandler(false)
                        return
                    }
                })
            }
        }
        exportOption.image = #imageLiteral(resourceName: "swipe_action_export")
        exportOption.backgroundColor = UIColor(red: 237.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        return exportOption
    }
    
    func addNoteOption(for directory: Directory, at indexPath: IndexPath) -> UIContextualAction {
        //Note
        let noteOptionTitle = (ProgressManager().note(for: directory.identifier) == nil) ? NSLocalizedString("WORKFLOW_TOOL_BUTTON_ADDNOTE", value: "ADD NOTE", comment: "Button that shows a view to add a note") : NSLocalizedString("WORKFLOW_TOOL_BUTTON_EDITNOTE", value: "EDIT NOTE", comment: "Button that shows a view to edit an existing note")
        
        let noteOption = UIContextualAction(style: .normal, title: noteOptionTitle) {  [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: @escaping (Bool) -> Void) in

            DispatchQueue.main.async {
                self?.addNote(for: directory, completion: {
                    DispatchQueue.main.async {
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                })
                completionHandler(true)
                return
            }
        }
        noteOption.image = #imageLiteral(resourceName: "swipe_action_note_add")
        noteOption.backgroundColor = UIColor(red: 237.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        return noteOption
    }
    
    
    func addCriticalToolOption(for directory: Directory, at indexPath: IndexPath) -> UIContextualAction? {
        //If it's marked as critical by DMS don't let them change it
        let _criticalTool = directory.metadata?["critical_path"] as? Bool ?? false
        
        // Only run if block criticalTool is nil or false
        if !_criticalTool  {
            
            //If its not marked as critical by user, give option
            //TODO: User critical handling
            
            let progressManager = ProgressManager()
            
            let toolOptionTitle = progressManager.userCriticalTool(for: directory.identifier) ? NSLocalizedString("WORKFLOW_TOOL_BUTTON_UNMARK", value: "UNMARK", comment: "Button that removes the critical tool mark from a tool") : NSLocalizedString("WORKFLOW_TOOL_BUTTON_MARK", value: "MARK", comment: "Button that adds the critical tool mark to a tool")
            let toolOption = UIContextualAction(style: .normal, title: toolOptionTitle) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                
                progressManager.toggleMarkToolAsUserCritical(for: directory.identifier)
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                
                DispatchQueue.global().async {
                    ToolIndexManager.shared.indexTool(directory, completionHandler: { error in
                        self.reload(with: nil)
                    })
                }
                
                completionHandler(true)
            }
            
            toolOption.image = #imageLiteral(resourceName: "swipe_action_critical_path_enable")
            toolOption.backgroundColor = UIColor(red: 237.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
            return toolOption
        }
        
        return nil
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if let _toolDisplayed = data[indexPath.section].rows[indexPath.row] as? Tool, let directory = _toolDisplayed.module() {
            
            var actions = [UIContextualAction]()
            
            // Export
            if let exportOption = self.addExportOptionIfAvailible(with: directory, at: indexPath) {
                actions.append(exportOption)
            }
            
            // Note
            actions.append(addNoteOption(for: directory, at: indexPath))
        
            //Critical too
            if let criticalToolOption = addCriticalToolOption(for: directory, at: indexPath) {
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
