////
////  AudioEngine.swift
////  FanFare
////
////  Created by Zining Wang on 11/14/19.
////  Copyright © 2019 Zining Wang. All rights reserved.
////
//
//import Foundation
//import AVFoundation
//
//class ARAudioEngine {
//    // AV AUDIO SESSION ********* ********* ********* ********* *********
//    private var audioEngine = AVAudioEngine()
//    private var audioEnvironment = AVAudioEnvironmentNode()
//    private var audioPlayer = AVAudioPlayerNode()
//
//    private var yawOffset: Double?
//
//    // Constants
//    struct Constants {
//        static let AUDIO_FILE_NAME      = "video1"
//        static let AUDIO_FILE_NAME_EXT  = "wav"
//    }
//
//    init(){
//        print("audioengine configured")
//        setupAudioEnvironment()
//        setupNotifications()
//    }
//}
//
//extension ARAudioEngine {
//    func setupAudioEnvironment() {
//        // Configure the audio session
//        let avSession = AVAudioSession.sharedInstance()
//        do {
//
//            try avSession.setCategory(AVAudioSession.Category.playback, options: [.mixWithOthers] )
//
//        } catch let error as NSError {
//            print("Error setting AVAudioSession category: \(error.localizedDescription)\n")
//        }
//
//        // Configure audio buffer sizes
//        let bufferDuration: TimeInterval = 0.005; // 5ms buffer duration
//        try? avSession.setPreferredIOBufferDuration(bufferDuration)
//
//        let desiredNumChannels = 2
//        if avSession.maximumOutputNumberOfChannels >= desiredNumChannels {
//            do {
//                try avSession.setPreferredOutputNumberOfChannels(desiredNumChannels)
//            } catch let error as NSError {
//                print("Error setting PreferredOuputNumberOfChannels: \(error.localizedDescription)")
//            }
//        }
//        do {
//            try avSession.setActive(true)
//        } catch let error as NSError {
//            print("Error setting session active: \(error.localizedDescription)\n")
//        }
//
//        // Configure the audio environment, initialize the listener to start at 0, facing front.
//        audioEnvironment.listenerPosition  = AVAudioMake3DPoint(0, 0, 0)
//        audioEnvironment.listenerAngularOrientation = AVAudioMake3DAngularOrientation(0.0, 0.0, -5.0)
//        audioEngine.attach(audioEnvironment)
//
//        // Configure the audio engine
//        let hardwareSampleRate = audioEngine.outputNode.outputFormat(forBus: 0).sampleRate
//        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: hardwareSampleRate, channels: 2) else { return }
//        audioEngine.connect(audioEnvironment, to: audioEngine.outputNode, format: audioFormat)
//        audioEnvironment.renderingAlgorithm = .HRTFHQ
//
//
//        // Configure the audio player
//        audioEngine.attach(audioPlayer)
//        audioPlayer.position = AVAudio3DPoint(x: 0.0, y: 0.0, z: -5.0)
//        if let audioFileURL = Bundle.main.url(forResource: Constants.AUDIO_FILE_NAME, withExtension: Constants.AUDIO_FILE_NAME_EXT) {
//            do {
//                // Open the audio file
//                let audioFile = try AVAudioFile(forReading: audioFileURL, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: false)
//
//                // Loop the audio playback upon completion - reschedule the same file
//                func loopCompletionHandler() {
//                    audioPlayer.scheduleFile(audioFile, at: nil, completionHandler: loopCompletionHandler)
//                }
//
//                audioEngine.connect(audioPlayer, to: audioEnvironment, format: audioFile.processingFormat)
//
//                // Schedule the file for playback, see 'scheduleBuffer' for sceduling indivdual AVAudioBuffer/AVAudioPCMBuffer
//                audioPlayer.scheduleFile(audioFile, at: nil, completionHandler: loopCompletionHandler)
//            }
//            catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
//
//    //  Setup notifications for AVAudioSession events
//    func setupNotifications() {
//        // Interruption handler
//        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
//
//        // Route change handler
//        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
//
//        // Media services reset handler
//        NotificationCenter.default.addObserver(self, selector: #selector(handleMediaServicesReset), name: AVAudioSession.mediaServicesWereResetNotification, object: nil)
//    }
//
//    // Handle an audio device interruption (i.e. phone call, music playing, etc...)
//    @objc func handleInterruption(notification: Notification) {
//        print("handle interruption notification audio/phonecall")
//        guard let userInfo = notification.userInfo,
//            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
//            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
//                return
//        }
//        if type == .began {
//            // Interruption began, take appropriate actions
//            stopPlaying()
//            print("Audio playback interrupted")
//        }
//        else if type == .ended {
//            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
//                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
//                if options.contains(.shouldResume) {
//                    startPlaying()
//                    print("Audio playback resumed")
//                } else {
//                    stopPlaying()
//                    print("Audio playback stopped")
//                }
//            }
//        }
//    }
//
//    // Handle a audio route change
//    @objc func handleRouteChange(notification: Notification) {
//        print("Audio route changed")
//    }
//
//    @objc private func handleMediaServicesReset(_ notification: NSNotification) {
//        // setupAudioEnvironment()
//        stopPlaying()
//        print("Media services have been reset")
//    }
//}
//
//extension ARAudioEngine {
//    // Stop playing
//    func stopPlaying() {
//        if(audioEngine.isRunning || audioPlayer.isPlaying) {
//            audioEngine.stop()
//            audioPlayer.stop()
//        }
////        DispatchQueue.main.async {
////            self.buttonText.setTitle("Start Playing", for: .normal)
////        }
//    }
//
//    // Start playing
//    func startPlaying() {
//        do {
//            // Reset the current head direction
////            yawOffset = nil
//            try audioEngine.start()
//            audioPlayer.play()
//        } catch {
//            print("this is an error with start playing", error)
//        }
//
////        DispatchQueue.main.async {
////            self.buttonText.setTitle("Stop Playing", for: .normal)
////        }
//    }
//
//    func update3DAudio(yaw: Float, pitch: Float, roll: Float){
//        // Update the listerner position in space
//        audioEnvironment.listenerAngularOrientation = AVAudioMake3DAngularOrientation(yaw, pitch, roll)
//    }
//}
//
////class ARAudioEngine {
////
////    var engine      : AVAudioEngine!
////    var environment : AVAudioEnvironmentNode!
////
////
////    func getBufferFromFileInBundle(url: URL) -> AVAudioPCMBuffer? {
////        // audio MUST be a monoaural source or it cant work in 3D
////        var file:AVAudioFile
////        var audioBuffer : AVAudioPCMBuffer? = nil
////        do{
////            file = try AVAudioFile(forReading: url)
////            audioBuffer = AVAudioPCMBuffer(pcmFormat:(file.processingFormat), frameCapacity: AVAudioFrameCount(file.length))
////            try file.read(into: audioBuffer!)
////        } catch let error as NSError {
////            print("Error AVAudioFile:\(error)")
////        }
////
////        return audioBuffer
////    }
////
////    func outputFormat() -> AVAudioFormat {
////        let outputFormat = engine.outputNode.outputFormat(forBus: 0)
////        let nChannels    = outputFormat.channelCount // testing, will always be 2 channels
////        let sampleRate   = outputFormat.sampleRate
////        return AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: nChannels)!
////    }
////
////    func setupEngine() {
////        engine      = AVAudioEngine()
////        environment = AVAudioEnvironmentNode()
////
////        engine.attach(environment)
////        engine.connect(environment, to: engine.outputNode, format: outputFormat())
////
////        environment.listenerPosition = AVAudioMake3DPoint(0.0, 0.0, 0.0);
////        environment.listenerVectorOrientation = AVAudioMake3DVectorOrientation(AVAudioMake3DVector(0, 0, -1),AVAudioMake3DVector(0, 0, 0))
////        environment.listenerAngularOrientation = AVAudioMake3DAngularOrientation(0.0,0.0, 0.0)
////
////
////        do{
////            try engine.start()
////        } catch let error as NSError {
////            print("Error start:\(error)")
////        }
////    }
////
////    func attachPlayer( _ player: AVAudioPlayerNode, _ audioBuffer: AVAudioPCMBuffer){
////
////        player.renderingAlgorithm = .HRTF
////        engine.attach(player)
////        engine.connect(player, to: environment, format: audioBuffer.format)
////    }
////
////    func resetEngine(){
////        engine.reset()
////        setupEngine()
////    }
////
////    func detachPlayer(player: AVAudioPlayerNode){
////        engine.detach(player)
////    }
////    func stopEngine(){
////        engine.stop()
////        do{
////            try engine.start()
////        } catch let error as NSError {
////            print("Error start:\(error)")
////        }
////    }
////}
