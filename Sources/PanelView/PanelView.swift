//
//  PanelView.swift
//
//
//  Created by eclypse on 7/12/24.
//

import UIKit
import Combine
import SwiftUI

public class PanelView: UIViewController, ResizablePanel {
    var mainStackView: UIStackView!
    
    var emptyView: UIView?
    
    public weak var delegate: PanelViewDelegate?
    
    var panelMappings = [Panel: UIView]()
    var panelWidthMappings = [Panel: NSLayoutConstraint]()
    var panelMinWidthMappings = [Panel: NSLayoutConstraint]()
    var panelMaxWidthMappings = [Panel: NSLayoutConstraint]()
    var panelCenterMappings = [Panel: CGPoint]()
    
    var pendingViewControllers = [Panel: UIViewController]()
    var pendingMinimumWidth = [Panel: CGFloat]()
    var pendingMaximumWidth = [Panel: CGFloat]()
    var pendingWidthFraction = [Panel: CGFloat]()
    var originalFrameMappings = [Panel: CGRect]()
    
    var swiftUIViewMappings = NSMapTable<Panel, SwiftUIViewWrapper>(valueOptions: .weakMemory)
    
    /// maps panels to its accompanying dividers
    var dividerMappings = [Panel: UIView]()
    
    
    private var hoverGestureMappings = [Panel: UIHoverGestureRecognizer]()
    private var dragGestureMappings = [Panel: UIHoverGestureRecognizer]()
    private var dividerToPanelMappings = [UIView: Panel]()
    
    var panelResizerWidth: CGFloat {
        return configuration.interPanelSpacing + 2
    }
    
    private let defaultPanelMinWidth: CGFloat = 320
    private let defaultPanelMaxWidth: CGFloat = 768
    
    public var splitViewReady = PassthroughSubject<Void, Error>()
    public var isAttachedToWindow = false
    
    private var didDisplayInitialPanel = false
    
    var _resizerConstraintIdentifier = "temp constraint:"
    
    /// children navigation controllers this panelview manages
    public var viewControllers = [Panel: UINavigationController]()
    
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
        for index in -configuration.numberOfPanelsToPrime...configuration.numberOfPanelsToPrime {
            let onTheFlyPanelIndex = Panel(index: index)
            let newlyCreatedPanel = createPanel(for: onTheFlyPanelIndex)
            mainStackView.addArrangedSubview(newlyCreatedPanel)
            newlyCreatedPanel.isHidden = true
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
        
        primaryStackView.spacing = configuration.interPanelSpacing
        primaryStackView.backgroundColor = .clear
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
    
    func createPanel(for indexedPanel: Panel) -> UIView {
        // attribute that is used to size the panels widthwise or heightwise
        let layoutAttribute: NSLayoutConstraint.Attribute
        if mainStackView.axis == .horizontal {
            layoutAttribute = .width
        } else {
            layoutAttribute = .height
        }
        
        func applyMinWidthConstraint() {
            var effectiveMinWidthConstantForPanel: CGFloat = defaultPanelMinWidth
            if let existingMinWidthConstraint = panelMinWidthMappings[indexedPanel] {
                effectiveMinWidthConstantForPanel = existingMinWidthConstraint.constant
            } else if let pendingMinWidthConstraint = pendingMinimumWidth[indexedPanel] {
                effectiveMinWidthConstantForPanel = pendingMinWidthConstraint
            }
            
            
            
            let minWidthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                        attribute: layoutAttribute,
                                                        relatedBy: .greaterThanOrEqual,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: effectiveMinWidthConstantForPanel)
            minWidthConstraint.isActive = true
            
            panelMinWidthMappings[indexedPanel] = minWidthConstraint
        }
        
        func applyMaxWidthConstraint() {
            var effectiveMaxWidthConstantForPanel: CGFloat = defaultPanelMaxWidth
            if let existingMaxWidthConstraint = panelMaxWidthMappings[indexedPanel] {
                effectiveMaxWidthConstantForPanel = existingMaxWidthConstraint.constant
            } else if let pendingMaxWidthConstraint = pendingMaximumWidth[indexedPanel] {
                effectiveMaxWidthConstantForPanel = pendingMaxWidthConstraint
            }
            
            let maxWidthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                        attribute: layoutAttribute,
                                                        relatedBy: .lessThanOrEqual,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: effectiveMaxWidthConstantForPanel)
            maxWidthConstraint.isActive = true
            
            panelMaxWidthMappings[indexedPanel] = maxWidthConstraint
        }
        
