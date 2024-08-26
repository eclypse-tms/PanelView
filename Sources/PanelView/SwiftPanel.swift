//
//  SwiftPanel.swift
//
//
//  Created by Nessa Kucuk, Turker on 8/23/24.
//

import SwiftUI

public struct SwiftPanel: UIViewRepresentable {
    public typealias UIViewType = UIView
    public typealias Coordinator = PanelViewSwiftUICoordinator
        
    public var configuration: PanelViewConfiguration = .init()
    let panelView: PanelView
    
    public init(configuration: PanelViewConfiguration, initialPanel: (any View)? = nil) {
        // by default all navigation bars are hidden for SwiftUI views
        var providedConfiguration = configuration
        providedConfiguration.hideAllNavigationBars = true
        
        self.configuration = providedConfiguration
        self.panelView = PanelView()
        if let validInitialView = initialPanel {
            self.panelView.show(swiftUIView: validInitialView, at: 0)
        }
    }
    
    public func makeUIView(context: Context) -> UIView {
        
        panelView.swiftUICoordinator = context.coordinator
        panelView.configuration = self.configuration
        
        context.coordinator.panelView = panelView
        
        return panelView.view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    public func makeCoordinator() -> PanelViewSwiftUICoordinator {
        return PanelViewSwiftUICoordinator()
    }
}

public extension SwiftPanel {
    func show(centralPanel: some View, completion: (() -> Void)? = nil) -> some View {
        panelView.show(swiftUIView: centralPanel, at: 0, animated: false, completion: completion)
        return self
    }
    
    /// Displays a SwiftUI view at the specified index. If there was another view already associated
    /// with that panel, this action replaces the existing view.
    /// - Parameters:
    ///   - view : a view controller to show.
    ///   - at: index. negative indices appear on the left side of the screen. positive indices appear on the right side.
    ///   - animated: whether to animate the transition. the default it true.
    ///   - completion: receive a callback when the panel is fully displayed.
    func show(_ view: some View, at index: Int, animated: Bool = true, completion: (() -> Void)? = nil) {
        panelView.show(swiftUIView: view, at: index, animated: animated, completion: completion)
    }
    
    /// Displays a SwiftUI view for the named panel. If there was another view already associated
    /// with that panel, this action replaces the existing view.
    /// - Parameters:
    ///   - viewController: a view controller to show.
    ///   - for: the name of the panel to show this view controller.
    ///   - animated: whether to animate the transition. the default it true.
    ///   - completion: receive a callback when the panel is fully displayed.
    func show(_ view: some View, for panel: Panel, animated: Bool = true, completion: (() -> Void)? = nil) {
        panelView.show(swiftUIView: view, for: panel, animated: animated, completion: completion)
    }
    
    /// checks whether the provided view type is currently being presented in one of the panels
    func presents<V: View>(viewType: V.Type) -> Panel? {
        return panelView.presents(swiftUIViewType: viewType)
    }
    
    /// Hides the panel at the given index.
    /// - Parameters:
    ///   - index: the index of the panel to hide.
    ///   - animated: whether to animate the hiding transition. default value is true.
    ///   - completion: notifies the called that hiding is complete.
    func hide(index: Int, animated: Bool = true, completion: (() -> Void)? = nil) {
        panelView.hide(index: index, animated: animated, releaseView: .true, completion: completion)
    }
    
    /// Hides the panel by its name.
    /// - Parameters:
    ///   - panel: the panel that contains the given view controller
    ///   - animated: whether to animate the hiding transition. default value is true.
    ///   - completion: notifies the called that hiding is complete.
    func hide(panel: Panel, animated: Bool = true, completion: (() -> Void)? = nil) {
        panelView.hide(panel: panel, animated: animated, releaseView: .true, completion: completion)
    }
}
