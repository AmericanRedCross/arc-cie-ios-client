//
//  ContentController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 25/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import Foundation

/// A controller responsible for managing content and bundles. This includes facilitating the downloads and updates of new bundle content.
class ContentController {
    
    /// Retrieves information about the latest bundle/publish for a project. This can be used to compare the current bundle and determine if there is an update available
    ///
    /// - Parameters:
    ///   - projectID: The project ID to look up the bundle information for
    ///   - completion: A Result<BundleInformation> object that contains either the bundle information or an error where appropriate.
    func getBundleInformation(for projectID: String, completion: @escaping (Result<BundleInformation>) -> Void) {}
    
    /// Downloads a bundle for the given project and unpacks it for use.
    ///
    /// - Parameters:
    ///   - projectID: The project ID to download the bundle for
    ///   - language: The language code to download the bundle for. Use `getBundleInformation(for:completion:)` to find the available language code
    ///   - completion: A Result<Bool> object where the boolean indicates success. This may also return an Error object where appropriate.
    func downloadBundle(for projectID: String, language: String, completion: @escaping (Result<Bool>) -> Void) {}
}

/// Contains information about an available storm bundle on the server
struct BundleInformation {
    
    /// The bundle identifier as provided by the server
    var identifier: String?
    /// The timedate that the bundle was created
    var publishDate: TimeInterval?
    /// The URL to download the file (May be a redirect)
    var downloadURL: URL?
    /// The language codes of the available languages
    var availableLanguages: [String]?
}
