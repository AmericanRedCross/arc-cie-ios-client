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

// Utility class for downloading and getting files from disk
class FileExporter {
    
    /// Gets a file from a provided url either by searching for it locally on disk and returning the local file address, or if not available locally, downloads over the network, saving it to disk and returning its new local file url
    ///
    /// - Parameters:
    ///   - file: the file url of the remote resource where the file is located.
    ///   - updateHandler: A closure which reports the progress of the download if the file needs to be downloaded
    ///   - completionHandler: A closure which returns the local file url of the requested file, or nil if it can't be exported
    class func exportFile(_ file: URL, updateHandler: ((CGFloat) -> Void)?,  completionHandler: ((URL?) -> Void)?) {
        
        //Load it up if we already have it
        if let localFile = ContentManager().localFileURL(for: file) {
            
            updateHandler?(1.0)
            completionHandler?(localFile)
            return
        }
        
        // We don't have the file downloaded so lets start downloading it
        //Download it instead
        ContentManager().downloadDocumentFile(from: file, progress: { (progress, bytesDownloaded, totalBytes) in
            
            updateHandler?(progress)
        }, completion: { (result) in
            
            switch result {
            case .success(let downloadedFileURL):
                
                completionHandler?(downloadedFileURL)
                return
                
            case .failure(_):
                completionHandler?(nil)
                return
            }
        })
    }
}
