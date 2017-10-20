//
//  ExportTableViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 13/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import ThunderBasics
import DMSSDK

class ExportTableViewController: UITableViewController {

    var documentcontroller: UIDocumentInteractionController?
    
    @IBOutlet weak var criticalPathLabel: UILabel!
    @IBOutlet weak var entireProgressLabel: UILabel!
    @IBOutlet weak var criticalPathExportButton: UIButton!
    @IBOutlet weak var entireProgressExportButton: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBAction func handleExportCriticalPath(_ sender: UIButton) {
        
        MDCHUDActivityView.start(in: view.window, text: "Exporting")
        
        defer {
            MDCHUDActivityView.finish(in: view.window)
        }
        
        if let criticalPathFile = CSVManager.exportModules(criticalOnly: true) {
         
            documentcontroller = UIDocumentInteractionController(url: criticalPathFile)
            documentcontroller?.presentOptionsMenu(from: sender.frame, in: view, animated: true)
        } else {
            presentError(ExportError.genericError)
        }
    }
    
    @IBAction func handleExportEntireProgress(_ sender: UIButton) {
        
        MDCHUDActivityView.start(in: view.window, text: "Exporting")
        
        defer {
            MDCHUDActivityView.finish(in: view.window)
        }

        if let criticalPathFile = CSVManager.exportModules(criticalOnly: false) {
            
            documentcontroller = UIDocumentInteractionController(url: criticalPathFile)
            documentcontroller?.presentOptionsMenu(from: sender.frame, in: view, animated: true)

        } else {
            presentError(ExportError.genericError)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        
        self.title = NSLocalizedString("EXPORT_NAVIGATION_TITLE", value: "Export Content", comment: "The title in the navigation bar at the top of view to export files")
        criticalPathLabel?.text = NSLocalizedString("EXPORT_CRITICALPATH_TEXT", value: "Critical Path Progress", comment: "Text for the row that allows exporting the critical path progress")
        entireProgressLabel?.text = NSLocalizedString("EXPORT_ENTIREPATH_TEXT", value: "Entire Progress", comment: "Text for the row that allows exporting the entire progress of the user")
        criticalPathExportButton?.setTitle(NSLocalizedString("EXPORT_BUTTON_EXPORT", value: "Export", comment: "Button that exports user content"), for: .normal)
        entireProgressExportButton?.setTitle(NSLocalizedString("EXPORT_BUTTON_EXPORT", value: "Export", comment: "Button that exports user content"), for: .normal)
        doneButton?.title = NSLocalizedString("EXPORT_BUTTON_DONE", value: "Done", comment: "Button to dismiss the export view")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // Provides localised errors for when exporting fails
    enum ExportError: LocalizedError {
        
        // General non specific error
        case genericError
        
        var errorDescription: String? {
                return "There was a problem exporting the file you requested."
        }
    }
}

//extension ExportTableViewController: UIDocumentInteractionControllerDelegate {
//
//    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
//
//    }
//
//    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
//
//    }
//}

