//
//  LeftPanelViewController.swift
//  MeerKatSentinel
//
//  Created by Zining Wang on 6/22/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import BoseWearable

class LeftPanelViewController: UIViewController {
    
    var selfName: String?
    var deviceName: String?
    var deviceState: WearableDeviceSessionState = .closed
    
    @IBOutlet weak var selfNameOutlet: UILabel!
    @IBOutlet weak var deviceOutput: UILabel!
    @IBOutlet weak var logOutButton: ImageButton!
    @IBOutlet weak var switchDeviceOutput: leftLabelButton!
    
    @IBOutlet weak var disconnectDeviceImage: ImageButton!
    @IBOutlet weak var switchDeviceImage: ImageButton!
    @IBOutlet weak var disconnectDeviceOutput: leftLabelButton!
    
    var delegate: LeftPanelViewControllerDelegate?
    
    private var activityIndicator: ActivityIndicator?    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addBackground(imageName: "LeftPullOut")
        selfNameOutlet.text = selfName
        
        if deviceState == .closed {
            deviceOutput.text = "Not Connected"
            deviceOutput.textColor = UIColor.red
            switchDeviceOutput.setTitle("Connect to Device", for: .normal)
            disconnectDeviceOutput.setTitle("Use Simulator", for: .normal)

        } else {
            deviceOutput.text = deviceName
            deviceOutput.textColor = UIColor.green
            switchDeviceOutput.setTitle("Switch Device", for: .normal)
            disconnectDeviceOutput.setTitle("Disconnect Device", for: .normal)
            
        }
        
        logOutButton.setNewImage("logout")
        disconnectDeviceImage.setNewImage("power-button-off")
        switchDeviceImage.setNewImage("sort")

        self.view.addSubview(logOutButton)
        
    }
    
    @IBAction func logOut(_ sender: Any) {
        delegate?.logOut()
    }
    
    @IBAction func switchDevice(_ sender: Any) {
        delegate?.stopSensors()
        searchDevices()
    }
    @IBAction func disconnectDevice(_ sender: Any) {
        delegate?.stopSensors()
        simulator()
    }
    
    func searchDevices(){
        // Block this view controller's UI before showing the modal search.
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        
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
                self.show(error)
                
            case .cancelled:
                // The user cancelled the search operation.
                break
            }
            
            // Unblock the UI
            self.activityIndicator?.removeFromSuperview()
        }
    }
    
    private func showMainController(for session: WearableDeviceSession) {
        
        let vc = ContainerViewController()
        vc.session = session
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func simulator(){
        // Instead of using a session for a remote device, create a session for a
        // simulated device.
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        showMainController(for: BoseWearable.shared.createSimulatedWearableDeviceSession())
    }

}

protocol LeftPanelViewControllerDelegate {
    func stopSensors()
    func logOut()
}

