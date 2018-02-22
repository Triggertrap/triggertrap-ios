//
//  Functions.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 30/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

func ShowAlertInViewController(viewController: UIViewController, title: String, message: String, cancelButton: String) {
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: UIAlertControllerStyle.Alert)
    
    // The order in which we add the buttons matters.
    // Add the Cancel button first to match the iOS 7 default style,
    // where the cancel button is at index 0.
    alert.addAction(UIAlertAction(title: cancelButton,
        style: .Default,
        handler: nil))
    
    viewController.presentViewController(alert, animated: true, completion: nil)
}

func StoryboardNameForViewControllerIdentifier(identifier: String) -> String? {
    
    if ConstCableReleaseModes.contains(identifier) {
        return ConstStoryboardIdentifierCableReleaseModes
    }
    
    if ConstTimelapseModes.contains(identifier) {
        return ConstStoryboardIdentifierTimelapseModes
    }
    
    if ConstSensorModes.contains(identifier) {
        return ConstStoryboardIdentifierSensorModes
    }
    
    if ConstHDRModes.contains(identifier) {
        return ConstStoryboardIdentifierHDRModes
    }
    
    if ConstCalculators.contains(identifier) {
        return ConstStoryboardIdentifierCalculators
    }
    
    if ConstRemoteModes.contains(identifier) {
        return ConstStoryboardIdentifierRemoteModes
    }
    
    return nil
}

enum Theme: Int {
    case Normal = 0,
    Night
}

func AppTheme() -> Theme {
    if let appTheme = NSUserDefaults.standardUserDefaults().objectForKey(ConstAppTheme) as? Int, theme = Theme(rawValue: appTheme) {
        return theme
    } else {
        return Theme.Normal
    }
}

func IdentifiersForModesInSection(index: Int) -> [String] {
    
    if let sections = NSArray(contentsOfFile: pathForResource("Modes")), section = sections[index] as? NSArray, modes = section[1] as? NSArray {
        
        var identifiers: [String] = []
        
        for mode in modes {
            
            if let mode = mode as? NSDictionary, identifier = mode["identifier"] as? String {
                identifiers.append(identifier)
            }
        }
        return identifiers
    } else {
        return [""]
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func SizeForText(text: NSString, withFont font: UIFont, constrainedToSize size: CGSize) -> CGSize {
    return text.boundingRectWithSize(size, options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], attributes: [NSFontAttributeName: font], context: nil).size;
} 

func pathForResource(resource: String!) -> String {
    return NSBundle.mainBundle().pathForResource(resource, ofType: "plist")!
}

func componentInBounds(component: CGFloat) -> CGFloat {
    if component < 0 {
        return 0.0
    } else if component > 1 {
        return 1.0
    } else {
        return component
    }
}

// Use to change the color of a UIImage
func ImageWithColor(image: UIImage, color: UIColor) -> UIImage {
    
    let rect = CGRect(x: 0, y: 0, width: image.size.width * UIScreen.mainScreen().scale, height: image.size.height * UIScreen.mainScreen().scale)
    UIGraphicsBeginImageContext(rect.size)
    
    let context = UIGraphicsGetCurrentContext()
    CGContextClipToMask(context, rect, image.CGImage)
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextFillRect(context, rect)
    
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let flippedImage = UIImage(CGImage: img.CGImage!, scale: 1.0, orientation: UIImageOrientation.DownMirrored)
    return flippedImage
}

// MARK: - Theme Updates

    func applyThemeUpdateToNumberInput(numberInput: TTNumberInput?) {
        
        numberInput?.displayView.textColor = UIColor.triggertrap_accentColor()
        numberInput?.borderColor = UIColor.triggertrap_accentColor()
        numberInput?.borderHighlightColor = UIColor.triggertrap_primaryColor()
        numberInput?.setNeedsDisplay()
    }
    
    func applyThemeUpdateToTimeInput(timeInput: TTTimeInput?) {
        timeInput?.setFontColor(UIColor.triggertrap_accentColor())
        timeInput?.borderColor = UIColor.triggertrap_accentColor()
        timeInput?.borderHighlightColor = UIColor.triggertrap_primaryColor()
        timeInput?.setNeedsDisplay()
    }
    
    func applyThemeUpdateToPicker(picker: HorizontalPicker?) {
        
        picker?.fontColor = UIColor.triggertrap_accentColor()
        picker?.gradientView.leftGradientStartColor = UIColor.triggertrap_fillColor()
        picker?.gradientView.leftGradientEndColor = UIColor.triggertrap_clearColor()
        picker?.gradientView.rightGradientEndColor = UIColor.triggertrap_fillColor()
        picker?.gradientView.rightGradientStartColor = UIColor.triggertrap_clearColor()
        picker?.gradientView.horizontalLinesColor = UIColor.triggertrap_foregroundColor()
        picker?.gradientView.verticalLinesColor = UIColor.triggertrap_primaryColor()
        picker?.gradientView.setNeedsDisplay()
        picker?.layoutSubviews()
    }

func applyThemeUpdateToDescriptionLabel(label: UILabel) {
    label.textColor = UIColor.triggertrap_foregroundColor()
}


// MARK: - Generate .strings from .plist file for localization

var fileName: String?
var content = ""

// Content type of the plist

enum PlistType {
    case Array,
    Dictionary
}

func GenerateStringsFileFromPlist(plist: String, plistType: PlistType) {
    
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    
    let fileDirectory = paths[0]
    
    fileName = String(format: "%@/%@Plist.strings", arguments: [fileDirectory, plist])
    content = ""
    
    switch plistType {
    case .Array:
        if let content = NSArray(contentsOfFile: pathForResource(plist)) {
            ReadArray(content)
        }
        break
    case .Dictionary:
        if let content = NSDictionary(contentsOfFile: pathForResource(plist)) {
            ReadDictionary(content)
        }
        break
    }
    
    do {
        try content.writeToFile(fileName!, atomically: true, encoding: NSUTF8StringEncoding)
        print("Spotlight search: \(fileDirectory)")
        print("Generated \(plist).strings successfully")
    } catch {
        print("Error: \(error)")
    }
}

private func ReadArray(array: NSArray) {
    
    for value in array {
        ReadValueAndKey(value, key: nil)
    }
}

private func ReadDictionary(dictionary: NSDictionary) {
    
    for (key, value) in dictionary {
        ReadValueAndKey(value, key: key)
    }
}

private func ReadValueAndKey(value: AnyObject, key: AnyObject?) {
    if value is String && (key as? String) != "icon" {
        AppendContentWithString(value as! String)
    } else if value is NSArray {
        ReadArray(value as! NSArray)
    } else if value is NSDictionary {
        ReadDictionary(value as! NSDictionary)
    }
}

private func AppendContentWithString(string: String) {
    
    // Comment format: /* Title */
    let comment = "\n/* \(string) */"
    
    // String format: "string"="string";
    let string = "\n\"\(string)\"=\"\(string)\";\n"
    
    content.appendContentsOf(comment)
    content.appendContentsOf(string)
}
