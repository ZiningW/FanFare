//
//  mainView.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import Foundation
import UIKit

class MainViewLabels: UILabel{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    func setupLabel() {
        font = UIFont(name: Fonts.helveticaLight, size: 15)
        textColor = Colors.fadedDepressionGray
    }
    private func setShadow() {
        layer.backgroundColor = Colors.fadedDepressionGray.cgColor
        layer.shadowColor    = UIColor.black.cgColor
        layer.shadowOffset   = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius   = 8
        layer.shadowOpacity  = 0.5
        clipsToBounds        = true
        layer.masksToBounds  = false
    }
    
    func selectTrackLabel() {
        font = UIFont(name: Fonts.helveticaLight, size: 20)
        textColor = Colors.driedBloodRedButton
    }
}

class MainViewAudioLabels: UILabel{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    func setupLabel() {
        font = UIFont(name: Fonts.helveticaLight, size: 14)
        textColor = Colors.fadedDepressionGray
    }
    private func setShadow() {
        layer.backgroundColor = Colors.fadedDepressionGray.cgColor
        layer.shadowColor    = UIColor.black.cgColor
        layer.shadowOffset   = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius   = 8
        layer.shadowOpacity  = 0.5
        clipsToBounds        = true
        layer.masksToBounds  = false
    }
}

class MainViewTrackTitleLabels: UILabel{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    func setupLabel() {
        font = UIFont(name: Fonts.helveticaLight, size: 20)
        textColor = Colors.fadedDepressionGray
    }
    private func setShadow() {
        layer.backgroundColor = Colors.fadedDepressionGray.cgColor
        layer.shadowColor    = UIColor.black.cgColor
        layer.shadowOffset   = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius   = 8
        layer.shadowOpacity  = 0.5
        clipsToBounds        = true
        layer.masksToBounds  = false
    }
}

class MainLayerFormat: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setupLayer(){
        let gradient = CAGradientLayer()
        backgroundColor = Colors.indigo
        let color = Colors.indigo
        gradient.colors = [color.withAlphaComponent(0.0).cgColor, color.withAlphaComponent(0.4).cgColor, color.withAlphaComponent(0.7).cgColor, color.withAlphaComponent(0.9).cgColor]
        gradient.locations = [0.0, 0.1, 0.3, 1.0]
        gradient.frame = layer.bounds
        layer.mask = gradient
    }
}
