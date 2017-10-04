//
//  ModuleIndexManager.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 04/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation
import CoreSpotlight
import ARCDM
import MobileCoreServices

class ToolIndexManager {
    
    static let shared = ToolIndexManager()
    
    private let domain = "org.redcross.cie.search"
    
    var searchQuery: CSSearchQuery? = nil
    
    func searchTools(using term: String, completionHandler: @escaping ((Error?, [Module]) -> Void)) {
        
        var foundTools: [Module] = []
        
        if let _searchQuery = searchQuery {
            
            _searchQuery.cancel()
            self.searchQuery = nil
        }
        
        let queryString = "title == '\(term)*'wc"
        
        self.searchQuery = CSSearchQuery(queryString: queryString, attributes: ["title", "displayName"])
        
        self.searchQuery?.foundItemsHandler = { (items : [CSSearchableItem]) in
            
            let returnedTools = items.flatMap({ (searchItem) -> Module? in

                guard let moduleIdentifier = Int(searchItem.uniqueIdentifier), let modulesToSearch = ModuleManager().modules else { return nil }

                return ModuleManager().module(for: moduleIdentifier, in: modulesToSearch)
            })

            foundTools.append(contentsOf: returnedTools)
        }
        
        self.searchQuery?.completionHandler = { (error: Error?) in
            completionHandler(nil, foundTools)
        }
        
        self.searchQuery?.start()
    }
    
    func index(products: [Module], completionHandler: ((Error?) -> Void)?) {
        
        unIndexAll { (error) in
            if let error = error {
                completionHandler?(error)
            } else {
                
                self.createIndex(products: products, completionHandler: { (error) in
                    completionHandler?(error)
                })
            }
        }
    }
    
    func createIndex(products: [Module], completionHandler: ((Error?) -> Void)?) {
        
        var searchableItems = [CSSearchableItem]()
        
        if let modules = ModuleManager().modules {
            
            for module in modules {
                
                if let steps = module.directories {
                    
                    for step in steps {
                        
                        if let substeps = step.directories {
                            
                            for substep in substeps {
                                
                                if let files = substep.directories {
                                    
                                    for file in files {
                                        
                                        let searchableSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
                                        searchableSet.displayName = file.moduleTitle
                                        searchableSet.title = file.moduleTitle
                                        
                                        if let _firstAttachment = file.attachments?.first {
                                            
                                            if let size = _firstAttachment.size {
                                                searchableSet.fileSize = NSNumber(value: size)
                                            }
                                            
                                            if let _mimeImage = _firstAttachment.mimeImage() {
                                                searchableSet.thumbnailData = UIImagePNGRepresentation(_mimeImage)
                                            }
                                        }
                                        
                                        guard let _moduleIdentifier = file.identifier else {
                                            break
                                        }
                                        
                                        let item = CSSearchableItem(uniqueIdentifier: "\(_moduleIdentifier)", domainIdentifier: domain, attributeSet: searchableSet)
                                        
                                        searchableItems.append(item)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        CSSearchableIndex.default().indexSearchableItems(searchableItems, completionHandler: completionHandler)
    }
    
    func unIndexAll(completionHandler: ((Error?) -> Void)?) {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domain], completionHandler: completionHandler)
    }
    
}
