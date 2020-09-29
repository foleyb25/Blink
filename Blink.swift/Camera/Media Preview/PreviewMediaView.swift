//
//  PreviewMediaView.swift
//  Blink
//
//  Created by Brian Foley on 9/22/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewMediaView: UIView {
    
    // stores url of video file. used for filemanager deletion
    var url: URL?
    
    //stores captured image
    var image: UIImage?
    
    //capturing movies
    internal var playerLayer : AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.frame = UIScreen.main.bounds
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    let imagePreview: UIImageView = {
        let viewItem = UIImageView()
        viewItem.frame = UIScreen.main.bounds
        viewItem.contentMode = .scaleAspectFill
        viewItem.clipsToBounds = true
        return viewItem
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(cancelPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "trash"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(sendPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "paperplane"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(imagePreview.layer)
        layer.addSublayer(playerLayer)
        addSubview(cancelButton)
        addSubview(sendButton)
        setupConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerLayer.player?.currentItem)
    }

    //restarts video once the end is reached
    @objc func playerItemDidReachEnd(notification: Notification) {
           if let playerItem = notification.object as? AVPlayerItem {
               playerItem.seek(to: CMTime.zero, completionHandler: nil)
           }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension UIResponder {
    func getOwningViewController() -> UIViewController? {
        var nextResponser = self
        while let next = nextResponser.next {
          nextResponser = next
          if let viewController = nextResponser as? UIViewController {
            return viewController
          }
        }
        return nil
      }
}

