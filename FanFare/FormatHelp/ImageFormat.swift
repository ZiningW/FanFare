//
//  ImageFormat.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//
import Foundation
import UIKit

class AlertImage: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImage()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImage()
    }
    
    private func setupImage() {
        setShadow()
    }
    
    func setShadow() {
        layer.backgroundColor = nil
        layer.borderWidth   = 0
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius  = 8
        layer.shadowOpacity = 0.5
        clipsToBounds       = true
        layer.masksToBounds = false
        glowingImage()
    }
    
    func glowingImage(){
        layer.backgroundColor = nil
        layer.borderWidth   = 0
        layer.shadowColor = UIColor.red.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 15
        layer.shadowOpacity = 1
        clipsToBounds       = true
        layer.masksToBounds = false
        
        startAnimation()
    }
    
    private func startAnimation() {
        
        let layerAnimation = CABasicAnimation(keyPath: "shadowRadius")
        layerAnimation.fromValue = 15
        layerAnimation.toValue = 0
        layerAnimation.autoreverses = true
        layerAnimation.isAdditive = false
        layerAnimation.duration = CFTimeInterval(1/2)
        layerAnimation.fillMode = CAMediaTimingFillMode.forwards
        layerAnimation.isRemovedOnCompletion = false
        layerAnimation.repeatCount = .infinity
        self.layer.add(layerAnimation, forKey: "glowingAnimation")
        
    }
    
}

