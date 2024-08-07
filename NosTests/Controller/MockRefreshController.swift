import Foundation

/// A refresh controller used for testing.
class MockRefreshController: RefreshController {
    var shouldRefresh = false
    var lastRefreshDate: Date?

    func setShouldRefresh(_ shouldRefresh: Bool) {
    }
    
    func setLastRefreshDate(_ lastRefreshDate: Date) {
    }
}
