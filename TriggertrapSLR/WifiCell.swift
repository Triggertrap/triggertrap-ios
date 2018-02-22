//
//  WifiCell.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 16/10/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class WifiCell: UICollectionViewCell {
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var connectedImage: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    
    override var bounds : CGRect {
        didSet {
            // Fix autolayout constraints broken in Xcode 6 GM + iOS 7.1
            self.contentView.frame = bounds
        }
    }
    
    var deviceConnected: Bool = false {
        didSet {
            if deviceConnected {
                connectedImage.isHidden = false
            } else {
                connectedImage.isHidden = true
            }
            
            self.backgroundColor = UIColor.triggertrap_fillColor()
            deviceName.textColor = UIColor.triggertrap_accentColor()
            separatorView.backgroundColor = UIColor.triggertrap_foregroundColor()
            deviceImage.image = ImageWithColor(UIImage(named: "wifiMaster")!, color: UIColor.triggertrap_primaryColor())
            connectedImage.image = ImageWithColor(UIImage(named: "wifiRedTick")!, color: UIColor.triggertrap_primaryColor())
        }
    }
}
