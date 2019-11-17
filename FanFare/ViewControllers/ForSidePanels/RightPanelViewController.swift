//
//  SidePanelViewController.swift
//  MeerKatSentinel
//
//  Created by Zining Wang on 6/22/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import UIKit
import CoreLocation

class RightPanelViewController: UIViewController {
    
    let viewModel = RightSidePanelCellModel()
    var fBaseHandler: FirebaseHandler?
    
    weak var delegate: RightPanelViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView?
    
    var track: [TrackClass]!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.getItems(trackDict: track)
        viewModel.trackArray = track
        viewModel.fBaseHandler = fBaseHandler
        
        tableView?.delegate = viewModel
        tableView?.dataSource = viewModel
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableView.automaticDimension
        
        tableView?.register(CustomHeader.self, forHeaderFooterViewReuseIdentifier: CustomHeader.reuseIdentifer)
        tableView?.register(TrackCell.nib, forCellReuseIdentifier: TrackCell.identifier)
        
        tableView?.reloadData()
    }
}

extension RightPanelViewController: RightSidePanelCellModelDelegate {

    func didSelectTrack(_ track: TrackClass) {
        delegate?.didSelectTrack(track)
    }
    
}

protocol RightPanelViewControllerDelegate: class{
    func didSelectTrack(_ track: TrackClass)
    
}
