//
//  PasteboardManager.swift
//  ClickClip
//
//  Created by Gabriel Valencia on 4/17/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//

import Cocoa

public protocol PasteboardManagerDelegate {
    func itemSaved(item: String)
}

public class PasteboardManager {
    
    let pb = NSPasteboard.general
    let dataMgr = PHDataManagerCoreData()
    var delegates = [PasteboardManagerDelegate]()
    
    public init() {
        ownChangeCount = pb.changeCount
    }
    
    var changeCount: Int {
        return pb.changeCount
    }
    
    var currentStringItem: String? {
        if pb.pasteboardItems!.count == 0 {
            return nil
        }
        if let item = pb.pasteboardItems![0].string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) {
            return item
        }
        return nil
    }
    
    var ownChangeCount = 0
    
    public func resetCount() {
        ownChangeCount = pb.changeCount
    }
    
    public func setPasteboard(_ item: String) {
        pb.clearContents()
        pb.setString(item, forType: NSPasteboard.PasteboardType.string)
    }
    
    public func saveCurrentItem(handler: (() -> Void)?) {
        if let currentStr = self.currentStringItem {
            _ = self.dataMgr.saveClippingString(content: currentStr)
            handler?()
            self.notifyDelegatesItemSaved(item: currentStr)
        }
    }
    
    public func pbItemEquals(item: PasteboardItem, str: String) -> Bool {
        if let strItem = item as? StringPasteboardItem {
            if strItem.content! == str {
                return true
            }
        }
        
        return false
    }
    
    public func addDelegate(d: PasteboardManagerDelegate) {
        self.delegates.append(d)
    }
    
    public func clearDelegates() {
        self.delegates.removeAll()
    }
    
    func notifyDelegatesItemSaved(item: String) {
        for delegate in self.delegates {
            delegate.itemSaved(item: item)
        }
    }
}
