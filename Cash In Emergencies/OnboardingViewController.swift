//
//  OnboardingViewController.swift
//  Cash In Emergencies
//
//  Created by Matthew Cheetham on 16/08/2017.
//  Copyright © 2017 3 SIDED CUBE. All rights reserved.
//

import UIKit
import AVKit

class OnboardingViewController: UIViewController {

    @IBAction func handlePlayVideo(_ sender: UIButton) {
        
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
}
