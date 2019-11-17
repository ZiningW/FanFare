//
//  BottomPanelViewController.swift
//  SoundScape
//
//  Created by Zining Wang on 7/18/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import UIKit


class BottomPanelViewController: UIViewController{
    
    weak var delegate: BottomPanelViewControllerDelegate?
    override func viewDidLoad() {
        self.delegate?.testFunc()
    }
}

protocol BottomPanelViewControllerDelegate: class{
    func testFunc()
}
