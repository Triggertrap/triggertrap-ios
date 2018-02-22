//
//  NavigationControllerDelegate.swift
//  CircleTransition
//
//  Created by Rounak Jain on 23/10/14.
//  Copyright (c) 2014 Rounak Jain. All rights reserved.
//

import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    @IBOutlet weak var navigationController: UINavigationController?
  
    var shouldComplete: Bool = false
    var interactionController: UIPercentDrivenInteractiveTransition?
    var initialDirectionIsRight = false
    
    var interactionDisabled: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(NavigationControllerDelegate.panned(_:)))
        self.navigationController!.view.addGestureRecognizer(panGesture)
    }
  
    @IBAction func panned(gestureRecognizer: UIPanGestureRecognizer) {
        
        if interactionDisabled {
            print("Interaction Disabled - Animation is still in process", terminator: "")
            return
        }
        
        let velocity = gestureRecognizer.velocityInView(self.navigationController!.view)
        let rightDirection = velocity.x < 0 ? true : false
        
        switch gestureRecognizer.state {
            case .Began:
            initialDirectionIsRight = rightDirection
            
            if !rightDirection && self.navigationController?.topViewController!.isKindOfClass(KitSelectorViewController) != true && self.navigationController?.topViewController!.isKindOfClass(CameraSelectorViewController) != true && self.navigationController?.topViewController!.isKindOfClass(SplashViewController) != true {
                self.interactionController = UIPercentDrivenInteractiveTransition()
                self.navigationController?.popViewControllerAnimated(true)
            } else if rightDirection && self.navigationController?.topViewController!.isKindOfClass(TestTriggertViewController) != true  {
                self.interactionController = UIPercentDrivenInteractiveTransition()
                self.navigationController?.topViewController!.performSegueWithIdentifier("PushSegue", sender: nil)
            }
                
            case .Changed:
                
                if let interactionController = self.interactionController {
                    
                    let translation = gestureRecognizer.translationInView(self.navigationController!.view)
                    
                    let dragAmount: CGFloat = self.navigationController!.view.frame.width / 2
                    let threshold: CGFloat = 0.5
                    
                    var percent = translation.x / dragAmount
                    var multiplier: CGFloat = 1.0
                    
                    // User's initial swipe is the same direction as the current one
                    if initialDirectionIsRight == rightDirection {
                        
                        multiplier = translation.x < 0 ? -1.0 : 1.0
                    // User changed the direction of swiping
                    } else {
                        if translation.x < 0 && !rightDirection {
                            multiplier = -1.0
                        } else if translation.x > 0 && rightDirection {
                            multiplier = 1.0
                        } else {
                            multiplier = 0
                        }
                    }

                    percent *= multiplier
                    percent = fmax(percent, 0.0)
                    percent = fmin(percent, 0.99) 
                    
                    interactionController.updateInteractiveTransition(percent)
                    shouldComplete = percent >= threshold
                }
                
            case .Ended:
                if let interactionController = self.interactionController {
                    if shouldComplete == false {
                        interactionController.cancelInteractiveTransition()
                        interactionDisabled = false
                    } else {
                        interactionController.finishInteractiveTransition()
                        interactionDisabled = true
                    }
                    
                    self.interactionController = nil
                }
                
            default:
                if let interactionController = self.interactionController {
                    interactionController.cancelInteractiveTransition()
                    self.interactionController  = nil
                    interactionDisabled = false
                }
            }
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) { 
        interactionDisabled = false
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        print("From VC: \(fromVC) To VC: \(toVC)", terminator: "")
        
        // Stage 1 transitions
        if fromVC.isKindOfClass(KitSelectorViewController) && toVC.isKindOfClass(CameraSelectorViewController) {
            
            print("KitToCameraSelectorTransition", terminator: "")
            return KitToCameraSelectorTransition()
            
        } else if fromVC.isKindOfClass(KitSelectorViewController) && toVC.isKindOfClass(ConnectKitViewController) {
            print("KitToConnectTransition Push", terminator: "")
            
            let transition = KitToConnectTransition()
            transition.state = KitToConnectTransition.State.Push
            return transition
            
        } else if fromVC.isKindOfClass(ConnectKitViewController) && toVC.isKindOfClass(KitSelectorViewController) {
            
            print("KitToConnectTransition Pop", terminator: "")
            let transition = KitToConnectTransition()
            transition.state = KitToConnectTransition.State.Pop
            return transition
            
        } else if fromVC.isKindOfClass(CameraSelectorViewController) && toVC.isKindOfClass(ConnectKitViewController) {
            
            print("CameraSelectorToConnectTransition Push", terminator: "")
            let transition = CameraSelectorToConnectTransition()
            transition.state = CameraSelectorToConnectTransition.State.Push
            return transition
            
        } else if fromVC.isKindOfClass(ConnectKitViewController) && toVC.isKindOfClass(CameraSelectorViewController) {
            
            print("CameraSelectorToConnectTransition Pop", terminator: "")
            let transition = CameraSelectorToConnectTransition()
            transition.state = CameraSelectorToConnectTransition.State.Pop
            return transition
            
        } else if fromVC.isKindOfClass(ConnectKitViewController) && toVC.isKindOfClass(VolumeViewController) {
            
            print("ConnectToVolumeTransition Push", terminator: "")
            let transition = ConnectToVolumeTransition()
            transition.state = ConnectToVolumeTransition.State.Push
            return transition
            
        } else if fromVC.isKindOfClass(VolumeViewController) && toVC.isKindOfClass(ConnectKitViewController) {
            
            print("ConnectToVolumeTransition Pop", terminator: "")
            let transition = ConnectToVolumeTransition()
            transition.state = ConnectToVolumeTransition.State.Pop
            return transition
            
        } else if fromVC.isKindOfClass(VolumeViewController) && toVC.isKindOfClass(CameraViewController) {
            
            print("VolumeToCameraTransition Push", terminator: "")
            let transition = VolumeToCameraTransition()
            transition.state = VolumeToCameraTransition.State.Push
            return transition
            
        } else if fromVC.isKindOfClass(CameraViewController) && toVC.isKindOfClass(VolumeViewController) {
            
            print("VolumeToCameraTransition Pop", terminator: "")
            let transition = VolumeToCameraTransition()
            transition.state = VolumeToCameraTransition.State.Pop
            return transition
            
        } else if fromVC.isKindOfClass(CameraViewController) && toVC.isKindOfClass(ManualFocusViewController) {
            
            print("CameraToManualFocusTransition Push", terminator: "")
            let transition = CameraToManualFocusTransition()
            transition.state = CameraToManualFocusTransition.State.Push
            return transition
            
        }  else if fromVC.isKindOfClass(ManualFocusViewController) && toVC.isKindOfClass(CameraViewController) {
            
            print("CameraToManualFocusTransition Pop", terminator: "")
            let transition = CameraToManualFocusTransition()
            transition.state = CameraToManualFocusTransition.State.Pop
            return transition
            
        } else if fromVC.isKindOfClass(ManualFocusViewController) && toVC.isKindOfClass(TestTriggertViewController) {
            
            print("ManualFocusToTestTriggerTransition Push", terminator: "")
            let transition = ManualFocusToTestTriggerTransition()
            transition.state = ManualFocusToTestTriggerTransition.State.Push
            return transition
            
        } else if fromVC.isKindOfClass(TestTriggertViewController) && toVC.isKindOfClass(ManualFocusViewController) {
            
            print("ManualFocusToTestTriggerTransition Pop", terminator: "")
            let transition = ManualFocusToTestTriggerTransition()
            transition.state = ManualFocusToTestTriggerTransition.State.Pop
            return transition
            
        } else if fromVC.isKindOfClass(SplashViewController) && toVC.isKindOfClass(KitSelectorViewController) {
            
            // Use custom transition here if needed between the splash view controller and the kit selector view controller
            
            return nil
        }
        
        print("Nil", terminator: "")
        return nil
    }
  
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionController
    }
}
