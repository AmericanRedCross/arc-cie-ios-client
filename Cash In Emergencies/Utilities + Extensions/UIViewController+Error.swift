//
//  UIViewController+Error.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 16/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func presentError(_ error: Error) {
     
        let errorTitle: String
        
        if let localisedError = error as? LocalizedError {
            errorTitle = localisedError.errorDescription ?? error.localizedDescription
        } else {
            errorTitle = error.localizedDescription
        }
        
        let alertController = UIAlertController(title: errorTitle, message: nil, preferredStyle: .alert)
        
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
