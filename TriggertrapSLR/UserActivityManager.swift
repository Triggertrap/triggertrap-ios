//
//  UserActivityManager.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 30/11/2015.
//  Copyright © 2015 Triggertrap Limited. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class UserActivityManager {
    static let sharedInstance = UserActivityManager()
    
    var userActivity: NSUserActivity?
    var activities = [Activity]()
    
    private init() {
        
        // Add modes to the activities
        
        if let modes = NSArray(contentsOfFile: pathForResource("Modes")) {
            for section in modes {
                if let section = section as? NSArray, let modesInSection = section[1] as? NSArray {
                    for mode in modesInSection {
                        if let mode = mode as? NSDictionary {
                            
                            let title = NSLocalizedString(mode["title"] as! String, tableName: "ModesPlist", bundle: NSBundle.mainBundle(), value: "", comment: "Ignore when translating")
                            
                            let description = NSLocalizedString(mode["description"] as! String, tableName: "ModesPlist", bundle: NSBundle.mainBundle(), value: "", comment: "Ignore when translating")
                            
                            // Spotlight icon has the same name as the icon with "Spotlight" at the end
                            var spotlightIconName = ""
                            
                            if let iconName = mode["icon"] as? String {
                                spotlightIconName = "\(iconName)Spotlight"
                            }
                            
                            let identifier = mode["identifier"] as! String
                            
                            self.activities.append(Activity(title: title, description: description, identifier: identifier, iconName: spotlightIconName))
                        }
                    }
                }
            }
        }
    }
}
