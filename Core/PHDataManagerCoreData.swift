//
//  DataManager.swift
//
//  Created by Gabriel Valencia on 4/17/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//

import Cocoa
import CoreData
import Foundation
import SUtils

public class PHDataManagerCoreData: NSObject, PHDataMgr {
    
    static let MODEL_NAME = "PasteboardHistory"
    
    static let BASE_PB_ITEM_CLASS_NAME = "PasteboardItem"
    static let STRING_PB_ITEM_CLASS_NAME = "StringPasteboardItem"
    static let BINARY_PB_ITEM_CLASS_NAME = "BinaryPasteboardItem"
    
    var maxItems: Int = Preferences.DEFAULT_MAX_SAVED_ITEMS
    
    var observer: CoreDataContextObserver?
    
    override public init() {
        super.init()
        self.refreshMaxSavedItems()
        NotificationCenter.default.addObserver(self, selector: #selector(PHDataManagerCoreData.defaultsChanged(notification:)), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    public func refreshMaxSavedItems() {
        if let maxPref = PreferencesManager.getPrefs().string(forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS) {
            self.maxItems = Int(maxPref)!
        }
    }
    
    @objc public func defaultsChanged(notification:NSNotification){
        if let defaults = notification.object as? UserDefaults {
            if let maxPref = defaults.string(forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS) {
                self.maxItems = Int(maxPref)!
            }
        }
    }
    
    // MARK: - Core Data stack
    
    @available(OSX 10.12, *)
    lazy var persistentContainer: NSPersistentContainer = {
        NSLog("Initializing persistent container for PasteboardHistory...")
        let sexyFrameworkBundleIdentifier = "com.valencia.PasteboardHistory"
        let customKitBundle = Bundle(identifier: sexyFrameworkBundleIdentifier)!
        let modelURL = customKitBundle.url(forResource: PHDataManagerCoreData.MODEL_NAME, withExtension: "momd")!
        guard let mom = NSManagedObjectModel.mergedModel(from: [customKitBundle]) else {
            fatalError("Could not load model")
        }
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: PHDataManagerCoreData.MODEL_NAME, managedObjectModel: mom)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    public func getManagedObjectCtx() -> NSManagedObjectContext {
        var ctx: NSManagedObjectContext?
        if #available(OSX 10.12, *) {
            ctx = self.persistentContainer.viewContext
        } else {
            ctx = self.managedObjectContext
        }
        
        let mp = NSMergePolicy.init(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        ctx?.mergePolicy = mp
        self.observer = CoreDataContextObserver(context: ctx!)
        return ctx!
    }
    
    @available(macOS 10.11, *)
    public lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: PHDataManagerCoreData.MODEL_NAME, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    @available(macOS 10.11, *)
    public lazy var managedObjectContext: NSManagedObjectContext = {
        NSLog("Initializing managed object context directly...")
        let persistentStoreCoordinator = self.persistentStoreCoordinator
        
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        managedObjectContext.mergePolicy = NSMergePolicy.init(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        
        return managedObjectContext
    }()
    
    @available(macOS 10.11, *)
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // URL Documents Directory
        let URLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let applicationDocumentsDirectory = URLs[(URLs.count - 1)]
        
        // URL Persistent Store
        let URLPersistentStore = applicationDocumentsDirectory.appendingPathComponent(PHDataManagerCoreData.MODEL_NAME + ".sqlite")
        
        do {
            // Add Persistent Store to Persistent Store Coordinator
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: URLPersistentStore, options: nil)
            
        } catch {
            // Populate Error
            var userInfo = [String: AnyObject]()
            userInfo[NSLocalizedDescriptionKey] = "There was an error creating or loading the application's saved data." as AnyObject
            userInfo[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data." as AnyObject
            
            userInfo[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "com.valencia.PasteboardHistory", code: 1001, userInfo: userInfo)
            
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            abort()
        }
        
        return persistentStoreCoordinator
    }()

    
    // MARK: - Core Data Saving and Undo support
    
    public func save(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = self.getManagedObjectCtx()
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                // enforce max items
                self.enforceMaxSavedItems(doSave: false)
                try context.save()
            } catch {
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }
    
    public func enforceMaxSavedItems(doSave: Bool) {
        let context = self.getManagedObjectCtx()
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        do {
            self.refreshMaxSavedItems()
            // enforce max items
            let count = self.fetchTotalCount()
            if (count > self.maxItems) {
                let overage = count - self.maxItems
                let oldest = self.fetchOldest(numToFetch: overage)
                for item in oldest {
                    try self.deleteById(id: item.id!)
                }
            }
            if doSave {
                try context.save()
            }
        } catch {
            let nserror = error as NSError
            NSApplication.shared.presentError(nserror)
        }
    }
    
    public func saveItemString(str: String) -> StringPasteboardItem {
        var strItem: StringPasteboardItem?
        if #available(OSX 10.12, *) {
            strItem = StringPasteboardItem(context: self.getManagedObjectCtx())
        } else {
            // Fallback on earlier versions
            strItem = NSEntityDescription.insertNewObject(forEntityName: PHDataManagerCoreData.STRING_PB_ITEM_CLASS_NAME, into: self.getManagedObjectCtx()) as? StringPasteboardItem
        }
        
        strItem!.content = str
        self.save(nil)
        NSLog("Saved new \(PHDataManagerCoreData.STRING_PB_ITEM_CLASS_NAME): \(strItem!.content ?? "nil")")
        return strItem!
    }
    
