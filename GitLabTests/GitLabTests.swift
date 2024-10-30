//
//  GitLabTests.swift
//  GitLabTests
//
//  Created by Stef Kors on 13/09/2021.
//

import XCTest
@testable import Merge_Requests_for_GitLab

class GitLabTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGitLabDateParsing() throws {

        let input = "2023-10-16T15:03:08+02:00"
        let parsedDate = Date.from(input)
        if let parsedDate {
            let cal = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .timeZone], from: parsedDate)
            XCTAssertEqual(cal.year, 2023)
            XCTAssertEqual(cal.month, 10)
            XCTAssertEqual(cal.day, 16)
            XCTAssertEqual(cal.hour, 15)
            XCTAssertEqual(cal.minute, 3)
            XCTAssertEqual(cal.timeZone, .init(identifier: "Europe/Oslo"))
        }
        XCTAssertTrue(parsedDate != nil)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }


    func testGitLabDateParsingBulk() throws {
        let inputs = [
            "2023-10-30T10:40:00+01:00",
            "2023-10-16T15:03:08+02:00",
            "2023-10-10T12:33:24+02:00",
            "2023-08-07T13:02:28+02:00",
            "2023-05-06T17:07:05+02:00",
            "2023-04-26T13:51:54+02:00",
            "2023-10-30T10:40:00+01:00",
            "2023-10-16T15:03:08+02:00",
            "2023-10-10T12:33:24+02:00",
            "2023-08-07T13:02:28+02:00",
            "2023-05-06T17:07:05+02:00",
            "2023-04-26T13:51:54+02:00"
        ]

        for input in inputs {
            let parsedDate = Date.from(input)
            if let parsedDate {
                XCTAssertEqual(Calendar.current.dateComponents([.year], from: parsedDate).year, 2023)
            }
            XCTAssertTrue(parsedDate != nil)
        }
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
