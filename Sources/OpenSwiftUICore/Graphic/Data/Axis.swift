//
//  Axis.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

/// The horizontal or vertical dimension in a 2D coordinate system.
@frozen
public enum Axis: Int8, CaseIterable {
    /// The horizontal dimension.
    case horizontal
    
    /// The vertical dimension.
    case vertical
    
    /// An efficient set of axes.
    @frozen
    public struct Set: OptionSet {
        public let rawValue: Int8

        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        public static let horizontal = Set(.horizontal)
        public static let vertical = Set(.vertical)

        init(_ axis: Axis) {
            self.init(rawValue: 1 << axis.rawValue)
        }
    }
}

extension Axis: CustomStringConvertible {
    public var description: String { self == .horizontal ? "horizontal" : "vertical" }
}
