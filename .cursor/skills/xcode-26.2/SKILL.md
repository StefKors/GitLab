---
name: xcode-26.2
description: Fix Xcode 26.2 compiler errors and warnings in Swift files related to Swift concurrency, type system, and memory safety. Use when encountering Swift compiler errors in Xcode 26.2, especially around actor isolation, Sendable conformance, existential types, or strict language features. Applies to all .swift files in this project.
---

# Xcode 26.2 Compiler Error Resolution

Guidance for resolving Xcode 26.2 compiler errors and warnings in Swift code.

## Swift Concurrency

### Actor Isolation Errors

**Calling actor-isolated methods from nonisolated context:**
```swift
@MainActor
class MyModel {
  func update() { ... }
}

// Error: call to main actor-isolated instance method 'update()' in a synchronous nonisolated context
func runUpdate(model: MyModel) {
  model.update() // ❌
}
```

**Fix:** Isolate the caller or wrap in a Task:
```swift
@MainActor
func runUpdate(model: MyModel) {
  model.update() // ✅
}

// OR
func runUpdate(model: MyModel) {
  Task { @MainActor in
    model.update() // ✅
  }
}
```

### Protocol Conformances Crossing Actor Boundaries

**Error:** `conformance of 'MyData' to protocol 'P' crosses into main actor-isolated code`

**Options:**
1. Isolate the conformance: `struct MyData: @MainActor P`
2. Mark methods `nonisolated`: `nonisolated func f()`
3. Use `@preconcurrency`: `struct MyData: @preconcurrency P` (runtime checks)

### Sendable Closures

**Error:** `capture of non-Sendable type 'T' in a '@Sendable' closure`

**Fix:** Capture by value or make type Sendable:
```swift
callConcurrently { [result] in  // ✅ Capture by value
  print(result)
}

// OR make type Sendable
class MyModel: Sendable { ... }
```

**Error:** `sending 'x' risks causing data races`

**Fix:** Use `nonisolated(nonsending)` for async methods on non-Sendable types:
```swift
nonisolated(nonsending)
func printNameConcurrently() async {
  print(name)
}
```

### Sendable Metatypes

**Error:** `capture of non-Sendable type 'T.Type'`

**Fix:** Require `SendableMetatype` conformance:
```swift
func doSomethingStatic<T: P & SendableMetatype>(_: T.Type) {
  Task { @concurrent in
    T.doSomething() // ✅
  }
}
```

## Type System

### Existential `any` Syntax

**Error:** Protocol used as type without `any` keyword

**Fix:** Use `any` for existential types:
```swift
func sillyFunction(collection: any Collection) { // ✅
  // ...
}
```

### String Interpolation Conformance

When conforming to `StringInterpolationProtocol`, `appendInterpolation` methods must:
- Be instance methods (not `static` or `class`)
- Return `Void` or be marked `@discardableResult`
- Be at least as accessible as the containing type

## Memory Safety

### Strict Memory Safety Warnings

**Error:** Use of `@unsafe` functions or types

**Fix:** Acknowledge unsafe behavior:
```swift
// Option 1: unsafe expression
return unsafe Int(bitPattern: malloc(size))

// Option 2: @unsafe attribute
struct MyType: @unsafe CustomStringConvertible { ... }

// Option 3: @safe attribute (encapsulates unsafe)
@safe struct MyTemporaryBuffer<T> {
  private var storage: UnsafeBufferPointer<T>
}
```

## Additional Resources

For detailed documentation on specific error types, see:
- `actor-isolated-call.md` - Actor isolation issues
- `conformance-isolation.md` - Protocol conformance isolation
- `sendable-closure-captures.md` - Sendable closure requirements
- `existential-any.md` - Existential type syntax
- `strict-memory-safety.md` - Memory safety warnings
- `string-interpolation-conformance.md` - String interpolation requirements

## Quick Reference

| Error Pattern | Solution |
|--------------|----------|
| Actor-isolated call from nonisolated | Add `@MainActor` or wrap in `Task { @MainActor in }` |
| Protocol conformance crosses actor | Use `@MainActor` on conformance or `nonisolated` on methods |
| Non-Sendable capture | Capture by value `[var]` or make type `Sendable` |
| Sending risks data race | Use `nonisolated(nonsending)` for async methods |
| Protocol without `any` | Add `any` keyword: `any Collection` |
| Unsafe memory operation | Use `unsafe` expression or `@unsafe`/`@safe` attributes |
