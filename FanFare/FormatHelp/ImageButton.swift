//
//  ImageButton.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import UIKit

class ImageButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    
    private func setupButton() {
        setShadow()
    }
    
    func setNewImage(_ image: String){
        guard let newImage = UIImage(named: image) else { return }
        
        tintColor = UIColor.white
        setImage(newImage, for: .normal)
    }
    
    func setShadow() {
        layer.backgroundColor = nil
        layer.borderWidth   = 0
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 1.0, height: 3.0)
        layer.shadowRadius  = 4
        layer.shadowOpacity = 0.5
        clipsToBounds       = true
        layer.masksToBounds = false
    }
    
    func setShadowWhite(){
        
        layer.borderWidth = -10
        layer.masksToBounds = false
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = self.frame.height/2
        layer.backgroundColor = UIColor.white.cgColor
        
        layer.shadowColor   = UIColor.white.cgColor
        layer.shadowOffset  = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius  = 8
        layer.shadowOpacity = 1.0
    }
    
    func glowingButton(color: CGColor){
        layer.backgroundColor = nil
        layer.borderWidth   = 0
        layer.shadowColor = color
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
    
    func removeAnimation(){
        layer.removeAllAnimations()
        setupButton()
    }
}
@IBDesignable
class GlowingButton: UIButton {
    @IBInspectable var animDuration : CGFloat = 3
    @IBInspectable var cornerRadius : CGFloat = 5
    @IBInspectable var maxGlowSize : CGFloat = 10
    @IBInspectable var minGlowSize : CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentScaleFactor = UIScreen.main.scale
        layer.masksToBounds = false
        setupButton()
        startAnimation()
    }
    
    func setupButton(){
        layer.backgroundColor = nil
        layer.borderWidth   = 0
        layer.shadowColor = Colors.evilBlue.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = maxGlowSize
        layer.shadowOpacity = 1
        clipsToBounds       = true
        layer.masksToBounds = false
        

    }
    
    func startAnimation() {
        
        let layerAnimation = CABasicAnimation(keyPath: "shadowRadius")
        layerAnimation.fromValue = maxGlowSize
        layerAnimation.toValue = minGlowSize
        layerAnimation.autoreverses = true
        layerAnimation.isAdditive = false
        layerAnimation.duration = CFTimeInterval(animDuration/2)
        layerAnimation.fillMode = CAMediaTimingFillMode.forwards
        layerAnimation.isRemovedOnCompletion = false
        layerAnimation.repeatCount = .infinity
        self.layer.add(layerAnimation, forKey: "glowingAnimation")
        
    }
}
