#if os(macOS)
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
public import OpenSwiftUICore
public import AppKit
import OpenSwiftUI_SPI

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public struct NSHostingSizingOptions: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let minSize: NSHostingSizingOptions = .init(rawValue: 1 << 0)
    public static let intrinsicContentSize: NSHostingSizingOptions = .init(rawValue: 1 << 1)
    public static let maxSize: NSHostingSizingOptions = .init(rawValue: 1 << 2)
    public static let preferredContentSize: NSHostingSizingOptions = .init(rawValue: 1 << 3)
    public static let standardBounds: NSHostingSizingOptions = .init(rawValue: 1 << 4)
}


@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public struct NSHostingSceneBridgingOptions: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let title: NSHostingSceneBridgingOptions = .init(rawValue: 1 << 0)
    public static let toolbars: NSHostingSceneBridgingOptions = .init(rawValue: 1 << 1)
    public static let all: NSHostingSceneBridgingOptions = .init(rawValue: 1 << 2)
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
open class NSHostingView<Content>: NSView, NSUserInterfaceValidations, NSDraggingSource where Content: View {
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public var sizingOptions: NSHostingSizingOptions

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public var safeAreaRegions: SafeAreaRegions

    
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public var sceneBridgingOptions: NSHostingSceneBridgingOptions
    
    final package let viewGraph: ViewGraph
    package var currentTimestamp: Time = .zero
    
    package var propertiesNeedingUpdate: ViewRendererHostProperties = .all
    
    package var renderingPhase: ViewRenderingPhase = .none
    
    package var externalUpdateCount: Int = .zero
    static func defaultViewGraphOutputs() -> ViewGraph.Outputs { .defaults }
    public required init(rootView: Content) {
        _rootView = rootView
        Update.begin()
        sizingOptions = .standardBounds
        safeAreaRegions = .all
        viewGraph = ViewGraph(
            rootViewType: ModifiedContent<Content, HitTestBindingModifier>.self,
            requestedOutputs: Self.defaultViewGraphOutputs()
        )
        initializeViewGraph()
        Update.end()
    }

    @available(*, unavailable)
    public dynamic required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    
    public final var _rendererConfiguration: _RendererConfiguration

    public final var _rendererObject: AnyObject? {
        nil
    }

    open var firstTextLineCenter: CGFloat? {
        nil
    }

    public var rootView: Content {
        _rootView
    }
    
    private var _rootView: Content

    public func validateUserInterfaceItem(_ item: any NSValidatedUserInterfaceItem) -> Bool { false }
    public func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation { [] }
    public func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {}
    public func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {}
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension NSHostingView {
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public final func _viewDebugData() -> [_ViewDebug.Data] { [] }
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension NSHostingView {
    public func _renderForTest(interval: Double) {}
    
    public func _renderAsyncForTest(interval: Double) -> Bool {
        false
    }
}

extension NSHostingView: ViewRendererHost {
    
    package func updateRootView() {
        
    }
    
    package func updateEnvironment() {
        
    }
    
    package func updateSize() {
        
    }
    
    package func updateSafeArea() {
        
    }
    
    package func updateScrollableContainerSize() {
        
    }
    
    package func renderDisplayList(_ list: DisplayList, asynchronously: Bool, time: Time, nextTime: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time {
        .infinity
    }
    
    package func requestUpdate(after: Double) {
        
    }
    
}

#endif
