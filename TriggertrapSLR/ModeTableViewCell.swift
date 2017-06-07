//
//  ModeTableViewCell.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 19/10/2015.
//  Copyright © 2015 Triggertrap Limited. All rights reserved.
//

import UIKit

class ModeTableViewCell: BFPaperTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var square: UIView!
    @IBOutlet weak var separatorView: SeparatorView!
    
    var wearablesSupported = false
    var remoteSupported = false
    var identifier: String?
}
