//
//  ARHandler.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import AVFoundation
import ARVideoKit
import Photos

class ARHandler: NSObject, RenderARDelegate, RecordARDelegate  {

    var sceneView: ARSCNView!
    var nodeArray = [SCNNode]()
    var nameArray = [String: Int]()
    var audioSourceArray = [SCNAudioSource]()
    var videoSourceStringArray = [Any]()
    
    var nodeCounter = 0
    
    var fBaseHandler: FirebaseHandler?
    
    weak var delegate: ARHandlerDelegate?
    
    var documentsURL: URL?
    
    // Video Recording
    var recordingCounter = 0
    var firstTimeRecord: Bool? = true
    let recordingQueue = DispatchQueue(label: "recordingThread", attributes: .concurrent)
    let caprturingQueue = DispatchQueue(label: "capturingThread", attributes: .concurrent)
    var recorder:RecordAR?
    
    var newVideoPath: URL?
    ///
    
    
    // For Bose Rotation
    var pitch: Float?
    var roll: Float?
    var yaw: Float?
    
    var didSetUpScene: Bool? = false
    var listenerNode: SCNNode?
    
    init(scene: ARSCNView){
        super .init()
        self.sceneView = scene
        self.sceneView.delegate = self

        configureLighting()
        addTapGestureToSceneView()
        
        setUpAudioLoop()
        setUpVideo()
        
        getFile()
        
        listenerNode = generateTestNode()
        
        documentsURL = getDocumentsDirectory()
        
        
    }
    
    func initVideoRecording(){
        // Initialize ARVideoKit recorder
        recorder = RecordAR(ARSceneKit: sceneView)

        /*----👇---- ARVideoKit Configuration ----👇----*/

        // Set the recorder's delegate
        recorder?.delegate = self

        // Set the renderer's delegate
        recorder?.renderAR = self

        // Configure the renderer to perform additional image & video processing 👁
        recorder?.onlyRenderWhileRecording = false

        // Configure ARKit content mode. Default is .auto
        recorder?.contentMode = .aspectFill

        //record or photo add environment light rendering, Default is false
        recorder?.enableAdjustEnvironmentLighting = true

        // Set the UIViewController orientations
        recorder?.inputViewOrientations = [.landscapeLeft, .landscapeRight, .portrait]
        // Configure RecordAR to store media files in local app directory
        recorder?.deleteCacheWhenExported = false
        
        ///
    }

    func addTapGestureToSceneView() {

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)

    }

    @objc func didReceiveTapGesture(_ sender: UITapGestureRecognizer) {

        if nodeCounter <= videoSourceStringArray.count - 1{
            if nodeCounter == 0 {
                delegate?.arActive(isActive: true)
            }

            let location = sender.location(in: sceneView)
            guard let hitTestResult = sceneView.hitTest(location, types: [.featurePoint, .estimatedHorizontalPlane]).first
                else { return }
            let anchor = ARAnchor(transform: hitTestResult.worldTransform)
            sceneView.session.add(anchor: anchor)

        }
    }


    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }


    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        nodeArray = []

        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        delegate?.arActive(isActive: false)

        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.session.run(configuration, options: options)
    }

}

extension ARHandler {
    // MARK: - Exported UIAlert present method
    func exportMessage(success: Bool, status: PHAuthorizationStatus) {
        if success {
            let alert = UIAlertController(title: "Exported", message: "Media exported to camera roll successfully!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Awesome", style: .cancel, handler: nil))
            self.delegate?.presentMessage(alert: alert)
        }else if status == .denied || status == .restricted || status == .notDetermined {
            let errorView = UIAlertController(title: "😅", message: "Please allow access to the photo library in order to save this media file.", preferredStyle: .alert)
            let settingsBtn = UIAlertAction(title: "Open Settings", style: .cancel) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    } else {
                        UIApplication.shared.openURL(URL(string:UIApplication.openSettingsURLString)!)
                    }
                }
            }
            errorView.addAction(UIAlertAction(title: "Later", style: UIAlertAction.Style.default, handler: {
                (UIAlertAction)in
            }))
            errorView.addAction(settingsBtn)
            self.delegate?.presentMessage(alert: errorView)
        }else{
            let alert = UIAlertController(title: "Exporting Failed", message: "There was an error while exporting your media file.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.delegate?.presentMessage(alert: alert)
        }
    }

}

extension ARHandler {
    
    func generateCubeNode() -> SCNNode {
        // Generate a canvas for the video to display on
        let cube = SCNBox(width: 0.75, height: 2, length: 0.02, chamferRadius: 0.02)
        let cubeNode = SCNNode()
        cubeNode.position.y += Float(cube.width / 2)
        cubeNode.geometry = cube
        cubeNode.name = "cube"
        
        return cubeNode
    }
    
    func generateTestNode() -> SCNNode {
        // Generate a node for audio listener
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.02)
        let cubeNode = SCNNode()
        
