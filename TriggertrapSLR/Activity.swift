//
//  Mode.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 30/11/2015.
//  Copyright © 2015 Triggertrap Limited. All rights reserved.
//

import UIKit
import Foundation
import CoreSpotlight

struct Activity {
    var title: String
    var description: String
    var identifier: String
    var iconName: String
}

extension Activity {
    @available(iOS 9.0, *)
    func searchableAttributeSet() -> CSSearchableItemAttributeSet {
        let attr = CSSearchableItemAttributeSet(itemContentType: "com.triggertrap.Triggertrap")
        attr.title = title
        attr.contentDescription = description
        
        if let image = UIImage(named: iconName) {
            attr.thumbnailData = UIImagePNGRepresentation(image)
        } else {
            print("Not found")
        }
        
        // Title & description get automatically added to the keywords
        attr.keywords = ConstUserActivityKeywords
        return attr
    }
}