        func applyPrefferredWidthConstraint() {
            var effectiveWidthConstantForPanel: CGFloat = 475
            
            if let existingWidthConstraint = panelWidthMappings[indexedPanel] {
                effectiveWidthConstantForPanel = existingWidthConstraint.constant
            } else if let savedWidthFraction = pendingWidthFraction[indexedPanel] {
                if mainStackView.axis == .horizontal {
                    effectiveWidthConstantForPanel = view.frame.width * savedWidthFraction
                } else {
                    effectiveWidthConstantForPanel = view.frame.height * savedWidthFraction
                }
            }
            
            let widthConstraint = NSLayoutConstraint(item: aNewPanel,
                                                        attribute: layoutAttribute,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: effectiveWidthConstantForPanel)
            widthConstraint.priority = .defaultHigh
            widthConstraint.isActive = true
            
            panelWidthMappings[indexedPanel] = widthConstraint
        }
        
        // view resizer needs to be added to the main view above the stackview.
        
        func createPanelDivider(newlyCreatedPanel: UIView) {
            let viewDivider = UIView()
            viewDivider.tag = indexedPanel.index
            // viewResizer.backgroundColor = .purple
            viewDivider.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(viewDivider)
            
            if mainStackView.axis == .horizontal {
                // the panels are laid out side by side
                var layoutConstraints = [NSLayoutConstraint]()
                layoutConstraints.append(viewDivider.topAnchor.constraint(equalTo: self.view.topAnchor))
                layoutConstraints.append(viewDivider.bottomAnchor.constraint(equalTo: self.view.bottomAnchor))
                layoutConstraints.append(viewDivider.widthAnchor.constraint(equalToConstant: panelResizerWidth))
                
                if indexedPanel.index < 0 {
                    // this is a leading side panel, we need to place the resizer view on the trailing edge of the panel
                    let tempConstraint = viewDivider.trailingAnchor.constraint(equalTo: newlyCreatedPanel.trailingAnchor, constant: 0)
                    tempConstraint.identifier = "\(_resizerConstraintIdentifier)\(indexedPanel.index)"
                    layoutConstraints.append(tempConstraint)
                } else {
                    // this is a trailing side panel, we need to place the resizer on the leading edge of the panel
                    let tempConstraint = viewDivider.leadingAnchor.constraint(equalTo: newlyCreatedPanel.leadingAnchor, constant: 0)
                    tempConstraint.identifier = "\(_resizerConstraintIdentifier)\(indexedPanel.index)"
                    layoutConstraints.append(tempConstraint)
                }
                
                NSLayoutConstraint.activate(layoutConstraints)
                
            } else {
                // the panels are laid out top to bottom
                var layoutConstraints = [NSLayoutConstraint]()
                layoutConstraints.append(viewDivider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
                layoutConstraints.append(viewDivider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
                layoutConstraints.append(viewDivider.heightAnchor.constraint(equalToConstant: panelResizerWidth))
                
                if indexedPanel.index < 0 {
                    // this is a top panel that appears above the central panel. we need to place the resizer view on the
                    // bottom edge of the panel
                    let tempConstraint = viewDivider.bottomAnchor.constraint(equalTo: newlyCreatedPanel.bottomAnchor, constant: 0)
                    tempConstraint.identifier = "\(_resizerConstraintIdentifier)\(indexedPanel.index)"
                    layoutConstraints.append(tempConstraint)
                } else {
                    // this is a bottom panel that appears below the central panel. we need to place the resizer view
                    // on the top edge of the panel
                    let tempConstraint = viewDivider.topAnchor.constraint(equalTo: newlyCreatedPanel.topAnchor, constant: 0)
                    tempConstraint.identifier = "\(_resizerConstraintIdentifier)\(indexedPanel.index)"
                    layoutConstraints.append(tempConstraint)
                }
                
                NSLayoutConstraint.activate(layoutConstraints)
            }
            
            dividerMappings[indexedPanel] = viewDivider
            dividerToPanelMappings[viewDivider] = indexedPanel
            
            enableResizing(for: indexedPanel)
            
            viewDivider.isHidden = true
        }
        
        
        let aNewPanel = UIView()
        aNewPanel.tag = indexedPanel.index
        aNewPanel.isHidden = true
        panelMappings[indexedPanel] = aNewPanel
        mainStackView.addArrangedSubview(aNewPanel)
        
        if indexedPanel.index != 0 {
            // Configure min width
            applyMinWidthConstraint()
            
            // configure max width
            applyMaxWidthConstraint()
            
            // configure width
            applyPrefferredWidthConstraint()
            
            // attach its accompanying view resizer
            if indexedPanel.index != 0, configuration.allowsUIPanelSizeAdjustment {
                createPanelDivider(newlyCreatedPanel: aNewPanel)
            }
        }
        return aNewPanel
    }
    
    public func push(viewController: UIViewController) {
        if let navController = viewControllers[.center] {
            navController.pushViewController(viewController, animated: true)
        } else {
            fatalError("each panel in panel view must have a parent navigation controller")
        }
    }
    
    public func push(viewController: UIViewController, on panel: Panel) {
        if let navController = viewControllers[panel] {
            navController.pushViewController(viewController, animated: true)
        } else {
            fatalError("each panel in panel view must have a parent navigation controller")
        }
    }
    
    public func popViewController() {
        if let navController = viewControllers[.center] {
            navController.popViewController(animated: true)
        } else {
            fatalError("each panel in panel view must have a parent navigation controller")
        }
    }
    
    public func popViewController(on panel: Panel) {
        if let navController = viewControllers[panel] {
            navController.popViewController(animated: true)
        } else {
            fatalError("each panel in panel view must have a parent navigation controller")
        }
    }
    
    
    /// checks whether the provided viewController is currently being presented in one of the panels
    public func presents(viewController: UIViewController) -> Panel? {
        var vcPresentedIn: Panel?
        for (eachPanel, eachNavController) in viewControllers {
            if eachNavController.viewControllers.contains(viewController) {
                vcPresentedIn = eachPanel
                break
            }
        }
        return vcPresentedIn
    }
    

    func calculateAppropriateIndex(for panel: Panel) -> Int {
        let sortedPanels: [Panel] = panelMappings.map { $0.key }.sorted()
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
    
    @discardableResult
    func add(childNavController: UINavigationController, on panel: Panel) -> UIView {
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
    
    // MARK: Hover Gesture
    @objc
    func didHoverOnSeparator(_ recognizer: UIHoverGestureRecognizer) {
        #if targetEnvironment(macCatalyst)
        
        guard let hoveredSeparator = recognizer.view else { return }
        switch recognizer.state {
        case .began, .changed:
            if let highlightColor = configuration.viewResizerHoverColor {
                UIView.animate(withDuration: configuration.panelTransitionDuration, animations: {
                    hoveredSeparator.backgroundColor = highlightColor
                })
            }
            if mainStackView.axis == .horizontal {
                NSCursor.resizeLeftRight.set()
            } else {
                NSCursor.resizeUpDown.set()
            }
        case .ended, .cancelled:
            if configuration.viewResizerHoverColor != nil {
                UIView.animate(withDuration: configuration.panelTransitionDuration, animations: {
                    hoveredSeparator.backgroundColor = .clear
                })
            }
            NSCursor.arrow.set()
        default:
            if configuration.viewResizerHoverColor != nil {
                UIView.animate(withDuration: configuration.panelTransitionDuration, animations: {
                    hoveredSeparator.backgroundColor = .clear
                })
            }
            NSCursor.arrow.set()
        }
        #endif
    }
    
    
    @objc
    func didDragSeparator(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        // we cannot continue if we cannot identify which panel and its associated resizer is touched
        guard let draggedSeparator = gestureRecognizer.view,
              let resizedPanelIndex = dividerToPanelMappings[draggedSeparator],
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
                        proposedWidthOrHeight = originalFrame.height + appliedTranslation.y
                    } else {
                        proposedWidthOrHeight = originalFrame.height - appliedTranslation.y
                    }
                }
                
                let finalPanelWidth: CGFloat
                if proposedWidthOrHeight < minWidthConstraint.constant {
                    finalPanelWidth = minWidthConstraint.constant
                    #if targetEnvironment(macCatalyst)
                    if mainStackView.axis == .horizontal {
                        NSCursor.resizeRight.set()
                    } else {
                        NSCursor.resizeUp.set()
                    }
                    #endif
                    
                } else if proposedWidthOrHeight > maxWidthConstraint.constant {
                    finalPanelWidth = maxWidthConstraint.constant
                    #if targetEnvironment(macCatalyst)
                    if mainStackView.axis == .horizontal {
                        NSCursor.resizeLeft.set()
                    } else {
                        NSCursor.resizeDown.set()
                    }
                    #endif
                } else {
                    // it is within the min and max
                    finalPanelWidth = proposedWidthOrHeight
                    #if targetEnvironment(macCatalyst)
                    if mainStackView.axis == .horizontal {
                        NSCursor.resizeLeftRight.set()
                    } else {
                        NSCursor.resizeUpDown.set()
                    }
                    #endif
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
                #if targetEnvironment(macCatalyst)
                NSCursor.arrow.set()
                #endif
            }
            
        } else { 
            // On cancellation, return the piece to its original location.
            
            if let originalFrame = originalFrameMappings[resizedPanelIndex] {
                attachedPanel.center = originalFrame.center
            }
            #if targetEnvironment(macCatalyst)
            NSCursor.arrow.set()
            #endif
        }
    }
}

