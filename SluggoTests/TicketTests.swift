//
//  TicketTests.swift
//  SluggoTests
//
//  Created by Andrew Gavgavian on 4/28/21.
//

import XCTest
@testable import Sluggo

class TicketTests: XCTestCase {
    let testWorkingJson = """
    {
        "id": 2,
        "ticket_number": 2,
        "object_uuid": "cefdf703-40ff-40d0-b07a-1583cc33d7d4",
        "title": "Hi",
        "description": "this is a description",
        "created": "2021-04-28T20:31:43+0000",
        "activated": "2021-04-28T20:31:43+0000",
    }
    """
    
    let testWorkingJsonWithExtraProps = """
    {
        "id": 2,
        "ticket_number": 2,
        "tag_list": [],
        "object_uuid": "cefdf703-40ff-40d0-b07a-1583cc33d7d4",
        "assigned_user": {
            "id": "c4ca4238a0b923820dcc509a6f75849bfce3644a63f700b351c5afeb783c1cc2",
            "owner": {
                "id": 1,
                "email": "agavgavi@ucsc.edu",
                "first_name": "Andrew",
                "last_name": "Gavgavian",
                "username": "agavgavi"
            },
            "team_id": 1,
            "object_uuid": "bfe12225-d80c-415e-a7ff-1b4db7fe6f7e",
            "role": "AD",
            "bio": "ADMIN",
            "created": "2021-04-28T20:24:17+0000",
            "activated": "2021-04-28T20:24:15+0000",
            "deactivated": null
        },
        "status": null,
        "title": "Hi",
        "description": "this is a description",
        "due_date": null,
        "created": "2021-04-28T20:31:43+0000",
        "activated": "2021-04-28T20:31:43+0000",
        "deactivated": null
    }
    """
    
    func testTicketDoesDeserialize() {

        let ticket: TicketRecord? = JsonLoader.decode(data: testWorkingJson.data(using: .utf8)!)
        
        XCTAssertNotNil(ticket)
        
        XCTAssertEqual(ticket!.ticket_number, 2)
        XCTAssertEqual(ticket!.title, "Hi")
        XCTAssertEqual(ticket!.id, 2)
        
        
        XCTAssertNil(ticket!.status)
        XCTAssertNil(ticket!.assigned_user)

        
    }
    
    func testTicketDeserializesWithExtraProps() {
        
        
        let memberJson = """
            {
                "id": "c4ca4238a0b923820dcc509a6f75849bfce3644a63f700b351c5afeb783c1cc2",
                "owner": {
                    "id": 1,
                    "email": "agavgavi@ucsc.edu",
                    "first_name": "Andrew",
                    "last_name": "Gavgavian",
                    "username": "agavgavi"
                },
                "team_id": 1,
                "object_uuid": "bfe12225-d80c-415e-a7ff-1b4db7fe6f7e",
                "role": "AD",
                "bio": "ADMIN",
                "created": "2021-04-28T20:24:17+0000",
                "activated": "2021-04-28T20:24:15+0000",
                "deactivated": null
            }
            """
        let ticket: TicketRecord? = JsonLoader.decode(data: testWorkingJsonWithExtraProps.data(using: .utf8)!)
        
        let member: MemberRecord? = JsonLoader.decode(data: memberJson.data(using: .utf8)!)
        
        XCTAssertNotNil(ticket)
        
        XCTAssertEqual(ticket!.ticket_number, 2)
        XCTAssertEqual(ticket!.title, "Hi")
        XCTAssertEqual(ticket!.id, 2)
        
        XCTAssertEqual(ticket!.assigned_user!.id, member!.id)
        XCTAssertEqual(ticket!.object_uuid, UUID(uuidString: "cefdf703-40ff-40d0-b07a-1583cc33d7d4"))
        
    }
    
    func testTicketDoesSerialize() {
        
        let ticket = TicketRecord(id: 1, ticket_number: 1, tag_list: nil, object_uuid: UUID(uuidString: "aa80fe7c-d346-4944-9d9e-3d7286fc4ca7")!, assigned_user: nil, status: nil, title: "Howdy Partner", description: "This is a ticket", due_date: Date(), created: Date(), activated: Date(), deactivated: Date())
        
        let json = JsonLoader.encode(object: ticket)
        XCTAssertNotNil(json)
        print(json!)
        
        let ticketDuplicate: TicketRecord? = JsonLoader.decode(data: json!)
        XCTAssertNotNil(ticketDuplicate)
        
        XCTAssertEqual(ticket.id, ticketDuplicate!.id)
        XCTAssertEqual(ticket.ticket_number, ticketDuplicate!.ticket_number)
        XCTAssertEqual(ticket.title, ticketDuplicate!.title)
        XCTAssertEqual(ticket.description, ticketDuplicate!.description)
        XCTAssertEqual(ticket.object_uuid, ticketDuplicate!.object_uuid)
    }
}
