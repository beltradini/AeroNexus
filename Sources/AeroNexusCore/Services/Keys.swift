import Vapor 
import RediStack

public struct PipelineKey: StorageKey {
    public typealias Value = IngestionPipeline
}

public struct SchedulerKey: StorageKey {
    public typealias Value = SchedulerService
}

public struct TimelineGeneratorKey: StorageKey {
    public typealias Value = TimelineGenerator
}

public struct RedisServiceKey: StorageKey {
    public typealias Value = RedisService
}

public struct FlightStateEngineKey: StorageKey {
    public typealias Value = FlightStateEngine
}

