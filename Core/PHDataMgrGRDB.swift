//
//  PHDataMgrGRDB.swift
//  PasteboardHistory
//
//  Created by Gabriel Valencia on 10/3/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//

import Cocoa
import GRDB

public class PHDataMgrGRDB: NSObject, PHDataMgr {
    
    func refreshMaxSavedItems() {
        
    }
    
    func save(_ sender: AnyObject?) {
        
    }
    
    func enforceMaxSavedItems(doSave: Bool) {
        
    }
    
    func saveClippingString(content: String) -> StringPasteboardItem {
        return StringPasteboardItem(entity: <#T##NSEntityDescription#>, insertInto: <#T##NSManagedObjectContext?#>)
    }
    
    func fetchByStringContent(content: String) -> StringPasteboardItem? {
        return nil
    }
    
    func fetchOldest(numToFetch: Int) -> [PasteboardItem] {
        return nil
    }
    
    func fetchAllPasteboardItems() -> [PasteboardItem] {
        return nil
    }
    
    func fetchTotalCount() -> Int {
        return 0
    }
    
    func deletebyStringContent(content: String) throws {
        
    }
    
    func deleteAllPasteboardItems() throws {
        
    }

}

//extension PasteboardItem: Persistable, TableMapping, RowConvertible {
//
//    public required init(row: Row) {
//        <#code#>
//    }
//
//    public static var databaseTableName: String {
//        get { return "PasteboardItem" }
//    }
//
//    public func encode(to container: inout PersistenceContainer) {
//        <#code#>
//    }
//}

