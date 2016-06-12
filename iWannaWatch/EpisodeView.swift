//
//  Test.swift
//  iWannaWatch
//
//  Created by Gaston Siffert on 6/5/16.
//  Copyright © 2016 Gaston Siffert. All rights reserved.
//

import Cocoa

class EpisodeView: NSViewController {
    
    private static let unseen   = NSImage(named: "unseen")
    private static let seen     = NSImage(named: "seen")
    
    @IBOutlet weak var titleLabel       : NSTextField!
    @IBOutlet weak var codeTextField    : NSTextField!
    @IBOutlet weak var seenButton       : NSButton!
    
    private var hasSeen             = false
    
    var episode: Episode? {
        didSet {
            updateGUI()
        }
    }
    
    override func awakeFromNib() {
        updateGUI()
    }
    
    private func updateGUI() {
        codeTextField?.stringValue      = episode == nil ? "" : episode!.code
        titleLabel?.stringValue         = episode?.title ?? ""
        setButtonImage()
    }
    
    private func setButtonImage() {
        if hasSeen == false {
            seenButton?.image = EpisodeView.unseen
        } else {
            seenButton?.image = EpisodeView.seen
        }
    }
    
    @IBAction func seenPressed(sender: NSButton) {
        Animations.startScaleAnimation(seenButton)
        Animations.startSpinningAnimation(seenButton)
        let request = EpisodeWatchedRequest()
        if !hasSeen {
            request.post(episode!.id, onSuccess: onSuccess, onErrors: onFailed)
        } else {
            request.delete(episode!.id, onSuccess: onSuccess, onErrors: onFailed)
        }
    }
    
    private func onSuccess(episode: Episode) {
        hasSeen = !hasSeen
        setButtonImage()
        seenButton?.layer?.removeAnimationForKey(Animations.ROTATE_KEY)
    }
    
    private func onFailed(errors: [Error]) {
        print(errors.first)
        seenButton?.layer?.removeAnimationForKey(Animations.ROTATE_KEY)
    }
    
}
