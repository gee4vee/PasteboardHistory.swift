//
//  PasteboardHistoryTests.swift
//  PasteboardHistoryTests
//
//  Created by Gabriel Valencia on 10/2/17.
//  Copyright © 2017 Gabriel Valencia. All rights reserved.
//

import XCTest
import SUtils
@testable import PasteboardHistory

class PasteboardHistoryTests: XCTestCase {
    
    static let TEST_STRING_CONTENT = "this is a test string pasteboard item"
    
    let pb = PasteboardManager()
    let dm = PHDataManagerCoreData()
    
    override func setUp() {
        super.setUp()
        do {
            try dm.deleteAllPasteboardItems()
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssert(dm.fetchAllPasteboardItems().count == 0, "Pasteboard items not cleared")
    }
    
    override func tearDown() {
        do {
            try dm.deleteAllPasteboardItems()
        } catch {
            XCTFail(error.localizedDescription)
        }
        PreferencesManager.getPrefs().set(Preferences.DEFAULT_MAX_SAVED_ITEMS, forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS)
        super.tearDown()
    }
    
    static func randomNum() -> Int {
        let someInt:Int = Random.randomInt(max: 100)
        return someInt
    }
    
    static func getRandomTestContentString() -> String {
        return PasteboardHistoryTests.TEST_STRING_CONTENT + String(describing: randomNum())//UUID().uuidString
    }
    
    func testDataMgrSaveClippingString() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        let strItem = self.dm.saveItemString(str: testStr)
        XCTAssert(strItem.content! == testStr, "Unexpected saved content")
        let allItems = self.dm.fetchAllPasteboardItems()
        XCTAssert(allItems.count == 1, "Unexpected item count")
        let fetchedItem = allItems[0] as! StringPasteboardItem
        XCTAssert(fetchedItem.content! == testStr, "Unexpected saved content")
    }
    
    func testDataMgrSaveClippingStringTwice() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        let strItem = self.dm.saveItemString(str: testStr)
        XCTAssert((strItem.content ?? "nil") == testStr, "Unexpected saved content value: \(strItem.content ?? "nil")")
        
        var allItems = self.dm.fetchAllPasteboardItems()
        XCTAssert(allItems.count == 1, "Unexpected item count")
        let fetchedItem = allItems[0] as! StringPasteboardItem
        XCTAssert(fetchedItem.content! == testStr, "Unexpected saved content")
        
        let strItem2 = self.dm.saveItemString(str: testStr)
        XCTAssert((strItem2.content ?? "nil") == testStr, "Unexpected saved content value: \(strItem2.content ?? "nil")")
        allItems = self.dm.fetchAllPasteboardItems()
        XCTAssert(allItems.count == 1, "Unexpected item count")
        let fetchedItem2 = allItems[0] as! StringPasteboardItem
        XCTAssert(fetchedItem2.content! == fetchedItem.content!, "Unexpected saved content")
    }
    
    func testDataMgrDeleteClippingString() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        let strItem = self.dm.saveItemString(str: testStr)
        XCTAssert(strItem.content! == testStr, "Unexpected saved content")
        do {
            try self.dm.deleteByStringContent(content: testStr)
        } catch {
            XCTFail(error.localizedDescription)
        }
        let allItems = self.dm.fetchAllPasteboardItems()
        XCTAssert(allItems.count == 0, "Item was not deleted")
    }
    
    func testDataMgrFetchByStringContent() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        let strItem = self.dm.saveItemString(str: testStr)
        XCTAssert(strItem.content! == testStr, "Unexpected saved content")
        let fetchedItem = self.dm.fetchByStringContent(content: testStr)
        XCTAssert(fetchedItem!.content! == testStr, "Unexpected fetched content")
    }
    
    func testDataMgrMaxSavedItems() {
        let max = 5
        PreferencesManager.getPrefs().setValue(max, forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS)
        for _ in 1...(max+1) {
            let testStr = PasteboardHistoryTests.getRandomTestContentString()
            _ = self.dm.saveItemString(str: testStr)
        }
        
        let total = self.dm.fetchTotalCount()
        defer {
            PreferencesManager.getPrefs().set(Preferences.DEFAULT_MAX_SAVED_ITEMS, forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS)
        }
        XCTAssert(total == max, "Too many items were saved: \(total)")
    }
    
    func testPbMonCopyString() {
        let pbm = PasteboardMonitor(pbMgr: self.pb)
        let exp = expectation(description: "PBCopy")
        let testStr = PasteboardHistoryTests.getRandomTestContentString() + UUID().uuidString
        self.pb.setPasteboard(testStr)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            if let fetchedItem = self.dm.fetchByStringContent(content: testStr) {
                XCTAssert((fetchedItem.content ?? "nil") == testStr, "Unexpected fetched content value: \(fetchedItem.content ?? "nil")")
            } else {
                XCTFail("Fetched item is nil")
            }
            exp.fulfill()
            pbm.invalidateTimer()
        })
        NSLog("Waiting for PBCopy")
        wait(for: [exp], timeout: 30)
    }
    
    func testPerformanceSaveClippingString() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        self.measure {
            _ = self.dm.saveItemString(str: testStr)
        }
    }
    
    func testPerformanceSaveClippingStringMany() {
        self.measure {
            let maxNum = 20
            PreferencesManager.getPrefs().set(maxNum, forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS)
            for _ in 1...maxNum {
                let testStr = PasteboardHistoryTests.getRandomTestContentString() + UUID().uuidString
                let newItem = self.dm.saveItemString(str: testStr)
                XCTAssert(newItem.content != nil, "New item content is nil")
            }
        }
    }
    
    func testPerformanceFetchAll() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        _ = self.dm.saveItemString(str: testStr)
        self.measure {
            _ = self.dm.fetchAllPasteboardItems()
        }
    }
    
    func testPerformanceFetchAllMany() {
        let maxNum = 100
        PreferencesManager.getPrefs().set(maxNum, forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS)
        for _ in 1...maxNum {
            let testStr = PasteboardHistoryTests.getRandomTestContentString()
            _ = self.dm.saveItemString(str: testStr)
        }
        self.measure {
            _ = self.dm.fetchAllPasteboardItems()
        }
    }
    
    func testPerformanceFetchByStringContent() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        _ = self.dm.saveItemString(str: testStr)
        self.measure {
            _ = self.dm.fetchByStringContent(content: testStr)
        }
    }
    
    func testPerformanceDeleteByStringContent() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        _ = self.dm.saveItemString(str: testStr)
        self.measure {
            do {
                NSLog("Attempting to save \(testStr)")
                try self.dm.deleteByStringContent(content: testStr)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testPerformanceDeleteByStringContentMany() {
        let maxNum = 20
        PreferencesManager.getPrefs().set(maxNum, forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS)
        var data = [String]()
        for _ in 1...maxNum {
            let testStr = PasteboardHistoryTests.getRandomTestContentString() + UUID().uuidString
            let newItem = self.dm.saveItemString(str: testStr)
            XCTAssert(newItem.content != nil, "New item content is nil")
            data.append(testStr)
        }
        
        let testStr = data[Random.randomInt(max: maxNum)]
        self.measure {
            do {
                try self.dm.deleteByStringContent(content: testStr)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
