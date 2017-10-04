//
//  PasteboardItem+CoreDataProperties.swift
//  PasteboardHistory
//
//  Created by Gabriel Valencia on 10/2/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//
//

import Foundation
import CoreData


extension PasteboardItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PasteboardItem> {
        return NSFetchRequest<PasteboardItem>(entityName: "PasteboardItem")
    }

    @NSManaged public var timestamp: NSDate?

}
