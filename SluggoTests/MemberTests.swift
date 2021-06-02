//
//  MemberTests.swift
//  SluggoTests
//
//  Created by Andrew Gavgavian on 4/18/21.
//

import XCTest
@testable import Sluggo

class MemberTests: XCTestCase {
    let testWorkingJson = """
    {
        "id": "c4ca4238a0b923820dcc509a6f75849bfce3644a63f700b351c5afeb783c1cc2",
        "owner": {
            "username": "wtpisaac",
            "email": "wtpisaac@icloud.com",
            "id": 1
        },
        "team_id": 1,
        "object_uuid": "2823f95d-aa66-43da-acab-34ce2bedfe13",
        "role": "UA",
        "bio": null,
        "pronouns": "he/him",
        "created": "2021-04-13T23:17:20+0000",
        "activated": null,
        "deactivated": null
    }
    """

    let testWorkingJsonWithExtraProps = """
    {
        "id": "c4ca4238a0b923820dcc509a6f75849bfce3644a63f700b351c5afeb783c1cc2",
        "owner": {
            "username": "wtpisaac",
            "email": "wtpisaac@icloud.com",
            "id": 1
        },
        "team_id": 1,
        "object_uuid": "2823f95d-aa66-43da-acab-34ce2bedfe13",
        "role": "UA",
        "bio": "I work on things very very well",
        "pronouns": "he/him",
        "created": "2021-04-13T23:17:20+0000",
        "activated": "2021-04-13T23:17:21+0000",
        "deactivated": "2021-04-13T23:17:22+0000"
    }
    """

    let testPaginated = """
    {
        "count":1,
        "next":null,
        "previous":null,
        "results":[
            {
                "id":"c74d97b01eae257e44aa9d5bade97baf332532dcfaa1cbf61e2a266bd723612c",
                "owner": {
                    "id":1,
                    "email":"sam@sam.sam",
                    "first_name":"",
                    "last_name":"",
                    "username":"sam"
                },
                "team_id":16,
                "object_uuid":"eb486ea8-660d-4d3b-850b-80c42bb4301f",
                "role":"AD",
                "bio":"asdf",
                "pronouns":null,
                "created":"2021-05-06T20:58:47+0000",
                "activated":null,
                "deactivated":null
            }
        ]
    }
    """

    func testSerializesMultiple() {
        let members: PaginatedList<MemberRecord>? = JsonLoader.decode(data: testPaginated.data(using: .utf8)!)
        XCTAssertNotNil(members)
    }

    func testMemberDoesDeserialize() {
        let member: MemberRecord? = JsonLoader.decode(data: testWorkingJson.data(using: .utf8)!)
        XCTAssertNotNil(member)

        XCTAssertEqual(member!.team_id, 1)
        XCTAssertEqual(member!.role, "UA")
        XCTAssertEqual(member!.id, "c4ca4238a0b923820dcc509a6f75849bfce3644a63f700b351c5afeb783c1cc2")

        XCTAssertNil(member!.bio)
        XCTAssertNil(member!.activated)
        XCTAssertNil(member!.deactivated)
    }

    func testUserDeserializesWithExtraProps() {
        let member: MemberRecord? = JsonLoader.decode(data: testWorkingJsonWithExtraProps.data(using: .utf8)!)
        XCTAssertNotNil(member)

        XCTAssertEqual(member!.team_id, 1)
        XCTAssertEqual(member!.role, "UA")
        XCTAssertEqual(member!.id, "c4ca4238a0b923820dcc509a6f75849bfce3644a63f700b351c5afeb783c1cc2")

        XCTAssertEqual(member!.bio, "I work on things very very well")
    }

    func testUserDoesSerialize() {
        let user = UserRecord(id: 1,
                              email: "wtpisaac@icloud.com",
                              first_name: "Isaac",
                              last_name: "Trimble-Pederson",
                              username: "wtpisaac")

        let member = MemberRecord(id: "this is an md5 eventually",
                                  owner: user,
                                  team_id: 1,
                                  object_uuid: UUID(),
                                  role: "UA",
                                  bio: nil,
                                  created: Date(),
                                  activated: nil,
                                  deactivated: nil)

        let json = JsonLoader.encode(object: member)
        XCTAssertNotNil(json)
        print(json!)

        let memberDuplicate: MemberRecord? = JsonLoader.decode(data: json!)
        XCTAssertNotNil(memberDuplicate)

        XCTAssertEqual(member.object_uuid, memberDuplicate!.object_uuid)
        XCTAssertEqual(member.team_id, memberDuplicate!.team_id)
        XCTAssertEqual(member.role, memberDuplicate!.role)
        XCTAssertEqual(member.bio, memberDuplicate?.bio)
        XCTAssertEqual(member.id, memberDuplicate!.id)
    }
}
