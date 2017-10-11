//
//  SettingsTableViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 24/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import AVKit
import ARCDM
import ThunderBasics
import CloudKit

/// The view controller responsible for user settings and downloading the latest bundles. This view also facilitates language switching if available
class SettingsTableViewController: UITableViewController {
    
    //MARK: - Variables
    /// The label indicating whether or not content is available. This is in the first table view cell
    @IBOutlet weak var contentAvailableLabel: UILabel!
    
    /// The button that activates downloading of the latest bundle. Hidden by default.
    @IBOutlet weak var downloadButton: UIButton!
    
    /// A button that displays the current language short code and facilitates changing language when tapped
    @IBOutlet weak var currentLanguageButton: UIButton!
    
    /// The content controller responsible for loading locale and remote bundle information and facilitating downloads.
    let contentController = ContentController()
    
    /// The bundle information from the server containing information about languages and download URLs
    var bundleInformation: BundleInformation?
    
    //MARK: - VC Lifecycle & Drawing
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        
        redraw()
        getBundleInformation()
    }
    
    func redraw() {
        
        let currentTimestamp = contentController.currentBundleTimestamp
        if let publishDate = bundleInformation?.publishDate, publishDate.timeIntervalSince1970 > currentTimestamp {
            
            downloadButton.isHidden = false
            contentAvailableLabel.text = "New Content Available"
        } else if let publishDate = bundleInformation?.publishDate, publishDate.timeIntervalSince1970 == currentTimestamp {
            
            downloadButton.isHidden = true
            contentAvailableLabel.text = "Content up to date"
        } else {
            
            downloadButton.isHidden = true
            contentAvailableLabel.text = "Checking for updates..."
        }
        
        if bundleInformation != nil {
            currentLanguageButton.isEnabled = true
        }
        
        //Set language label
        if let language = UserDefaults.standard.string(forKey: "ContentOverrideLanguage") {
            currentLanguageButton.setTitle(language.uppercased(), for: .normal)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            //Download section
            switch indexPath.row {
            case 0:
                //Perform update
                return
            default:
                return
            }
        case 1:
            switch indexPath.row {
            case 0:
                //Play video
                handlePlayVideo()
                return
            case 1:
                handleResetData()
                return
            case 2:
                //Change language
                handleLanguagePicker()
                return
            default:
                return
            }
        default:
            return
        }
    }
    
    //MARK: - Action handling
    /// Resets the user data so that the app works like a fresh install
    func handleResetData() {
        
        let resetDataAlert = UIAlertController(title: "Reset All Data", message: "This will clear all progress and notes recorded in the app", preferredStyle: .alert)
        
        resetDataAlert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: { (action: UIAlertAction) in
            ProgressManager().clearAllUserValues()
        }))
        
        resetDataAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(resetDataAlert, animated: true, completion: nil)
    }
    
    
    /// Handles tapping of the download button on the bundle cell
    ///
    /// - Parameter sender: The download button
    @IBAction func handleDownloadButton(_ sender: UIButton) {
        
        MDCHUDActivityView.start(in: view.window)
        sender.isEnabled = false
        downloadBundle()
    }
    
    /// Presents the tutorial video and dismisses on completion
    func handlePlayVideo() {
        
        if let _fileURL = Bundle.main.url(forResource: "onboarding_video", withExtension: "mp4") {
            
            let player = AVPlayer(url: _fileURL)
            
            let playerView = AVPlayerViewController()
            playerView.showsPlaybackControls = true
            if #available(iOS 11.0, *) {
                playerView.exitsFullScreenWhenPlaybackEnds = true
            } else {
                NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            }
            
            playerView.player = player
            
            present(playerView, animated: true, completion: nil)
            
            player.play()
        }
    }
    
    /// Presents an action sheet with available languages that the user can select
    @IBAction func handleLanguagePicker() {
        
        let languagePicker = UIAlertController(title: "Select Language", message: nil, preferredStyle: .actionSheet)
        
        if let languageOptions = bundleInformation?.availableLanguages {
            
            for language in languageOptions.reversed() {
                
                let languageString = Locale.current.localizedString(forIdentifier: language)
                
                languagePicker.addAction(UIAlertAction(title: languageString, style: .default, handler: { (action) in
                    
                    MDCHUDActivityView.start(in: self.view.window)
                    UserDefaults.standard.set(language, forKey: "ContentOverrideLanguage")
                    self.downloadBundle()
                }))
            }
            
            languagePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        
        showDetailViewController(languagePicker, sender: self)
    }
    
    /// Dismisses the tutorial video on devices running iOS 10 when the video finishes playing
    ///
    /// - Parameter note: The notification that was sent from the player on completion of the video playback
    @objc func playerDidFinishPlaying(note: NSNotification) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Downloading
    func downloadBundle() {
        
        //Set base URL
        var url: URL?
        
        //Add language if required
        if let baseURL = self.bundleInformation?.downloadURL, let language = UserDefaults.standard.string(forKey: "ContentOverrideLanguage") {
            if let _newURL = URL(string: "\(baseURL)&language=\(language)") {
                url = _newURL
            }
        } else {
            url = self.bundleInformation?.downloadURL
        }
        
        guard let _url = url else {
            return
        }
        
        self.contentController.downloadBundle(from: _url, progress: { (progress, bytesDownloaded, totalBytes) in
            print(progress)
        }, completion: { [weak self] (result) in
            print(result)
            
            switch result {
            case .success:
                OperationQueue.main.addOperation({
                    MDCHUDActivityView.finish(in: self?.view.window)
                    NotificationCenter.default.post(name: NSNotification.Name("ContentControllerBundleDidUpdate"), object: nil)
                    
                    //Save and reload
                    if let _interval = self?.bundleInformation?.publishDate?.timeIntervalSince1970 {
                        UserDefaults.standard.set(_interval, forKey: "CurrentBundleTimestamp")
                    }
                    self?.redraw()
                })
            case .failure(let error):
                print(error)
            }
            }
        )
    }
    
    /// Downloads the latest bundle information and sets it to the `bundleInformation` variable. This causes the view to reload on completion
    func getBundleInformation() {
        contentController.getBundleInformation(for: "1") { [weak self] (result) in
            
            switch result {
            case .success(let information):
                
                self?.bundleInformation = information
                self?.redraw()
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
