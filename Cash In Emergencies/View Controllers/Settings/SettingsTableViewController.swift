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

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var contentAvailableLabel: UILabel!
    
    @IBOutlet weak var downloadButton: UIButton!
    
    let contentController = ContentController()
    
    var bundleInformation: BundleInformation?
    
    func redraw() {
        
        //        contentAvailableLabel?.text = bundleInformation?.identifier
        
        let currentTimestamp = contentController.currentBundleTimestamp
        if let publishDate = bundleInformation?.publishDate, publishDate.timeIntervalSince1970 > currentTimestamp {
            
            downloadButton.isHidden = false
            contentAvailableLabel.text = "New Content Available"
        } else {
            
            downloadButton.isHidden = true
            contentAvailableLabel.text = "Content up to date"
        }
        //        tableView.red
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        
        contentController.getBundleInformation(for: "1") { (result) in
            
            switch result {
            case .success(let information):
                
                self.bundleInformation = information
                self.redraw()
                //                if let _url = information.downloadURL {
                //
                //                    self.contentController.downloadBundle(from: _url, progress: { (progress, bytesDownloaded, totalBytes) in
                //                        print(progress)
                //                    }, completion: { (result) in
                //                        print(result)
                //
                //
                //                    })
                //                }
                
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    /// Resets the user data so that the app works like a fresh install
    func handleResetData() {
        
        let resetDataAlert = UIAlertController(title: "Reset All Data", message: "This will clear all progress and notes recorded in the app", preferredStyle: .alert)
        
        resetDataAlert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: { (action: UIAlertAction) in
            
            //Handle resetting data here when the controller exists
            
        }))
        
        resetDataAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(resetDataAlert, animated: true, completion: nil)
    }
    
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
    @IBAction func handleDownloadButton(_ sender: UIButton) {
        
        MDCHUDActivityView.start(in: view.window)
        sender.isEnabled = false
        
        if let _url = bundleInformation?.downloadURL {
            
            self.contentController.downloadBundle(from: _url, progress: { (progress, bytesDownloaded, totalBytes) in
                print(progress)
            }, completion: { [weak self] (result) in
                print(result)
                
                switch result {
                case .success(let didSucceed):
                    OperationQueue.main.addOperation({
                        sender.isEnabled = true
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

        )}
    }
    
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
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleLanguagePicker() {
    
        let languagePicker = UIAlertController(title: "Select Language", message: nil, preferredStyle: .actionSheet)
        
        if let languageOptions = bundleInformation?.availableLanguages {
            
            for language in languageOptions {
                languagePicker.addAction(UIAlertAction(title: language, style: .default, handler: { (action) in
                    
                }))
            }
            
            languagePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        
        showDetailViewController(languagePicker, sender: self)
    }
}
