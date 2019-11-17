//
//  MainViewController.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import UIKit
import AVFoundation
import SceneKit
import ARKit

class MainViewController: UIViewController {

    // init firebase class
    var fBaseHandler: FirebaseHandler?
    var boseHandler: BoseHandler?
    var arHandler: ARHandler?
    var selectedTrack: TrackClass?
    var initialTrack: Bool = true
    
//    let arAudioEngine = ARAudioEngine()

    @IBOutlet weak var resetButton: ImageButton!
    @IBOutlet weak var menuButton: ImageButton!
    @IBOutlet weak var rightButton: ImageButton!
    @IBOutlet weak var playButton: ImageButton!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var arScnView: ARSCNView!
    
    @IBOutlet weak var gradientLayer: MainLayerFormat!
    
    @IBOutlet weak var arDescriptionOutput: MainViewLabels!
    
    var didPlayAudio: Bool = true
    var didLoopAudio: Bool = false
    
    var audioSliderUpdater : CADisplayLink! = nil
    
    var delegate: MainViewControllerDelegate?
    
    @IBAction func menuButtonAction(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        delegate?.toggleRightPanel()
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        resetEverything()
    }
    
    @IBAction func recordButton(_ sender: Any) { 
        arHandler?.recordVideo()
    }
    
    @IBAction func playButtonAction(_ sender: ImageButton) {
        print("play button selected")
//        arHandler?.startAudio()
        arHandler?.addVideoToBlank()

    }
    
    @IBAction func recordButtonAction(_ sender: Any) {
        arHandler?.recordVideo()
    }
    
}

// MARK: - View lifecycle
extension MainViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arHandler = ARHandler(scene: arScnView)
        arHandler?.delegate = self
        arHandler?.fBaseHandler = fBaseHandler
        
        boseHandler?.delegate = self
        menuButton.setNewImage("menu")
        rightButton.setNewImage("musical-note")
        resetButton.setNewImage("refresh")
        resetButton.isHidden = true
        
        initialTrackSelected()
        
        playButton.setNewImage("play")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        
        arHandler?.resetTrackingConfiguration()
        
        boseHandler?.listenForWearableDeviceEvents()
        boseHandler?.listenForSensors()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            boseHandler?.stopListeningForSensors()
        }
        
        arHandler?.sceneView.session.pause()
    }
    
}

extension MainViewController {
    
    func preloadMusic(track: TrackClass){
        
        let docsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = docsPath.appendingPathComponent(track.folderName)
        let fileManager = FileManager.default
        
        var docsArray = [URL]()
        var counter: Int = 0
        
        do {
            docsArray = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
        } catch {
            print(error)
        }

    }
    
    func resetPlayers(){
        
        resetEverything()
    }
    
    func resetEverything(){
        arHandler?.resetTrackingConfiguration()
        arHandler?.nodeCounter = 0
        
        didPlayAudio = true
        if initialTrack == true {
            initialTrackSelected()
            return
        }
        guard let track = selectedTrack else {return}
        preloadMusic(track: track)
        
    }
}

extension MainViewController {
  
    private func logOutReturnToMain(){
        boseHandler?.stopListeningForSensors()
        fBaseHandler!.logout()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        
    }
    
}

extension MainViewController: LeftPanelViewControllerDelegate {
    
    func stopSensors(){
        // stop our own sensors before attaching to a new sensor to avoid them fucking with eachother
        boseHandler?.stopListeningForSensors()
    }
    
    func logOut() {
        // for the logout button
        logOutReturnToMain()
    }
    
    func initialTrackSelected(){
        let initArray = ["video1", "video2"]
        
        delegate?.collapseSidePanels()
        
    }
}

extension MainViewController: RightPanelViewControllerDelegate {
    func didSelectTrack(_ track: TrackClass) {
        resetPlayers()
        selectedTrack = track
        preloadMusic(track: track)
        delegate?.collapseSidePanels()
        initialTrack = false
    }
}

extension MainViewController: BoseHandlerDelegate {
    func showError(_ error: (Error)) {
        self.show(error)
    }
    
    func presentController(_ vc: ContainerViewController) {
        self.present(vc, animated: true, completion: nil)
    }
    
    func navigationShowError(_ error: Error?, _ pop: @escaping () -> ()) {
        navigationController?.show(error, dismissHandler: pop)
    }
    
    func navigationPopToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func navigationShowAlert(_ pop: @escaping () -> ()) {
        navigationController?.showAlert(title: "Disconnected", message: "The connection was closed", dismissHandler: pop)
    }
    
    func updateRotation(yaw: Float, pitch: Float, roll: Float) {
        arHandler?.updateBoseRotation(rawYaw: yaw, rawPitch: pitch, rawRoll: roll)
    }
    
}

extension MainViewController: ARHandlerDelegate {
    
    func changeButtonTitle(title: String) {
        recordButton.setTitle(title, for: .normal)
    }
    
    func presentMessage(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }

    func arActive(isActive: Bool) {
        if isActive {
            resetButton.isHidden = false
        } else {
            resetButton.isHidden = true
        }
    }
}

protocol MainViewControllerDelegate {
    func toggleLeftPanel()
    func toggleRightPanel()
    func collapseSidePanels()
}
