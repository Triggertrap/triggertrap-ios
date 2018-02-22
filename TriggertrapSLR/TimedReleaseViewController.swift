//
//  TimedReleaseViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class TimedReleaseViewController: CableReleaseViewController, TTNumberInputDelegate, TTKeyboardDelegate {
    
    @IBOutlet weak var numberInputView: TTTimeInput!
    @IBOutlet weak var ndCalculatorImageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = ndCalculatorImageView.image {
            ndCalculatorImageView.image = ImageWithColor(image, color: UIColor.triggertrap_primaryColor())
        }
        
        setupNumberPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check whether settings manager pulse length has been changed and it is less than the numberInputView value
        if self.numberInputView.savedValue(forKey: "timeCableRelease-duration") < (settingsManager?.pulseLength.uint64Value)!  {
            self.numberInputView.saveValue((settingsManager?.pulseLength.uint64Value)! , forKey: "timeCableRelease-duration")
        }
        
        // Load the previous value
        self.numberInputView.value = self.numberInputView.savedValue(forKey: "timeCableRelease-duration")
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        WearablesManager.sharedInstance.delegate = nil
    }
    
    // MARK: - Theme
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        if let image = ndCalculatorImageView.image {
            ndCalculatorImageView.image = ImageWithColor(image, color: UIColor.triggertrap_primaryColor())
        }
        
        applyThemeUpdateToTimeInput(numberInputView)
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            
            if sufficientVolumeToTrigger() {
                sequenceManager.activeViewController = self 
                
                //Show red view
                showFeedbackView(ConstStoryboardIdentifierCableReleaseFeedbackView)
                
                //Setup counter label and circle timer so that they are populated when red view animates
                feedbackViewController.counterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue;
                feedbackViewController.counterLabel?.startValue = self.numberInputView.value
                
                feedbackViewController.circleTimer?.cycleDuration = Double(self.numberInputView.value) / 1000.0
                feedbackViewController.circleTimer?.continuous = false
                feedbackViewController.circleTimer?.progress = 1.0
                feedbackViewController.circleTimer?.progressDirection = kProgressDirection.progressDirectionAntiClockwise.rawValue
            }
            
        } else {
            sequenceManager.cancel()
        }
    }
    
    @IBAction func ndCalculatorTapped(_ button: UIButton) {
        print("ND Calculator button tapped")
        
        let storyboard = UIStoryboard(name: ConstStoryboardIdentifierCalculators, bundle: Bundle.main)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "ND Calculator") as! NeutralDensityCalculatorViewController
        viewController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        viewController.isEmbedded = true
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.isTranslucent = false

        navigationController.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
        
        navigationController.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.triggertrap_metric_regular(23.0), NSForegroundColorAttributeName: UIColor.triggertrap_iconColor(1.0)]
 
        
        viewController.ndCalculatorCompletionBlock = ({ duration in
            self.numberInputView.saveValue(duration, forKey: "timeCableRelease-duration")
        })
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func openKeyboard(_ sender : TTTimeInput) {
        adjustMinVal()
        sender.openKeyboard(in: self.view, covering: self.bottomRightView)
    }
    
    // MARK: - Overrides
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is TimedReleaseViewController {
            
            let duration = NSNumber(value: self.numberInputView.value as UInt64)
            
            prepareForSequence()
            
            //Start sequence
            self.sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: duration.doubleValue, unit: .milliseconds))]), repeatSequence: false)
            
            feedbackViewController.startAnimations()
        }
    }
    
    // MARK: - Private
    
    func setupNumberPicker() {
        self.numberInputView.ttKeyboardDelegate = self
        self.numberInputView.delegate = self
        self.numberInputView.maxValue = 359999990
        self.numberInputView.value = 30000
        adjustMinVal()
        self.numberInputView.displayView.textAlignment = NSTextAlignment.center
    }
    
    func adjustMinVal() {
        self.numberInputView.minValue = SettingsManager.sharedInstance().pulseLength.uint64Value
    }
    
    // MARK: - TTNumberInputKeyboard Delegate
    
    func ttNumberInputKeyboardDidDismiss() {
        self.numberInputView.saveValue(self.numberInputView.value, forKey: "timeCableRelease-duration")
    }
}

extension TimedReleaseViewController: WearableManagerDelegate {
    
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton())
    }
}
