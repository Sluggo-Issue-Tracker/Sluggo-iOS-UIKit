//
//  UserTests.swift
//  SluggoTests
//
//  Created by Isaac Trimble-Pederson on 4/18/21.
//

import XCTest
@testable import Sluggo

class UserTests: XCTestCase {
    let testWorkingJson = """
    {
        "username": "wtpisaac",
        "email": "wtpisaac@icloud.com",
        "id": 1
    }
    """
    
    let testWorkingJsonWithExtraProps = """
    {
        "username": "wtpisaac",
        "email": "wtpisaac@icloud.com",
        "id": 1,
        "first_name": "Isaac",
        "last_name": "Trimble-Pederson"
    }
    """
    
    func testUserDoesDeserialize() {
        let user: UserRecord? = JsonLoader.decode(data: testWorkingJson.data(using: .utf8)!)
        XCTAssertNotNil(user)
        
        XCTAssertEqual(user!.username, "wtpisaac")
        XCTAssertEqual(user!.email, "wtpisaac@icloud.com")
        XCTAssertEqual(user!.id, 1)
        
        XCTAssertNil(user!.first_name)
        XCTAssertNil(user!.last_name)
    }
    
    func testUserDeserializesWithExtraProps() {
        let user: UserRecord? = JsonLoader.decode(data: testWorkingJsonWithExtraProps.data(using: .utf8)!)
        XCTAssertNotNil(user)
        
        XCTAssertEqual(user!.username, "wtpisaac")
        XCTAssertEqual(user!.email, "wtpisaac@icloud.com")
        XCTAssertEqual(user!.id, 1)
        
        XCTAssertEqual(user!.first_name, "Isaac")
        XCTAssertEqual(user!.last_name, "Trimble-Pederson")
    }
    
    func testUserDoesSerialize() {
        let user = UserRecord(id: 1, email: "wtpisaac@icloud.com", first_name: "Isaac", last_name: "Trimble-Pederson", username: "wtpisaac")
        
        let json = JsonLoader.encode(object: user)
        XCTAssertNotNil(json)
        print(json!)
        
        let userDuplicate: UserRecord? = JsonLoader.decode(data: json!)
        XCTAssertNotNil(userDuplicate)
        
        XCTAssertEqual(user.username, userDuplicate!.username)
        XCTAssertEqual(user.email, userDuplicate!.email)
        XCTAssertEqual(user.first_name, userDuplicate!.first_name)
        XCTAssertEqual(user.last_name, userDuplicate!.last_name)
        XCTAssertEqual(user.id, userDuplicate!.id)
    }
}
