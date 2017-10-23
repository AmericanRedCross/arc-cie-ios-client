//
//  Tracker.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 23/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation

/**
 Provides Google Analytics tracking functionality to the app. All tracking should be done via this file
 */
class Tracker {
    
    /**
     Logs a page view with GA
     - param named: The page name to track
     */
    class func trackPage(_ named: String) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        guard let _tracker = tracker else {
            return
        }
        
        _tracker.set(kGAIScreenName, value: named)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        _tracker.send(builder?.build() as! [AnyHashable: Any])
    }
    
    /**
     Logs an event into Google Analytics
     - param category: The GA Category to file under
     - param action: A description of the action taken by the user
     - param label: Additional description of the event action if applicable
     - param value: A numerical value to add to the event if applicable
     */
    class func trackEventWith(_ category: String, action: String, label: String?, value: NSNumber?) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        guard let _tracker = tracker else {
            return
        }
        
        let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value)
        _tracker.send(builder?.build() as! [AnyHashable: Any])
    }
}
