//
//  UIFont.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 22/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit


public extension UIFont {
    class func triggertrap_metric_regular (_ size: CGFloat = 20.0) -> UIFont { return UIFont.systemFont(ofSize: size, weight: UIFontWeightRegular)} //UIFont(name: "Metric-Regular", size: size)
    class func triggertrap_metric_light (_ size: CGFloat = 20.0) -> UIFont { return UIFont.systemFont(ofSize: size, weight: UIFontWeightLight)} //UIFont(name: "Metric-Light", size: size)
    class func triggertrap_metric_bold (_ size: CGFloat = 20.0) -> UIFont { return UIFont.systemFont(ofSize: size, weight: UIFontWeightBold)} //UIFont(name: "Metric-Semibold", size: size)
    class func triggertrap_openSans_regular (_ size: CGFloat = 20.0) -> UIFont { return UIFont(name: "OpenSans", size: size)!} //UIFont(name: "OpenSans", size: size)
    class func triggertrap_openSans_bold (_ size: CGFloat = 20.0) -> UIFont { return UIFont(name: "OpenSans-Bold", size: size)!} //UIFont(name: "OpenSans-Bold", size: size)
}
