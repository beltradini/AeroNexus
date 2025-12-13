//
//  AeroNexusCLI.swift
//  AeroNexusCLI
//
//  Created by Alex Beltran on 2024.
//  Copyright © 2024 AeroNexus. All rights reserved.
//

import ArgumentParser
import AeroNexusCore

/// Command line interface for AeroNexus.
@main
struct AeroNexusCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "AeroNexus Command Line Interface",
        version: "1.0.0"
    )
    
    mutating func run() async throws {
        print("AeroNexus CLI - Flight Management System")
        // CLI functionality will be implemented here
    }
}