    public func saveItemBinary(blob: NSData) -> BinaryPasteboardItem {
        var bItem: BinaryPasteboardItem?
        if #available(OSX 10.12, *) {
            bItem = BinaryPasteboardItem(context: self.getManagedObjectCtx())
        } else {
            // Fallback on earlier versions
            bItem = NSEntityDescription.insertNewObject(forEntityName: PHDataManagerCoreData.BINARY_PB_ITEM_CLASS_NAME, into: self.getManagedObjectCtx()) as? BinaryPasteboardItem
        }
        
        bItem!.binContent = blob
        // TODO update ID based on binary data.
        self.observer?.observeObject(object: bItem!, completionBlock: {(object, state) in
            if let updatedContent = object.committedValues(forKeys: ["binContent"])["binContent"] as? NSData {
                if let binaryObj = object as? BinaryPasteboardItem {
                    // TODO update ID based on binary data.
                    NSLog("Binary data for item \(binaryObj.id ?? "nil") updated with size \(updatedContent.length)")
                }
            }
        })
        self.save(nil)
        NSLog("Saved new \(PHDataManagerCoreData.BINARY_PB_ITEM_CLASS_NAME) with data size \(bItem!.binContent?.length ?? -1)")
        return bItem!
    }
    
    public func fetchById(id: String) -> PasteboardItem? {
        let fetchReq: NSFetchRequest<PasteboardItem> = PasteboardItem.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "id == %@", argumentArray: [id])
        let sortDesc = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchReq.sortDescriptors = [sortDesc]
        do {
            let results = try self.getManagedObjectCtx().fetch(fetchReq)
            if results.count == 0 {
                return nil
            }
            
            return results[0]
        } catch {
            fatalError("Failed to fetch pasteboard items with id \(id): \(error)")
        }
    }
    
    public func fetchByStringContent(content: String) -> StringPasteboardItem? {
        let fetchReq: NSFetchRequest<StringPasteboardItem> = StringPasteboardItem.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "content == %@", argumentArray: [content])
        let sortDesc = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchReq.sortDescriptors = [sortDesc]
        do {
            let results = try self.getManagedObjectCtx().fetch(fetchReq)
            if results.count == 0 {
                return nil
            }
            
            return results[0]
        } catch {
            fatalError("Failed to fetch pasteboard items with content \(content): \(error)")
        }
    }
    
    public func fetchOldest(numToFetch: Int) -> [PasteboardItem] {
        let fetchReq: NSFetchRequest<StringPasteboardItem> = StringPasteboardItem.fetchRequest()
        fetchReq.fetchLimit = numToFetch
        let sortDesc = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchReq.sortDescriptors = [sortDesc]
        do {
            let results = try self.getManagedObjectCtx().fetch(fetchReq)
            return results
        } catch {
            fatalError("Failed to fetch oldest items due to error \(error)")
        }
    }
    
    public func fetchAllPasteboardItems() -> [PasteboardItem] {
        let fetchAllReq: NSFetchRequest<PasteboardItem> = PasteboardItem.fetchRequest()
        let sortDesc = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchAllReq.sortDescriptors = [sortDesc]
        do {
            let results = try self.getManagedObjectCtx().fetch(fetchAllReq)
            return results
        } catch {
            fatalError("Failed to fetch saved pasteboard items: \(error)")
        }
    }
    
    public func fetchTotalCount() -> Int {
        let fetchAllReq: NSFetchRequest<PasteboardItem> = PasteboardItem.fetchRequest()
        do {
            let count = try self.getManagedObjectCtx().count(for: fetchAllReq)
            return count
        } catch {
            fatalError("Failed to fetch saved pasteboard item count: \(error)")
        }
    }
    
    public func deleteById(id: String) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PHDataManagerCoreData.BASE_PB_ITEM_CLASS_NAME)
        fetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [id])
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.getManagedObjectCtx().execute(deleteRequest)
        } catch {
            NSLog(error.localizedDescription)
            throw DataMgrError.DeleteFailed(cause: error)
        }
    }
    
    public func deleteByStringContent(content: String) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PHDataManagerCoreData.BASE_PB_ITEM_CLASS_NAME)
        fetchRequest.predicate = NSPredicate(format: "content == %@", argumentArray: [content])
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.getManagedObjectCtx().execute(deleteRequest)
        } catch {
            NSLog(error.localizedDescription)
            throw DataMgrError.DeleteFailed(cause: error)
        }
    }
    
    public func deleteAllPasteboardItems() throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PHDataManagerCoreData.BASE_PB_ITEM_CLASS_NAME)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.getManagedObjectCtx().execute(deleteRequest)
        } catch {
            NSLog(error.localizedDescription)
            throw DataMgrError.DeleteFailed(cause: error)
        }

    }

}
