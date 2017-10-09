//
//  BinaryPasteboardItem+CoreDataProperties.swift
//  PasteboardHistory
//
//  Created by Gabriel Valencia on 10/8/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//
//

import Foundation
import CoreData


extension BinaryPasteboardItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BinaryPasteboardItem> {
        return NSFetchRequest<BinaryPasteboardItem>(entityName: "BinaryPasteboardItem")
    }

    @NSManaged public var binContent: NSData?
    
    override public var description: String {
        return "BinaryPasteboardItem[binContentSize=\(self.binContent?.length ?? -1)\", id=\"\(self.id ?? "<not_set>")\", timestamp=\(self.timestamp!)]"
    }

}
