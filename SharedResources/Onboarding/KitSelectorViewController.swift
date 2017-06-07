//
//  KitSelectorViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 27/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class KitSelectorViewController: OnboardingViewController {
     
    @IBOutlet var kitImageView: UIImageView!
    
    @IBOutlet var whiteViewDescriptionLabel: UILabel!
    @IBOutlet var whiteViewTitleLabel: UILabel!
    @IBOutlet var notYetButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var separatorLine: UIView!
    
    // Information view
    
    @IBOutlet var informationView: UIView!
    @IBOutlet var greyViewInformationLabel: UILabel!
    @IBOutlet var greyViewPraiseLabel: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var dismissButton: UIButton!
}
