//
//  GitUserTests.swift
//  GitUserTests
//
//  Created by Rey Sayas on 7/27/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import XCTest
@testable import GitUser

class GitUserTests: XCTestCase {
    
    var coreDataService: CoreDataService?
    
    override func setUp() {
        super.setUp()
        coreDataService = CoreDataService.sharedInstance
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    // Be sure to test this when the api github api rate limit reset.
    func test_a_requestApi() {
        print("================= A ===============")
        let expectation = XCTestExpectation(description: "Semaphore")
        requestAPI(expectation: expectation)
        wait(for: [expectation], timeout: 20.0)
        print("================= A ===============")
    }
    
    private func requestAPI(expectation: XCTestExpectation) {
        var count = 0;
        for n in 1...100 {
            let randomInt = Int.random(in: 0...1);
            let priority: DispatchPriority?
            
            if randomInt == 1 {
                priority = .high
            } else {
                priority = .low
            }
            
            ApiService.shared.getUserList(dispatchPriority: priority!) { (result) in
                switch result {
                case .success( _):
                    // Save returned data on Device
                    print("Index: \(n)")
                    print("Priority: \(String(describing: priority))")
                    print("Count: \(count)")
                    print("======================")
                    
                    if count == 99 {
                        expectation.fulfill()
                    } else {
                        count += 1
                    }
                case .failure(let error):
                    print(error.localizedDescription);
                }
            }
        }
    }
    
    func test_init_coreDataManager() {
        let instance = CoreDataService.sharedInstance
        XCTAssertNotNil( instance )
    }
    
    func test_coreDataStackInitialization() {
        let coreDataStack = CoreDataService.sharedInstance.persistentContainer
        XCTAssertNotNil( coreDataStack )
    }
    
    func test_insert_users() {
        let expectation = XCTestExpectation(description: "Insert Users in Core data")
        usersRequestAPI(expectation: expectation)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func usersRequestAPI(expectation: XCTestExpectation) {
        let priority: DispatchPriority = .high
        ApiService.shared.getUserList(dispatchPriority: priority) { (result) in
            switch result {
            case .success(let result):
                // Save returned data on Device
                self.coreDataService?.insertUser(users: result.data, withProgress: { (count, total) in
                    print("Total Save: \(count) / \(total)")
                }, complete: {
                    expectation.fulfill()
                })
            case .failure(let error):
                print(error.localizedDescription);
            }
        }
    }
    
    func test_fetch_allUsers() {
        let results = coreDataService?.getAllUsers()
        XCTAssertEqual(results?.count, 30)
    }
    
    func test_update_user_note() {
        let results = coreDataService?.getAllUsers()
        var user = results?.first
        
        let note = "This is a test"
        
        user?.note = note
        
        coreDataService?.updateUserDetails(user: user!, complete: {
            let _results = self.coreDataService?.getAllUsers()
            let _user = _results?.first
            XCTAssertEqual(note, _user?.note)
        })
    }
    
    func test_flush_users() {
        coreDataService?.deleteAllUsers {
            let results = self.coreDataService?.getAllUsers()
            XCTAssertEqual(results?.count, 0)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
    }

}
