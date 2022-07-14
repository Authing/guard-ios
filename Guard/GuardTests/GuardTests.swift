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
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient().getSecurityLevel() { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data != nil)
                XCTAssert(data!["score"] as! Int == 70)
                
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testRegisterByEmailNormal() throws {
        let expectation = XCTestExpectation(description: "registerByEmailNormal")
        AuthClient().registerByEmail(email: "1@1024.cn", password: "111111") { code, message, userInfo in
            XCTAssert(code == 200)
            
            // since force login is true we can get detail right after register
            AuthClient().getCurrentUser() { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data?.email == "1@1024.cn")
                
                AuthClient().deleteAccount { code, message in
                    XCTAssert(code == 200)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testRegisterByEmail1() throws {
        let expectation = XCTestExpectation(description: "registerByEmail invalid email address")
        AuthClient().registerByEmail(email: "1024.cn", password: "111111") { code, message, userInfo in
            XCTAssert(code == 400)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testRegisterByEmail2() throws {
        let expectation = XCTestExpectation(description: "registerByEmail email address exist")
        AuthClient().registerByEmail(email: "1@1024.cn", password: "111111") { code, message, userInfo in
            XCTAssert(code == 200)
            AuthClient().registerByEmail(email: "1@1024.cn", password: "111111") { code, message, userInfo in
                XCTAssert(code == 2026)
                
                AuthClient().loginByAccount(account: "1@1024.cn", password: "111111") { code, message, userInfo in
                    XCTAssert(code == 200)
                    
                    AuthClient().deleteAccount { code, message in
                        XCTAssert(code == 200)
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testRegisterByUserName() throws {
        let expectation = XCTestExpectation(description: "registerByUserName")
        AuthClient().registerByUserName(username: "10242048", password: "111111") { code, message, userInfo in
            XCTAssert(code == 200)
            
            // since force login is true we can get detail right after register
            AuthClient().getCurrentUser() { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data?.username == "10242048")
                
                AuthClient().deleteAccount { code, message in
                    XCTAssert(code == 200)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testLoginByAccount() throws {
        let expectation = XCTestExpectation(description: "loginByAccount")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient().loginByAccount(account: "doiknow", password: "idontknow") { code, message, data in
                XCTAssert(code == 2004)
                XCTAssert(data == nil)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testListApplications() throws {
        let expectation = XCTestExpectation(description: "listApplications")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient().listApplications() { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data != nil)
                XCTAssert(data!.count > 0)
                
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testListOrgs() throws {
        let expectation = XCTestExpectation(description: "listOrgs")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient().listOrgs() { code, message, data in
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
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient().listRoles() { code, message, data in
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
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient().listAuthorizedResources() { code, message, data in
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
        AuthClient().registerByUserName(username: "iOSCI", password: "111111") { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient().deleteAccount() { code, message in
                XCTAssert(code == 200)
                
                AuthClient().loginByAccount(account: "iOSCI", password: "111111") { code, message, userInfo in
                    XCTAssert(code == 2004)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testPerformanceLoginByAccount() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            let expectation = XCTestExpectation(description: "loginByAccount")
            AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: TIMEOUT)
        }
    }
}
