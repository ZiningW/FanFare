//
//  LogInScreenText.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import UIKit

class LogInText: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    private func setupLabel(){
        font = UIFont(name: Fonts.helveticaLight, size: 14)
        textColor = Colors.depressionGray
    }
    
}

class LogInUISwitch: UISwitch {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSwitch()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSwitch()
    }
    
    private func setupSwitch(){
        onTintColor = Colors.indigo
    }
}

class LogInButton: UIButton {
    
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
        
        titleLabel?.font    = UIFont(name: Fonts.helveticaLight, size: 26)
        layer.cornerRadius  = frame.size.height/4
        setTitleColor(Colors.indigo, for: .normal)
        layer.borderColor   = Colors.indigo.cgColor
        layer.borderWidth   = 2
    }
    
    private func setShadow() {
        layer.shadowColor   = UIColor.black.cgColor
        //        layer.shadowColor   = Colors.chickenShitYellow.cgColor
        layer.shadowOffset  = CGSize(width: 0.0, height: 3.0)
        layer.shadowRadius  = 5
        layer.shadowOpacity = 0.5
        clipsToBounds       = true
        layer.masksToBounds = false
    }
}

