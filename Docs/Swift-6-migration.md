# Swift 6 Migration Notes

Migrated from Swift 5.1 / iOS 10 to Swift 6.2 / iOS 17+. Xcode 26.

---

## Package.swift

- `swift-tools-version` → `6.0`
- Added `.platforms`: iOS 17, tvOS 17, macOS 14
- Added `.swiftLanguageMode(.v6)` to opt the target into strict concurrency checking
- Also updated `xcodeproj` deployment targets to match (they are independent)

---

## Step 1 — Syntax: `private(set)` whitespace

Swift 6 removed the lenient parsing that allowed `private (set)`. Must be written `private(set)`.

---

## Step 2 — Syntax: `class` → `AnyObject` in protocols

`protocol Foo: class` was deprecated in Swift 5.7 and removed in Swift 6.
Both `Observable` and `WizLocalizationChangeObzerver` were updated to `: AnyObject`.

---

## Step 3 — Data models: `class` → `struct + Sendable`

`Language`, `Workspace`, `LocalizedString`, and `Project` were all pure data containers with no subclasses or identity semantics — they should always have been structs.

**Why it matters:** Swift 6 requires types that cross actor/concurrency boundaries to conform to `Sendable`. Value types (`struct`) get this for free. Reference types (`class`) need explicit conformance and careful handling.

Also removed `Project`'s `lazy var localizations` and `lazy var api` — a data model shouldn't own an API client or cache. Those belong in the actor that coordinates them (`Wiz`).

---

## Step 4 — Global mutable state: `Log.swift`

Three static vars were flagged as unsafe global mutable state:
- `dateFormat` and `logIndicators` → `let` (they never changed anyway)
- `currentLogLevel` → `nonisolated(unsafe) static var`

`nonisolated(unsafe)` is the Swift 6 escape hatch for global mutable state where you're taking manual responsibility for thread safety. Appropriate here since log level is only set once at startup.

---

## Step 5 — `StringsCaches`: `class` → `actor`

The singleton cache manager had a shared mutable `[String: Cache]` dictionary accessed from multiple threads. Converting to an `actor` makes this compiler-verified: only one task can be inside the actor at a time, so all reads and writes are serialized automatically.

Callers now `await` its methods.

---

## Step 6 — Networking layer: `@Sendable` closures + `@unchecked Sendable`

`URLSession.dataTask` takes a `@Sendable` completion handler. When our `CompletionWithResult` typealias wasn't marked `@Sendable`, the compiler flagged every closure that captured it.

Fix: add `@Sendable` to the typealias and to each completion parameter in `WizApiService`.

`NetworkService` and `WizApiService` are marked `@unchecked Sendable` — they own only thread-safe state, but `NSObject` inheritance and the completion-handler pattern prevent the compiler from proving it automatically. Phase 2 will replace this networking layer entirely.

Also moved API key injection out of `WizApiRequest` (which was reaching into the `Wiz` actor synchronously) and into `WizApiService`, which injects the `x-api-key` header after building the `URLRequest`.

---

## Step 7 — `Wiz`: `class` → `actor`

The centerpiece change. Converting the main SDK class to an `actor`:

- All stored properties become actor-isolated — the compiler now verifies thread safety instead of relying on `DispatchQueue` convention
- `DispatchQueue` usage replaced with `Task {}` and `await`
- `sharedInstance` → `shared` (kept old name as alias)
- Legacy completion-handler APIs bridged to `async/await` via `withCheckedThrowingContinuation`
- Observer list changed from `NSHashTable` (not `Sendable`) to `[ObjectIdentifier: WeakObserver]`
- Language-change notifications dispatched to `@MainActor` via `await MainActor.run {}`

---

## Step 8 — `UIKit+Extensions`: `@MainActor` protocol + synchronous snapshot

**Protocol isolation:** All UIKit types are `@MainActor`-isolated in Swift 6. Conforming them to a non-`@MainActor` protocol causes a "conformance crosses actor isolation" error. Fix: mark `WizLocalizable` as `@MainActor`.

**Associated object keys:** Changed `var` → `nonisolated(unsafe) var`. Must be `var` (not `let`) because Swift only allows `&variable` (inout coercion) on mutable values, even when using the address as a pointer key. `nonisolated(unsafe)` satisfies the global mutable state rule — these are never actually mutated.

**String lookup — Swift 6.2 region-based isolation:** `Task { @MainActor in await actor.method() }` triggers a region-isolation error in Swift 6.2, even for `Sendable` return types like `String`. The compiler tracks that the value originated in the `Wiz` actor's memory region and is strict about the transfer back to `@MainActor`.

Fix: added `nonisolated(unsafe) var _snapshot: [String: String]` to the `Wiz` actor. The actor writes to this after each successful string fetch. UIKit reads from it synchronously via `nonisolated func getString(forKey:)` — no `await`, no region crossing. A momentarily stale read is acceptable for UI; the next language-change notification triggers a re-localize.

This pattern — actor as writer, synchronous snapshot as reader — is also the foundation for Phase 2's local cache architecture.

---

## Key Swift 5 → 6 concepts encountered

| Concept | Where it appeared |
|---------|------------------|
| `class` → `AnyObject` in protocols | `Observable`, `WizLocalizationChangeObzerver` |
| `Sendable` for value types vs. classes | All data models |
| `@Sendable` on escaping closures | `NetworkService`, `WizApiService` |
| `@unchecked Sendable` for legacy classes | `Cache`, `NetworkService`, `WizApiService`, `WizError` |
| `actor` for shared mutable state | `StringsCaches`, `Wiz` |
| `nonisolated(unsafe)` for global state | `Log`, `UIKit+Extensions` storage keys, `Wiz._snapshot` |
| `@MainActor` protocol isolation | `WizLocalizable` |
| `withCheckedThrowingContinuation` | Bridging completion handlers in `Wiz` |
| Region-based isolation (Swift 6.2) | UIKit string lookup — resolved via synchronous snapshot |
