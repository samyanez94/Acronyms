//
//  UserTests.swift
//  Acronyms
//
//  Created by Samuel Yanez on 10/03/20.
//  Copyright © 2020 Samuel Yanez. All rights reserved.
//

@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    var app: Application!

    let usersURI = "/api/users/"

    override func setUpWithError() throws {
        app = try Application.testable()
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    func testGetUsers() throws {
        let users = try [
            User.create(name: "Alice", username: "alice", on: app.db),
            User.create(name: "Luke", username: "lukes", on: app.db)
        ]

        try app.test(.GET, usersURI, afterResponse: { response in
            let responseUsers = try response.content.decode([User].self)

            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(responseUsers.count, users.count)

            for (index, _) in responseUsers.enumerated() {
                let responseUser = responseUsers[index]
                let user = users[index]
                XCTAssertEqual(responseUser.name, user.name)
                XCTAssertEqual(responseUser.username, user.username)
                XCTAssertEqual(responseUser.id, user.id)
            }
        })
    }

    func testGetUser() throws {
        let user = try User.create(name: "Alice", username: "alice", on: app.db)

        try app.test(.GET, "\(usersURI)\(user.id!)", afterResponse: { response in
            let responseUser = try response.content.decode([User].self)

            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(responseUser.first?.name, user.name)
            XCTAssertEqual(responseUser.first?.username, user.username)
            XCTAssertEqual(responseUser.first?.id, user.id)
        })
    }

    func testPostUsers() throws {
        let user = User(name: "Alice", username: "alice")

        try app.test(.POST, usersURI, beforeRequest: { request in
            try request.content.encode(user)
        }, afterResponse: { response in
            let responseUser = try response.content.decode(User.self)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(responseUser.name, user.name)
            XCTAssertEqual(responseUser.username, user.username)
            XCTAssertNotNil(responseUser.id)

            try app.test(.GET, usersURI, afterResponse: { response in
                let users = try response.content.decode([User].self)
                XCTAssertEqual(response.status, .ok)
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users.first?.name, responseUser.name)
                XCTAssertEqual(users.first?.username, responseUser.username)
                XCTAssertEqual(users.first?.id, responseUser.id)
            })
        })
    }
}
