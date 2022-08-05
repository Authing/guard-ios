//
//  GuardTests.swift
//  GuardTests
//
//  Created by Lance Mao on 2021/11/23.
//

import XCTest
@testable import Guard

class GuardTests: XCTestCase {

    var TIMEOUT = 30.0
    var account: String  = "ci"
    var password: String  = "111111"
    var emailAddress: String = "test@authing.com"
    var emailCode: String = ""
    var phone: String = "15100000000"
    var phoneCode: String = ""
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Authing.start("6244398c8a4575cdb2cb5656");
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
            
            AuthClient().loginByAccount(account: self.account, password: "idontknow") { code, message, data in
                XCTAssert(code == 2333)
                XCTAssert(data == nil)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testLogout() throws {
        let expectation = XCTestExpectation(description: "logout")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient().logout() { code, message in
                XCTAssert(code == 200)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testGetSecurityLevel() throws {
        let expectation = XCTestExpectation(description: "getSecurityLevel")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient().getSecurityLevel() { code, message, data in
                XCTAssert(code == 200)
                XCTAssert(data != nil)
                XCTAssert(data!["score"] as! Int == 60)
                
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    //MARK: ---------- Get userInfo ----------
    func testGetCurrentUser() throws {
        let expectation = XCTestExpectation(description: "getCurrentUser")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            AuthClient().getCurrentUser() { code, message, data in
                XCTAssert(code == 200)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testSetCustomUserData() throws {
        let expectation = XCTestExpectation(description: "setCustomUserData")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            let body: NSDictionary = ["udfs" : ["definition": "test", "value": "value"]]
            AuthClient().setCustomUserData(customData: body) { code, message, data in
                XCTAssert(code == 200)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testGetCustomUserData() throws {
        let expectation = XCTestExpectation(description: "getCustomUserData")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            AuthClient().getCustomUserData(userInfo: userInfo ?? UserInfo()) { code, message, userInfo2 in
                XCTAssert(code == 200)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
                
    func testUpdatePassword() throws {
        let expectation = XCTestExpectation(description: "updatePassword")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            AuthClient().updatePassword(newPassword: "test", oldPassword: self.password) { code, message, userInfo in
                XCTAssert(code == 200)
                AuthClient().loginByAccount(account: self.account, password: "test") { code, message, userInfo in
                    XCTAssert(code == 200)
                    AuthClient().updatePassword(newPassword: self.password, oldPassword: "test") { code, message, userInfo in
                        XCTAssert(code == 200)
                        expectation.fulfill()
                    }
                }
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
                XCTAssert(data!.count == 0)
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
                XCTAssert(data!.count == 0)
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
                XCTAssert(data!.count == 0)
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
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testPerformanceLoginByAccount() throws {
        self.measure {
            let expectation = XCTestExpectation(description: "loginByAccount")
            AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: TIMEOUT)
        }
    }
    
    //MARK: ---------- Update profile ----------
    func testUpdateProfile() throws {
        let expectation = XCTestExpectation(description: "updateProfile")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            AuthClient().updateProfile(object: ["test": "profile"]) { code, message, userInfo in
                XCTAssert(code == 200)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testResetPasswordByFirstTimeLoginToken() throws {
        let expectation = XCTestExpectation(description: "resetPasswordByFirstTimeLoginToken")
        let userName = "t1"
        AuthClient().loginByAccount(account: userName, password: "t1") { code, message, userInfo in
            XCTAssert(code == 1639)
            AuthClient().resetPasswordByFirstTimeLoginToken(token: userInfo?.firstTimeLoginToken ?? "", password: "test1") { code, message in
                XCTAssert(code == 200)
                AuthClient().loginByAccount(account: userName, password: "test1") { code, message, userInfo in
                    XCTAssert(code == 200)
                    AuthClient().deleteAccount { code, message in
                        XCTAssert(code == 200)
                    }
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    //MARK: ---------- OIDC ----------
    
    func testOIDCRegisterByUserName() throws {
        let expectation = XCTestExpectation(description: "OIDC registerByUserName")
        OIDCClient().registerByUserName(username: "OIDCTest", password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testOIDCLoginByAccount() throws {
        let expectation = XCTestExpectation(description: "OIDC loginByAccount")
        OIDCClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testOIDCGetUserInfoByAccessToken() throws {
        let expectation = XCTestExpectation(description: "OIDC getUserInfoByAccessToken")
        OIDCClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            OIDCClient().getUserInfoByAccessToken(userInfo: userInfo) { code, message, userInfo in
                XCTAssert(code == 200)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testOIDCGetNewAccessTokenByRefreshToken() throws {
        let expectation = XCTestExpectation(description: "OIDC getNewAccessTokenByRefreshToken")
        OIDCClient().loginByAccount(account: "OIDCTest", password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            OIDCClient().getNewAccessTokenByRefreshToken(userInfo: userInfo) { code, message, userInfo in
                XCTAssert(code == 200)
                AuthClient().deleteAccount { code, message in
                    XCTAssert(code == 200)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testPerformanceOIDCLoginByAccount() throws {
        self.measure {
            let expectation = XCTestExpectation(description: "OIDC performance loginByAccount")
            OIDCClient().loginByAccount(account: account, password: password) { code, message, userInfo in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: TIMEOUT)
        }
    }
    
    //MARK: ---------- Get verification code scene ----------
    
    func testSendSms() throws {
        let expectation = XCTestExpectation(description: "sendSMS")
        AuthClient().sendSms(phone: phone) { code, message in
            XCTAssert(code == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testRegisterByPhoneCode() throws {
        let expectation = XCTestExpectation(description: "registerByPhoneCode")

        AuthClient().registerByPhoneCode(phone: phone, code: phoneCode) { code, message, userInfo in
            XCTAssert(code == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testLoginByPhoneCode() throws {
        let expectation = XCTestExpectation(description: "loginByPhoneCode")

        AuthClient().loginByPhoneCode(phone: phone, code: phoneCode) { code, message, userInfo in
            XCTAssert(code == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testBindPhone() throws {
        let expectation = XCTestExpectation(description: "bindPhone")

        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            AuthClient().bindPhone(phone: self.phone, code: self.phoneCode) { code, message, userInfo in
                XCTAssert(code == 200)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testUnbindPhone() throws {
        let expectation = XCTestExpectation(description: "unbindPhone")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            AuthClient().unbindPhone { code, message, userInfo in
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }

    func testSendEmail() throws {
        let expectation = XCTestExpectation(description: "sendEmail")
        AuthClient().sendEmail(email: emailAddress, scene: "VERIFY_CODE") { code, message in
            XCTAssert(code == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testRegisterByEmailCode() throws {
        let expectation = XCTestExpectation(description: "registerByEmailCode")

        AuthClient().registerByEmailCode(email: emailAddress, code: emailCode) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient().getCurrentUser() { code, message, data in
                XCTAssert(code == 200)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testLoginByEmailCode() throws {
        let expectation = XCTestExpectation(description: "loginByEmailCode")

        AuthClient().loginByEmail(email: emailAddress, code: emailCode) { code, message, userInfo in
            XCTAssert(code == 200)
            
            AuthClient().getCurrentUser() { code, message, data in
                XCTAssert(code == 200)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testBindEmail() throws {
        let expectation = XCTestExpectation(description: "bindEmail")

        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            AuthClient().bindEmail(email: self.emailAddress, code: self.emailCode) { code, message, userInfo in
                XCTAssert(code == 200)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testUnbindEmail() throws {
        let expectation = XCTestExpectation(description: "unbindEmail")
        AuthClient().loginByAccount(account: account, password: password) { code, message, userInfo in
            XCTAssert(code == 200)
            AuthClient().unbindEmail { code, message, userInfo in
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    //MARK: ---------- Social ----------
    func testLoginByWechat() throws {
        let expectation = XCTestExpectation(description: "loginByWechat")
        AuthClient().loginByWechat("code") { code, message, userInfo in
            XCTAssert(code == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testLoginByWeCom() throws {
        let expectation = XCTestExpectation(description: "loginByWeCom")
        AuthClient().loginByWeCom("code") { code, message, userInfo in
            XCTAssert(code == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testLoginbyWeComAgency() throws {
        let expectation = XCTestExpectation(description: "loginbyWeComAgency")
        AuthClient().loginbyWeComAgency("code") { code, message, userInfo in
            XCTAssert(code == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testLoginByLark() throws {
        let expectation = XCTestExpectation(description: "loginByLark")
        AuthClient().loginByLark("code") { code, message, userInfo in
            XCTAssert(code == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    func testLoginByApple() throws {
        let expectation = XCTestExpectation(description: "loginByApple")
        AuthClient().loginByApple("code") { code, message, userInfo in
            XCTAssert(code == 200)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: TIMEOUT)
    }
}
