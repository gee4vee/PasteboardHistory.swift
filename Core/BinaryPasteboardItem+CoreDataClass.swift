//
//  BinaryPasteboardItem+CoreDataClass.swift
//  PasteboardHistory
//
//  Created by Gabriel Valencia on 10/8/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//
//

import Foundation
import CoreData

@objc(BinaryPasteboardItem)
public class BinaryPasteboardItem: PasteboardItem {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.dataType = DataType.binary.rawValue
    }

}
