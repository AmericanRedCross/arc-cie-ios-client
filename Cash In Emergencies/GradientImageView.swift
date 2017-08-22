//
//  GradientImageView.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 22/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import CoreGraphics

@IBDesignable
class GradientImageView: UIImageView {

    @IBInspectable var rightToLeftGradient: Bool = false
    
    @IBInspectable var leftColor: UIColor = .clear
    
    @IBInspectable var rightColor: UIColor = .clear
    
    @IBInspectable var topToBottomGradient: Bool = false
    
    @IBInspectable var topColor: UIColor = .clear
    
    @IBInspectable var bottomColor: UIColor = .clear
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.sublayers = nil
        
        if rightToLeftGradient {
            let rightToLeftLayer = CAGradientLayer()
            rightToLeftLayer.colors = [leftColor.cgColor, rightColor.cgColor]
            rightToLeftLayer.locations = [0, 1]
            rightToLeftLayer.startPoint = CGPoint(x: 0, y: 0.5)
            rightToLeftLayer.endPoint = CGPoint(x: 1, y: 0.5)
            
            layer.insertSublayer(rightToLeftLayer, above: layer)
            rightToLeftLayer.frame = frame
        }
        
        if topToBottomGradient {
            
            let topToBottomLayer = CAGradientLayer()
            topToBottomLayer.colors = [topColor.cgColor, bottomColor.cgColor]
            topToBottomLayer.locations = [0, 1]
            topToBottomLayer.startPoint = CGPoint(x: 0.5, y: 0)
            topToBottomLayer.endPoint = CGPoint(x: 0.5, y: 1)
            
            layer.insertSublayer(topToBottomLayer, above: layer)
            topToBottomLayer.frame = frame
        }
    }
}
