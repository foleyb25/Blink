//
//  Animations.swift
//  Blink2
//
//  Created by Brian Foley on 5/22/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class Animations {
    
    static func animateRecordButton(videoButton: UIButton, captureButton: UIButton) {
    
        
        //moves video button to capturebutton and increases capturebuttonsize
        moveAndExpand(fromButton: videoButton, toButton: captureButton)
        //start record and show number of seconds text
        startRecordTimer(button: videoButton)
        //add pulsating effect, from button is the videorecord button
        pulsateRecordButton(button: videoButton)
        
    }
    
    private static func moveAndExpand(fromButton: UIButton, toButton: UIButton) {
        fromButton.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        UIView.animate(withDuration: 0.25, animations: {
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: toButton.center.x - fromButton.center.x, y: 0)
            transform = transform.scaledBy(x: 2.0, y: 2.0)
            fromButton.transform = transform
        }, completion: nil)
    }
    
    static func animateMoveRecordButtonBack(button: UIButton) {
        button.setBackgroundImage(UIImage(systemName: "video.circle"), for: .normal)
        button.isHidden = true
        button.transform = .identity
        timer.invalidate()
        button.setTitle("", for: .normal)
        button.layer.removeAllAnimations()
    }
    
    
    static func animatePulsatingLayer(layer: CALayer) {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.duration = 0.75
        animation.fromValue = UIColor.clear.cgColor
        animation.toValue = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5).cgColor
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: "pulsing")
    }
 
    
    private static func pulsateRecordButton(button: UIButton) {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = UIColor.clear.cgColor
        animation.toValue = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5).cgColor
        animation.duration = 0.75
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        button.layer.add(animation, forKey: "redpulse")
    }
    
    private static var seconds = 0
    private static var timer = Timer()
    
    private static func startRecordTimer(button: UIButton) {
        timer.invalidate()
        seconds = 0
        button.setTitle("\(seconds)", for: .normal)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            seconds+=1
            button.setTitle("\(seconds)", for: .normal)
        }

    }
}
