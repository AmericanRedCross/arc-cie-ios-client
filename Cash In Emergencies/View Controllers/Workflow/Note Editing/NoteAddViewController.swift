//
//  NoteAddViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 03/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import ARCDM

class NoteAddViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var module: Module?
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if let textView = textView {
            textView.becomeFirstResponder()
        }
        
        //Set up view
        
        if let module = module {
            
            //Set appropriate title
            if let moduleHierarchy = module.metadata?["hierarchy"] as? String, let moduleTitle = module.moduleTitle {
                title = "\(moduleHierarchy) \(moduleTitle)"
            }
            
            //Restore text
            if let _moduleIdentifier = module.identifier, let text = ProgressManager().note(for: _moduleIdentifier) {
                textView?.text = text
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Notifications
    
    @objc func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    @objc func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification: notification)
    }
    
    // MARK: - Private
    
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions.init(rawValue: UInt(rawAnimationCurve))
        
        bottomLayoutConstraint.constant = -(view.bounds.maxY - convertedKeyboardEndFrame.minY)
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    // MARK: - Dismissing + saving
    
    @IBAction func handleCancelButton(_ sender: UIButton) {
        
        let dismissWarning = UIAlertController(title: "Discard Note", message: "This will discard any changes that have been made to this note", preferredStyle: .alert)
        dismissWarning.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: { [weak self] (action) in
            self?.dismiss(animated: true, completion: nil)
        }))
        dismissWarning.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(dismissWarning, animated: true, completion: nil)
    }
    
    @IBAction func handleSaveButton(_ sender: UIButton) {
        
        if let _inputText = textView.text, let moduleIdentifier = module?.identifier {
            
            ProgressManager().save(note: _inputText, for: moduleIdentifier)
            dismiss(animated: true, completion: nil)
        }
    }
}

