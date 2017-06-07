
//
//  VolumeViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 27/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class VolumeViewController: OnboardingViewController {
    
    @IBOutlet var whiteViewDescriptionLabel: UILabel!
    @IBOutlet var whiteViewTitleLabel: UILabel!
    
    @IBOutlet var separatorLine: UIView!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var plugView: UIView! // For transition
    @IBOutlet var donglePlugImageView: UIImageView!
    
    @IBOutlet var phoneImageView: UIImageView! // For transition
    
    @IBOutlet var informationView: UIView!
    @IBOutlet var greyViewInformationLabel: UILabel! // For transition
    @IBOutlet var greyViewPraiseLabel: UILabel! // For transition
    
    @IBOutlet var dongleCableView: DongleCableView!
    
    @IBOutlet var dongleView: UIView!
    @IBOutlet var dongleBodyTopImageView: UIImageView!
    
    // Volume VC to Camera VC
    
    @IBOutlet var cameraCableView: DongleCableView!
    @IBOutlet var cameraView: UIImageView!
    @IBOutlet var cameraConnectorBodyImageView: UIImageView!
    @IBOutlet var dongleCoilImageView: UIImageView!
    
    @IBOutlet var cameraCoilImageView: UIImageView!
    @IBOutlet var cameraConnectorView: UIView!
    
    @IBOutlet var dismissButton: UIButton!
    
    private var currentPercent: Float = 50.0
    private var myVolumeView: MPVolumeView!
    
    dynamic var audioSession = AVAudioSession.sharedInstance()
    private var outputVolume = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        whiteViewDescriptionLabel.text = NSLocalizedString("Set to 100%", comment: "Set to 100%")
        
        // Add MPVolumeView to the view and hide it (needed to read the volume level of the device)
        myVolumeView = MPVolumeView(frame: self.view.bounds)
        myVolumeView.hidden = true
        self.view.addSubview(myVolumeView)
        
        do {
           try audioSession.setActive(true)
        } catch {
            print("Error: \(error)")
        }
         
        setVolumeLabel()
        
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.New, context: &outputVolume)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDongleCableView()
        updateCameraCableView()
    }
    
    deinit {
        self.audioSession.removeObserver(self, forKeyPath: "outputVolume", context: &outputVolume)
    }
    
    // MARK: - Private
    
    private func updateDongleCableView() {
        let plugCenter = dongleCableView.convertPoint(donglePlugImageView.center, fromView: plugView)
        let dongleCenter = dongleCableView.convertPoint(dongleBodyTopImageView.center, fromView: dongleView)
        
        dongleCableView.point1 = CGPoint(x: plugCenter.x, y: plugCenter.y + donglePlugImageView.frame.size.height / 2 + 2)
        dongleCableView.point2 = CGPoint(x: dongleCenter.x, y: dongleCenter.y - dongleBodyTopImageView.frame.size.height / 2 - 2)
        
        dongleCableView.addShapeLayer()
    }
    
    private func updateCameraCableView() {
        
        let plugCenter = cameraCableView.convertPoint(cameraConnectorBodyImageView.center, fromView: cameraConnectorView)
        
        let dongleCenter = cameraCoilImageView.convertPoint(cameraCoilImageView.frame.origin, fromView: cameraCoilImageView)
        
        cameraCableView.point1 = CGPoint(x: plugCenter.x + 5, y: plugCenter.y + cameraConnectorBodyImageView.frame.size.height / 2 + 2)
        cameraCableView.point2 = CGPoint(x: dongleCenter.x + 6, y: dongleCenter.y + cameraCoilImageView.frame.size.height - 6)
        cameraCableView.bezierType = DongleCableView.BezierPathType.Camera
        cameraCableView.addShapeLayer()
    }
    
    private func setVolumeLabel() {
        if audioSession.outputVolume >= 1.0 {
            currentPercent = 100.0
        } else {
            currentPercent = audioSession.outputVolume * 100.0
        }
        
        currentPercent = 10.0 * floor((currentPercent / 10.0) + 0.5)
        whiteViewTitleLabel.text = String(format: NSLocalizedString("Current volume: %.0f%%", comment: "Current volume: %.0f%%"), currentPercent)
    }
    
    
    // MARK: - KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
         
        if context == &outputVolume {
            setVolumeLabel()
        }
    }
}
