//
//  BoseController.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import BLECore
import Logging
import BoseWearable
import simd

import WorldMagneticModel

class BoseHandler: NSObject {
    var session: WearableDeviceSession! {
        didSet {
            session?.delegate = self
        }
    }
    var sessionState: WearableDeviceSessionState?
    
    /// Used to block the UI when sensor service is suspended.
    private var suspensionOverlay: SuspensionOverlay?
    
    // We create the SensorDispatch without any reference to a session or a device.
    // We provide a queue on which the sensor data events are dispatched on.
    private let sensorDispatch = SensorDispatch(queue: .main)
    
    /// Retained for the lifetime of this object. When deallocated, deregisters
    /// this object as a WearableDeviceEvent listener.
    private var token: ListenerToken?
    
    private var yawOffset: Double?
    
    weak var delegate: BoseHandlerDelegate?
    
    override init(){
        super .init()
        sensorDispatch.handler = self as? SensorDispatchHandler
    }
    
    func initBoseSession(){
        sessionState = session.state
        sensorDispatch.handler = self
    }
    
}

extension BoseHandler {
    
    func dismiss(dueTo error: Error?, isClosing: Bool = false) {
        // Common dismiss handler passed to show()/showAlert().
        let popToRoot = { [weak self] in
            DispatchQueue.main.async {
                self!.delegate?.navigationPopToRoot()
            }
        }
        
        if isClosing && error == nil {
            sessionState = .closed
 
            delegate?.navigationShowAlert(popToRoot)
        }
            // Show an error alert.
        else {
            sessionState = .closed
            delegate?.navigationShowError(error, popToRoot)
        }
    }
    
    func listenForWearableDeviceEvents() {
        
        token = session.device?.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }
    
    func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        switch event {
        case .didFailToWriteSensorConfiguration(let error):
            // Show an error if we were unable to set the sensor configuration.
            delegate?.showError(error)
            
        case .didSuspendWearableSensorService(let reason):
            // Block the UI when the sensor service is suspended.
            print("broken due to \(reason)")
        case .didResumeWearableSensorService:
            // Unblock the UI when the sensor service is resumed.
            suspensionOverlay?.removeFromSuperview()
            
        default:
            break
        }
    }
    
    /// Configures the rotation sensor at 50 Hz (a 20 ms sample period).
    func listenForSensors() {
        session.device?.configureSensors { config in
            
            // Here, config is the current sensor config. We begin by turning off
            // all sensors, allowing us to start with a "clean slate."
            config.disableAll()
            
            // Enable the rotation and accelerometer sensors
            config.enable(sensor: .rotation, at: ._20ms)
            print("enabled")
        }
    }
    
    /// Disables all of the sensors.
    func stopListeningForSensors() {
        session.device?.configureSensors { config in
            config.disableAll()
        }
    }
    
}

extension BoseHandler: SensorDispatchHandler {

    func receivedRotation(quaternion: Quaternion, accuracy: QuaternionAccuracy, timestamp: SensorTimestamp) {

                
        //   rad -> deg
        func degrees(fromRadians radians: Double) -> Double {
            return radians * 180.0 / .pi
        }
        
        // If needed, use the current yaw as the offset so the sound direction is directly in front
        if yawOffset == nil {
            yawOffset = degrees(fromRadians: quaternion.zRotation)
        }
        var yaw = Float(degrees(fromRadians: quaternion.zRotation) - yawOffset!)
        
        //Wrap around whatever the offset could have done, to bring the angle back in range.
        while yaw < -180.0 {
            yaw += 360.0
        }
        
        while yaw > 180 {
            yaw -= 360
        }
        
        let pitch = Float(degrees(fromRadians: quaternion.xRotation))
        let roll = Float(degrees(fromRadians: quaternion.yRotation))
        
//        print("pppitch", pitch)
        
//        // Update the listerner position in space
//        audioEnvironment.listenerAngularOrientation = AVAudioMake3DAngularOrientation(yaw, pitch, roll)
        self.delegate?.updateRotation(yaw: yaw, pitch: pitch, roll: roll)

    }

}

// MARK: - WearableDeviceSessionDelegate

extension BoseHandler: WearableDeviceSessionDelegate {
    func sessionDidOpen(_ session: WearableDeviceSession) {
        // This view controller is only shown after the session has successfully
        // opened. It is dismissed when the session closes. We don't need to do
        // anything here.
    }

    func session(_ session: WearableDeviceSession, didFailToOpenWithError error: Error) {
        // This view controller is only shown after the session has successfully
        // opened. It is dismissed when the session closes. We don't need to do
        // anything here.
    }

    func session(_ session: WearableDeviceSession, didCloseWithError error: Error) {
        // The session was closed, possibly due to an error.
        dismiss(dueTo: error, isClosing: true)

        // Unblock this view controller's UI.
        suspensionOverlay?.removeFromSuperview()
    }

    func sessionDidClose(_ session: WearableDeviceSession) {
        dismiss(dueTo: nil, isClosing: true)

        // Unblock this view controller's UI.
        suspensionOverlay?.removeFromSuperview()
    }
}

extension BoseHandler {
    func searchDevices(){
        // Perform the device search and connect to the selected device. This
        // may present a view controller on a new UIWindow.
        BoseWearable.shared.startConnection(mode: .alwaysShow) { result in
            switch result {
            case .success(let session):
                // A device was selected, a session was created and opened. Show
                // a view controller that will become the session delegate.
                self.showMainController(for: session)
                
            case .failure(let error):
                // An error occurred when searching for or connecting to a
                // device. Present an alert showing the error.
//                self.show(error)
                self.delegate?.showError(error)
                
            case .cancelled:
                // The user cancelled the search operation.
                break
            }
        }
    }
    
    private func showMainController(for session: WearableDeviceSession) {
        
        let vc = ContainerViewController()
        vc.session = session
        
        delegate?.presentController(vc)
    }
}

protocol BoseHandlerDelegate: class {
    
    func showError(_ error: (Error))
    func presentController(_ vc: ContainerViewController)
    func navigationShowError(_ error: Error?, _ pop: @escaping ()->())
    func navigationPopToRoot()
    func navigationShowAlert(_ pop: @escaping ()->())
    func updateRotation(yaw: Float, pitch: Float, roll: Float)
}
