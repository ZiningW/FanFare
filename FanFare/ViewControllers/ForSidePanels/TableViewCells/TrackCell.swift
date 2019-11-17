//
//  UserCell.swift
//  MeerKatSentinel
//
//  Created by Zining Wang on 7/3/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import UIKit
import CoreLocation

class TrackCell: UITableViewCell {

    var downloadTapped: ((UITableViewCell) -> Void)?
    @IBOutlet weak var downloadBtn: ImageButton!
    @IBOutlet weak var trackName: UILabel!
    
    
    var item: TrackClass? {
        didSet {
            guard let item = item else {
                return
            }

            if checkFolderExist(track: item) == false {
                downloadBtn.setNewImage("download")
            } else {
                downloadBtn.setNewImage("check-circular-button")
            }

            trackName.text = item.folderName
            
        }
    }

    @IBAction func downloadTapped(_ sender: Any) {
        downloadTapped?(self)
    }
    
    func checkFolderExist(track: TrackClass) -> Bool {
        let docsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = docsPath.appendingPathComponent(track.folderName)
        
        let fileManager = FileManager.default
        var fileExists: Bool?
        var isDir : ObjCBool = false
        
        if fileManager.fileExists(atPath: path.path, isDirectory:&isDir){
            if isDir.boolValue {
                fileExists = true
                track.downloaded = true
            } else {
                fileExists = false
                track.downloaded = false
            }
        } else {
            fileExists = false
            track.downloaded = false
        }
        return fileExists!
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
 
}


    

