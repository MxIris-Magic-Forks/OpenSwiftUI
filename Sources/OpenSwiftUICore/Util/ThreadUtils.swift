//
//  ThreadUtils.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

import Foundation

final package class ThreadSpecific<T> {
    var key: pthread_key_t
    let defaultValue: T
    
    package init(_ defaultValue: T) {
        key = 0
        self.defaultValue = defaultValue
        pthread_key_create(&key) { pointer in
            #if !canImport(Darwin)
            guard let pointer else { return }
            #endif
            pointer.withMemoryRebound(to: Any.self, capacity: 1) { ptr in
                ptr.deinitialize(count: 1)
                ptr.deallocate()
            }
        }
    }

    deinit {
        preconditionFailure("\(Self.self).deinit is unsafe and would leak", file: #file, line: #line)
    }
    
    private final var box: UnsafeMutablePointer<Any> {
        let pointer = pthread_getspecific(key)
        if let pointer {
            return pointer.assumingMemoryBound(to: Any.self)
        } else {
            let box = UnsafeMutablePointer<Any>.allocate(capacity: 1)
            pthread_setspecific(key, box)
            box.initialize(to: defaultValue)
            return box
        }
    }
    
    final package var value: T {
        get {
            box.pointee as! T
        }
        set {
            box.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee = newValue }
        }
    }
}

package func onMainThread(do body: @escaping () -> Void) {
    #if os(WASI)
    // See #76: Thread and RunLoopMode.common is not available on WASI currently
    body()
    #else
    if Thread.isMainThread {
        body()
    } else {
        RunLoop.main.perform(inModes: [.common]) {
            // Workaround the @Senable warning
            body()
        }
    }
    #endif
}

package func mainThreadPrecondition() {
    #if !os(WASI)
    guard Thread.isMainThread else {
        fatalError("calling into OpenSwiftUI on a non-main thread is not supported")
    }
    #endif
}
