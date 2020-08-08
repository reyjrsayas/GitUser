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
            
//            ApiService.shared.getUserList(dispatchPriority: priority!) { (result) in
//                switch result {
//                case .success(let response):
//                    // Save returned data on Device
//                    print("Index: \(n)")
//                    print("Priority: \(priority)")
//                    print("Count: \(count)")
//                    print("======================")
//                    
//                    if count == 99 {
//                        expectation.fulfill()
//                    } else {
//                        count += 1
//                    }
//                case .failure(let error):
//                    print(error.localizedDescription);
//                }
//            }
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
    }

}
