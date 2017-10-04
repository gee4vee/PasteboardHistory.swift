//
//  PasteboardMonitor.swift
//  ClickClip
//
//  Created by Gabriel Valencia on 4/17/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//

import Cocoa

public class PasteboardMonitor: NSObject {
    
    var pbMgr: PasteboardManager
    var timer = Foundation.Timer()
    
    override public init() {
        self.pbMgr = PasteboardManager()
    }
    
    public init(pbMgr: PasteboardManager) {
        self.pbMgr = pbMgr
        super.init()
        timer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        update()
    }
    
    @objc public func update() {
        if (pbMgr.changeCount != pbMgr.ownChangeCount)  {
            if pbMgr.currentStringItem != nil {
                pbMgr.resetCount()
                NSLog("PasteboardMonitor: current pItem:" + pbMgr.currentStringItem!)
                self.pbMgr.saveCurrentItem(handler: nil)
            }
        }
    }
    
    public func invalidateTimer() {
        NSLog("invalidating timer")
        self.timer.invalidate()
    }
    
}
