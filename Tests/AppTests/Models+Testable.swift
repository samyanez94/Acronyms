//
//  Models+Testable.swift
//  Acronyms
//
//  Created by Samuel Yanez on 10/03/20.
//  Copyright © 2020 Samuel Yanez. All rights reserved.
//

@testable import App
import Fluent

extension User {
    
    static func create(name: String = "Luke",
                       username: String = "lukes",
                       on database: Database) throws -> User {
        let user = User(name: name, username: username)
        
        try user.save(on: database)
            .wait()
        
        return user
    }
}
