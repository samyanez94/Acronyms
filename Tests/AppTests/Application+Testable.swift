//
//  Application+Testable.swift
//  Acronyms
//
//  Created by Samuel Yanez on 10/03/20.
//  Copyright © 2020 Samuel Yanez. All rights reserved.
//

import XCTVapor
import App

extension Application {
    
    static func testable() throws -> Application {
        let app = Application(.testing)
        
        try configure(app)
        
        try app.autoRevert()
            .wait()
        
        try app.autoMigrate()
            .wait()
        
        return app
    }
}
