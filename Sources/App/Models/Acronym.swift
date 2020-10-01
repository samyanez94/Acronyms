//
//  Acronym.swift
//  Acronyms
//
//  Created by Samuel Yanez on 9/27/20.
//  Copyright © 2020 Samuel Yanez. All rights reserved.
//

import Fluent
import Vapor

final class Acronym: Model, Content {
    
    static let schema = "acronyms"
    
    @ID
    var id: UUID?
    
    @Field(key: "short")
    var short: String
    
    @Field(key: "long")
    var long: String
    
    @Parent(key: "userId")
    var user: User
    
    @Siblings(through: AcronymCategoryPivot.self, from: \.$acronym,to: \.$category)
    var categories: [Category]
    
    init() {}
    
    init(id: UUID? = nil,
         short: String,
         long: String,
         userId: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userId
    }
}
