//
//  CSVManager.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 12/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation
import ARCDM

/// Deals with exporting a CSV of the tools and user critical data
class CSVManager {
    
    private var csvHeadings = ["Step","Done","No.","Sub-Step Action & Guidance","Sub-Step Notes","Critical Tool","Critical Notes"]
    
    func exportModules(criticalOnly: Bool = false) -> Data? {
        
        let progressManager = ProgressManager()
        let newLine = "\n"
        
        guard let modules = ModuleManager().modules else {
            return nil
        }
        
        var csvString = ""
        
        for module in modules {
            
            if let moduleTitle = module.moduleTitle {
                csvString = csvString+moduleTitle+" ,,,,,,"+newLine+csvHeadings.joined(separator: ",")+newLine
            }
            
            if let steps = module.directories {
                
                for step in steps {
                    
                    if let substeps = step.directories {
                        
                        for substep in substeps {
                            
                            if let tools = substep.directories {
                                
                                for tool in tools {
                                    
                                    //Step
                                    if let _stepName = step.moduleTitle {
                                        csvString = csvString+_stepName.csvSafeString()+","
                                    } else {
                                        csvString = csvString+","
                                    }
                                    
                                    //Done
                                    if let identifier = tool.identifier, progressManager.checkState(for: identifier) {
                                        csvString = csvString+"yes"+","
                                    } else {
                                        csvString = csvString+"no"+","
                                    }
                                    
                                    //No.
                                    if let hierarchy = substep.metadata?["hierarchy"] as? String {
                                        csvString = csvString+hierarchy+","
                                    }
                                    
                                    //Sub-Step Action & Guidance
                                    if let substepName = substep.moduleTitle {
                                        csvString = csvString+substepName.csvSafeString()+","
                                    } else {
                                        csvString = csvString+","
                                    }
                                    
                                    //Sub-Step Notes
                                    if let substepIdentifier = substep.identifier, let substepNote = progressManager.note(for: substepIdentifier) {
                                        csvString = csvString+substepNote.csvSafeString()+","
                                    } else {
                                        csvString = csvString+","
                                    }
                                    
                                    //Critical Tool
                                    if let toolTitle = tool.moduleTitle {
                                        csvString = csvString+toolTitle.csvSafeString()+","
                                    } else {
                                        csvString = csvString+","
                                    }
                                    
                                    //Critical Notes
                                    if let toolIdentifier = tool.identifier, let toolNote = progressManager.note(for: toolIdentifier) {
                                        csvString = csvString+toolNote.csvSafeString()+","
                                    }
                                    
                                    //Next
                                    csvString = csvString+newLine
                                }
                            }
                        }
                    }
                }
            }
            
            csvString = csvString+newLine
        }
        
        if let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first, let cacheURL = URL(string: cacheDirectory) {
            
            let filePath = cacheURL.appendingPathComponent("file.csv")
            do {
                try csvString.write(toFile:filePath.path, atomically: true, encoding: .utf8)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        }
    
        return nil
    }
}

extension String {
    
    func csvSafeString() -> String {
        return "\"" + self.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
