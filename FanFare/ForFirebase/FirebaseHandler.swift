//
//  FirebaseHandler.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseUI
import FirebaseStorage


class FirebaseHandler{
    var selfUid: String
    var selfUserName: String
    let storage = Storage.storage()
    var storageRef: StorageReference
    let ref: DatabaseReference
    var trackArray = [TrackClass]()
    
    var numberOfItems: Int = 0
    
    init(){
        ref = Database.database().reference().child("StorageReference")
        selfUid = Auth.auth().currentUser?.uid ?? fBaseConstants.defaultUid
        selfUserName = Auth.auth().currentUser?.displayName ?? fBaseConstants.defaultUserName
        storageRef = storage.reference()
        
//        writeToRealTimeDB()
    }
    
    func writeToRealTimeDB(){
        let data = ["trackName": "Frank",
                    "audio":["video1.mp3","video2.mp3","video3.mp3"],
                    "video":["video1.mp4","video2.mp4","video3.mp4"],
                    "downloaded":"false"] as [String : Any]
        let trackID = "Frank"
        
        ref.child(trackID).updateChildValues(data)
    }
    
    func writeToDB(){
        let trackID = "Frank"
        let videoData = [numberOfItems: "video"+String(numberOfItems)+".mp4"]
        let audioData = [numberOfItems: "audio"+String(numberOfItems)+".mp3"]
        ref.child(trackID).child("video").updateChildValues(videoData)
        ref.child(trackID).child("audio").updateChildValues(audioData)
    }
    
    func logout(){
   
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    func getStorageFiles(trackList: TrackClass){
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        for (ind, value) in trackList.video.enumerated(){
            
            let localURL = documentsURL.appendingPathComponent(trackList.folderName + "/" + String(ind) + ".mp4")
            
            do{
                try FileManager.default.createDirectory(atPath: localURL.path, withIntermediateDirectories: true, attributes: nil)
                    let filePath = trackList.folderName + "/" + value
                    let ref = storageRef.child(filePath)
                
                    let downloadTask = ref.write(toFile: localURL)
                    downloadObservers(downloadTask: downloadTask, fileNumber: ind)
                
            }catch let error as NSError{
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        
        for (ind, value) in trackList.audio.enumerated(){
            
            let localURL = documentsURL.appendingPathComponent(trackList.folderName + "/" + String(ind) + ".mp3")
            
            do{
                try FileManager.default.createDirectory(atPath: localURL.path, withIntermediateDirectories: true, attributes: nil)
                    let filePath = trackList.folderName + "/" + value
                    let ref = storageRef.child(filePath)
                
                    let downloadTask = ref.write(toFile: localURL)
                    downloadObservers(downloadTask: downloadTask, fileNumber: ind)
                
            }catch let error as NSError{
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
    
    }
    
    private func downloadObservers(downloadTask: StorageDownloadTask, fileNumber: Int){
        downloadTask.observe(.pause) { snapshot in
            // Download paused
        }
        
        downloadTask.observe(.progress) { snapshot in
            // Download reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("percent downloaded: \(percentComplete)")
        }
        
        downloadTask.observe(.success) { snapshot in
            print("file number \(fileNumber) downloaded")
        }
        
        // Errors only occur in the "Failure" case
        downloadTask.observe(.failure) { snapshot in
            guard let errorCode = (snapshot.error as? NSError)?.code else {
                return
            }
            guard let error = StorageErrorCode(rawValue: errorCode) else {
                return
            }
            switch (error) {
            case .objectNotFound:
                // File doesn't exist
                print("object not found: \(error)")
                break
            case .unauthorized:
                // User doesn't have permission to access file
                print("unauthorized: \(error)")
                break
            case .cancelled:
                // User cancelled the download
                print("user cancelled: \(error)")
                break
                
            case .unknown:
                // Unknown error occurred, inspect the server response
                print("unknown error: \(error)")
                break
            default:
                // Another error occurred. This is a good place to retry the download.
                break
            }
        }
    }
}

extension FirebaseHandler {
    func uploadToStorage(url: URL, type: String){
        // File located on disk
        let localFile = url
        var path: String?
        if type == "audio"{
            path = "Frank/"+"audio"+String(numberOfItems)+".mp3"
        } else {
            path = "Frank/"+"video"+String(numberOfItems)+".mp4"
        }
        // Create a reference to the file you want to upload
        let ref = storageRef.child(path!)

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = ref.putFile(from: localFile, metadata: nil) { metadata, error in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          // You can also access to download URL after upload.
          ref.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
              return
            }
          }
        }
    }
}

extension FirebaseHandler{
    
    func processTrackList(){
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let trackDict = snapshot.value as? [String: [String: Any]] ?? [:]
            
            for (uid, value) in trackDict {
                
                let audioList = value["audio"] as! [String]
                self.numberOfItems = audioList.count
                var downloaded: Bool = false
                if value["downloaded"] as! String == "true"{
                    downloaded = true
                }
                let trackDict = TrackList(trackID: uid,
                                          trackName: value["trackName"] as! String,
                                          audio: value["audio"] as! [String],
                                          video: value["video"] as! [String],
                                          downloaded: downloaded)
                let trackClass = TrackClass(trackDict: trackDict)
         
                self.trackArray.append(trackClass!)
            }
        })
    }
    
    func getTrackList() -> [TrackClass]{
        return trackArray
    }
    
}

