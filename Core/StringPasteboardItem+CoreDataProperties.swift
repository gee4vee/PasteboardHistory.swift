//
//  StringPasteboardItem+CoreDataProperties.swift
//  PasteboardHistory
//
//  Created by Gabriel Valencia on 10/2/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//
//

import Foundation
import CoreData


extension StringPasteboardItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StringPasteboardItem> {
        return NSFetchRequest<StringPasteboardItem>(entityName: "StringPasteboardItem")
    }

    /**
     The content of the item.
     */
    @NSManaged public var content: String?
    
    override public var description: String {
        return "StringPasteboardItem[content=\"\(self.content ?? "")\", id=\"\(self.id ?? "<not_set>")\", timestamp=\(self.timestamp!)]"
    }

}
