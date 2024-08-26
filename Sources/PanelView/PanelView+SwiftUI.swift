//
//  PanelView+SwiftUI.swift
//
//
//  Created by eclypse on 7/16/24.
//

import SwiftUI

internal final class SwiftUIViewWrapper: View {

    private let internalView: AnyView
    let originalView: Any

    init<V: View>(_ view: V) {
        internalView = AnyView(view)
        originalView = view
    }
    
    var body: some View {
        internalView
    }
}

public extension PanelView {
    /// pass any SwiftUI view to display at one of the panels
    func show(swiftUIView: some View, at index: Int, animated: Bool = true, completion: (() -> Void)? = nil) {
        let onTheFlyPanel = Panel(index: index)
        show(swiftUIView: swiftUIView, for: onTheFlyPanel, animated: animated, completion: completion)
    }
    
    func show(swiftUIView: some View, for panel: Panel, animated: Bool = true, completion: (() -> Void)? = nil) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        swiftUIViewMappings.setObject(SwiftUIViewWrapper(swiftUIView), forKey: panel)
        show(viewController: hostingController, for: panel, animated: animated, completion: completion)
    }
    
    /// checks whether the provided SwiftUI view is currently being presented in one of the panels
    /// we can only check for type as all the view in SwiftUI as structs.
    func presents<V: View>(swiftUIViewType: V.Type) -> Panel? {
        var panelThatContainsSwiftUI: Panel?
        for (eachPanelIndex, _) in panelMappings {
            if let possibleViewMatch = swiftUIViewMappings.object(forKey: eachPanelIndex) {
                // we can only check if the types are identical since all SwiftUI views are structs
                let typeOfThisSwiftUIViewAtThisPanel = type(of: possibleViewMatch.originalView)
                if swiftUIViewType == typeOfThisSwiftUIViewAtThisPanel {
                    // we found the matching panel
                    panelThatContainsSwiftUI = eachPanelIndex
                    break
                }
            }
        }
        return panelThatContainsSwiftUI
    }
}
