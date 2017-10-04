//
//  PasteboardItem+CoreDataClass.swift
//  PasteboardHistory
//
//  Created by Gabriel Valencia on 10/2/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PasteboardItem)
public class PasteboardItem: NSManagedObject {
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        let now = NSDate()
        self.timestamp = now
    }

}
