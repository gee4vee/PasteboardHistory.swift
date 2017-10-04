//
//  PHDataMgr.swift
//  PasteboardHistory
//
//  Created by Gabriel Valencia on 10/3/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//

import Cocoa

// Defines the protocol for data managers for pasteboard history.
protocol PHDataMgr: AnyObject {
    
    func refreshMaxSavedItems()
    
    func save(_ sender: AnyObject?)
    
    func enforceMaxSavedItems(doSave: Bool)
    
    func saveClippingString(content: String) -> StringPasteboardItem
    
    func fetchByStringContent(content: String) -> StringPasteboardItem?
    
    func fetchOldest(numToFetch: Int) -> [PasteboardItem]
    
    func fetchAllPasteboardItems() -> [PasteboardItem]
    
    func fetchTotalCount() -> Int
    
    func deletebyStringContent(content: String) throws
    
    func deleteAllPasteboardItems() throws
}

public enum DataMgrError: Error {
    case DeleteFailed(cause: Error)
    case FetchFailed(cause: Error)
    case SaveFailed(cause: Error)
}
