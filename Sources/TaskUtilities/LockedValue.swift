//
//  LockedValue.swift
//
//
//  Created by Stuart A. Malone on 12/12/23.
//

import Foundation

/// Protect mutable data with a ``RecursiveTaskLock``.
///
/// The preferred way to protect mutable data that can be called from
/// multiple tasks is to store that data inside an actor. However, this is not
/// possible in synchronous code. ``LockedValue`` uses a ``RecursiveTaskLock``
/// to ensure that only one task calling synchronous code can access the value at a time.
///
/// - Warning: Using `LockedValue` instead of actors is subject to deadlocks
/// like the [dining philosopher's problem](https://en.wikipedia.org/wiki/Dining_philosophers_problem).
/// Use `LockedValue`s sparingly, and only in situations where it's not possible
/// to make asynchronous calls.
public final class LockedValue<Value> {
    private let lock = RecursiveTaskLock()
    private var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public func withLockedValue<T>(_ mutate: (inout Value) throws -> T) rethrows -> T {
        try lock.withLock {
            try mutate(&value)
        }
    }
}

extension LockedValue: @unchecked Sendable where Value: Sendable {}
