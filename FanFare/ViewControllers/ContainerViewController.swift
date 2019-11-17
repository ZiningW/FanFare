//
//  ContainerViewController.swift
//  FanFare
//
//  Created by Zining Wang on 11/14/19.
//  Copyright © 2019 Zining Wang. All rights reserved.
//

import UIKit
import BoseWearable
import simd

class ContainerViewController: UIViewController {
    enum SlideOutState {
        case bothCollapsed
        case leftPanelExpanded
        case rightPanelExpanded
    }
    
    let fBaseHandler = FirebaseHandler()
    let boseHandler = BoseHandler()
    
    var centerNavigationController: UINavigationController!
    
    var mainViewController: MainViewController!
    var bottomViewController: BottomPanelViewController!
    
    var session: WearableDeviceSession!
    
    var currentState: SlideOutState = .bothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .bothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    var leftViewController: LeftPanelViewController?
    var rightViewController: RightPanelViewController?
    
    let centerPanelExpandedOffset: CGFloat = 90
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fBaseHandler.trackArray.removeAll()
        fBaseHandler.processTrackList()
        boseHandler.session = session
        boseHandler.initBoseSession()
        
        
        mainViewController = UIStoryboard.mainViewController()
        mainViewController.delegate = self
        mainViewController.fBaseHandler = fBaseHandler
        mainViewController.boseHandler = boseHandler
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: mainViewController)
        centerNavigationController.setNavigationBarHidden(true, animated: true)
        view.addSubview(centerNavigationController.view)
        addChild(centerNavigationController)
        
        centerNavigationController.didMove(toParent: self)
        
      
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)

    }
}

extension ContainerViewController {
    func addBottomPanel(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BottomViewController") as! BottomPanelViewController
        self.view.addSubview(vc.view)
        addChild(vc)
        vc.didMove(toParent: self)
    }
}

private extension UIStoryboard {
    static func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    static func leftViewController() -> LeftPanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? LeftPanelViewController
    }
    
    static func rightViewController() -> RightPanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "RightViewController") as? RightPanelViewController
    }
    
    static func mainViewController() -> MainViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
    }
}

// MARK: CenterViewController delegate

extension ContainerViewController: MainViewControllerDelegate {
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        
        guard leftViewController == nil else { return }
        
        if let vc = UIStoryboard.leftViewController() {
            vc.selfName = fBaseHandler.selfUserName
            vc.deviceName = session.device?.name
            
            if session.state != boseHandler.sessionState{
                vc.deviceState = boseHandler.sessionState!
            }else {
                vc.deviceState = session.state
            }
            addChildLeftSidePanelController(vc)
            leftViewController = vc
        }
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if shouldExpand {
            
            currentState = .leftPanelExpanded
            animateCenterPanelXPosition(
                targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { _ in
                self.currentState = .bothCollapsed
                self.leftViewController?.view.removeFromSuperview()
                self.leftViewController = nil
            }
        }
    }
    
    func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != .rightPanelExpanded)
        
        if notAlreadyExpanded {
            addRightPanelViewController()
            
        }
        
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addRightPanelViewController() {
        
        guard rightViewController == nil else { return }
        
        if let vc = UIStoryboard.rightViewController() {
            let trackArray = fBaseHandler.getTrackList()
            vc.track = trackArray
            vc.fBaseHandler = fBaseHandler
            addChildSidePanelController(vc)
            rightViewController = vc
        }
    }
    
    func animateRightPanel(shouldExpand: Bool) {
        
        if shouldExpand {
            currentState = .rightPanelExpanded
            
            animateCenterPanelXPosition(
                targetPosition: -centerNavigationController.view.frame.width + centerPanelExpandedOffset)
        } else {
            
            animateCenterPanelXPosition(targetPosition: 0) { _ in
                self.currentState = .bothCollapsed
                
                self.rightViewController?.view.removeFromSuperview()
                self.rightViewController = nil
            }
            
        }
    }

    func collapseSidePanels() {
        switch currentState {
        case .rightPanelExpanded:
            toggleRightPanel()
            
        case .leftPanelExpanded:
            toggleLeftPanel()
            
        default:
            break
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut, animations: {
                        self.centerNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func addChildSidePanelController(_ sidePanelController: RightPanelViewController) {
        sidePanelController.delegate = mainViewController
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChild(sidePanelController)
        sidePanelController.didMove(toParent: self)
    }
    
    func addChildLeftSidePanelController(_ sidePanelController: LeftPanelViewController) {
        sidePanelController.delegate = mainViewController
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChild(sidePanelController)
        sidePanelController.didMove(toParent: self)
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if shouldShowShadow {
            centerNavigationController.view.layer.shadowOpacity = 0.8
            mainViewController.view.isUserInteractionEnabled = false
            
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
            mainViewController.view.isUserInteractionEnabled = true
            
        }
    }
}

// MARK: Gesture recognizer

extension ContainerViewController: UIGestureRecognizerDelegate {
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        
        switch recognizer.state {
        case .began:
            if currentState == .bothCollapsed {
                if gestureIsDraggingFromLeftToRight {
                    addLeftPanelViewController()
                } else {
                    addRightPanelViewController()
                }
                
                showShadowForCenterViewController(true)
            } 
        case .changed:
            if let rview = recognizer.view {
                rview.center.x = rview.center.x + recognizer.translation(in: view).x
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
            

        case .ended:
            if let _ = leftViewController,
                let rview = recognizer.view {
                // animate the side panel open or closed based on whether the view
                // has moved more or less than halfway
                let hasMovedGreaterThanHalfway = rview.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            } else if let _ = rightViewController,
                let rview = recognizer.view {
                let hasMovedGreaterThanHalfway = rview.center.x < 0
                animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
            
        default:
            break
        }
    }
    
    
}

