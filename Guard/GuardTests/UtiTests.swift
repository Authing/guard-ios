//
//  UtiTests.swift
//  GuardTests
//
//  Created by Lance Mao on 2022/3/7.
//

import XCTest
import Guard

class UtiTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testComputePasswordSecurityLevel() throws {
        XCTAssert(Util.computePasswordSecurityLevel(password: "a") == .weak)
        XCTAssert(Util.computePasswordSecurityLevel(password: "helloworld123") == .medium)
        XCTAssert(Util.computePasswordSecurityLevel(password: "helloworld123!") == .strong)
    }
    
    func testIsIp() throws {
        XCTAssert(Util.isIp("192.168.1.1") == true)
        XCTAssert(Util.isIp("authing.cn") == false)
        XCTAssert(Util.isIp("192.168.1.2.3") == false)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
