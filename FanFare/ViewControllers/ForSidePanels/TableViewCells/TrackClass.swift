//
//  RightSidePanelClasses.swift
//  MeerKatSentinel
//
//  Created by Zining Wang on 7/3/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import Foundation

class TrackClass {

    // For users
    var trackID: String
    var folderName: String
    var video: [String]
    var audio: [String]
    var downloaded: Bool

    init?(trackDict: TrackList) {
        self.trackID = trackDict.trackID
        self.folderName = trackDict.trackName
        self.video = trackDict.video
        self.audio = trackDict.audio
        self.downloaded = trackDict.downloaded
    }
}

struct TrackList {
    let trackID: String
    let trackName: String
    let video: [String]
    let audio: [String]
    var downloaded: Bool
    
    
    init(trackID: String, trackName: String, audio: [String], video: [String], downloaded: Bool) {
        self.trackName = trackName
        self.video = video
        self.audio = audio
        self.downloaded = downloaded
        self.trackID = trackID
    }
}


