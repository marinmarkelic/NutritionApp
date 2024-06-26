enum QueryStatus {

    case available
    case running
    case failed

}

enum RunStatus {

    case queued
    case inProgress
    case completed
    case expired
    case failed
    case undefined

    init(from string: String) {
        switch string {
        case "queued":
            self = .queued
        case "in_progress":
            self = .inProgress
        case "completed":
            self = .completed
        case "expired":
            self = .expired
        case "failed", "incomplete", "cancelled":
            self = .failed
        default:
            self = .undefined
        }
    }

    var isStillRunning: Bool {
        self == .queued || self == .inProgress
    }

}
