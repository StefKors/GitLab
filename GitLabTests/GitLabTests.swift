//
//  GitLabTests.swift
//  GitLabTests
//
//  Created by Stef Kors on 13/09/2021.
//

import XCTest
import GRDB
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
            XCTAssertEqual(cal.timeZone?.secondsFromGMT(), 2 * 60 * 60)
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

    func testGitLabDateParsingInvalidInput() throws {
        let invalidInputs = [
            "",
            "not-a-date",
            "2023-13-40T99:99:99+99:99"
        ]

        for input in invalidInputs {
            XCTAssertNil(Date.from(input))
        }
    }

    func testPerformanceExample() throws {
        XCTAssertTrue(true)
    }

}

final class ReliabilityTests: XCTestCase {
    private func makeDatabase() throws -> DatabaseQueue {
        let db = try DatabaseQueue()
        try db.write { db in
            try db.create(table: "account") { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("token", .text).notNull()
                table.column("instance", .text).notNull()
                table.column("provider", .jsonb).notNull()
                table.column("createdAt", .datetime).notNull()
            }

            try db.create(table: "universalMergeRequest") { table in
                table.column("id", .text).notNull().unique()
                table.column("requestID", .text).notNull()
                table.column("createdAt", .datetime).notNull()
                table.column("provider", .jsonb).notNull()
                table.column("mergeRequest", .jsonb)
                table.column("pullRequest", .jsonb)
                table.column("accountsId", .integer)
                    .references("account", column: "id", onDelete: .cascade)
                    .notNull()
                table.column("type", .jsonb)
            }

            try db.create(table: "launchpadRepo") { table in
                table.column("id", .text).notNull().unique()
                table.column("name", .text).notNull()
                table.column("image", .blob)
                table.column("imageURL", .jsonb)
                table.column("group", .text).notNull()
                table.column("url", .jsonb).notNull()
                table.column("createdAt", .datetime).notNull()
                table.column("updatedAt", .datetime).notNull()
                table.column("provider", .jsonb)
                table.column("hasUpdatedSinceLaunch", .boolean).notNull().defaults(to: false)
            }
        }

        return db
    }

    func testGitHubClientRejectsInvalidInstances() {
        XCTAssertThrowsError(try NetworkManagerGitHub.shared.getClient(instance: ""))
        XCTAssertThrowsError(try NetworkManagerGitHub.shared.getClient(instance: "ftp://github.com"))
    }

    func testGitLabClientRejectsInvalidInstances() {
        XCTAssertThrowsError(try NetworkManagerGitLab.shared.getClient(instance: ""))
        XCTAssertThrowsError(try NetworkManagerGitLab.shared.getClient(instance: "file://local"))
    }

    func testGitHubClientNormalizesDotComInstance() {
        XCTAssertNoThrow(try NetworkManagerGitHub.shared.getClient(instance: "https://github.com"))
        XCTAssertNoThrow(try NetworkManagerGitHub.shared.getClient(instance: "https://api.github.com"))
    }

    func testAccountAndMergeRequestCRUDAndCascadeDelete() throws {
        let db = try makeDatabase()

        var account = Account(token: "token", instance: "https://gitlab.com", provider: .GitLab)
        let request = UniversalMergeRequest(request: .preview, account: account, provider: .GitLab, type: .authoredMergeRequests)

        try db.write { db in
            try account.insert(db)
            var insertedRequest = request
            insertedRequest.accountsId = account.id
            try insertedRequest.insert(db)

            let insertedAccounts = try Account.fetchCount(db)
            let insertedRequests = try UniversalMergeRequest.fetchCount(db)
            XCTAssertEqual(insertedAccounts, 1)
            XCTAssertEqual(insertedRequests, 1)

            if let accountID = account.id {
                _ = try Account.deleteOne(db, id: accountID)
            }

            let remainingRequests = try UniversalMergeRequest.fetchCount(db)
            XCTAssertEqual(remainingRequests, 0)
        }
    }

    func testLaunchpadRepoCRUD() throws {
        let db = try makeDatabase()
        var repo = LaunchpadRepo(
            id: "repo-1",
            name: "GitLab",
            group: "stefkors",
            url: URL(string: "https://gitlab.com/stefkors/gitlab")!,
            provider: .GitLab,
            hasUpdatedSinceLaunch: true
        )

        try db.write { db in
            try repo.insert(db)
            let fetched = try LaunchpadRepo.fetchAll(db)
            XCTAssertEqual(fetched.count, 1)
            XCTAssertEqual(fetched.first?.name, "GitLab")
        }
    }
}
