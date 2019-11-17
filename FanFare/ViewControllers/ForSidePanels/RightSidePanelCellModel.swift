//
//  RightSidePanelListModel.swift
//  MeerKatSentinel
//
//  Created by Zining Wang on 7/3/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

enum RightSidePanelCellType {
    case Track
}

protocol RightSidePanelCellItem {
    var type: RightSidePanelCellType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
}

class RightSidePanelCellModel: NSObject {
    
    var items = [RightSidePanelCellItem]()
    var delegate: RightSidePanelCellModelDelegate?
    var trackArray = [TrackClass]()
    var fBaseHandler: FirebaseHandler?
    
    override init() {
        super.init()
        
    }
    
    func getItems(trackDict: [TrackClass]){
        // Create Groups
        let trackItem = RightPanelTrackItem(trackDict: trackDict)
        items.append(trackItem)

    }
}

extension RightSidePanelCellModel: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        
        switch item.type {
   
        case .Track:
            if let item = item as? RightPanelTrackItem, let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.identifier, for: indexPath) as? TrackCell {

                let track = item.trackDict[indexPath.row]
                cell.item = track
                if track.downloaded == false {
                    cell.downloadTapped = { (cell) in
                        self.fBaseHandler!.getStorageFiles(trackList: track)
                   }
                }
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeader.reuseIdentifer) as? CustomHeader else {
            return nil
        }
        
        header.customLabel.text = items[section].sectionTitle
        
        return header

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Header height
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // see if the user tapped a table cell
        if items[indexPath.section].type == .Track{
            if trackArray[indexPath.row].downloaded == true {
                delegate?.didSelectTrack(trackArray[indexPath.row])
            } else {
                self.fBaseHandler!.getStorageFiles(trackList: trackArray[indexPath.row])
            }
        }
    }
}


class RightPanelTrackItem: RightSidePanelCellItem {
    var type: RightSidePanelCellType {
        return .Track
    }
    
    var sectionTitle: String {
        return "Tracks"
    }
    
    var rowCount: Int {
        return trackDict.count
    }
    
    var trackDict: [TrackClass]

    
    init(trackDict: [TrackClass]) {
        self.trackDict = trackDict
    }
}

protocol RightSidePanelCellModelDelegate {
    func didSelectTrack(_ track: TrackClass)
}

