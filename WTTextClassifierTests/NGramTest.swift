//
//  NGramTest.swift
//  testBrainCore
//
//  Created by Ross on 2017. 8. 31..
//  Copyright © 2017년 wanted. All rights reserved.
//

import XCTest
@testable import WTTextClassifier

class NGramTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testNgram() {
        let array = ngram("원티드")
        XCTAssert("원티" == array[0])
        XCTAssert("티드" == array[1])
    }
}
