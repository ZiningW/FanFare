//
//  LaunchScreenViewController.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import UIKit
import BoseWearable
import FirebaseUI


class LaunchScreenViewController: UIViewController{
  
    private var activityIndicator: ActivityIndicator?
    private var userName: String = "None"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.addBackground(imageName: "LaunchScreen")
        userName = Auth.auth().currentUser?.displayName ?? "None"
        
        if userName == "None"{
            showLogInController()
        } else {
            simulator()
        }
    }
    
    private func showLogInController() {

        guard let vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
            fatalError("Cannot instantiate view controller")
        }
        show(vc, sender: self)
        
    }
    
    private func showMainController(for session: WearableDeviceSession) {
        
        let vc = ContainerViewController()
        vc.session = session
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func searchDevices(){
        // Block this view controller's UI before showing the modal search.
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        
        // Perform the device search and connect to the selected device. This
        // may present a view controller on a new UIWindow.
        BoseWearable.shared.startConnection(mode: .connectToLast(timeout: 5)) { result in
            switch result {
            case .success(let session):
                // A device was selected, a session was created and opened. Show
                // a view controller that will become the session delegate.
                self.showMainController(for: session)
                
            case .failure(let error):
                // An error occurred when searching for or connecting to a
                // device. Present an alert showing the error.
                self.show(error)
                self.simulator()
                
            case .cancelled:
                // The user cancelled the search operation.
                break
            }
        }
        self.activityIndicator?.removeFromSuperview()
    }
    
    func simulator(){
        // Instead of using a session for a remote device, create a session for a
        // simulated device.
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        showMainController(for: BoseWearable.shared.createSimulatedWearableDeviceSession())
        self.activityIndicator?.removeFromSuperview()
    }
    
    
}
