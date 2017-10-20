//
//  MarkdownViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 28/09/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import MarkdownView
import ThunderBasics

class MarkdownViewController: UIViewController {
    
    var downView: MarkdownView?
    
    /// Button to dismiss the markdown view
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton?.title = NSLocalizedString("MARKDOWN_DONE", value: "Done", comment: "Button in the navigation bar that dismisses the view")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MDCHUDActivityView.start(in: self.view, text: "Loading document")
    }
    
    func loadMarkdown(string: String) {
        
        downView = MarkdownView()
        
//        downView = try? DownView(frame: view.frame, markdownString: string)

        if let _downView = downView {
            view.addSubview(_downView)
            downView?.frame = view.frame
            downView?.alpha = 0
        }
        
        downView?.load(markdown: string)
        
        downView?.onRendered = { [weak self] (height: CGFloat) in
            
            guard let welf = self else { return }
            
            UIView.animate(withDuration: 0.4, animations: {
                welf.downView?.alpha = 1
            })
            
            DispatchQueue.main.async {
                 MDCHUDActivityView.finish(in: welf.view)
            }
        }
        
        // called when user touch link
        downView?.onTouchLink = { [weak self] request in
            guard let url = request.url else { return false }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        }
       
//        try? downView?.update(markdownString: string)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        downView?.frame = view.frame
    }
}
