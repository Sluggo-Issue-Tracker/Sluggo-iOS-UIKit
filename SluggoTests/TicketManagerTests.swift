//
//  TicketManagerTests.swift
//  SluggoTests
//
//  Created by Isaac Trimble-Pederson on 5/11/21.
//

import XCTest
@testable import Sluggo

class TicketManagerTests: XCTestCase {
    var identity: AppIdentity!
    var exampleUser: UserRecord!
    var exampleMember: MemberRecord!

    override func setUp() {
        let team = TeamRecord(id: 1,
                              name: "bugslotics",
                              object_uuid: UUID(),
                              ticket_head: 1,
                              created: Date(timeIntervalSince1970: 0),
                              activated: nil,
                              deactivated: nil)

        identity = AppIdentity()
        identity.team = team
        identity.baseAddress = Constants.Config.URL_BASE

        exampleUser = UserRecord(id: 1,
                                 email: "sammy@ucsc.edu",
                                 first_name: "Sammy",
                                 last_name: "Slug",
                                 username: "sammytheslug")
        exampleMember = MemberRecord(id: UUID().uuidString,
                                     owner: exampleUser,
                                     team_id: 1,
                                     object_uuid: UUID(),
                                     role: "AD",
                                     bio: nil,
                                     created: Date(timeIntervalSince1970: 0),
                                     activated: nil,
                                     deactivated: nil)
    }

    func testListURLGeneration() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let ticketManager = TicketManager(identity)
        let obtainedURL = ticketManager.makeListUrl(page: 1, assignedMember: nil)

        XCTAssertEqual(obtainedURL, URL(string: "http://127.0.0.1:8000/api/teams/1/tickets/?page=1")!)
    }

    func testListURLGenerationWithAssignedFilter() throws {
        let ticketManager = TicketManager(identity)
        let obtainedURL = ticketManager.makeListUrl(page: 1, assignedMember: exampleMember)
        let url = URL(string:
                        "http://127.0.0.1:8000/api/teams/1/tickets/?page=1&assigned_user__owner__username=sammytheslug")

        XCTAssertEqual(obtainedURL, url)
    }

}
