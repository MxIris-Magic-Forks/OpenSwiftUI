//
//  ViewAlias.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: TODO
//  ID: D9F7AF928092578A4B8FA861B49E2161

package protocol ViewAlias: PrimitiveView {
    init()
}

extension View {
    package func viewAlias<Alias: ViewAlias, Source: View>(
        _ alias: Alias.Type,
        _ source: () -> Source
    ) -> some View {
        modifier(StaticSourceWriter<Alias, Source>(source: source()))
    }

    package func viewAlias<Alias: ViewAlias, Source: View>(
        _ alias: Alias.Type,
        _ source: () -> Source?
    ) -> some View {
        modifier(OptionalSourceWriter<Alias, Source>(source: source()))
    }
}

private struct StaticSourceWriter<Alias: ViewAlias, Source: View>: PrimitiveViewModifier, _GraphInputsModifier {
    var source: Source

    static func _makeInputs(modifier: _GraphValue<StaticSourceWriter<Alias, Source>>, inputs: inout _GraphInputs) {
        fatalError("TODO")
    }
}

private struct OptionalSourceWriter<Alias: ViewAlias, Source: View>: PrimitiveViewModifier, _GraphInputsModifier {
    var source: Source?

    static func _makeInputs(modifier: _GraphValue<OptionalSourceWriter<Alias, Source>>, inputs: inout _GraphInputs) {
        fatalError("TODO")
    }
}
