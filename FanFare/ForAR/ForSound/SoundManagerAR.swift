////
////  3DAudioTest.swift
////  SoundScape
////
////  Created by Zining Wang on 7/21/19.
////  Copyright © 2019 Zining Wang. All rights reserved.
////
//
//import AVFoundation
//
//class SoundManager {
//
//    var player = AVAudioPlayerNode()
//    var file: URL!
//
//    var audioEngine: ARAudioEngine!
//    var audioBuffer: AVAudioPCMBuffer!
//
//    var audioFile: AVAudioFile?
//
//    var playerTime: AVAudioTime?
//    var audioLengthSeconds: Float = 0
//    var audioLengthSamples: AVAudioFramePosition = 0
//
//    var startInSongSeconds: Float = 0
//    
//    var sampleRate: Double?
//
//
//    init(file: URL, engine: ARAudioEngine){
//        self.file = file
//        self.audioEngine = engine
//        startAudioTest()
//        player.volume = 0.0
//        setAudioFile()
//        getSampleRate()
//        getTotalLength()
//    }
//
//    func getSampleRate(){
//        sampleRate = player.outputFormat(forBus: 0).sampleRate
//    }
//
//    func updatePosition(_ x: Float, _ y: Float, _ z: Float){
//
//        let posInSpace = AVAudioMake3DPoint(x, y, z)
//
//        player.position = posInSpace
//        print("posInspace", posInSpace)
//    }
//
//    func startAudioTest() {
//
//        guard let audioBuffer = audioEngine.getBufferFromFileInBundle(url: file) else {return}
//
//        audioEngine.attachPlayer(player, audioBuffer)
//        player.scheduleBuffer(audioBuffer, at: nil, options: .loops, completionHandler: nil)
//
//    }
//
//    func setAudioFile(){
//        do {
//            audioFile = try AVAudioFile(forReading: file)
//        } catch {
//            return
//        }
//    }
//
//    func changeVolume( _ volume: Float){
//        player.volume = volume
//    }
//
//    func pauseAudio(){
//        player.pause()
//    }
//
//    func stopAudio(){
//        player.stop()
//    }
//
//    func playAudio(time: AVAudioTime){
//        player.play(at: time)
//    }
//
//    func createStartTime() -> AVAudioTime? {
//
//        var time:AVAudioTime?
//        let lapsedTime = 1000 * 500
//
//        time = AVAudioTime(hostTime: mach_absolute_time() + UInt64(lapsedTime))
//
//        return time
//
//    }
//
//    func getCurrentTime() -> Float{
//
//        if(self.player.isPlaying){
//            if let nodeTime = self.player.lastRenderTime, let playerTime = player.playerTime(forNodeTime: nodeTime) {
//                let elapsedSeconds = startInSongSeconds + (Float(playerTime.sampleTime) / Float(sampleRate!))
//
//                if elapsedSeconds == audioLengthSeconds {
//                    startInSongSeconds = 0
//                    return 0
//                }
//                return elapsedSeconds
//            }
//        } else {
//            print("ran")
//            return startInSongSeconds
//        }
//        return 0
//    }
//
//    func getTotalLength(){
//        guard let aFile = audioFile else {return}
//        audioLengthSamples = aFile.length
//        audioLengthSeconds = Float(audioLengthSamples) / Float(sampleRate!)
//    }
//
//    func seekTo(time: Double) {
//        player.stop()
//        startInSongSeconds = Float(time)
//
//        let startSample = floor(time * sampleRate!)
//        let lengthSamples = Float(audioLengthSamples) - Float(startSample)
//
//        player.scheduleSegment(audioFile!, startingFrame: AVAudioFramePosition(startSample), frameCount: AVAudioFrameCount(lengthSamples), at: nil, completionHandler: {self.player.pause()})
//
//    }
//
//}
//
