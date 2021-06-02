//
//  TagTests.swift
//  SluggoTests
//
//  Created by Samuel Schmidt on 5/11/21.
//

import XCTest
@testable import Sluggo

class TagTests: XCTestCase {

    let workingSingleJson = """
    {
        "id": 1,
        "team_id": 15,
        "object_uuid": "a40cb545-3ada-4656-a02d-2fdaba81fc21",
        "title": "word around office, the",
        "created": "2021-05-12T04:12:27+0000",
        "activated": null,
        "deactivated": null
    }
    """

    func testExample() {
        let tag: TagRecord? = JsonLoader.decode(data: workingSingleJson.data(using: .utf8)!)

        XCTAssertNotNil(tag)
        let tagUnwrapped = tag!

        XCTAssertEqual(tagUnwrapped.id, 1)
        XCTAssertEqual(tagUnwrapped.team_id, 15)
        XCTAssertEqual(tagUnwrapped.object_uuid,
                       UUID(uuidString: "a40cb545-3ada-4656-a02d-2fdaba81fc21"))
        XCTAssertEqual(tagUnwrapped.title, "word around office, the")
    }

    let workingMultipleJson = """
    {
        "count": 3,
        "next": null,
        "previous": null,
        "results": [
            {
                "id": 1,
                "team_id": 15,
                "object_uuid": "a40cb545-3ada-4656-a02d-2fdaba81fc21",
                "title": "word around office, the",
                "created": "2021-05-12T04:12:27+0000",
                "activated": null,
                "deactivated": null
            },
            {
                "id": 2,
                "team_id": 15,
                "object_uuid": "c849aa2a-72b3-4d3b-a919-ea479ebd04d3",
                "title": "fadsfddsafdsadfdsadfasdfasdf",
                "created": "2021-05-12T04:23:29+0000",
                "activated": null,
                "deactivated": null
            },
            {
                "id": 3,
                "team_id": 15,
                "object_uuid": "3f87b6c2-5023-411c-a139-52e10d9a02a3",
                "title": "bcc bghjncvcdfvxz",
                "created": "2021-05-12T04:23:34+0000",
                "activated": null,
                "deactivated": null
            }
        ]
    }
    """

    func testMultiple() {
        let tags: PaginatedList<TagRecord>? = JsonLoader.decode(data: workingMultipleJson.data(using: .utf8)!)
        XCTAssertNotNil(tags)
        let tagsUnwrapped = tags!

        XCTAssertEqual(tagsUnwrapped.count, 3)
        XCTAssertEqual(tagsUnwrapped.next, nil)
        XCTAssertEqual(tagsUnwrapped.previous, nil)

        // the tags individually are probably correct if everything else goes well
    }

    let brokenMultipleJson = """
    {
        "count": 3,
        "next": null,
        "previous": null,
        "results": [
            {
                "id": 1,
                "team_id": 15,
                "object_uuid": "a40cb545-3ada-4656-a02d-2fdaba81fc21",
                "title": "word around office, the",
                "created": "2021-05-12T04:12:27+0000",
                "activated": null,
                "deactivated": null
            },
            {
                "id": 2,
                "team_id": 15,
                "object_uuid": "c849aa2a-72b3-4d3b-a919-ea479ebd04d3",
                "title": "fadsfddsafdsadfdsadfasdfasdf",
                "created": "2021-05-12T04:23:29+0000",
                "activated": null,
                "deactivated": null
            },
            null
        ]
    }
    """

    func testNoneNil() {
        let tags: PaginatedList<TagRecord>? = JsonLoader.decode(data: brokenMultipleJson.data(using: .utf8)!)

        // this should fail because the data in the array must never be null
        XCTAssertNil(tags)
    }

}
