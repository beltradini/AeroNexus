//
//  CreateTimelineEvents.swift
//  AeroNexus
//
//  Created by Alejandro Beltrán on 12/12/25.
//

import Fluent

struct CreateTimelineEvents: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(TimelineEvent.schema)
            .id()
            .field("flight_id", .uuid, .required, .references("flights", "id"))
            .field("event_type", . string, .required)
            .field("scheduled_time", .datetime, .required)
            .field("actual_time", .datetime)
            .field("estimated_time", .datetime)
            .field("location", .string, .required)
            .field("status", .string, .required)
            .field("metadata", .dictionary)
            .create()
    }
    
    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(TimelineEvent.schema).delete()
    }
}
