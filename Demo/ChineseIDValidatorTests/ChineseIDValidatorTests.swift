//
//  ChineseIDValidatorTests.swift
//  ChineseIDValidatorTests
//
//  Created by ray on 2017/12/28.
//  Copyright © 2017年 ray. All rights reserved.
//

import XCTest
@testable import ChineseIDValidator

class ChineseIDValidatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValid() {
        let validList: [String] = ["210202195410244995", "330106196409100099"]
        let invalidList: [String] = ["1231231231", "123456457845123", "512345645125487545"]
        
        for valid in validList {
            XCTAssert(valid.CNIDValidator().isValid, valid)
        }
        for invalid in invalidList {
            XCTAssert(!invalid.CNIDValidator().isValid, invalid)
        }
    }
    
    func testFake() {
        for _ in 0..<100 {
            let fakedId = CNID.Faker().id
            print(fakedId)
            XCTAssert(fakedId.CNIDValidator().isValid, fakedId)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
