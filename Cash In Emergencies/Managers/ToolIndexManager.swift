//
//  ModuleIndexManager.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 04/10/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation
import CoreSpotlight
import DMSSDK
import MobileCoreServices

class ToolIndexManager {
    
    static let shared = ToolIndexManager()
    
    private let domain = "org.redcross.cie.search"
    
    var searchQuery: CSSearchQuery? = nil
    
    private init() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(bundleDidChange), name: NSNotification.Name("ContentControllerBundleDidUpdate"), object: nil)
        
    }
    
    func searchCriticalTools(with completionHandler: @escaping ((Error?, [(parent: String, tool: Directory)]) -> Void)) {
    
        var foundTools = [(String, Directory)]()
    
        if let _searchQuery = searchQuery {
    
            _searchQuery.cancel()
            self.searchQuery = nil
        }
    
        let queryString = "critical_path == '1'"
    
        self.searchQuery = CSSearchQuery(queryString: queryString, attributes: ["title", "displayName", "containerDisplayName"])
    
        self.searchQuery?.foundItemsHandler = { (items : [CSSearchableItem]) in
    
            let returnedTools = items.flatMap({ (searchItem) -> (String, Directory)? in

                guard let moduleIdentifier = Int(searchItem.uniqueIdentifier), let modulesToSearch = DirectoryManager().directories else { return nil }

                if let _foundModule = DirectoryManager.directory(for: moduleIdentifier, in: modulesToSearch), let parentString = searchItem.attributeSet.containerDisplayName {
                    return (parentString, _foundModule)
                }
    
                return nil
            })

            foundTools.append(contentsOf: returnedTools)
        }
    
        self.searchQuery?.completionHandler = { (error: Error?) in
            completionHandler(nil, foundTools)
        }
    
        self.searchQuery?.start()
    
    }
    
    func searchTools(using term: String, completionHandler: @escaping ((Error?, [(parent: String, tool: Directory)]) -> Void)) {
        
        var foundTools = [(String, Directory)]()
        
        if let _searchQuery = searchQuery {
            
            _searchQuery.cancel()
            self.searchQuery = nil
        }
        
        let queryString = "title == '\(term)*'wc"
        
        self.searchQuery = CSSearchQuery(queryString: queryString, attributes: ["title", "displayName", "containerDisplayName"])
        
        self.searchQuery?.foundItemsHandler = { (items : [CSSearchableItem]) in
            
            let returnedTools = items.flatMap({ (searchItem) -> (String, Directory)? in

                guard let moduleIdentifier = Int(searchItem.uniqueIdentifier), let modulesToSearch = DirectoryManager().directories else { return nil }

                if let _foundModule = DirectoryManager.directory(for: moduleIdentifier, in: modulesToSearch), let parentString = searchItem.attributeSet.containerDisplayName {
                    return (parentString, _foundModule)
                }
                
                return nil
            })

            foundTools.append(contentsOf: returnedTools)
        }
        
        self.searchQuery?.completionHandler = { (error: Error?) in
            completionHandler(nil, foundTools)
        }
        
        self.searchQuery?.start()
    }
    
    func index(products: [Directory], completionHandler: ((Error?) -> Void)?) {
        
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
    
    func createIndex(products: [Directory], completionHandler: ((Error?) -> Void)?) {
        
        var searchableItems = [CSSearchableItem]()
        
        if let modules = DirectoryManager().directories {
            
            for module in modules {
                
                if let steps = module.directories {
                    
                    for step in steps {
                        
                        if let substeps = step.directories {
                            
                            for substep in substeps {
                                
                                if let files = substep.directories {
                                    
                                    for file in files {
                                        
                                        let item = createSearchableItem(for: file, parentSubstep: substep)
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
    
    func createSearchableItem(for file: Directory, parentSubstep: Directory) -> CSSearchableItem {
        
        let searchableSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        searchableSet.displayName = file.directoryTitle
        searchableSet.title = file.directoryTitle
        searchableSet.containerTitle = parentSubstep.directoryTitle
        if let moduleTitle = parentSubstep.directoryTitle, let subHierarchy = parentSubstep.metadata?["hierarchy"] as? String {
            searchableSet.containerDisplayName = "\(subHierarchy) \(moduleTitle)"
        }
        
        if let _criticalTool = file.metadata?["critical_path"] as? Bool {
            if _criticalTool {
                if let _key = CSCustomAttributeKey(keyName: "critical_path") {
                    searchableSet.setValue(_criticalTool as NSNumber, forCustomKey: _key)
                }
            }
        } else if ProgressManager().userCriticalTool(for: file.identifier) {
            if let _key = CSCustomAttributeKey(keyName: "critical_path") {
                searchableSet.setValue((1 as NSNumber), forCustomKey: _key)
            }
        }
        
        searchableSet.containerIdentifier = String(describing: parentSubstep.identifier)
        
        
        if let _firstAttachment = file.attachments?.first {
            
            if let size = _firstAttachment.size {
                searchableSet.fileSize = NSNumber(value: size)
            }
            
            if let _mimeImage = _firstAttachment.mimeImage() {
                searchableSet.thumbnailData = UIImagePNGRepresentation(_mimeImage)
            }
        }
        
        let _moduleIdentifier = file.identifier
        
        let item = CSSearchableItem(uniqueIdentifier: "\(_moduleIdentifier)", domainIdentifier: domain, attributeSet: searchableSet)
        
        return item
    }
    
    func indexTool(_ directory: Directory, completionHandler: ((Error?) -> Void)?) {
        
        if let parentIdentifier = directory.parentIdentifier, let directories = DirectoryManager().directories {
            if let parentDirectory = DirectoryManager.directory(for: parentIdentifier, in: directories) {
                let item = createSearchableItem(for: directory, parentSubstep: parentDirectory)
                CSSearchableIndex.default().indexSearchableItems([item], completionHandler: completionHandler)
            }
        }
    }
    
    func unIndexAll(completionHandler: ((Error?) -> Void)?) {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domain], completionHandler: completionHandler)
    }
}

extension ToolIndexManager {
 
    @objc func bundleDidChange() {
        
        unIndexAll { [weak self] (error) in
            
            if let modules = DirectoryManager().directories {
                self?.createIndex(products: modules, completionHandler: { (error) in
                    
                    NotificationCenter.default.post(name: NSNotification.Name("ModulesDidIndex"), object: nil)
                    
                })
            }
        }
    }
}
