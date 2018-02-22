//
//  UIFont.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 22/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit


public extension UIFont {
    class func triggertrap_metric_regular (size: CGFloat = 20.0) -> UIFont { return UIFont.systemFontOfSize(size, weight: UIFontWeightRegular)} //UIFont(name: "Metric-Regular", size: size)
    class func triggertrap_metric_light (size: CGFloat = 20.0) -> UIFont { return UIFont.systemFontOfSize(size, weight: UIFontWeightLight)} //UIFont(name: "Metric-Light", size: size)
    class func triggertrap_metric_bold (size: CGFloat = 20.0) -> UIFont { return UIFont.systemFontOfSize(size, weight: UIFontWeightBold)} //UIFont(name: "Metric-Semibold", size: size)
    class func triggertrap_openSans_regular (size: CGFloat = 20.0) -> UIFont { return UIFont(name: "OpenSans", size: size)!} //UIFont(name: "OpenSans", size: size)
    class func triggertrap_openSans_bold (size: CGFloat = 20.0) -> UIFont { return UIFont(name: "OpenSans-Bold", size: size)!} //UIFont(name: "OpenSans-Bold", size: size)
}