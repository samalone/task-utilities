# TaskUtilities

TaskUtilities is a small collection of types that help troubleshoot asynchronous
Swift code and make synchronous code safe to call from an asynchronous context.

[!IMPORTANT] `RecursiveTaskLock` and `LockedValue` are only intended for unusual
cases where you must make synchronous code safe to call from multiple
asynchronous tasks. Use these classes sparingly because they are blocking and
subject to deadlocks like the
[dining philosopher's problem](https://en.wikipedia.org/wiki/Dining_philosophers_problem).
If you have the option of writing asynchronous code, Swift actors are a better
way to protect mutable state. [!IMPORTANT]

## RecursiveTaskLock

`RecursiveTaskLock` provides a lock that can be locked recursively from within a
single task. Attempting to obtain the lock from a second task when it has been
locked by another will cause the second task to block until the lock is
released. This lets you make synchronous code safe to call from asynchronous
code in cases where you cannot use Swift actors.

```swift
class Names {
    let lock = RecursiveTaskLock()
    var names: [String] = []

    func contains(name: String) -> Bool {
        lock.withLock {
            names.contains(name)
        }
    }

    func add(name: String) {
        lock.withLock {
            names.append(name)
        }
    }
}
```

## LockedValue

`LockedValue` wraps a lock around mutable data so that it can only be accessed
from one Task at a time. This is preferable to using a `RecursiveTaskLock`
directly, because it prevents you from accidentally accessing the data without
locking the lock.

```swift
class Names {
    let names = LockedValue<[String]>([])

    func contains(name: String) -> Bool {
        names.withLockedValue { names in
            names.contains(name)
        }
    }

    func add(name: String) {
        names.withLockedValue { names in
            names.append(name)
        }
    }
}
```

## TaskPath

`TaskPath` is a debugging aid to help you understand the Task structure of
asynchronous code. It allows you to give a task a name, and retrieve that name
from an arbitrary point in your code.

```swift
Task.detached {
    TaskPath.with(name: "Fetch image") {
        ...
    }
}

// In other code called from that task:
print(TaskPath.current) // Prints "{Task Fetch image}"
```

If you name the same Task a different points in your code, the call structure
will be preserved:

```swift
Task.detached {
    TaskPath.with(name: "Fetch image") {
        ...
        TaskPath.with(name: "Constructing request") {
            ...
        }
    }
}

// In other code called from the inner task:
print(TaskPath.current) // Prints "{Task Fetch image > Constructing request}"
```

## Installation

Add the package `https://github.com/samalone/task-utilities` to your Xcode
project, or add:

```swift
   .package(url: "https://github.com/samalone/task-utilities.git", from: "1.0.0"),
```

to your package dependencies in your `Package.swift` file. Then add:

```swift
   .product(name: "TaskUtilities", package: "task-utilities"),
```

to the target dependencies of your package target.
