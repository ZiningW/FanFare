//
//  LeftPanelFormat.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//
import UIKit

class LeftPanelTitleText: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    private func setupLabel(){
        font = UIFont(name: Fonts.helveticaLight, size: 40)
        textColor = Colors.deepPurple
    }
    
}

class LeftPanelNotImportantText: UILabel {
    
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

class leftLabelButton: UIButton{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton(){
        titleLabel?.font     = UIFont(name: Fonts.helveticaLight, size: 16)
        setTitleColor(Colors.depressionGray, for: .normal)
    }
}

class leftLogOutButton: UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton(){
        titleLabel?.font     = UIFont(name: Fonts.helveticaLight, size: 16)
        setTitleColor(Colors.evilBlue, for: .normal)
    }
}

class leftSegmentSwitch: UISegmentedControl{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSeg()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSeg()
    }
    
    private func setupSeg(){
        let segmentedControl = UISegmentedControl()
        segmentedControl.tintColor = Colors.chickenShitYellow
    }
}



