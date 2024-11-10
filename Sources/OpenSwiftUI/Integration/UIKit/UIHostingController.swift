#if os(iOS)
public import UIKit

@available(macOS, unavailable)
@available(watchOS, unavailable)
@MainActor
@preconcurrency
open class UIHostingController<Content> : UIViewController where Content : View {
    var host: _UIHostingView<Content>
    
    override open dynamic var keyCommands: [UIKeyCommand]? {
        // TODO
        nil
    }
    
    public init(rootView: Content) {
        // TODO
        host = _UIHostingView(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
        _commonInit()
    }
    
    public init?(coder: NSCoder, rootView: Content) {
        // TODO
        host = _UIHostingView(rootView: rootView)
        super.init(coder: coder)
        _commonInit()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) must be implemented in a subclass and call super.init(coder:, rootView:)")
    }
    
    func _commonInit() {
        host.viewController = self
        // toolbar
        // toolbar.addPreferences(to: ViewGraph)
        // ...
        // IsAppleInternalBuild
    }
    
    open override func loadView() {
        view = host
    }
    
    public var rootView: Content {
        get { host.rootView }
        _modify { yield &host.rootView }
    }
}

@available(macOS, unavailable)
extension UIHostingController: _UIHostingViewable where Content == AnyView {
}

@available(macOS, unavailable)
public func _makeUIHostingController(_ view: AnyView) -> NSObject & _UIHostingViewable {
    UIHostingController(rootView: view)
}

@available(macOS, unavailable)
public func _makeUIHostingController(_ view: AnyView, tracksContentSize: Bool) -> NSObject & _UIHostingViewable {
    let hostingController = UIHostingController(rootView: view)
    if tracksContentSize {
        // TODO: hostingController.host
        // SizeThatFitsObserver
    }
    return hostingController
}

#endif
