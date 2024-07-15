//
//  PanelViewController.swift
//
//
//  Created by Nessa Kucuk, Turker on 7/12/24.
//

import UIKit
import Combine

public class PanelViewController: UIViewController {
    private var mainStackView: UIStackView!
    
    private var emptyView: UIView?
    
    private var panelMappings = [PanelIndex: UIView]()
    private var panelWidthMappings = [PanelIndex: NSLayoutConstraint]()
    private var panelMinWidthMappings = [PanelIndex: NSLayoutConstraint]()
    private var panelMaxWidthMappings = [PanelIndex: NSLayoutConstraint]()
    private var panelCenterMappings = [PanelIndex: CGPoint]()
    
    private var pendingViewControllers = [PanelIndex: UIViewController]()
    private var pendingMinimumWidth = [PanelIndex: CGFloat]()
    private var pendingMaximumWidth = [PanelIndex: CGFloat]()
    private var pendingWidthFraction = [PanelIndex: CGFloat]()
    private var originalFrameMappings = [PanelIndex: CGRect]()
    
    private var resizerMappings = [PanelIndex: UIView]()
    private var hoverGestureMappings = [PanelIndex: UIHoverGestureRecognizer]()
    private var dragGestureMappings = [PanelIndex: UIHoverGestureRecognizer]()
    private var resizerToPanelMappings = [UIView: PanelIndex]()
    
    private let animationDuration = 0.3333
    private let panelResizerWidth: CGFloat = 3
    private let defaultPanelMinWidth: CGFloat = 320
    private let defaultPanelMaxWidth: CGFloat = 768
    
    var splitViewReady = PassthroughSubject<Void, Error>()
    private var isAttachedToWindow = false
    
    private var didDisplayInitialPanel = false
    
    private var _resizerConstraintIdentifier = "temp constraint:"
    
    // MARK: Public Members
    public var configuration = PanelViewConfiguration()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        configurePrimaryStackView()
        configureEmptyView()
        configureInitialPanels()
        
        
        splitViewReady.send()
        isAttachedToWindow = true
        
