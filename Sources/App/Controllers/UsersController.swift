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
        usersRoute.get(":id", use: getAllHandler)
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
        User.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}
