//
//  ModuleProgressView.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 10/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import ThunderBasics


// Displays the progress of a module as a coloured bar, set the progress property to change the
@IBDesignable
class ModuleProgressView : UIView {
    
    // A layer to display the progress
    var progressBar: CALayer = CALayer()
    
    // Progress value from 0.0 to 100.0, used to calculate the width of the progress bar
    var progress: Double = 0.0 {
        didSet {
            DispatchQueue.main.async {
                self.layoutSubviews()
                self.progressBar.removeAllAnimations()
                
            }
        }
    }
    
    // The main colour of the progress bar
    var barColour: UIColor = UIColor.clear {
        didSet {
            progressBar.backgroundColor = barColour.cgColor
            layoutSubviews()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        barColour = tintColor
        progressBar.anchorPoint = CGPoint(x: 0, y: 0)
        layer.insertSublayer(progressBar, at: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        barColour = tintColor
        progressBar.anchorPoint = CGPoint(x: 0, y: 0)
        layer.insertSublayer(progressBar, at: 0)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressBar.backgroundColor = barColour.cgColor
        let progressWidth: CGFloat = ((bounds.width / 100) * min(CGFloat(progress), 100))
        
        let direction = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute)
        if direction == .rightToLeft {
            progressBar.frame = CGRect(x: frame.size.width - progressWidth, y: bounds.origin.y, width: progressWidth, height: bounds.height)
            
            if #available(iOS 11.0, *), progress != 100 {
                progressBar.cornerRadius = 4
                progressBar.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            }
        } else {
            progressBar.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: progressWidth, height: bounds.height)
            if #available(iOS 11.0, *), progress != 100 {
                progressBar.cornerRadius = 4
                progressBar.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            }
        }
    }
    
    
    func setProgress(newProgress: Double, animation: Bool) {
        
        let oldProgressWidth: CGFloat = ((bounds.width / 100) * min(CGFloat(progress), 100))
        let progressWidth: CGFloat = ((bounds.width / 100) * min(CGFloat(newProgress), 100))
        
        let direction = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute)
        
        var oldBounds = CGRect(x: progressBar.bounds.origin.x, y: progressBar.frame.origin.y, width: CGFloat(oldProgressWidth), height: frame.height)
        var newBounds = CGRect(x: progressBar.frame.origin.x, y: progressBar.frame.origin.y, width: CGFloat(progressWidth), height: frame.height)
        
        
        if direction == .rightToLeft {
            oldBounds = CGRect(x: frame.size.width - oldProgressWidth, y: progressBar.frame.origin.y, width: CGFloat(oldProgressWidth), height: frame.height)
            newBounds = CGRect(x: frame.size.width - progressWidth, y: progressBar.frame.origin.y, width: CGFloat(progressWidth), height: frame.height)
        }
        
        
        if direction == .leftToRight {
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.progress = newProgress
            })
            
            let boundsAnimation = CABasicAnimation(keyPath: "bounds")
            boundsAnimation.fillMode = kCAFillModeForwards
            boundsAnimation.fromValue = NSValue(cgRect: oldBounds)
            boundsAnimation.toValue = NSValue(cgRect: newBounds)
            boundsAnimation.duration = 0.2
            boundsAnimation.isRemovedOnCompletion = false
            boundsAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            
            progressBar.add(boundsAnimation, forKey: "addProgress")
            CATransaction.commit()
        } else {
            self.progress = newProgress
        }
    }
}