        /*
        if !pendingViewControllers.isEmpty {
            let sortedPanels = pendingViewControllers.sorted(by: { lhs, rhs in
                return lhs.key.index < rhs.key.index
            })
            
            for (eachPanel, eachVC) in sortedPanels {
                self.show(viewController: eachVC, for: eachPanel, animated: false)
            }
            //pendingViewControllers.removeAll()
        }
        
        if !pendingMinimumWidth.isEmpty {
            for (eachPanel, eachMinWidth) in pendingMinimumWidth {
                self.minimumWidth(eachMinWidth, for: eachPanel)
            }
            //pendingMinimumWidth.removeAll()
        }
        
        if !pendingMaximumWidth.isEmpty {
            for (eachPanel, eachMaxWidth) in pendingMaximumWidth {
                self.maximumWidth(eachMaxWidth, for: eachPanel)
            }
            //pendingMaximumWidth.removeAll()
        }
        
        if !pendingWidthFraction.isEmpty {
            for (eachPanel, widthFraction) in pendingWidthFraction {
                self.preferredWidthFraction(widthFraction, for: eachPanel)
            }
            //pendingWidthFraction.removeAll()
        }
        */
    }
    
    private func configureInitialPanels() {
        for index in -5...5 {
            let onTheFlyPanelIndex = PanelIndex(index: index)
            let newlyCreatedPanel = createPanel(for: onTheFlyPanelIndex)
            mainStackView.addArrangedSubview(newlyCreatedPanel)
            newlyCreatedPanel.isHidden = true
            // hideViewResizer(panel: onTheFlyPanelIndex)
        }
    }
    
    /// adds the stackview to the view hierarchy
    private func configurePrimaryStackView() {
        let primaryStackView = UIStackView()
        switch configuration.orientation {
        case .horizontal:
            primaryStackView.axis = .horizontal
        case .vertical:
            primaryStackView.axis = .vertical
        }
        
        primaryStackView.spacing = 1
        primaryStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(primaryStackView)
        NSLayoutConstraint.activate([
            primaryStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            primaryStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            primaryStackView.topAnchor.constraint(equalTo: self.view.topAnchor),
            primaryStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        mainStackView = primaryStackView
    }
    
    private func configureEmptyView() {
        if let validEmptyStateView = configuration.emptyStateView {
            let emptyViewContainer = UIStackView()
            
            emptyViewContainer.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(emptyViewContainer)
            NSLayoutConstraint.activate([
                emptyViewContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                emptyViewContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
            
            emptyViewContainer.addArrangedSubview(validEmptyStateView)
            
            emptyView = emptyViewContainer
        }
    }
    
    private func createPanel(for panelIndex: PanelIndex) -> UIView {
        func applyMinWidthConstraint() {
            var effectiveMinWidthConstantForPanel: CGFloat = defaultPanelMinWidth
            if let existingMinWidthConstraint = panelMinWidthMappings[panelIndex] {
                effectiveMinWidthConstantForPanel = existingMinWidthConstraint.constant
            } else if let pendingMinWidthConstraint = pendingMinimumWidth[panelIndex] {
                effectiveMinWidthConstantForPanel = pendingMinWidthConstraint
            }
            
            let minWidthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                        attribute: .width,
                                                        relatedBy: .greaterThanOrEqual,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: effectiveMinWidthConstantForPanel)
            minWidthConstraint.isActive = true
            
            panelMinWidthMappings[panelIndex] = minWidthConstraint
        }
        
        func applyMaxWidthConstraint() {
            var effectiveMaxWidthConstantForPanel: CGFloat = defaultPanelMaxWidth
            if let existingMaxWidthConstraint = panelMaxWidthMappings[panelIndex] {
                effectiveMaxWidthConstantForPanel = existingMaxWidthConstraint.constant
            } else if let pendingMaxWidthConstraint = pendingMaximumWidth[panelIndex] {
                effectiveMaxWidthConstantForPanel = pendingMaxWidthConstraint
            }
            
            let maxWidthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                        attribute: .width,
                                                        relatedBy: .lessThanOrEqual,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: effectiveMaxWidthConstantForPanel)
            maxWidthConstraint.isActive = true
            
            panelMaxWidthMappings[panelIndex] = maxWidthConstraint
        }
        
        func applyPrefferredWidthConstraint() {
            var effectiveWidthConstantForPanel: CGFloat = 475
            
            if let existingWidthConstraint = panelWidthMappings[panelIndex] {
                effectiveWidthConstantForPanel = existingWidthConstraint.constant
            } else if let savedWidthFraction = pendingWidthFraction[panelIndex] {
                effectiveWidthConstantForPanel = view.frame.width * savedWidthFraction
            }
            
            let widthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: effectiveWidthConstantForPanel)
            widthConstraint.isActive = true
            
            panelWidthMappings[panelIndex] = widthConstraint
        }
        
        // view resizer needs to be added to the main view above the stackview.
        
        func createViewResizer(newlyCreatedPanel: UIView) {
            let viewResizer = UIView()
            viewResizer.tag = panelIndex.index
            // viewResizer.backgroundColor = .purple
            viewResizer.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(viewResizer)
            
            if mainStackView.axis == .horizontal {
                // the panels are laid out side by side
                var layoutConstraints = [NSLayoutConstraint]()
                layoutConstraints.append(viewResizer.topAnchor.constraint(equalTo: self.view.topAnchor))
                layoutConstraints.append(viewResizer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor))
                layoutConstraints.append(viewResizer.widthAnchor.constraint(equalToConstant: panelResizerWidth))
                
                if panelIndex.index < 0 {
                    // this is a leading side panel, we need to place the resizer view on the trailing edge of the panel
                    let tempConstraint = viewResizer.trailingAnchor.constraint(equalTo: newlyCreatedPanel.trailingAnchor, constant: 0)
                    tempConstraint.identifier = "\(_resizerConstraintIdentifier)\(panelIndex.index)"
                    layoutConstraints.append(tempConstraint)
                } else {
                    // this is a trailing side panel, we need to place the resizer on the leading edge of the panel
                    let tempConstraint = viewResizer.leadingAnchor.constraint(equalTo: newlyCreatedPanel.leadingAnchor, constant: 0)
                    tempConstraint.identifier = "\(_resizerConstraintIdentifier)\(panelIndex.index)"
                    layoutConstraints.append(tempConstraint)
                }
                
                NSLayoutConstraint.activate(layoutConstraints)
                
            } else {
                // the panels are laid out top to bottom
                var layoutConstraints = [NSLayoutConstraint]()
                layoutConstraints.append(viewResizer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
                layoutConstraints.append(viewResizer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
                layoutConstraints.append(viewResizer.heightAnchor.constraint(equalToConstant: panelResizerWidth))
                
                if panelIndex.index < 0 {
                    // this is a top panel that appears above the central panel. we need to place the resizer view on the
                    // bottom edge of the panel
                    let tempConstraint = viewResizer.bottomAnchor.constraint(equalTo: newlyCreatedPanel.bottomAnchor, constant: 0)
                    tempConstraint.identifier = "\(_resizerConstraintIdentifier)\(panelIndex.index)"
                    layoutConstraints.append(tempConstraint)
                } else {
                    // this is a bottom panel that appears below the central panel. we need to place the resizer view
                    // on the top edge of the panel
                    let tempConstraint = viewResizer.topAnchor.constraint(equalTo: newlyCreatedPanel.topAnchor, constant: 0)
                    tempConstraint.identifier = "\(_resizerConstraintIdentifier)\(panelIndex.index)"
                    layoutConstraints.append(tempConstraint)
                }
                
                NSLayoutConstraint.activate(layoutConstraints)
            }
            
            // add hover gesture
            let viewResizerHoverGesture = UIHoverGestureRecognizer(target: self, action: #selector(didHoverOnSeparator(_:)))
            viewResizer.addGestureRecognizer(viewResizerHoverGesture)
            
            // add drag gesture
            let viewResizerDragGesture = MacPanGestureRecognizer(target: self, action: #selector(didDragSeparator(_:)))
            viewResizer.addGestureRecognizer(viewResizerDragGesture)
            
            resizerMappings[panelIndex] = viewResizer
            resizerToPanelMappings[viewResizer] = panelIndex
            viewResizer.isHidden = true
        }
        
        
        let aNewPanel = UIView()
        aNewPanel.tag = panelIndex.index
        aNewPanel.isHidden = true
        panelMappings[panelIndex] = aNewPanel
        mainStackView.addArrangedSubview(aNewPanel)
        
        if panelIndex.index != 0 {
            // Configure min width
            applyMinWidthConstraint()
            
            // configure max width
            applyMaxWidthConstraint()
            
            // configure width
            applyPrefferredWidthConstraint()
            
            // attach its accompanying view resizer
            if panelIndex.index != 0 {
                createViewResizer(newlyCreatedPanel: aNewPanel)
            }
        }
        return aNewPanel
    }
    

    /// children navigation controllers this splitview manages
    var viewControllers = [PanelIndex: UINavigationController]()

    /// navigation controller that manages the view stack on the center view
    public var centralPanelNavController: UINavigationController? {
        return viewControllers[.centerPanel]
    }
    
    /// navigation controller that manages the view stack on the side view (left hand side) of the panel view
    public var sideMenuController: UINavigationController? {
        return viewControllers[.navigationPanel]
    }
    
    public func topViewController(for panel: PanelIndex) -> UIViewController? {
        return viewControllers[panel]?.topViewController
    }
    
    public func isVisible(panel: PanelIndex) -> Bool {
        if let discoveredPanel = panelMappings[panel] {
            return !discoveredPanel.isHidden
        } else {
            return false
        }
    }
    
    public func minimumWidth(_ width: CGFloat, at index: Int) {
        let onTheFlyPanelIndex = PanelIndex(index: index)
        minimumWidth(width, for: onTheFlyPanelIndex)
    }
    
    public func minimumWidth(_ width: CGFloat, for panel: PanelIndex) {
        if isAttachedToWindow, let constraintForPanel = panelMinWidthMappings[panel] {
            constraintForPanel.constant = width
        } else {
            pendingMinimumWidth[panel] = width
        }
    }
    
    public func maximumWidth(_ width: CGFloat, at index: Int) {
        let onTheFlyPanelIndex = PanelIndex(index: index)
        maximumWidth(width, for: onTheFlyPanelIndex)
    }
    
    public func maximumWidth(_ width: CGFloat, for panel: PanelIndex) {
        if isAttachedToWindow, let constraintForPanel = panelMaxWidthMappings[panel] {
            constraintForPanel.constant = width
        } else {
            pendingMaximumWidth[panel] = width
        }
    }
    
    public func preferredWidthFraction(_ fraction: CGFloat, at index: Int) {
        let onTheFlyPanelIndex = PanelIndex(index: index)
        preferredWidthFraction(fraction, for: onTheFlyPanelIndex)
    }
    
    public func preferredWidthFraction(_ fraction: CGFloat, for panel: PanelIndex) {
        let sanitizedFraction: CGFloat
        if fraction > 1 {
            sanitizedFraction = 1
        } else if fraction < 0 {
            sanitizedFraction = 0
        } else {
            sanitizedFraction = fraction
        }
        
        if isAttachedToWindow, let constraintForPanel = panelWidthMappings[panel] {
            constraintForPanel.constant = view.frame.width * sanitizedFraction
        } else {
            pendingWidthFraction[panel] = sanitizedFraction
        }
    }
    
    
    public func collapseSideMenu(animated: Bool, completion: (() -> Void)?) {
        if viewControllers.count > 1 {
            hide(panel: .navigationPanel, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    /// hides the third panel (inspector panel)
    public func collapseInspector(animated: Bool, completion: (() -> Void)?) {
        hide(panel: .inspectorPanel, animated: animated, completion: completion)
    }
    
    public func push(viewController: UIViewController) {
        if let navController = viewControllers[.centerPanel] {
            navController.pushViewController(viewController, animated: true)
        } else {
            fatalError("each panel in panel view must have a parent navigation controller")
        }
    }
    
    public func push(viewController: UIViewController, on panel: PanelIndex) {
        if let navController = viewControllers[panel] {
            navController.pushViewController(viewController, animated: true)
        } else {
            fatalError("each panel in panel view must have a parent navigation controller")
        }
    }
    
    public func popViewController() {
        if let navController = viewControllers[.centerPanel] {
            navController.popViewController(animated: true)
        } else {
            fatalError("each panel in panel view must have a parent navigation controller")
        }
    }
    
    public func popViewController(on panel: PanelIndex) {
        if let navController = viewControllers[panel] {
            navController.popViewController(animated: true)
        } else {
            fatalError("each panel in panel view must have a parent navigation controller")
        }
    }
    
    
    public func hidePanel(containing viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        let panelToHide: PanelIndex? = presents(viewController: viewController)
        
        if let discoveredPanelToHide = panelToHide {
            hide(panel: discoveredPanelToHide, animated: animated, completion: completion)
        }
    }
    
    /// checks whether the provided viewController is currently being presented in one of the panels
    public func presents(viewController: UIViewController) -> PanelIndex? {
        var vcPresentedIn: PanelIndex?
        for (eachIndex, eachNavController) in viewControllers {
            if eachNavController.viewControllers.contains(viewController) {
                vcPresentedIn = eachIndex
                break
            }
        }
        return vcPresentedIn
    }
    
    private func hideViewResizer(panel: PanelIndex) {
        if let associatedResizer = resizerMappings[panel] {
            let uniqueConstraintIdentifier = "\(_resizerConstraintIdentifier)\(associatedResizer.tag)"
            if let constraintThatNeedToAltered = self.view.constraints.first(where: { $0.identifier == uniqueConstraintIdentifier }) {
                constraintThatNeedToAltered.constant = 0
            }
        }
    }
    
    public func hide(index: Int, animated: Bool = true, completion: (() -> Void)? = nil) {
        let onTheFlyIndex = PanelIndex(index: index)
        hide(panel: onTheFlyIndex, animated: animated, completion: completion)
    }
    
    public func hide(panel: PanelIndex, animated: Bool = true, completion: (() -> Void)? = nil) {
        _hide(panel: panel, animated: animated, hidingCompleted: { [weak self] in
            guard let strongSelf = self else { return }
            if let previousVC = strongSelf.viewControllers[panel] {
                previousVC.removeSelfFromParent()
                strongSelf.viewControllers.removeValue(forKey: panel)
            }
            completion?()
        })
    }
    
    private func _hide(panel: PanelIndex, animated: Bool, hidingCompleted: (() -> Void)?) {
        func hideAppropriatePanel() {
            panelMappings[panel]?.isHidden = true
            
            hideViewResizer(panel: panel)
            
            if let validEmptyStateView = emptyView {
                var atLeastOnePanelVisible = false
                for eachPanel in mainStackView.subviews {
                    if !eachPanel.isHidden {
                        // at least one panel is visible
                        atLeastOnePanelVisible = true
                        break
                    }
                }
                
                if !atLeastOnePanelVisible {
                    // all panels are hidden, show the empty view
                    self.view.bringSubviewToFront(validEmptyStateView)
                    validEmptyStateView.isHidden = false
                }
            }
        }
        
        if panel.index != 0, animated {
            // we shouldn't animate hiding of the main panel
            UIView.animate(withDuration: animationDuration, animations: {
                hideAppropriatePanel()
            }, completion: { _ in
                hidingCompleted?()
            })
        } else {
            hideAppropriatePanel()
            hidingCompleted?()
        }
    }
    
    public func show(viewController: UIViewController, at index: Int, animated: Bool = true) {
        let onTheFlyIndex = PanelIndex(index: index)
        show(viewController: viewController, for: onTheFlyIndex, animated: animated)
    }
    
    public func show(viewController: UIViewController, for panel: PanelIndex, animated: Bool = true) {
        func animationBlock() {
            if let aPanel = panelMappings[panel] {
                
                //if panel.index > 0 {
                aPanel.removeFromSuperview()
                let subViewIndex = calculateAppropriateIndex(for: panel)
                mainStackView.insertArrangedSubview(aPanel, at: subViewIndex)
                aPanel.isHidden = false
                
                
                // we need to re-establish the constraints for panel resizers
                if let associatedResizer = resizerMappings[panel] {
                    let reestablishedConstraint: NSLayoutConstraint
                    if mainStackView.axis == .horizontal {
                        if panel.index < 0 {
                            // this is a horizonal layout and the panel is on the left hand side (leading side)
                            // resizer needs to be aligned to the trailing side of the panel
                            reestablishedConstraint = associatedResizer.trailingAnchor.constraint(equalTo: aPanel.trailingAnchor, constant: panelResizerWidth/2.0)
                        } else {
                            // this is a horizonal layout and the panel is on the right hand side (trailing side)
                            // resizer needs to be aligned to the leading side of the panel
                            reestablishedConstraint = associatedResizer.leadingAnchor.constraint(equalTo: aPanel.leadingAnchor, constant: -panelResizerWidth/2.0)
                        }
                    } else {
                        if panel.index < 0 {
                            // this is a vertical layout and the panel is on the top side
                            // resizer needs to be aligned to the bottom side of the panel
                            reestablishedConstraint = associatedResizer.bottomAnchor.constraint(equalTo: aPanel.bottomAnchor, constant: panelResizerWidth/2.0)
                        } else {
                            // this is a vertical layout and the panel is on the bottom
                            // resizer needs to be aligned to the top side of the panel
                            reestablishedConstraint = associatedResizer.topAnchor.constraint(equalTo: aPanel.topAnchor, constant: panelResizerWidth/2.0)
                        }
                    }
                    reestablishedConstraint.identifier = "\(_resizerConstraintIdentifier)\(associatedResizer.tag)"
                    reestablishedConstraint.isActive = true
                    associatedResizer.isHidden = false
                }
                
            }
        }
        
        if isAttachedToWindow {
            if let previousVC = viewControllers[panel] {
                previousVC.removeSelfFromParent()
                viewControllers.removeValue(forKey: panel)
            }
            
            
            // since there is at least one panel that is will be visible
            // we should hide the empty view stack
            if let validEmptyStateView = emptyView {
                self.view.sendSubviewToBack(validEmptyStateView)
                validEmptyStateView.isHidden = true
            }
            
            if let alreadyEmbeddedInNavController = viewController as? UINavigationController {
                add(childNavController: alreadyEmbeddedInNavController, on: panel)
            } else {
                let navController = UINavigationController(rootViewController: viewController)
                add(childNavController: navController, on: panel)
            }
            
            if panel.index != 0, animated {
                UIView.animate(withDuration: animationDuration, animations: {
                    animationBlock()
                })
            } else {
                animationBlock()
            }
        } else {
            pendingViewControllers[panel] = viewController
        }
    }
    
    private func calculateAppropriateIndex(for panel: PanelIndex) -> Int {
        let sortedPanels: [PanelIndex] = panelMappings.map { $0.key }.sorted()
        if sortedPanels.isEmpty {
            // since there are no panels, the subview index is zero
            return 0
        }
        
        var nextIndex: Int?
        for (subviewIndex, eachPanelIndex) in sortedPanels.enumerated() {
            if eachPanelIndex.index == panel.index {
                nextIndex = subviewIndex
            }
        }
        
        if let discoveredIndex = nextIndex {
            return discoveredIndex
        } else {
            // this panel must be the last panel
            return sortedPanels.endIndex
        }
    }
    
    public func reset(with singleViewController: UIViewController, on panel: PanelIndex, animated: Bool = true) {
        reset(multiple: [singleViewController: panel])
    }
    
    public func reset(multiple multiViewControllers: [UIViewController: PanelIndex], animated: Bool = true) {
        // first remove any existing view controllers from the parent
        for (_, vc) in viewControllers {
            vc.removeSelfFromParent()
        }
        viewControllers.removeAll(keepingCapacity: true)
        
        // reset everything
        panelMappings.forEach { (_, panel) in
            panel.isHidden = true
        }
        
        // add the view controller one at a time by wrapping it with a nav controller
        for (eachViewController, eachPanel) in multiViewControllers {
            let navController: UINavigationController
            if let alreadyEmbeddedInNavController = eachViewController as? UINavigationController {
                navController = alreadyEmbeddedInNavController
            } else {
                navController = UINavigationController(rootViewController: eachViewController)
            }
            viewControllers[eachPanel] = navController
            if let panelToUnhide = panelMappings[eachPanel] {
                add(childNavController: navController, on: eachPanel)
                panelToUnhide.isHidden = false
            }
        }
        
        if !didDisplayInitialPanel {
            didDisplayInitialPanel = true
            self.view.backgroundColor = .opaqueSeparator
        }
    }
    
    public var centerNavigationController: UINavigationController? {
        return viewControllers[.centerPanel]
    }
    
    @discardableResult
    private func add(childNavController: UINavigationController, on panel: PanelIndex) -> UIView {
        if let currentPanel = childNavController.parent?.view {
            //if the child already has a parent, it won't add anything
            return currentPanel
        }
        
        addChild(childNavController)
        viewControllers[panel] = childNavController
        
        let parentView: UIView
        
        if let existingPanel: UIView = panelMappings[panel] {
            parentView = existingPanel
        } else {
            parentView = createPanel(for: panel)
        }
        
        // there is already a parent panel, simply add
        parentView.addSubview(childNavController.view)
        
        childNavController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            parentView.leadingAnchor.constraint(equalTo: childNavController.view.leadingAnchor),
            parentView.trailingAnchor.constraint(equalTo: childNavController.view.trailingAnchor),
            parentView.topAnchor.constraint(equalTo: childNavController.view.topAnchor),
            parentView.bottomAnchor.constraint(equalTo: childNavController.view.bottomAnchor)]
        )
        
        
        childNavController.didMove(toParent: self)
        
        return parentView
    }
    
    public func replaceTopViewController(with this: UIViewController, animated: Bool) {
        if let navController = viewControllers[.centerPanel] {
            navController.replaceTopViewController(with: this, animated: animated)
        }
    }
    
    @discardableResult
    public func popToViewController<T>(usingType viewControllerType: T.Type, animated: Bool) -> [UIViewController]? {
        if let navController = viewControllers[.centerPanel] {
            return navController.popToViewController(usingType: viewControllerType, animated: animated)
        }
        return nil
    }
    
    @objc
    private func didHoverOnSeparator(_ recognizer: UIHoverGestureRecognizer) {
        #if targetEnvironment(macCatalyst)
        
        guard let hoveredSeparator = recognizer.view else { return }
        switch recognizer.state {
        case .began, .changed:
            if let highlightColor = configuration.viewResizerHighlightColorOnHover {
                UIView.animate(withDuration: animationDuration, animations: {
                    hoveredSeparator.backgroundColor = highlightColor
                })
            }
            NSCursor.resizeLeftRight.set()
        case .ended, .cancelled:
            if configuration.viewResizerHighlightColorOnHover != nil {
                UIView.animate(withDuration: animationDuration, animations: {
                    hoveredSeparator.backgroundColor = .clear
                })
            }
            NSCursor.arrow.set()
        default:
            if configuration.viewResizerHighlightColorOnHover != nil {
                UIView.animate(withDuration: animationDuration, animations: {
                    hoveredSeparator.backgroundColor = .clear
                })
            }
            NSCursor.arrow.set()
        }
        #endif
    }
    
    
    @objc
    private func didDragSeparator(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        // we cannot continue if we cannot identify which panel and its associated resizer is touched
        guard let draggedSeparator = gestureRecognizer.view,
              let resizedPanelIndex = resizerToPanelMappings[draggedSeparator],
              let attachedPanel = panelMappings[resizedPanelIndex] else { return }
        
        guard resizedPanelIndex.index != 0 else { return } // center panel cannot be resized
        
        // Get the changes in the X and Y directions relative to the superview's coordinate space.
        let appliedTranslation = gestureRecognizer.translation(in: draggedSeparator.superview)
        
        if gestureRecognizer.state == .began {
            // user is manipulating the first panel width
            panelCenterMappings[resizedPanelIndex] = attachedPanel.center
            originalFrameMappings[resizedPanelIndex] = attachedPanel.frame
            // print("saving resized panels initial conditions... center: \(draggedSeparator.frame.center), frame: \(draggedSeparator.frame)")
        }
        
           // Update the position for the .began, .changed, and .ended states
        if gestureRecognizer.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            if let minWidthConstraint = panelMinWidthMappings[resizedPanelIndex], 
               let maxWidthConstraint = panelMaxWidthMappings[resizedPanelIndex],
               let originalFrame = originalFrameMappings[resizedPanelIndex] {
                // get first panel's current frame and add the translation
                
                let proposedWidthOrHeight: CGFloat
                if mainStackView.axis == .horizontal {
                    if resizedPanelIndex.index < 0 {
                        proposedWidthOrHeight = originalFrame.width + appliedTranslation.x
                    } else {
                        proposedWidthOrHeight = originalFrame.width - appliedTranslation.x
                    }
                } else {
                    if resizedPanelIndex.index < 0 {
                        proposedWidthOrHeight = originalFrame.height + appliedTranslation.x
                    } else {
                        proposedWidthOrHeight = originalFrame.height - appliedTranslation.x
                    }
                }
                
                let finalPanelWidth: CGFloat
                if proposedWidthOrHeight < minWidthConstraint.constant {
                    finalPanelWidth = minWidthConstraint.constant
                    NSCursor.resizeRight.set()
                } else if proposedWidthOrHeight > maxWidthConstraint.constant {
                    finalPanelWidth = maxWidthConstraint.constant
                    NSCursor.resizeLeft.set()
                } else {
                    // it is within the min and max
                    finalPanelWidth = proposedWidthOrHeight
                    NSCursor.resizeLeftRight.set()
                }
                
                if let existingWidthConstraint = panelWidthMappings[resizedPanelIndex] {
                    existingWidthConstraint.constant = finalPanelWidth
                    // print("translation applied in the x dimension: \(appliedTranslation.x), proposed width: \(proposedWidthOrHeight), final width: \(finalPanelWidth)")
                } else {
                    // print("this panel has no width constraint")
                }
                
            } else {
                // print("this panel has no min and max width constraints")
            }
            
            if gestureRecognizer.state == .ended {
                NSCursor.arrow.set()
            }
            
        } else { 
            // On cancellation, return the piece to its original location.
            
            if let originalFrame = originalFrameMappings[resizedPanelIndex] {
                attachedPanel.center = originalFrame.center
            }
            NSCursor.arrow.set()
        }
    }
}

