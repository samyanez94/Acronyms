//
//  AcronymsController.swift
//  Acronyms
//
//  Created by Samuel Yanez on 9/27/20.
//  Copyright © 2020 Samuel Yanez. All rights reserved.
//

import Fluent
import Vapor

struct AcronymsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Create route group
        let acronymsRoutes = routes.grouped("api", "acronyms")

        // Register routes
        acronymsRoutes.post(use: createHandler)
        acronymsRoutes.get(":acronymId", use: getHandler)
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.put(":acronymId", use: updateHandler)
        acronymsRoutes.delete(":acronymId", use: deleteHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.get("sorted", use: sortedHandler)
        acronymsRoutes.get(":acronymId", "user", use: getUserHandler)
        acronymsRoutes.post(":acronymId", "categories", ":categoryId", use: addCategoriesHandler)
        acronymsRoutes.get(":acronymId", "categories", use: getCategoriesHandler)
        acronymsRoutes.delete(":acronymId", "categories", use: removeCategoriesHandler)
    }

    // MARK: - Handlers

    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(
            short: data.short,
            long: data.long,
            userId: data.userId
        )
        return acronym.save(on: req.db).map { acronym }
    }

    func getHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("acronymId"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }

    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updatedAcronym = try req.content.decode(Acronym.self)
        return Acronym.find(req.parameters.get("acronymId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updatedAcronym.short
                acronym.long = updatedAcronym.long
                return acronym.save(on: req.db)
                    .map { acronym }
            }
    }

    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Acronym.find(req.parameters.get("acronymId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }

    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }
            .all()
    }

    func getFirstHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }

    func sortedHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }

    func getUserHandler(_ req: Request) throws -> EventLoopFuture<User> {
        Acronym.find(req.parameters.get("acronymId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db)
            }
    }

    func addCategoriesHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        print("Yeet")
        let acronymQuery = Acronym.find(req.parameters.get("acronymId"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let categoryQuery = Category.find(req.parameters.get("categoryId"), on: req.db)
            .unwrap(or: Abort(.notFound))
        return acronymQuery.and(categoryQuery)
            .flatMap { acronym, category in
                acronym.$categories
                    .attach(category, on: req.db)
                    .transform(to: .created)
            }
    }

    func getCategoriesHandler(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Acronym.find(req.parameters.get("acronymId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$categories.get(on: req.db)
            }
    }

    func removeCategoriesHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym.find(req.parameters.get("acronymId"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let categoryQuery = Category.find(req.parameters.get("categoryId"), on: req.db)
            .unwrap(or: Abort(.notFound))
        return acronymQuery.and(categoryQuery)
            .flatMap { acronym, category in
                acronym.$categories
                    .detach(category, on: req.db)
                    .transform(to: .noContent)
            }
    }

    // MARK: - Domain Transfer Objects

    struct CreateAcronymData: Content {
        let short: String
        let long: String
        let userId: UUID
    }
}
