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

open class NSHostingController<Content>: NSViewController where Content: View {}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
open class NSHostingView<Content>: NSView, XcodeViewDebugDataProvider where Content: View {
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public var sizingOptions: NSHostingSizingOptions = .standardBounds

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public var safeAreaRegions: SafeAreaRegions = .all {
        didSet {}
    }

    // @available(iOS, unavailable)
    // @available(tvOS, unavailable)
    // @available(watchOS, unavailable)
    // @available(visionOS, unavailable)
    // public var sceneBridgingOptions: NSHostingSceneBridgingOptions

    // TODO:
    // var sceneStorageValues: SceneStorageValues?

    private var _rootView: Content

    package final let viewGraph: ViewGraph

    package final let renderer = DisplayList.ViewRenderer(platform: .init(definition: NSViewPlatformViewDefinition.self))

    package var currentTimestamp: Time = .zero

    package var propertiesNeedingUpdate: ViewRendererHostProperties = .all

    package var renderingPhase: ViewRenderingPhase = .none

    package var isHiddenForReuse: Bool = false {
        didSet {
            updateRemovedState()
        }
    }

    package var externalUpdateCount: Int = .zero

    var canAdvanceTimeAutomatically = true

    var needsDeferredUpdate = false

    var isPerformingLayout: Bool {
        if renderingPhase == .rendering {
            return true
        }
        return externalUpdateCount > 0
    }

    public required init(rootView: Content) {
        self._rootView = rootView
        Update.begin()
        self.viewGraph = ViewGraph(
            rootViewType: ModifiedContent<Content, HitTestBindingModifier>.self,
            requestedOutputs: Self.defaultViewGraphOutputs()
        )
        super.init(frame: .zero)
        initializeViewGraph()
        Update.end()
    }

    @available(*, unavailable)
    public dynamic required init?(coder aDecoder: NSCoder) {
        // TODO:
        fatalError()
    }

    /// The renderer configuration of the hosting view.
    public final var _rendererConfiguration: _RendererConfiguration {
        get {
            Update.locked { renderer.configuration }
        }
        set {
            Update.locked { renderer.configuration = newValue }
        }
    }

    /// An optional object representing the current renderer.
    public final var _rendererObject: AnyObject? {
        Update.locked {
            renderer.exportedObject(rootView: self)
        }
    }

    open var firstTextLineCenter: CGFloat? {
        nil
    }

    private var isUpdating = false
    
    open override func layout() {
        super.layout()
        guard canAdvanceTimeAutomatically else {
            return
        }
        guard !isPerformingLayout else {
            needsDeferredUpdate = true
            return
        }

        Update.locked {
            cancelAsyncRendering()
        }
        
        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = false
            isUpdating = true
            render()
            isUpdating = false
        }
    }

    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
    }

    func setRootView(_ view: Content, transaction: Transaction) {
        _rootView = view
        viewGraph.asyncTransaction(transaction) { [weak self] in
            guard let self else { return }
            updateRootView()
        }
    }

    public var rootView: Content {
        get { _rootView }
        set {
            _rootView = newValue
            invalidateProperties(.rootView)
        }
    }

    var initialInheritedEnvironment: EnvironmentValues? = nil

    var inheritedEnvironment: EnvironmentValues? = nil {
        didSet {
            invalidateProperties(.environment)
        }
    }

    package var environmentOverride: EnvironmentValues? = nil {
        didSet {
            invalidateProperties(.environment)
        }
    }

    private lazy var foreignSubviews: NSHashTable<NSView>? = NSHashTable.weakObjects()

    private var isInsertingRenderedSubview: Bool = false

    weak var viewController: NSHostingController<Content>? = nil {
        didSet {}
    }

    var colorScheme: ColorScheme? = nil {
        didSet {}
    }

    public final func _viewDebugData() -> [_ViewDebug.Data] { [] }

    /// TODO:
    func clearUpdateTimer() {}

    /// TODO:
    func cancelAsyncRendering() {
//        Update.locked {
//            displayLink?.cancelAsyncRendering()
//        }
    }

    /// FIXME:
    func _forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {
        let tree = preferenceValue(_IdentifiedViewsKey.self)
        let adjustment = { [weak self](rect: inout CGRect) in
            guard let self else { return }
            rect = convert(rect, from: nil)
        }
        tree.forEach { proxy in
            var proxy = proxy
            proxy.adjustment = adjustment
            body(proxy)
        }
    }

    package func makeViewDebugData() -> Data? {
        Update.ensure {
            _ViewDebug.serializedData(viewGraph.viewDebugData())
        }
    }

    static func defaultViewGraphOutputs() -> ViewGraph.Outputs { .defaults }
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSHostingView {
    public func _renderForTest(interval: Double) {}

    public func _renderAsyncForTest(interval: Double) -> Bool {
        false
    }
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSHostingView {
    func makeRootView() -> ModifiedContent<Content, HitTestBindingModifier> {
        NSHostingView.makeRootView(
            rootView
        )
    }

    func updateRemovedState() {
        var removedState: GraphHost.RemovedState = []
        if window == nil {
            removedState.insert(.unattached)
        }
        if isHiddenForReuse {
            removedState.insert(.hiddenForReuse)
            Update.locked {
                cancelAsyncRendering()
            }
        }
        Update.ensure {
            viewGraph.removedState = removedState
        }
    }
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSHostingView: ViewRendererHost {
    package func updateEnvironment() {}

    package func updateSize() {}

    package func updateSafeArea() {}

    package func updateScrollableContainerSize() {}

    package func renderDisplayList(_ list: DisplayList, asynchronously: Bool, time: Time, nextTime: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time {
        .infinity
    }

    package func updateRootView() {
        let rootView = makeRootView()
        viewGraph.setRootView(rootView)
    }

    package func requestUpdate(after: Double) {}
}

@_spi(Private)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSHostingView: HostingViewProtocol {
    public func convertAnchor<Value>(_ anchor: Anchor<Value>) -> Value {
        anchor.convert(to: viewGraph.transform)
    }
}
#endif
