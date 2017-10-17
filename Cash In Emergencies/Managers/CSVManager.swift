//
//  CSVManager.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 12/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation
import DMSSDK

/// Deals with exporting a CSV of the tools and user critical data
class CSVManager {
    
    /// Exports the modules as a CSV, saves that CSV to disk and then returns to file path URL to you
    ///
    /// - Parameter criticalOnly: If true only modules that are marked as critical tools by the DMS or the user will be entered into the CSV
    /// - Returns: The file URL of the created CSV on the disk
    class func exportModules(criticalOnly: Bool = false) -> URL? {
        
        /// An array of heading items to be set in the CSV for each module
        let csvHeadings = ["Step","Sub-Step Action & Guidance","Done","Sub-Step Notes","Tool","Done","Tool Notes"]
        
        let progressManager = ProgressManager()
        let newLine = "\n"
        
        guard let modules = DirectoryManager().directories else {
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
                                    
                                    if criticalOnly {
                                        //TODO: Include user marked critical tools
                                        if tool.metadata?["critical_path"] == nil {
                                            continue
                                        }
                                    }
                                    
                                    //Step
                                    if let stepName = step.moduleTitle, let stepHierarchy = step.metadata?["hierarchy"] as? String {
                                        csvString = csvString+(stepHierarchy+" "+stepName).csvSafeString()+","
                                    } else {
                                        csvString = csvString+","
                                    }
                                    
                                    //Sub-Step Action & Guidance
                                    if let substepName = substep.moduleTitle, let substepHierarchy = substep.metadata?["hierarchy"] as? String {
                                        csvString = csvString+(substepHierarchy+" "+substepName).csvSafeString()+","
                                    } else {
                                        csvString = csvString+","
                                    }
                                    
                                    //Done
                                    if progressManager.checkState(for: substep.identifier) {
                                        csvString = csvString+"yes"+","
                                    } else {
                                        csvString = csvString+"no"+","
                                    }
                                    
                                    //Sub-Step Notes
                                    if let substepNote = progressManager.note(for: substep.identifier) {
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
                                    
                                    //Done
                                    if progressManager.checkState(for: tool.identifier) {
                                        csvString = csvString+"yes"+","
                                    } else {
                                        csvString = csvString+"no"+","
                                    }
                                    
                                    //Critical Notes
                                    if let toolNote = progressManager.note(for: tool.identifier) {
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
        
        if let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let cacheURL = URL(fileURLWithPath: cacheDirectory)
            let cieDataDirectory = cacheURL.appendingPathComponent("CIEData")
            try? FileManager.default.createDirectory(atPath: cieDataDirectory.path, withIntermediateDirectories: true, attributes: nil)
            
            let filePath = cieDataDirectory.appendingPathComponent("export.csv")
            do {
                try csvString.write(toFile:filePath.path, atomically: true, encoding: .utf8)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            
            return filePath
        }
    
        return nil
    }
}

extension String {
    
    func csvSafeString() -> String {
        return "\"" + self.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
