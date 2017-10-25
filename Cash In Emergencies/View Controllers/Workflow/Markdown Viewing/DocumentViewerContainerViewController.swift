//
//  DocumentViewerContainerViewController.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 23/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import ThunderBasics
import DMSSDK

class DocumentViewerContainerViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var toolFileTypeImageView: UIImageView!
    
    @IBOutlet weak var toolNameLabel: UILabel!
    
    @IBOutlet weak var exportButton: UIButton!
    
    @IBOutlet weak var toolSizeLabel: UILabel!
    
    @IBOutlet weak var downloadProgressView: ModuleProgressView!
    
    @IBOutlet weak var attachedFileView: UIView!
    
    var toolColour: UIColor = UIColor(hexString: "ed1b2e")
    
    var attachedFile: FileDescriptor?
    
    @IBOutlet weak var attachedFileViewHeightConstraint: NSLayoutConstraint!
    
    var documentController: UIDocumentInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadProgressView.barColour = UIColor(hexString: "ed1b2e")

        doneButton?.title = NSLocalizedString("MARKDOWN_DONE", value: "Done", comment: "Button in the navigation bar that dismisses the view")
        
        toolFileTypeImageView.tintColor = toolColour
        
        if let attachedFile = attachedFile {
            
            if let url = attachedFile.url {
                if ContentManager().localFileURL(for: url) != nil {
                    downloadProgressView.progress = 100.0
                }
            }
            
            toolFileTypeImageView.image = attachedFile.mimeImage()
            
            toolNameLabel.text = attachedFile.title
            
            if let fileSize = attachedFile.size {
                
                let countBytesFormatter = ByteCountFormatter()
                countBytesFormatter.allowedUnits = [.useKB, .useMB, .useGB]
                countBytesFormatter.countStyle = .file
                let fileSizeText = countBytesFormatter.string(fromByteCount: Int64(fileSize))
                
                toolSizeLabel.text = fileSizeText
                
            } else {
                toolSizeLabel.isHidden = true
            }
            
        } else {
           
            attachedFileViewHeightConstraint.isActive = false
            attachedFileView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let window = self.parent?.view.window {
            MDCHUDActivityView.start(in: window, text: "Loading document")
        }
    }
    
    @IBAction func pressedExport(_ sender: Any) {
        if let url = attachedFile?.url {
            
            if let window = self.parent?.view.window {
                MDCHUDActivityView.start(in: window, text: "Exporting document")
            }
            
            self.toggleUserInteraction(on: false)
            FileExporter.exportFile(url, updateHandler: { (progress) in
                    DispatchQueue.main.async {
                        self.downloadProgressView.progress = Double(progress * 100)
                    }
                }, completionHandler: { (localFileUrl) in
                    if let window = self.parent?.view.window {
                        MDCHUDActivityView.finish(in: window)
                    }
                    self.toggleUserInteraction(on: true)
                    if let localFileUrl = localFileUrl {
                        self.documentController = UIDocumentInteractionController(url: localFileUrl)
                        self.documentController?.delegate = self
                        self.documentController?.presentOptionsMenu(from: self.view.frame, in: self.view, animated: true)
                    }
                })
        }
    }
}


extension DocumentViewerContainerViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
    

