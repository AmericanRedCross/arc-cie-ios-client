//
//  ModuleColourUtility.swift
//  Cash In Emergencies
//
//  Created by Joel Trew on 12/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation
import ThunderBasics
import ARCDM

class ModuleColourUtility {
    
    private static var fallBackColour = UIColor(hexString: "ed1b2e")!
    
    class func colour(for module: Module) -> UIColor {
        
        guard let hierarchy = module.metadata?["hierarchy"] as? String else {

            return fallBackColour
        }
        return ModuleColourUtility.colour(for: hierarchy)
    }
    
    class func colour(for moduleHierarchy: String) -> UIColor {
        switch moduleHierarchy {
            
        case "1": return UIColor(hexString: "9D9FA2")
        case "2": return UIColor(hexString: "F47D78")
        case "3": return UIColor(hexString: "C5E1B1")
        case "4": return UIColor(hexString: "9BD7D7")
        case "5": return UIColor(hexString: "0079A7")
            
        default:
            return fallBackColour
        }
    }
}
