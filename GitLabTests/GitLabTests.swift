//
//  GitLabTests.swift
//  GitLabTests
//
//  Created by Stef Kors on 13/09/2021.
//

import XCTest
import GRDB
@testable import Merger

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

    func testGitLabDateParsingFractionalSeconds() throws {
        // GitLab REST API timestamps include fractional seconds, e.g. /v4/events created_at
        let inputs = [
            "2026-08-03T14:22:31.473Z",
            "2026-08-03T14:22:31.000Z"
        ]

        for input in inputs {
            let parsedDate = Date.from(input)
            XCTAssertNotNil(parsedDate, "Failed to parse fractional-seconds timestamp: \(input)")
            if let parsedDate {
                let cal = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: parsedDate)
                XCTAssertEqual(cal.year, 2026)
                XCTAssertEqual(cal.month, 8)
                XCTAssertEqual(cal.day, 3)
                XCTAssertEqual(cal.hour, 14)
                XCTAssertEqual(cal.minute, 22)
                XCTAssertEqual(cal.second, 31)
            }
        }
    }

    func testGitLabDateParsingZuluSuffix() throws {
        // GitHub GraphQL timestamps use a plain Z suffix without fractional seconds
        let input = "2023-07-03T11:47:21Z"
        let parsedDate = Date.from(input)
        XCTAssertNotNil(parsedDate)
        if let parsedDate {
            let cal = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: parsedDate)
            XCTAssertEqual(cal.year, 2023)
            XCTAssertEqual(cal.month, 7)
            XCTAssertEqual(cal.day, 3)
            XCTAssertEqual(cal.hour, 11)
            XCTAssertEqual(cal.minute, 47)
        }
    }

    func testPushEventDecoding() throws {
        // Realistic /v4/events?action=pushed payload
        let json = """
        [
          {
            "id": 122,
            "project_id": 3,
            "action_name": "pushed new",
            "target_id": null,
            "target_iid": null,
            "target_type": null,
            "author_id": 1,
            "target_title": null,
            "created_at": "2026-08-03T14:22:31.473Z",
            "author": {"id": 1, "name": "Stef", "username": "stefkors", "avatar_url": "https://gitlab.com/uploads/avatar.png"},
            "push_data": {"commit_count": 1, "action": "created", "ref_type": "branch", "commit_from": null, "commit_to": "50c09", "ref": "feature-x", "commit_title": "add test"},
            "author_username": "stefkors"
          },
          {
            "id": 121,
            "project_id": 3,
            "action_name": "pushed to",
            "target_id": 44,
            "target_iid": 12,
            "target_type": null,
            "author_id": 1,
            "target_title": null,
            "created_at": "2026-08-03T12:10:05.012Z",
            "author": {"id": 1, "name": "Stef", "username": "stefkors", "avatar_url": null},
            "push_data": {"commit_count": 3, "action": "pushed", "ref_type": "branch", "commit_from": "abc", "commit_to": "def", "ref": "main", "commit_title": "wip"},
            "author_username": "stefkors"
          },
          {
            "id": 120,
            "project_id": 3,
            "action_name": "pushed new",
            "target_id": null,
            "target_iid": null,
            "target_type": null,
            "author_id": 1,
            "target_title": null,
            "created_at": "2026-08-02T09:00:00.000Z",
            "author": {"id": 1, "name": "Stef", "username": "stefkors", "avatar_url": null},
            "push_data": {"commit_count": 1, "action": "created", "ref_type": "tag", "commit_from": null, "commit_to": "aaa", "ref": "v1.2.0", "commit_title": "release"},
            "author_username": "stefkors"
          }
        ]
        """.data(using: .utf8)!

        let events = try JSONDecoder().decode(GitLab.PushEvents.self, from: json)

        XCTAssertEqual(events.count, 3)

        XCTAssertEqual(events[0].actionName, .pushedNew)
        XCTAssertEqual(events[0].projectID, 3)
        XCTAssertNil(events[0].targetID)
        XCTAssertEqual(events[0].pushData?.ref, "feature-x")
        XCTAssertEqual(events[0].pushData?.refType, .branch)
        XCTAssertEqual(events[0].author?.username, "stefkors")

        // target_id / target_iid arrive as integers (or null) in the events API
        XCTAssertEqual(events[1].actionName, .pushedTo)
        XCTAssertEqual(events[1].targetID, 44)
        XCTAssertEqual(events[1].targetIid, 12)
        XCTAssertEqual(events[1].pushData?.action, .pushed)

        XCTAssertEqual(events[2].pushData?.refType, .tag)
        XCTAssertEqual(events[2].pushData?.ref, "v1.2.0")
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

            let insertedAccounts = try Account.all().fetchCount(db)
            let insertedRequests = try UniversalMergeRequest.all().fetchCount(db)
            XCTAssertEqual(insertedAccounts, 1)
            XCTAssertEqual(insertedRequests, 1)

            if let accountID = account.id {
                _ = try Account.deleteOne(db, id: accountID)
            }

            let remainingRequests = try UniversalMergeRequest.all().fetchCount(db)
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
            let fetched = try LaunchpadRepo.all().fetchAll(db)
            XCTAssertEqual(fetched.count, 1)
            XCTAssertEqual(fetched.first?.name, "GitLab")
        }
    }

    func testAccountSlotPolicyFreeLimit() {
        let purchasedProductIDs = Set<String>()
        XCTAssertEqual(AccountSlotPolicy.purchasedExtraSlots(for: purchasedProductIDs), 0)
        XCTAssertEqual(AccountSlotPolicy.maxAllowedAccounts(for: purchasedProductIDs), 2)
        XCTAssertTrue(AccountSlotPolicy.canAddAccount(currentCount: 1, purchasedProductIDs: purchasedProductIDs))
        XCTAssertFalse(AccountSlotPolicy.canAddAccount(currentCount: 2, purchasedProductIDs: purchasedProductIDs))
        XCTAssertEqual(
            AccountSlotPolicy.nextRequiredProductID(for: purchasedProductIDs),
            "com.stefkors.gitlab.accountslot.3"
        )
    }

    func testAccountSlotPolicyUsesHighestUnlockedSlot() {
        let purchasedProductIDs = Set([
            "com.stefkors.gitlab.accountslot.3",
            "com.stefkors.gitlab.accountslot.5"
        ])

        XCTAssertEqual(AccountSlotPolicy.purchasedExtraSlots(for: purchasedProductIDs), 3)
        XCTAssertEqual(AccountSlotPolicy.maxAllowedAccounts(for: purchasedProductIDs), 5)
        XCTAssertEqual(
            AccountSlotPolicy.nextRequiredProductID(for: purchasedProductIDs),
            "com.stefkors.gitlab.accountslot.6"
        )
    }

    func testAccountSlotPolicyCapsAtMaximumSupportedAccounts() {
        let purchasedProductIDs = Set(["com.stefkors.gitlab.accountslot.10"])

        XCTAssertEqual(AccountSlotPolicy.maxAllowedAccounts(for: purchasedProductIDs), 10)
        XCTAssertNil(AccountSlotPolicy.nextRequiredProductID(for: purchasedProductIDs))
        XCTAssertFalse(AccountSlotPolicy.canAddAccount(currentCount: 10, purchasedProductIDs: purchasedProductIDs))
    }
}