        cubeNode.geometry = cube
        return cubeNode
    }
    
    func recordVideo() {

        //Record
        if firstTimeRecord == true{
            initVideoRecording()
            
            if recorder?.status == .readyToRecord {
                self.delegate?.changeButtonTitle(title: "Stop")
                recordingQueue.async {
                    self.recorder?.record()
                }
            }
            firstTimeRecord = false
        }else if recorder?.status == .readyToRecord {
            self.delegate?.changeButtonTitle(title: "Stop")
            recordingQueue.async {
                self.recorder?.record()
            }
        }else if recorder?.status == .recording {
            self.delegate?.changeButtonTitle(title: "Record")
            
            recorder?.stop() { path in
                self.recorder?.export(video: path) { saved, status in
                    DispatchQueue.main.sync {
                        self.exportMessage(success: saved, status: status)
                        // extract audio from video file after file was successfully saved
                        
                        self.newVideoPath = path
                        self.videoSourceStringArray.append(path)
                        
                    }
                }
            }
        }
    }

    func extractAudio(url: URL, counter: Int) {
        
        let asset = AVURLAsset(url: url, options: nil)
        let name = "audio" + String(counter) + ".wav"
        let fileURL = getDocumentsDirectory().appendingPathComponent(name)
        asset.writeAudioTrackToURL(fileURL) { (success, error) -> () in
            if !success {
                print(error!)
            }
        }
        self.fBaseHandler?.uploadToStorage(url: fileURL, type: "audio")
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    

}

extension ARHandler {
    func updateBoseRotation(rawYaw: Float, rawPitch: Float, rawRoll: Float){
        
        func radians(fromDegrees degrees: Float) -> Float {
            return degrees * .pi / 180.0
        }
        
        yaw = radians(fromDegrees: rawYaw)
        pitch = radians(fromDegrees: rawPitch)
        roll = radians(fromDegrees: rawRoll)
        
        let newRotation = SCNVector3Make(pitch!, yaw!, roll!)
        
        let position = sceneView.pointOfView?.position
        listenerNode?.position = position!
        
        if didSetUpScene == false{
            listenerNode?.eulerAngles = newRotation
            sceneView.audioListener = listenerNode
            didSetUpScene = true
        } else {
            sceneView.audioListener?.eulerAngles = newRotation
        }
        
        
    }

    func addVideoToBlank(){
        print("nodearray", nodeArray)
        for (n,targetNode) in nodeArray.enumerated(){
            // Get video source
            print("index",n)
            var fileUrlString: URL?
            if videoSourceStringArray[n] is String {
                fileUrlString = URL(fileURLWithPath: Bundle.main.path(forResource: videoSourceStringArray[n] as? String, ofType: "mp4")!)
                
            }
            else {
                print("new")
                fileUrlString = videoSourceStringArray[n] as? URL
            }
           
            //find our video file
            let videoItem = AVPlayerItem(url: fileUrlString!)
            
            let player = AVPlayer(playerItem: videoItem)
            player.play()
            // Set video player as the texture of the target node
            targetNode.geometry?.firstMaterial?.diffuse.contents = player

            // add observer when our player.currentItem finishes player, then start playing from the beginning
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { (notification) in
                player.seek(to: CMTime.zero)
                player.play()
                print("Looping Video")
            }
            
            //initialize video node with avplayer
            let videoNode = SKVideoNode(avPlayer: player)
            // set the size (just a rough one will do)
            let videoScene = SKScene(size: CGSize(width: 1, height: 2))
            // center our video to the size of our video scene
            videoNode.position = CGPoint(x: 0, y: 0)
            // invert our video so it does not look upside down
            videoNode.yScale = -1.0
            // add the video to our scene
            videoScene.addChild(videoNode)

            let plane = SCNPlane(width: 1, height: 2)
            // set the first materials content to be our video scene
            plane.firstMaterial?.diffuse.contents = videoScene
            // create a node out of the plane
            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3Make(0, 0, 0)
            
            targetNode.addChildNode(planeNode)
            
            if audioSourceArray.indices.contains(n){
                planeNode.addAudioPlayer(SCNAudioPlayer(source: audioSourceArray[n]))
                
            } else {
                print("out of range")
                return
            }
        }
    }
}

extension ARHandler: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        
        let targetNode = generateCubeNode()
        nodeArray.append(targetNode)
        
        // Detect horizontal plane
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [])
        
        node.addChildNode(targetNode)
        
        self.nodeCounter += 1
    }

}

extension ARHandler {
    
    private func getFile(){
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!

        do {
            let items = try fm.contentsOfDirectory(atPath: path)

            for item in items {
                print("Found \(item)")
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
    }
    
    private func setUpVideo(){
        videoSourceStringArray = ["video1", "video2", "video3"]
    }
    
    private func setUpAudioLoop(){
        let audioList = ["video1.mp3", "video2.mp3", "video3.mp3"]
        for i in audioList{
            setUpAudio(fileName: i)
        }
    }
    
    private func setUpAudio(fileName: String) {
        // Instantiate the audio source
        let audioSource: SCNAudioSource = SCNAudioSource(fileNamed: fileName)!
        // As an environmental sound layer, audio should play indefinitely
        audioSource.loops = true
        // Decode the audio from disk ahead of time to prevent a delay in playback
        audioSource.load()
        
        audioSourceArray.append(audioSource)
    }

}

protocol ARHandlerDelegate: class {
    func presentMessage(alert: UIAlertController)
    func arActive(isActive: Bool)
    func changeButtonTitle(title: String)
}

//MARK: - ARVideoKit Delegate Methods
extension ARHandler {
    func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {
        // Do some image/video processing.
    }

    func recorder(didEndRecording path: URL, with noError: Bool) {
        if noError {
            // Do something with the video path.
        }
    }

    func recorder(didFailRecording error: Error?, and status: String) {
        // Inform user an error occurred while recording.
    }

    func recorder(willEnterBackground status: RecordARStatus) {
        // Use this method to pause or stop video recording. Check [applicationWillResignActive(_:)](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622950-applicationwillresignactive) for more information.
        if status == .recording {
            recorder?.stopAndExport()
        }
    }
    
}




