//
//  ViewController.swift
//  HostingExample-macOS
//
//  Created by JH on 2025/3/29.
//

import AppKit
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let hostingView = NSHostingView(rootView: ContentView())
        hostingView.frame = view.bounds
        view.addSubview(hostingView)
    }
    
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

struct ContentView: View {
    var body: some View {
        ConditionalContentExample()
    }
}
