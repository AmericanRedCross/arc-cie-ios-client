//
//  FileExporter.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 23/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import DMSSDK
import ThunderBasics


class FileExporter {
    
    
    class func exportFile(_ file: URL, in viewController: UIViewController, updateHandler: ((CGFloat) -> Void)?,  completionHandler: ((Bool) -> Void)?) {
        
            //Load it up if we already have it
            if let localFile = ContentManager().localFileURL(for: file) {
                
                let documentController = UIDocumentInteractionController(url: localFile)
                
                OperationQueue.main.addOperation({
                    
                    documentController.presentOptionsMenu(from: viewController.view.frame, in: viewController.view, animated: true)
                })
                
                completionHandler?(true)
                return
            }
        
        // We don't have the file downloaded so lets start downloading it
        
            // Show a loading indicator
            DispatchQueue.main.async {
                viewController.view.isUserInteractionEnabled = false
                viewController.parent?.view.isUserInteractionEnabled = false
                viewController.navigationController?.view.isUserInteractionEnabled = false
                viewController.tabBarController?.view.isUserInteractionEnabled = false
                MDCHUDActivityView.start(in: viewController.view.window, text: NSLocalizedString("WORKFLOW_TOOL_INDICATOR_DOWNLOADING", value: "Downloading", comment: "Displayed below a loading indicator while a document is downloading"))
            }
            
            //Download it instead
            ContentManager().downloadDocumentFile(from: file, progress: { (progress, bytesDownloaded, totalBytes) in
                
                updateHandler?(progress)
            }, completion: { (result) in
                
                // Finish loading indicator
                DispatchQueue.main.async {
                    viewController.view.isUserInteractionEnabled = true
                    viewController.parent?.view.isUserInteractionEnabled = true
                    viewController.navigationController?.view.isUserInteractionEnabled = true
                    viewController.tabBarController?.view.isUserInteractionEnabled = true
                    MDCHUDActivityView.finish(in: viewController.view.window)
                }
                
                switch result {
                case .success(let downloadedFileURL):
                    
                    let documentcontroller = UIDocumentInteractionController(url: downloadedFileURL)
                    
                    OperationQueue.main.addOperation({

                        documentcontroller.presentOptionsMenu(from: viewController.view.frame, in: viewController.view, animated: true)
                        completionHandler?(true)
                        return
                    })
                    
                    return
                    
                case .failure(let error):
                    completionHandler?(false)
                    return
                }
            })
        }
}
