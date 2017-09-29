//
//  MarkdownViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 28/09/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import Down
import MarkdownView

class MarkdownViewController: UIViewController {
    
    var downView: MarkdownView?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadMarkdown(string: String) {
        
        downView = MarkdownView()
        
//        downView = try? DownView(frame: view.frame, markdownString: string)

        if let _downView = downView {
            view.addSubview(_downView)
            downView?.frame = view.frame
        }
        
        downView?.load(markdown: string)
//        try? downView?.update(markdownString: string)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        downView?.frame = view.frame
    }
}
