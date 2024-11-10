//
//  _PerformanceTest.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

import OpenSwiftUI_SPI

public protocol _PerformanceTest: _Test {
    var name: String { get }
    func runTest(host: _BenchmarkHost, options: [AnyHashable: Any])
}

extension __App {
    public static func _registerPerformanceTests(_ tests: [_PerformanceTest]) {
        TestingAppDelegate.performanceTests = tests
    }
}

extension _TestApp {
    public func runPerformanceTests(_ tests: [_PerformanceTest]) -> Never {
        fatalError("TODO")
    }
}

extension _BenchmarkHost {
    public func _started(test: _PerformanceTest) {
        #if os(iOS)
        UIApplication.shared.startedTest(test.name)
        #elseif os(macOS)
        NSApplication.shared.startedTest(test.name)
        #else
        fatalError("Unimplemented for other platform")
        #endif
    }

    public func _finished(test: _PerformanceTest) {
        #if os(iOS)
        UIApplication.shared.finishedTest(test.name)
        #elseif os(macOS)
        NSApplication.shared.finishedTest(test.name)
        #else
        fatalError("Unimplemented for other platform")
        #endif
    }

    public func _failed(test: _PerformanceTest) {
        #if os(iOS)
        UIApplication.shared.failedTest(test.name, withFailure: nil)
        #elseif os(macOS)
        NSApplication.shared.failedTest(test.name, withFailure: nil)
        #else
        fatalError("Unimplemented for other platform")
        #endif
    }
}
