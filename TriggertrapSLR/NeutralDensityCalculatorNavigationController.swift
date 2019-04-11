//
//  NeutralDensityCalculatorNavigationController.swift
//  TriggertrapSLR
//
//  Created by Alex Taffe on 10/22/18.
//  Copyright © 2018 Triggertrap Limited. All rights reserved.
//

import UIKit

class NeutralDensityCalculatorNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return AppTheme() == .normal ? .lightContent : .default
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
