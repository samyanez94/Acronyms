//
//  UsersController.swift
//  Acronyms
//
//  Created by Samuel Yanez on 9/27/20.
//  Copyright © 2020 Samuel Yanez. All rights reserved.
//

import Vapor

struct UsersController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        // Create route group.
        let usersRoute = routes.grouped("api", "users")
        
        // Register routes.
        usersRoute.post(use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(":userId", use: getAllHandler)
        usersRoute.get(":userId", "acronyms", use: getAcronymsHandler)
    }
    
    // MARK: - Handlers

    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<User> {
        User.find(req.parameters.get("userId"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAcronymsHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        User.find(req.parameters.get("userId"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { user in
                user.$acronyms.get(on: req.db)
            }
    }
}
