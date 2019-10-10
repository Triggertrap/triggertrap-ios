//
//  Functions.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 30/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

func ShowAlertInViewController(_ viewController: UIViewController, title: String, message: String, cancelButton: String) {
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: UIAlertController.Style.alert)
    
    // The order in which we add the buttons matters.
    // Add the Cancel button first to match the iOS 7 default style,
    // where the cancel button is at index 0.
    alert.addAction(UIAlertAction(title: cancelButton,
        style: .default,
        handler: nil))
    
    viewController.present(alert, animated: true, completion: nil)
}

func StoryboardNameForViewControllerIdentifier(_ identifier: String) -> String? {
    
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
    case normal = 0,
    night
}

func AppTheme() -> Theme {
    if #available(iOS 13.0, *) {
        return UIApplication.shared.keyWindow?.rootViewController?.traitCollection.userInterfaceStyle == .dark ? .night : .normal
    } else {
        if let appTheme = UserDefaults.standard.object(forKey: ConstAppTheme) as? Int, let theme = Theme(rawValue: appTheme) {
            return theme
        } else {
            return Theme.normal
        }
    }

}

func IdentifiersForModesInSection(_ index: Int) -> [String] {
    
    if let sections = NSArray(contentsOfFile: pathForResource("Modes")), let section = sections[index] as? NSArray, let modes = section[1] as? NSArray {
        
        var identifiers: [String] = []
        
        for mode in modes {
            
            if let mode = mode as? NSDictionary, let identifier = mode["identifier"] as? String {
                identifiers.append(identifier)
            }
        }
        return identifiers
    } else {
        return [""]
    }
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func SizeForText(_ text: NSString, withFont font: UIFont, constrainedToSize size: CGSize) -> CGSize {
    return text.boundingRect(with: size, options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil).size;
} 

func pathForResource(_ resource: String!) -> String {
    return Bundle.main.path(forResource: resource, ofType: "plist")!
}

func componentInBounds(_ component: CGFloat) -> CGFloat {
    if component < 0 {
        return 0.0
    } else if component > 1 {
        return 1.0
    } else {
        return component
    }
}

// Use to change the color of a UIImage
func ImageWithColor(_ image: UIImage, color: UIColor) -> UIImage {
    
    let rect = CGRect(x: 0, y: 0, width: image.size.width * UIScreen.main.scale, height: image.size.height * UIScreen.main.scale)
    UIGraphicsBeginImageContext(rect.size)
    
    let context = UIGraphicsGetCurrentContext()
    context?.clip(to: rect, mask: image.cgImage!)
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let flippedImage = UIImage(cgImage: (img?.cgImage!)!, scale: 1.0, orientation: UIImage.Orientation.downMirrored)
    return flippedImage
}

// MARK: - Theme Updates

    func applyThemeUpdateToNumberInput(_ numberInput: TTNumberInput?) {
        
        numberInput?.displayView.textColor = UIColor.triggertrap_accentColor()
        numberInput?.borderColor = UIColor.triggertrap_accentColor()
        numberInput?.borderHighlightColor = UIColor.triggertrap_primaryColor()
        numberInput?.setNeedsDisplay()
    }
    
    func applyThemeUpdateToTimeInput(_ timeInput: TTTimeInput?) {
        timeInput?.setFontColor(UIColor.triggertrap_accentColor())
        timeInput?.borderColor = UIColor.triggertrap_accentColor()
        timeInput?.borderHighlightColor = UIColor.triggertrap_primaryColor()
        timeInput?.setNeedsDisplay()
    }
    
    func applyThemeUpdateToPicker(_ picker: HorizontalPicker?) {
        
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

func applyThemeUpdateToDescriptionLabel(_ label: UILabel) {
    label.textColor = UIColor.triggertrap_foregroundColor()
}


// MARK: - Generate .strings from .plist file for localization

var fileName: String?
var content = ""

// Content type of the plist

enum PlistType {
    case array,
    dictionary
}

func GenerateStringsFileFromPlist(_ plist: String, plistType: PlistType) {
    
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    
    let fileDirectory = paths[0]
    
    fileName = String(format: "%@/%@Plist.strings", arguments: [fileDirectory, plist])
    content = ""
    
    switch plistType {
    case .array:
        if let content = NSArray(contentsOfFile: pathForResource(plist)) {
            ReadArray(content)
        }
        break
    case .dictionary:
        if let content = NSDictionary(contentsOfFile: pathForResource(plist)) {
            ReadDictionary(content)
        }
        break
    }
    
    do {
        try content.write(toFile: fileName!, atomically: true, encoding: String.Encoding.utf8)
        print("Spotlight search: \(fileDirectory)")
        print("Generated \(plist).strings successfully")
    } catch {
        print("Error: \(error)")
    }
}

private func ReadArray(_ array: NSArray) {
    
    for value in array {
        ReadValueAndKey(value as AnyObject, key: nil)
    }
}

private func ReadDictionary(_ dictionary: NSDictionary) {
    
    for (key, value) in dictionary {
        ReadValueAndKey(value as AnyObject, key: key as AnyObject)
    }
}

private func ReadValueAndKey(_ value: AnyObject, key: AnyObject?) {
    if value is String && (key as? String) != "icon" {
        AppendContentWithString(value as! String)
    } else if value is NSArray {
        ReadArray(value as! NSArray)
    } else if value is NSDictionary {
        ReadDictionary(value as! NSDictionary)
    }
}

private func AppendContentWithString(_ string: String) {
    
    // Comment format: /* Title */
    let comment = "\n/* \(string) */"
    
    // String format: "string"="string";
    let string = "\n\"\(string)\"=\"\(string)\";\n"
    
    content.append(comment)
    content.append(string)
}
