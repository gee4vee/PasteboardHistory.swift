//
//  PHDataMgr.swift
//  PasteboardHistory
//
//  Created by Gabriel Valencia on 10/3/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//

import Cocoa

/**
 Defines the protocol for data managers for pasteboard history.
 */
protocol PHDataMgr: AnyObject {
    
    func refreshMaxSavedItems()
    
    func save(_ sender: AnyObject?)
    
    func enforceMaxSavedItems(doSave: Bool)
    
    func saveItemString(str: String) -> StringPasteboardItem
    
    func saveItemBinary(blob: NSData) -> BinaryPasteboardItem
    
    func fetchById(id: String) -> PasteboardItem?
    
    func fetchByStringContent(content: String) -> StringPasteboardItem?
    
    func fetchOldest(numToFetch: Int) -> [PasteboardItem]
    
    func fetchAllPasteboardItems() -> [PasteboardItem]
    
    func fetchTotalCount() -> Int
    
    func deleteById(id: String) throws
    
    func deleteByStringContent(content: String) throws
    
    func deleteAllPasteboardItems() throws
}

/**
 Defines pasteboard item data types.
 */
public enum DataType: Int16 {
    /**
     An opaque string.
     */
    case string = 0
    
    /**
     Binary data.
     */
    case binary = 1
    
    /**
     A URL, e.g. for a web page.
     */
    case url = 2
}

/**
 Defines possible data manager errors.
 */
public enum DataMgrError: Error {
    case DeleteFailed(cause: Error)
    case FetchFailed(cause: Error)
    case SaveFailed(cause: Error)
}
