//
//  ViewController.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import UIKit
import BoseWearable
import FirebaseUI

class LoginViewController: UIViewController {
    
    @IBOutlet var simulatedSwitch: UISwitch!
    @IBOutlet var needSignIn: UILabel!
    
    private var activityIndicator: ActivityIndicator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addBackground(imageName: "LogInScreen")
        activityIndicator = nil
        
    }
    
    @IBAction func signinTapped(_ sender: Any) {
        
        // Create default Auth UI
        let authUI = FUIAuth.defaultAuthUI()
        
        // Check that it isn't nil
        guard authUI != nil else {
            return
        }
        
        // Set delegate and specify sign in options
        authUI?.delegate = self
        authUI?.providers = [FUIEmailAuth()]
        
        // Get the auth view controller and present it
        let authViewController = authUI!.authViewController()
        present(authViewController, animated: true, completion: nil)

    }

    private func showMainController(for session: WearableDeviceSession) {
        // Block this view controller's UI before showing the modal search.
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        let vc = ContainerViewController()
        vc.session = session
        
        self.present(vc, animated: true, completion: nil)
        // Unblock the UI
        self.activityIndicator?.removeFromSuperview()
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
            // Unblock the UI
            self.activityIndicator?.removeFromSuperview()
        }
    }
    
    func simulator(){
        // Instead of using a session for a remote device, create a session for a
        // simulated device.
        showMainController(for: BoseWearable.shared.createSimulatedWearableDeviceSession())
    }
}

extension LoginViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        // Check for error
        guard error == nil else {
            return
        }
        
        if simulatedSwitch.isOn {
            searchDevices()
        }else{
            simulator()
        }
        
    }
    
}




