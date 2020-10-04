//
//  CreateAcronymCategoryPivot.swift
//  Acronyms
//
//  Created by Samuel Yanez on 9/29/20.
//  Copyright © 2020 Samuel Yanez. All rights reserved.
//

import Fluent

struct CreateAcronymCategoryPivot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronym-category-pivot")
            .id()
            .field("acronymId", .uuid, .required, .references("acronyms", "id", onDelete: .cascade))
            .field("categoryId", .uuid, .required, .references("categories", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronym-category-pivot").delete()
    }
}
