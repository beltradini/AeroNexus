//
//  entrypoint.swift
//  AeroNexusAPI
//
//  Created by Alex Beltran on 2024.
//  Copyright © 2024 AeroNexus. All rights reserved.
//

import Vapor
import AeroNexusCore

@main
struct AeroNexusAPIEntryPoint {
    static func main() async throws {
        let app = try await Application.make(.detect())
        try AppConfigurator.configure(app)
        _ = try await app.autoMigrate()
        try await app.execute()
    }
}