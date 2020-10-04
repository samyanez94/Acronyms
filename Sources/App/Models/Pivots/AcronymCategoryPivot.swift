//
//  AcronymCategoryPivot.swift
//  Acronyms
//
//  Created by Samuel Yanez on 9/29/20.
//  Copyright © 2020 Samuel Yanez. All rights reserved.
//

import Fluent
import Foundation

final class AcronymCategoryPivot: Model {
    static let schema = "acronym-category-pivot"

    @ID
    var id: UUID?

    @Parent(key: "acronymId")
    var acronym: Acronym

    @Parent(key: "categoryId")
    var category: Category

    init() {}

    init(id: UUID? = nil,
         acronym: Acronym,
         category: Category) throws {
        self.id = id
        $acronym.id = try acronym.requireID()
        $category.id = try category.requireID()
    }
}
