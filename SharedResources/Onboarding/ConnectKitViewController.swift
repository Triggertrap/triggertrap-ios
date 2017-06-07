//
//  ConnectKitViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 27/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class ConnectKitViewController: OnboardingViewController {
    
    // White view
    
    @IBOutlet var separatorLine: UIView!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var informationView: UIView!
    @IBOutlet var greyViewInformationLabel: UILabel! // For transition
    @IBOutlet var greyViewPraiseLabel: UILabel! // For transition
    
    @IBOutlet var phoneImageView: UIImageView! // For transition
    @IBOutlet var dongleCableView: DongleCableView! // For transition
    
    @IBOutlet var plugedInView: UIView!
    @IBOutlet var plugView: UIView!
    
    @IBOutlet var donglePlugImageView: UIImageView!
    @IBOutlet var dongleBodyTopImageView: UIImageView!
    
    @IBOutlet var dongleView: UIView!

    @IBOutlet var dongleCoilImageView: UIImageView!
    
    @IBOutlet var dismissButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDongleCableView()
    }
    
    func updateDongleCableView() {
        let plugCenter = dongleCableView.convertPoint(donglePlugImageView.center, fromView: plugView)
        let dongleCenter = dongleCableView.convertPoint(dongleBodyTopImageView.center, fromView: dongleView)
        
        dongleCableView.point1 = CGPoint(x: plugCenter.x, y: plugCenter.y + donglePlugImageView.frame.size.height / 2 + 2)
        dongleCableView.point2 = CGPoint(x: dongleCenter.x, y: dongleCenter.y - dongleBodyTopImageView.frame.size.height / 2 - 2)
        
        dongleCableView.addShapeLayer()
    }
}
