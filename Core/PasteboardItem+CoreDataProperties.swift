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

    /**
     The point in time when the item was created or last copied.
     */
    @NSManaged public var timestamp: NSDate?
    
    /**
     The UUID of the item.
     */
    @NSManaged public var id: String?
    
    /**
     The item's data type. This will be a raw value of one of the PHDataMgr.DataType enum cases.
     */
    @NSManaged public var dataType: Int16

}
