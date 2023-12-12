import Foundation

/// A lock that can be recursively locked within the same task.
public final class RecursiveTaskLock: Sendable {
    private let lock = NSLock()
    @TaskLocal private static var lockedLocks: [RecursiveTaskLock] = []
    
    /// Executes the specified action with the lock locked.
    /// Only one task can obtain the lock at a time.
    public func withLock<T>(_ action: () throws -> T) rethrows -> T {
        let firstLock = !Self.lockedLocks.contains(where: {$0 === self})
        if firstLock {
            lock.lock()
        }
        defer {
            if firstLock {
                lock.unlock()
            }
        }
        return try Self.$lockedLocks.withValue(Self.lockedLocks + [self]) {
            try action()
        }
    }
}
