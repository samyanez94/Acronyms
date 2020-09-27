import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.post("api", "acronyms") { req -> EventLoopFuture<Acronym> in
        let acronym = try req.content.decode(Acronym.self)
        return acronym.save(on: req.db).map { acronym }
    }
    
    app.get("api", "acronyms") { req -> EventLoopFuture<[Acronym]> in
        Acronym.query(on: req.db).all()
    }
    
    app.get("api", "acronyms", ":id") { req -> EventLoopFuture<Acronym> in
        Acronym.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    app.put("api", "acronyms", ":id") { req -> EventLoopFuture<Acronym> in
        let updatedAcronym = try req.content.decode(Acronym.self)
        return Acronym.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updatedAcronym.short
                acronym.long = updatedAcronym.long
                return acronym.save(on: req.db)
                    .map { acronym }
            }
    }
    
    app.delete("api", "acronyms", ":id") { req -> EventLoopFuture<HTTPStatus> in
        Acronym.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
}
