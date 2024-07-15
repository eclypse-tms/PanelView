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
    
    private var panelMappings = [PanelViewIndex: UIView]()
    private var columnWidthMappings = [PanelViewIndex: NSLayoutConstraint]()
    private var columnMinWidthMappings = [PanelViewIndex: NSLayoutConstraint]()
    private var columnMaxWidthMappings = [PanelViewIndex: NSLayoutConstraint]()
    private var columnCenterMappings = [PanelViewIndex: CGPoint]()
    
    private var pendingViewControllers = [PanelViewIndex: UIViewController]()
    private var pendingMinimumWidth = [PanelViewIndex: CGFloat]()
    private var pendingMaximumWidth = [PanelViewIndex: CGFloat]()
    private var pendingWidthFraction = [PanelViewIndex: CGFloat]()
    
    private var resizerMappings = [PanelViewIndex: UIView]()
    private var hoverGestureMappings = [PanelViewIndex: UIHoverGestureRecognizer]()
    private var dragGestureMappings = [PanelViewIndex: UIHoverGestureRecognizer]()
    private var resizerToPanelMappings = [UIView: PanelViewIndex]()
    
    private let animationDuration = 0.3333
    private let panelResizerWidth: CGFloat = 20
    
    var splitViewReady = PassthroughSubject<Void, Error>()
    private var isAttachedToWindow = false
    
    private var didDisplayInitialColumn = false
    
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
            let sortedColumns = pendingViewControllers.sorted(by: { lhs, rhs in
                return lhs.key.index < rhs.key.index
            })
            
            for (eachColumn, eachVC) in sortedColumns {
                self.show(viewController: eachVC, for: eachColumn, animated: false)
            }
            //pendingViewControllers.removeAll()
        }
        
        if !pendingMinimumWidth.isEmpty {
            for (eachColumn, eachMinWidth) in pendingMinimumWidth {
                self.minimumWidth(eachMinWidth, for: eachColumn)
            }
            //pendingMinimumWidth.removeAll()
        }
        
        if !pendingMaximumWidth.isEmpty {
            for (eachColumn, eachMaxWidth) in pendingMaximumWidth {
                self.maximumWidth(eachMaxWidth, for: eachColumn)
            }
            //pendingMaximumWidth.removeAll()
        }
        
        if !pendingWidthFraction.isEmpty {
            for (eachColumn, widthFraction) in pendingWidthFraction {
                self.preferredWidthFraction(widthFraction, for: eachColumn)
            }
            //pendingWidthFraction.removeAll()
        }
        */
    }
    
    private func configureInitialPanels() {
        for index in -5...5 {
            let onTheFlyPanelIndex = PanelViewIndex(index: index)
            let newlyCreatedPanel = createPanel(for: onTheFlyPanelIndex)
            mainStackView.addArrangedSubview(newlyCreatedPanel)
            newlyCreatedPanel.isHidden = true
            hideViewResizer(column: onTheFlyPanelIndex)
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
    
    private func createPanel(for panelIndex: PanelViewIndex) -> UIView {
        func applyMinWidthConstraint() {
            var effectiveMinWidthConstantForPanel: CGFloat = 320
            if let existingMinWidthConstraint = columnMinWidthMappings[panelIndex] {
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
            
            columnMinWidthMappings[panelIndex] = minWidthConstraint
        }
        
        func applyMaxWidthConstraint() {
            var effectiveMaxWidthConstantForPanel: CGFloat = 768
            if let existingMaxWidthConstraint = columnMaxWidthMappings[panelIndex] {
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
            
            columnMaxWidthMappings[panelIndex] = maxWidthConstraint
        }
        
        func applyPrefferredWidthConstraint() {
            var effectiveWidthConstantForPanel: CGFloat = 475
            
            if let existingWidthConstraint = columnWidthMappings[panelIndex] {
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
            
            columnWidthMappings[panelIndex] = widthConstraint
        }
        
        // view resizer needs to be added to the main view above the stackview.
        
        func createViewResizer(newlyCreatedPanel: UIView) {
            let viewResizer = UIView()
            viewResizer.tag = panelIndex.index
            viewResizer.backgroundColor = .purple
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
                    let tempConstraint = viewResizer.trailingAnchor.constraint(equalTo: newlyCreatedPanel.trailingAnchor, constant: panelResizerWidth/2.0)
                    tempConstraint.identifier = "\(_resizerConstraintIdentifier)\(panelIndex.index)"
                    layoutConstraints.append(tempConstraint)
                } else {
                    // this is a trailing side panel, we need to place the resizer on the leading edge of the panel
                    let tempConstraint = viewResizer.leadingAnchor.constraint(equalTo: newlyCreatedPanel.leadingAnchor, constant: -panelResizerWidth/2.0)
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
                    let tempConstraint = viewResizer.bottomAnchor.constraint(equalTo: newlyCreatedPanel.bottomAnchor, constant: -panelResizerWidth/2.0)
                    tempConstraint.identifier = "\(_resizerConstraintIdentifier)\(panelIndex.index)"
                    layoutConstraints.append(tempConstraint)
                } else {
                    // this is a bottom panel that appears below the central panel. we need to place the resizer view
                    // on the top edge of the panel
                    let tempConstraint = viewResizer.topAnchor.constraint(equalTo: newlyCreatedPanel.topAnchor, constant: panelResizerWidth/2.0)
                    tempConstraint.identifier = "\(_resizerConstraintIdentifier)\(panelIndex.index)"
                    layoutConstraints.append(tempConstraint)
                }
                
                NSLayoutConstraint.activate(layoutConstraints)
            }
            
            resizerMappings[panelIndex] = viewResizer
        }
        
        
        let aNewPanel = UIView()
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
    
    private func configure(resizerView: UIView, for panelIndex: PanelViewIndex, associatedPanel: UIView) {
        
        let firstHoverGesture = UIHoverGestureRecognizer(target: self, action: #selector(didHoverOnSeparator(_:)))
        resizerView.addGestureRecognizer(firstHoverGesture)
        
        let firstDragGesture = MacPanGestureRecognizer(target: self, action: #selector(didDragSeparator(_:)))
        resizerView.addGestureRecognizer(firstDragGesture)
        
        resizerToPanelMappings[resizerView] = panelIndex
    }
    

    /// children navigation controllers this splitview manages
    var viewControllers = [PanelViewIndex: UINavigationController]()

    /// navigation controller that manages the view stack on the center view
    public var centralPanelNavController: UINavigationController? {
        return viewControllers[.centerPanel]
    }
    
    /// navigation controller that manages the view stack on the side view (left hand side) of the split view
    public var sideMenuController: UINavigationController? {
        return viewControllers[.navigationPanel]
    }
    
    public func topViewController(for column: PanelViewIndex) -> UIViewController? {
        return viewControllers[column]?.topViewController
    }
    
    public func isVisible(column: PanelViewIndex) -> Bool {
        if let discoveredColumn = panelMappings[column] {
            return !discoveredColumn.isHidden
        } else {
            return false
        }
    }
    
    public func minimumWidth(_ width: CGFloat, at index: Int) {
        let onTheFlyPanelIndex = PanelViewIndex(index: index)
        minimumWidth(width, for: onTheFlyPanelIndex)
    }
    
    public func minimumWidth(_ width: CGFloat, for column: PanelViewIndex) {
        if isAttachedToWindow, let constraintForPanel = columnMinWidthMappings[column] {
            constraintForPanel.constant = width
        } else {
            pendingMinimumWidth[column] = width
        }
    }
    
    public func maximumWidth(_ width: CGFloat, at index: Int) {
        let onTheFlyPanelIndex = PanelViewIndex(index: index)
        maximumWidth(width, for: onTheFlyPanelIndex)
    }
    
    public func maximumWidth(_ width: CGFloat, for column: PanelViewIndex) {
        if isAttachedToWindow, let constraintForPanel = columnMaxWidthMappings[column] {
            constraintForPanel.constant = width
        } else {
            pendingMaximumWidth[column] = width
        }
    }
    
    public func preferredWidthFraction(_ fraction: CGFloat, at index: Int) {
        let onTheFlyPanelIndex = PanelViewIndex(index: index)
        preferredWidthFraction(fraction, for: onTheFlyPanelIndex)
    }
    
    public func preferredWidthFraction(_ fraction: CGFloat, for column: PanelViewIndex) {
        let sanitizedFraction: CGFloat
        if fraction > 1 {
            sanitizedFraction = 1
        } else if fraction < 0 {
            sanitizedFraction = 0
        } else {
            sanitizedFraction = fraction
        }
        
        if isAttachedToWindow, let constraintForPanel = columnWidthMappings[column] {
            constraintForPanel.constant = view.frame.width * sanitizedFraction
        } else {
            pendingWidthFraction[column] = sanitizedFraction
        }
    }
    
    
    public func collapseSideMenu(animated: Bool, completion: (() -> Void)?) {
        if viewControllers.count > 1 {
            hide(column: .navigationPanel, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    /// hides the third column (inspector column)
    public func collapseInspector(animated: Bool, completion: (() -> Void)?) {
        hide(column: .inspectorPanel, animated: animated, completion: completion)
    }
    
    public func push(viewController: UIViewController) {
        if let navController = viewControllers[.centerPanel] {
            navController.pushViewController(viewController, animated: true)
        } else {
            fatalError("each column in split view must have a parent navigation controller")
        }
    }
    
    public func push(viewController: UIViewController, on column: PanelViewIndex) {
        if let navController = viewControllers[column] {
            navController.pushViewController(viewController, animated: true)
        } else {
            fatalError("each column in split view must have a parent navigation controller")
        }
    }
    
    public func popViewController() {
        if let navController = viewControllers[.centerPanel] {
            navController.popViewController(animated: true)
        } else {
            fatalError("each column in split view must have a parent navigation controller")
        }
    }
    
    public func popViewController(on column: PanelViewIndex) {
        if let navController = viewControllers[column] {
            navController.popViewController(animated: true)
        } else {
            fatalError("each column in split view must have a parent navigation controller")
        }
    }
    
    
    public func hideColumn(containing viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        let columnToHide: PanelViewIndex? = presents(viewController: viewController)
        
        if let discoveredColumnToHide = columnToHide {
            hide(column: discoveredColumnToHide, animated: animated, completion: completion)
        }
    }
    
    /// checks whether the provided viewController is currently being presented in one of the columns
    public func presents(viewController: UIViewController) -> PanelViewIndex? {
        var vcPresentedIn: PanelViewIndex?
        for (eachIndex, eachNavController) in viewControllers {
            if eachNavController.viewControllers.contains(viewController) {
                vcPresentedIn = eachIndex
                break
            }
        }
        return vcPresentedIn
    }
    
    private func hideViewResizer(column: PanelViewIndex) {
        if let associatedResizer = resizerMappings[column] {
            let uniqueConstraintIdentifier = "\(_resizerConstraintIdentifier)\(associatedResizer.tag)"
            if let constraintThatNeedToAltered = self.view.constraints.first(where: { $0.identifier == uniqueConstraintIdentifier }) {
                constraintThatNeedToAltered.constant = 0
            }
        }
    }
    
    public func hide(index: Int, animated: Bool = true, completion: (() -> Void)? = nil) {
        let onTheFlyIndex = PanelViewIndex(index: index)
        hide(column: onTheFlyIndex, animated: animated, completion: completion)
    }
    
    public func hide(column: PanelViewIndex, animated: Bool = true, completion: (() -> Void)? = nil) {
        _hide(column: column, animated: animated, hidingCompleted: { [weak self] in
            guard let strongSelf = self else { return }
            if let previousVC = strongSelf.viewControllers[column] {
                previousVC.removeSelfFromParent()
                strongSelf.viewControllers.removeValue(forKey: column)
            }
            completion?()
        })
    }
    
    private func _hide(column: PanelViewIndex, animated: Bool, hidingCompleted: (() -> Void)?) {
        func hideAppropriateColumn() {
            panelMappings[column]?.isHidden = true
            
            hideViewResizer(column: column)
            
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
        
        if column.index != 0, animated {
            // we shouldn't animate hiding of the main panel
            UIView.animate(withDuration: animationDuration, animations: {
                hideAppropriateColumn()
            }, completion: { _ in
                hidingCompleted?()
            })
        } else {
            hideAppropriateColumn()
            hidingCompleted?()
        }
    }
    
    public func show(viewController: UIViewController, at index: Int, animated: Bool = true) {
        let onTheFlyIndex = PanelViewIndex(index: index)
        show(viewController: viewController, for: onTheFlyIndex, animated: animated)
    }
    
    public func show(viewController: UIViewController, for column: PanelViewIndex, animated: Bool = true) {
        func animationBlock() {
            if let aColumn = panelMappings[column] {
                
                //if column.index > 0 {
                aColumn.removeFromSuperview()
                let subViewIndex = calculateAppropriateIndex(for: column)
                mainStackView.insertArrangedSubview(aColumn, at: subViewIndex)
                aColumn.isHidden = false
                
                
                // we need to re-establish the constraints for column resizers
                if let associatedResizer = resizerMappings[column] {
                    let reestablishedConstraint: NSLayoutConstraint
                    if mainStackView.axis == .horizontal {
                        if column.index < 0 {
                            // this is a horizonal layout and the panel is on the left hand side (leading side)
                            // resizer needs to be aligned to the trailing side of the panel
                            reestablishedConstraint = associatedResizer.trailingAnchor.constraint(equalTo: aColumn.trailingAnchor, constant: panelResizerWidth/2.0)
                        } else {
                            // this is a horizonal layout and the panel is on the right hand side (trailing side)
                            // resizer needs to be aligned to the leading side of the panel
                            reestablishedConstraint = associatedResizer.leadingAnchor.constraint(equalTo: aColumn.leadingAnchor, constant: -panelResizerWidth/2.0)
                        }
                    } else {
                        if column.index < 0 {
                            // this is a vertical layout and the panel is on the top side
                            // resizer needs to be aligned to the bottom side of the panel
                            reestablishedConstraint = associatedResizer.bottomAnchor.constraint(equalTo: aColumn.bottomAnchor, constant: panelResizerWidth/2.0)
                        } else {
                            // this is a vertical layout and the panel is on the bottom
                            // resizer needs to be aligned to the top side of the panel
                            reestablishedConstraint = associatedResizer.topAnchor.constraint(equalTo: aColumn.topAnchor, constant: panelResizerWidth/2.0)
                        }
                    }
                    reestablishedConstraint.identifier = "\(_resizerConstraintIdentifier)\(associatedResizer.tag)"
                    reestablishedConstraint.isActive = true
                }
                
            }
        }
        
        if isAttachedToWindow {
            if let previousVC = viewControllers[column] {
                previousVC.removeSelfFromParent()
                viewControllers.removeValue(forKey: column)
            }
            
            
            // since there is at least one panel that is will be visible
            // we should hide the empty view stack
            if let validEmptyStateView = emptyView {
                self.view.sendSubviewToBack(validEmptyStateView)
                validEmptyStateView.isHidden = true
            }
            
            let newlyCreatedPanel: UIView
            if let alreadyEmbeddedInNavController = viewController as? UINavigationController {
                newlyCreatedPanel = add(childNavController: alreadyEmbeddedInNavController, on: column)
            } else {
                let navController = UINavigationController(rootViewController: viewController)
                newlyCreatedPanel = add(childNavController: navController, on: column)
            }
            
            if column.index != 0, animated {
                UIView.animate(withDuration: animationDuration, animations: {
                    animationBlock()
                })
            } else {
                animationBlock()
            }
        } else {
            pendingViewControllers[column] = viewController
        }
    }
    
    private func calculateAppropriateIndex(for column: PanelViewIndex) -> Int {
        let sortedPanels: [PanelViewIndex] = panelMappings.map { $0.key }.sorted()
        if sortedPanels.isEmpty {
            // since there are no panels, the subview index is zero
            return 0
        }
        
        var nextIndex: Int?
        for (subviewIndex, eachPanelIndex) in sortedPanels.enumerated() {
            if eachPanelIndex.index == column.index {
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
    
    public func reset(with singleViewController: UIViewController, on column: PanelViewIndex, animated: Bool = true) {
        reset(multiple: [singleViewController: column])
    }
    
    public func reset(multiple multiViewControllers: [UIViewController: PanelViewIndex], animated: Bool = true) {
        // first remove any existing view controllers from the parent
        for (_, vc) in viewControllers {
            vc.removeSelfFromParent()
        }
        viewControllers.removeAll(keepingCapacity: true)
        
        // reset everything
        panelMappings.forEach { (_, column) in
            column.isHidden = true
        }
        
        // add the view controller one at a time by wrapping it with a nav controller
        for (eachViewController, eachColumn) in multiViewControllers {
            let navController: UINavigationController
            if let alreadyEmbeddedInNavController = eachViewController as? UINavigationController {
                navController = alreadyEmbeddedInNavController
            } else {
                navController = UINavigationController(rootViewController: eachViewController)
            }
            viewControllers[eachColumn] = navController
            if let columnToUnhide = panelMappings[eachColumn] {
                add(childNavController: navController, on: eachColumn)
                columnToUnhide.isHidden = false
            }
        }
        
        if !didDisplayInitialColumn {
            didDisplayInitialColumn = true
            self.view.backgroundColor = .opaqueSeparator
        }
    }
    
    public var centerNavigationController: UINavigationController? {
        return viewControllers[.centerPanel]
    }
    
    private func add(childNavController: UINavigationController, on column: PanelViewIndex) -> UIView {
        if let currentPanel = childNavController.parent?.view {
            //if the child already has a parent, it won't add anything
            return currentPanel
        }
        
        addChild(childNavController)
        viewControllers[column] = childNavController
        
        let parentView: UIView
        
        if let existingPanel: UIView = panelMappings[column] {
            parentView = existingPanel
        } else {
            parentView = createPanel(for: column)
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
        
        switch recognizer.state {
        case .began, .changed:
            NSCursor.resizeLeftRight.set()
        case .ended, .cancelled:
            NSCursor.arrow.set()
        default:
            NSCursor.arrow.set()
        }
        #endif
    }
    
    
    @objc
    private func didDragSeparator(_ gestureRecognizer: UIPanGestureRecognizer) {
        #if targetEnvironment(macCatalyst)
        guard let draggedSeparator = gestureRecognizer.view,
              let resizedPanel = resizerToPanelMappings[draggedSeparator] else { return }
        

        // Get the changes in the X and Y directions relative to the superview's coordinate space.
        let appliedTranslation = gestureRecognizer.translation(in: draggedSeparator.superview)
        
        if gestureRecognizer.state == .began {
            // user is manipulating the first column width
            columnCenterMappings[resizedPanel] = draggedSeparator.frame.center
            // print("saving resized columns initial conditions... center: \(resizedColumn.originalCenter), frame: \(resizedColumn.originalFrame)")
        }
        
        
           // Update the position for the .began, .changed, and .ended states
        if gestureRecognizer.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            if let minWidthConstraint = columnMinWidthMappings[resizedPanel], let maxWidthConstraint = columnMaxWidthMappings[resizedPanel] {
                // get first column's current frame and add the translation
                
                let proposedWidth: CGFloat
                if resizedPanel.index < 0 {
                    proposedWidth = draggedSeparator.frame.width + appliedTranslation.x
                } else {
                    proposedWidth = draggedSeparator.frame.width - appliedTranslation.x
                }
                
                let finalColumnWidth: CGFloat
                if proposedWidth < minWidthConstraint.constant {
                    finalColumnWidth = minWidthConstraint.constant
                    NSCursor.resizeRight.set()
                } else if proposedWidth > maxWidthConstraint.constant {
                    finalColumnWidth = maxWidthConstraint.constant
                    NSCursor.resizeLeft.set()
                } else {
                    // it is within the min and max
                    finalColumnWidth = proposedWidth
                    NSCursor.resizeLeftRight.set()
                }
                
                columnWidthMappings[resizedPanel]?.constant = finalColumnWidth
                // print("translation applied in the x dimension: \(appliedTranslation.x), proposed width: \(proposedWidth), final width: \(finalColumnWidth)")
            } else {
                // print("dragged view is not the first column")
            }
            
            if gestureRecognizer.state == .ended {
                NSCursor.arrow.set()
            }
            
        } else { // On cancellation, return the piece to its original location.
            // print("resizing is canceled")
            draggedSeparator.center = .zero
            NSCursor.arrow.set()
        }
        #endif
    }
}

