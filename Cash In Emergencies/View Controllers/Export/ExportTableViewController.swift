//
//  ExportTableViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 13/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit

class ExportTableViewController: UITableViewController {

    var documentcontroller: UIDocumentInteractionController?
    
    @IBAction func handleExportCriticalPath(_ sender: UIButton) {
        
        if let criticalPathFile = CSVManager.exportModules(criticalOnly: true) {
         
            documentcontroller = UIDocumentInteractionController(url: criticalPathFile)
            documentcontroller?.presentOptionsMenu(from: sender.frame, in: view, animated: true)
            
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

