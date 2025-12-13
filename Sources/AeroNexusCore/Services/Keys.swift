import Vapor 

public struct PipelineKey: StorageKey {
    public typealias Value = IngestionPipeline
}

public struct SchedulerKey: StorageKey {
    public typealias Value = SchedulerService
}

public struct TimelineGeneratorKey: StorageKey {
    public typealias Value = TimelineGenerator
}

