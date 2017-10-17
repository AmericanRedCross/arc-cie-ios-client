//
//  DMSSDKExtensions.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 04/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import DMSSDK

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
