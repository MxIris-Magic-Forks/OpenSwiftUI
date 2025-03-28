//
//  Defaultable.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

protocol Defaultable {
    associatedtype Value
    static var defaultValue: Value { get }
}
