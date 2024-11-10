//
//  UIHostingView.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: FAF0B683EB49BE9BABC9009857940A1E

#if os(iOS)
@_spi(ForOpenSwiftUIOnly) public import OpenSwiftUICore
public import UIKit

@available(macOS, unavailable)
@available(watchOS, unavailable)
open class _UIHostingView<Content>: UIView where Content: View {
    private var _rootView: Content
    package var viewGraph: ViewGraph
    package var currentTimestamp: Time = .zero
    package var propertiesNeedingUpdate: ViewRendererHostProperties = [.rootView] // FIXME
    package var isRendering: Bool = false
    var inheritedEnvironment: EnvironmentValues?
    var environmentOverride: EnvironmentValues?
    weak var viewController: UIHostingController<Content>?
    var displayLink: DisplayLink?
    var lastRenderTime: Time = .zero
    var canAdvanceTimeAutomatically = true
    var allowLayoutWhenNotVisible = false
    var isEnteringForeground = false
    
    public init(rootView: Content) {
        // TODO
        _rootView = rootView
        viewGraph = ViewGraph(rootViewType: Content.self, requestedOutputs: []) // Fixme
        // TODO
        // FIXME
        super.init(frame: .zero)
        
        initializeViewGraph()
        // TODO
    }
    
    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        updateRemovedState()
        NotificationCenter.default.removeObserver(self)
        clearDeisplayLink()
        clearUpdateTimer()
        invalidate()
        Update.ensure {
            viewGraph.preferenceBridge = nil
            viewGraph.invalidate()
        }
    }
    
    func setRootView(_ view: Content, transaction: Transaction) {
        _rootView = view
        let mutation = CustomGraphMutation { [weak self] in
            guard let self else { return }
            updateRootView()
        }
        viewGraph.asyncTransaction(
            transaction,
            mutation: mutation,
            style: .deferred,
            mayDeferUpdate: true
        )
    }
    
    var rootView: Content {
        get { _rootView }
        set {
            _rootView = newValue
            invalidateProperties(.init(rawValue: 1), mayDeferUpdate: true)
        }
    }
    
    func makeRootView() -> some View {
        _UIHostingView.makeRootView(rootView/*.modifier(EditModeScopeModifier(editMode: .default))*/)
    }
        
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    final public func _viewDebugData() -> [_ViewDebug.Data] {
        // TODO
        []
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard updatesWillBeVisible || allowLayoutWhenNotVisible else {
            return
        }
        guard canAdvanceTimeAutomatically else {
            return
        }
        Update.locked {
            cancelAsyncRendering()
            let interval: Double
            if let displayLink, displayLink.willRender {
                interval = .zero
            } else {
                interval = renderInterval(timestamp: .systemUptime) / UIAnimationDragCoefficient()
            }
            render(interval: interval)
            allowLayoutWhenNotVisible = false
        }
    }
    
    var updatesWillBeVisible: Bool {
        guard let window,
              let scene = window.windowScene else {
            return false
        }
        let environment = inheritedEnvironment ?? traitCollection.baseEnvironment
        switch scene.activationState {
        case .unattached, .foregroundActive, .foregroundInactive:
            return true
        case .background:
            fallthrough
        @unknown default:
            if isEnteringForeground {
                return true
            }
            return environment.scenePhase != .background
        }
    }
    
    func cancelAsyncRendering() {
        Update.locked {
            displayLink?.cancelAsyncRendering()
        }
    }
    
    private func renderInterval(timestamp: Time) -> Double {
        if lastRenderTime == .zero || lastRenderTime > timestamp {
            lastRenderTime = timestamp - 1e-6
        }
        let interval = timestamp - lastRenderTime
        lastRenderTime = timestamp
        return interval
    }
    
    // TODO
    func clearDeisplayLink() {
    }
    
    // TODO
    func clearUpdateTimer() {
    }
}

extension _UIHostingView: ViewRendererHost {
    package var renderingPhase: OpenSwiftUICore.ViewRenderingPhase {
        get {
            fatalError("TODO")
        }
        set(newValue) {
            fatalError("TODO")
        }
    }
    
    package var externalUpdateCount: Int {
        get {
            fatalError("TODO")
        }
        set(newValue) {
            fatalError("TODO")
        }
    }
    
    package func updateEnvironment() {
        fatalError("TODO")
    }
    
    package func updateSize() {
        fatalError("TODO")
    }
    
    package func updateSafeArea() {
        fatalError("TODO")
    }
    
    package func updateScrollableContainerSize() {
        fatalError("TODO")
    }
    
    package func renderDisplayList(_ list: DisplayList, asynchronously: Bool, time: Time, nextTime: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time {
        fatalError("TODO")
    }
    
    package func addImplicitPropertiesNeedingUpdate(to _: inout ViewRendererHostProperties) {}

    package func updateRootView() {
        let rootView = makeRootView()
        viewGraph.setRootView(rootView)
    }
    
    package func requestUpdate(after: Double) {
        // TODO
    }
    
    package func modifyViewInputs(_ inputs: inout _ViewInputs) {
        // TODO
    }
    
    package func outputsDidChange(outputs: ViewGraph.Outputs) {
        // TODO
    }
    
    package func focusDidChange() {
        // TODO
    }
    
    package func rootTransform() -> ViewTransform {
        fatalError("TODO")
    }
    
    public func graphDidChange() {
        // TODO
    }
    
    public func preferencesDidChange() {
        // TODO
    }
    
    func updateRemovedState() {
        // TODO
    }
}

extension UITraitCollection {
    var baseEnvironment: EnvironmentValues {
        // TODO
        EnvironmentValues()
    }
}

@_silgen_name("UIAnimationDragCoefficient")
private func UIAnimationDragCoefficient() -> Double

#endif
