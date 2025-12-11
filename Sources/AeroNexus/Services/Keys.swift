import Vapor 

struct PipelineKey: StorageKey {
    typealias Value = IngestionPipeline
}

struct SchedulerKey: StorageKey {
    typealias Value = SchedulerService
}

