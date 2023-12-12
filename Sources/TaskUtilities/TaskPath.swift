//
//  TaskPath.swift
//
//
//  Created by Stuart A. Malone on 11/18/23.
//

import Foundation

/// A debugging aid to help understand asynchronous code.
///
/// Wrap asynchronous code blocks in
/// ```
/// TaskPath.with("name") {
///     ...
/// }
/// ```
///
/// You can then use `TaskPath.current` to display the task
/// context of the executing code.
public struct TaskPath: CustomStringConvertible {
    @TaskLocal public static var current: TaskPath = .init()

    let path: String

    init(path: String = "") {
        self.path = path
    }

    /// Adds the name to the end of the TaskPath during execution of the block.
    public static func with<R>(name: String, block: () async throws -> R) async rethrows -> R {
        let p = current.path
        return try await $current.withValue(TaskPath(path: p.isEmpty ? name : p + " > " + name), operation: block)
    }

    /// Returns the string ` "{Task \(path)}"`, where `path` is the
    /// set of nested ``TaskPath/with`` call names, separated by '>' characters.
    public var description: String {
        "{Task \(path)}"
    }
}
