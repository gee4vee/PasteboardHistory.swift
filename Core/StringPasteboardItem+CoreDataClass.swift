//
//  StringPasteboardItem+CoreDataClass.swift
//  PasteboardHistory
//
//  Created by Gabriel Valencia on 10/2/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//
//

import Foundation
import CoreData

@objc(StringPasteboardItem)
public class StringPasteboardItem: PasteboardItem {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.dataType = DataType.string.rawValue
    }
}
