//
//  CreateCategory.swift
//  Acronyms
//
//  Created by Samuel Yanez on 9/29/20.
//  Copyright © 2020 Samuel Yanez. All rights reserved.
//

import Fluent

struct CreateCategory: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories").delete()
    }
}
