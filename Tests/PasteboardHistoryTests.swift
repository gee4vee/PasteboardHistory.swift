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
        return PasteboardHistoryTests.TEST_STRING_CONTENT + String(describing: PasteboardHistoryTests.randomNum())
    }
    
    func testDataMgrSaveClippingString() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        let strItem = self.dm.saveItemString(content: testStr)
        XCTAssert(strItem.content! == testStr, "Unexpected saved content")
        let allItems = self.dm.fetchAllPasteboardItems()
        XCTAssert(allItems.count == 1, "Unexpected item count")
        let fetchedItem = allItems[0] as! StringPasteboardItem
        XCTAssert(fetchedItem.content! == testStr, "Unexpected saved content")
    }
    
    func testDataMgrDeleteClippingString() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        let strItem = self.dm.saveItemString(content: testStr)
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
        let strItem = self.dm.saveItemString(content: testStr)
        XCTAssert(strItem.content! == testStr, "Unexpected saved content")
        let fetchedItem = self.dm.fetchByStringContent(content: testStr)
        XCTAssert(fetchedItem!.content! == testStr, "Unexpected fetched content")
    }
    
    func testDataMgrMaxSavedItems() {
        let max = 5
        PreferencesManager.getPrefs().setValue(max, forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS)
        for _ in 1...(max+1) {
            let testStr = PasteboardHistoryTests.getRandomTestContentString()
            _ = self.dm.saveItemString(content: testStr)
        }
        
        let total = self.dm.fetchTotalCount()
        defer {
            PreferencesManager.getPrefs().set(Preferences.DEFAULT_MAX_SAVED_ITEMS, forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS)
        }
        XCTAssert(total == max, "Too many items were saved: \(total)")
    }
    
    func testPbMonCopyString() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        self.pb.setPasteboard(testStr)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            let fetchedItem = self.dm.fetchByStringContent(content: testStr)
            XCTAssert(fetchedItem != nil, "Fetched item is nil")
            XCTAssert(fetchedItem!.content! == testStr, "Unexpected fetched content")
        })
    }
    
    func testPerformanceSaveClippingString() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        self.measure {
            _ = self.dm.saveItemString(content: testStr)
        }
    }
    
    func testPerformanceSaveClippingStringMany() {
        self.measure {
            let maxNum = 100
            PreferencesManager.getPrefs().set(maxNum, forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS)
            for _ in 1...maxNum {
                let testStr = PasteboardHistoryTests.getRandomTestContentString()
                _ = self.dm.saveItemString(content: testStr)
            }
        }
    }
    
    func testPerformanceFetchAll() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        _ = self.dm.saveItemString(content: testStr)
        self.measure {
            _ = self.dm.fetchAllPasteboardItems()
        }
    }
    
    func testPerformanceFetchAllMany() {
        let maxNum = 1000
        PreferencesManager.getPrefs().set(maxNum, forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS)
        for _ in 1...maxNum {
            let testStr = PasteboardHistoryTests.getRandomTestContentString()
            _ = self.dm.saveItemString(content: testStr)
        }
        self.measure {
            _ = self.dm.fetchAllPasteboardItems()
        }
    }
    
    func testPerformanceFetchByStringContent() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        _ = self.dm.saveItemString(content: testStr)
        self.measure {
            _ = self.dm.fetchByStringContent(content: testStr)
        }
    }
    
    func testPerformanceDeleteByStringContent() {
        let testStr = PasteboardHistoryTests.getRandomTestContentString()
        _ = self.dm.saveItemString(content: testStr)
        self.measure {
            do {
                try self.dm.deleteByStringContent(content: testStr)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testPerformanceDeleteByStringContentMany() {
        let maxNum = 1000
        PreferencesManager.getPrefs().set(maxNum, forKey: Preferences.PREF_KEY_MAX_SAVED_ITEMS)
        var data = [String]()
        for _ in 1...maxNum {
            let testStr = PasteboardHistoryTests.getRandomTestContentString()
            _ = self.dm.saveItemString(content: testStr)
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
