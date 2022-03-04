//
//  GuardTests.swift
//  GuardTests
//
//  Created by Lance Mao on 2021/11/23.
//

import XCTest
@testable import Guard

class GuardTests: XCTestCase {

    let TIMEOUT = 30.0
    let account = "ci"
    let password = "111111"
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Authing.start("60caaf41df670b771fd08937");
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetSecurityLevel() throws {
        let expectation = XCTestExpectation(description: "getSecurityLevel")
        AuthClient.loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient.getSecurityLevel() { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data != nil)
                XCTAssert(data!["score"] as! Int == 70)
                
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testListApplications() throws {
        let expectation = XCTestExpectation(description: "listApplications")
        AuthClient.loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient.listApplications() { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data != nil)
                XCTAssert(data!.count == 6)
                
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testListOrgs() throws {
        let expectation = XCTestExpectation(description: "listOrgs")
        AuthClient.loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient.listOrgs() { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data != nil)
                XCTAssert(data!.count == 2)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testListRoles() throws {
        let expectation = XCTestExpectation(description: "listRoles")
        AuthClient.loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient.listRoles() { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data != nil)
                XCTAssert(data!.count == 2)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testListAuthorizedResources() throws {
        let expectation = XCTestExpectation(description: "listAuthorizedResources")
        AuthClient.loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient.listAuthorizedResources() { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data != nil)
                XCTAssert(data!.count == 2)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testDeleteAccount() throws {
        let expectation = XCTestExpectation(description: "deleteAccount")
        AuthClient.registerByUserName(username: "iOSCI", password: "111111") { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient.deleteAccount() { code, message, data in
                XCTAssert(code == 200)
                
                AuthClient.loginByAccount(account: "iOSCI", password: "111111") { code, message, userInfo in
                    XCTAssert(code == 2333)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testMarkQRCodeScanned() throws {
        let expectation = XCTestExpectation(description: "markQRCodeScanned")
        AuthClient.loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient.markQRCodeScanned(ticket:"gUvNyfCW7mpD6pSzeDfyD4QLsCYwPV") { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data != nil)
                XCTAssert(data!["status"] as! Int == 1)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testLoginByScannedTicket() throws {
        let expectation = XCTestExpectation(description: "loginByScannedTicket")
        AuthClient.loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            let ticket = "gZHbp1PNjNqKbWbupZVaK1MHY16KjZ"
            AuthClient.markQRCodeScanned(ticket:ticket) { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data != nil)
                XCTAssert(data!["status"] as! Int == 1)
                AuthClient.loginByScannedTicket(ticket:ticket) { code, message, data in
                    XCTAssert(code == 200)
                    XCTAssert(data != nil)
                    XCTAssert(data!["status"] as! Int == 2)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testComputePasswordSecurityLevel() throws {
        let res = Util.computePasswordSecurityLevel(password: "a")
        XCTAssert(Util.computePasswordSecurityLevel(password: "a") == .weak)
        XCTAssert(Util.computePasswordSecurityLevel(password: "helloworld123") == .medium)
        XCTAssert(Util.computePasswordSecurityLevel(password: "helloworld123!") == .strong)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
