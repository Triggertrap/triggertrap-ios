
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
    
    fileprivate var currentPercent: Float = 50.0
    fileprivate var myVolumeView: MPVolumeView!
    
    @objc dynamic var audioSession = AVAudioSession.sharedInstance()
    fileprivate var outputVolume = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        whiteViewDescriptionLabel.text = NSLocalizedString("Set to 100%", comment: "Set to 100%")
        
        // Add MPVolumeView to the view and hide it (needed to read the volume level of the device)
        myVolumeView = MPVolumeView(frame: self.view.bounds)
        myVolumeView.isHidden = true
        self.view.addSubview(myVolumeView)
        
        do {
           try audioSession.setActive(true)
        } catch {
            print("Error: \(error)")
        }
         
        setVolumeLabel()
        
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: &outputVolume)
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
    
    fileprivate func updateDongleCableView() {
        let plugCenter = dongleCableView.convert(donglePlugImageView.center, from: plugView)
        let dongleCenter = dongleCableView.convert(dongleBodyTopImageView.center, from: dongleView)
        
        dongleCableView.point1 = CGPoint(x: plugCenter.x, y: plugCenter.y + donglePlugImageView.frame.size.height / 2 + 2)
        dongleCableView.point2 = CGPoint(x: dongleCenter.x, y: dongleCenter.y - dongleBodyTopImageView.frame.size.height / 2 - 2)
        
        dongleCableView.addShapeLayer()
    }
    
    fileprivate func updateCameraCableView() {
        
        let plugCenter = cameraCableView.convert(cameraConnectorBodyImageView.center, from: cameraConnectorView)
        
        let dongleCenter = cameraCoilImageView.convert(cameraCoilImageView.frame.origin, from: cameraCoilImageView)
        
        cameraCableView.point1 = CGPoint(x: plugCenter.x + 5, y: plugCenter.y + cameraConnectorBodyImageView.frame.size.height / 2 + 2)
        cameraCableView.point2 = CGPoint(x: dongleCenter.x + 6, y: dongleCenter.y + cameraCoilImageView.frame.size.height - 6)
        cameraCableView.bezierType = DongleCableView.BezierPathType.camera
        cameraCableView.addShapeLayer()
    }
    
    fileprivate func setVolumeLabel() {
        if audioSession.outputVolume >= 1.0 {
            currentPercent = 100.0
        } else {
            currentPercent = audioSession.outputVolume * 100.0
        }
        
        currentPercent = 10.0 * floor((currentPercent / 10.0) + 0.5)
        whiteViewTitleLabel.text = String(format: NSLocalizedString("Current volume: %.0f%%", comment: "Current volume: %.0f%%"), currentPercent)
    }
    
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         
        if context == &outputVolume {
            setVolumeLabel()
        }
    }
}
