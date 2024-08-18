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
    
    @IBOutlet var mainStackView: UIStackView!
    @IBOutlet var mainStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var mainStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var mainStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var mainStackViewBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet var panelMinus5: UIView!
    @IBOutlet var panelMinus4: UIView!
    @IBOutlet var panelMinus3: UIView!
    @IBOutlet var panelMinus2: UIView!
    @IBOutlet var panelMinus1: UIView!
    @IBOutlet var panelCenter: UIView!
    @IBOutlet var panelPlus1: UIView!
    @IBOutlet var panelPlus2: UIView!
    @IBOutlet var panelPlus3: UIView!
    @IBOutlet var panelPlus4: UIView!
    @IBOutlet var panelPlus5: UIView!
    
    @IBOutlet var panelMinus5MinWidth: NSLayoutConstraint!
    @IBOutlet var panelMinus5MaxWidth: NSLayoutConstraint!
    @IBOutlet var panelMinus5Width: NSLayoutConstraint!
    @IBOutlet var panelMinus4MinWidth: NSLayoutConstraint!
    @IBOutlet var panelMinus4MaxWidth: NSLayoutConstraint!
    @IBOutlet var panelMinus4Width: NSLayoutConstraint!
    @IBOutlet var panelMinus3MinWidth: NSLayoutConstraint!
    @IBOutlet var panelMinus3MaxWidth: NSLayoutConstraint!
    @IBOutlet var panelMinus3Width: NSLayoutConstraint!
    @IBOutlet var panelMinus2MinWidth: NSLayoutConstraint!
    @IBOutlet var panelMinus2MaxWidth: NSLayoutConstraint!
    @IBOutlet var panelMinus2Width: NSLayoutConstraint!
    @IBOutlet var panelMinus1MinWidth: NSLayoutConstraint!
    @IBOutlet var panelMinus1MaxWidth: NSLayoutConstraint!
    @IBOutlet var panelMinus1Width: NSLayoutConstraint!
    
    @IBOutlet var panelPlus5MinWidth: NSLayoutConstraint!
    @IBOutlet var panelPlus5MaxWidth: NSLayoutConstraint!
    @IBOutlet var panelPlus5Width: NSLayoutConstraint!
    @IBOutlet var panelPlus4MinWidth: NSLayoutConstraint!
    @IBOutlet var panelPlus4MaxWidth: NSLayoutConstraint!
    @IBOutlet var panelPlus4Width: NSLayoutConstraint!
    @IBOutlet var panelPlus3MinWidth: NSLayoutConstraint!
    @IBOutlet var panelPlus3MaxWidth: NSLayoutConstraint!
    @IBOutlet var panelPlus3Width: NSLayoutConstraint!
    @IBOutlet var panelPlus2MinWidth: NSLayoutConstraint!
    @IBOutlet var panelPlus2MaxWidth: NSLayoutConstraint!
    @IBOutlet var panelPlus2Width: NSLayoutConstraint!
    @IBOutlet var panelPlus1MinWidth: NSLayoutConstraint!
    @IBOutlet var panelPlus1MaxWidth: NSLayoutConstraint!
    @IBOutlet var panelPlus1Width: NSLayoutConstraint!
    
    public init() {
        super.init(nibName: String(describing: PanelView.self), bundle: PanelView.assetBundle)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var _emptyStateBackgroundView: UIView?
    var _emptyViewContainerStack: UIStackView?
    
    /// maps an index to a UIView
    var panelMappings = [PanelIndex: UIView]()
    
    
    var panelWidthMappings = [PanelIndex: NSLayoutConstraint]()
    var panelMinWidthMappings = [PanelIndex: NSLayoutConstraint]()
    var panelMaxWidthMappings = [PanelIndex: NSLayoutConstraint]()
    var panelCenterMappings = [PanelIndex: CGPoint]()
    
    var pendingViewControllers = [PanelIndex: UIViewController]()
    var pendingMinimumWidth = [PanelIndex: CGFloat]()
    var pendingMaximumWidth = [PanelIndex: CGFloat]()
    var pendingWidthFraction = [PanelIndex: CGFloat]()
    var originalFrameMappings = [PanelIndex: CGRect]()
    
    var swiftUIViewMappings = NSMapTable<PanelIndex, SwiftUIViewWrapper>(valueOptions: .weakMemory)
    
    /// maps panels to its accompanying dividers
    var dividerMappings = [PanelIndex: UIView]()
    
    
    private var hoverGestureMappings = [PanelIndex: UIHoverGestureRecognizer]()
    private var dragGestureMappings = [PanelIndex: UIHoverGestureRecognizer]()
    var dividerToPanelMappings = [UIView: PanelIndex]()
    
    var panelDividerWidth: CGFloat {
        return configuration.interPanelSpacing + 2
    }
    
    private var didDisplayInitialPanel = false
    
    var _dividerConstraintIdentifier = "divider constraint:"
    
    private var _initialConfiguration = true
    private let attachedToWindowSubject = PassthroughSubject<Void, Never>()
    let panelSizeChangedSubject = PassthroughSubject<ScreenSizeChanges, Never>()
    
    // MARK: Public Members
    
    /// This publisher streams an event when the PanelView is loaded and visible.
    public var attachedToWindow: AnyPublisher<Void, Never> {
        return attachedToWindowSubject.eraseToAnyPublisher()
    }
    
    /// This publisher streams an event when the PanelView's screen size changes as observed from UITraitCollection
    public var panelSizeChanged: AnyPublisher<ScreenSizeChanges, Never> {
        return panelSizeChangedSubject.eraseToAnyPublisher()
    }
    
    /// Check this property to determine whether the PanelView's view has been loaded and is visible in the window.
    ///
    /// This property may be useful if this is the root view in your window.
    public private (set) var isAttachedToWindow = false
    
    /// children navigation controllers this panelview manages
    public var viewControllers = [PanelIndex: UINavigationController]()
    
    /// assign a delegate to get notified of events in PanelViewDelegate
    public weak var delegate: PanelViewDelegate?
    
    /// you may use this property to separate one PanelView from another
    public var identifier: String = ""
    
    /// shorthand for PanelViewConfiguration.singlePanelMode
    public var isSinglePanelMode: Bool {
        return configuration.panelMode == .single
    }
    
    public var configuration = PanelViewConfiguration() {
        didSet {
            if _initialConfiguration {
                _initialConfiguration = false
            } else {
                processConfigurationChanges(oldConfig: oldValue, newConfig: configuration)
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        configurePrimaryStackView()
        
        if let validEmptyStateView = configuration.emptyStateView {
            configure(emptyStateView: validEmptyStateView)
        }
        
        configureInitialPanels()
        configureConstraintsForMainPanel()
        
        attachedToWindowSubject.send()
        isAttachedToWindow = true
        
        if !pendingViewControllers.isEmpty {
            let sortedPanels = pendingViewControllers.sorted(by: { lhs, rhs in
                return lhs.key.index < rhs.key.index
            })
            
            for (eachPanel, eachVC) in sortedPanels {
                self.show(viewController: eachVC, for: eachPanel, animated: false)
            }
            pendingViewControllers.removeAll()
        }
         
        
        if !pendingMinimumWidth.isEmpty {
            for (eachPanel, eachMinWidth) in pendingMinimumWidth {
                self.minimumWidth(eachMinWidth, for: eachPanel)
            }
            pendingMinimumWidth.removeAll()
        }
        
        if !pendingMaximumWidth.isEmpty {
            for (eachPanel, eachMaxWidth) in pendingMaximumWidth {
                self.maximumWidth(eachMaxWidth, for: eachPanel)
            }
            pendingMaximumWidth.removeAll()
        }
        
        if !pendingWidthFraction.isEmpty {
            for (eachPanel, widthFraction) in pendingWidthFraction {
                self.preferredWidthFraction(widthFraction, for: eachPanel)
            }
            pendingWidthFraction.removeAll()
        }
        
    }
    
    private func configureInitialPanels() {
        panelMinus5.isHidden = true
        panelMinus4.isHidden = true
        panelMinus3.isHidden = true
        panelMinus2.isHidden = true
        panelMinus1.isHidden = true
        panelCenter.isHidden = true
        panelPlus1.isHidden = true
        panelPlus2.isHidden = true
        panelPlus3.isHidden = true
        panelPlus4.isHidden = true
        panelPlus5.isHidden = true
        
        
        panelMappings[PanelIndex(index: -5)] = panelMinus5
        panelMappings[PanelIndex(index: -4)] = panelMinus4
        panelMappings[PanelIndex(index: -3)] = panelMinus3
        panelMappings[PanelIndex(index: -2)] = panelMinus2
        panelMappings[PanelIndex(index: -1)] = panelMinus1
        panelMappings[PanelIndex(index: 0)] = panelCenter
        panelMappings[PanelIndex(index: 1)] = panelPlus1
        panelMappings[PanelIndex(index: 2)] = panelPlus2
        panelMappings[PanelIndex(index: 3)] = panelPlus3
        panelMappings[PanelIndex(index: 4)] = panelPlus4
        panelMappings[PanelIndex(index: 5)] = panelPlus5
        
        panelMinus5.layer.zPosition = -5
        panelMinus4.layer.zPosition = -4
        panelMinus3.layer.zPosition = -3
        panelMinus2.layer.zPosition = -2
        panelMinus1.layer.zPosition = -1
        panelCenter.layer.zPosition = 0
        panelPlus1.layer.zPosition = 1
        panelPlus2.layer.zPosition = 2
        panelPlus3.layer.zPosition = 3
        panelPlus4.layer.zPosition = 4
        panelPlus5.layer.zPosition = 5
        
        panelMaxWidthMappings[PanelIndex(index: -5)] = panelMinus5MaxWidth
        panelMaxWidthMappings[PanelIndex(index: -4)] = panelMinus4MaxWidth
        panelMaxWidthMappings[PanelIndex(index: -3)] = panelMinus3MaxWidth
        panelMaxWidthMappings[PanelIndex(index: -2)] = panelMinus2MaxWidth
        panelMaxWidthMappings[PanelIndex(index: -1)] = panelMinus1MaxWidth
        panelMaxWidthMappings[PanelIndex(index: 5)] = panelPlus5MaxWidth
        panelMaxWidthMappings[PanelIndex(index: 4)] = panelPlus4MaxWidth
        panelMaxWidthMappings[PanelIndex(index: 3)] = panelPlus3MaxWidth
        panelMaxWidthMappings[PanelIndex(index: 2)] = panelPlus2MaxWidth
        panelMaxWidthMappings[PanelIndex(index: 1)] = panelPlus1MaxWidth
        
        panelMinWidthMappings[PanelIndex(index: -5)] = panelMinus5MinWidth
        panelMinWidthMappings[PanelIndex(index: -4)] = panelMinus4MinWidth
        panelMinWidthMappings[PanelIndex(index: -3)] = panelMinus3MinWidth
        panelMinWidthMappings[PanelIndex(index: -2)] = panelMinus2MinWidth
        panelMinWidthMappings[PanelIndex(index: -1)] = panelMinus1MinWidth
        panelMinWidthMappings[PanelIndex(index: 5)] = panelPlus5MinWidth
        panelMinWidthMappings[PanelIndex(index: 4)] = panelPlus4MinWidth
        panelMinWidthMappings[PanelIndex(index: 3)] = panelPlus3MinWidth
        panelMinWidthMappings[PanelIndex(index: 2)] = panelPlus2MinWidth
        panelMinWidthMappings[PanelIndex(index: 1)] = panelPlus1MinWidth
        
        panelWidthMappings[PanelIndex(index: -5)] = panelMinus5Width
        panelWidthMappings[PanelIndex(index: -4)] = panelMinus4Width
        panelWidthMappings[PanelIndex(index: -3)] = panelMinus3Width
        panelWidthMappings[PanelIndex(index: -2)] = panelMinus2Width
        panelWidthMappings[PanelIndex(index: -1)] = panelMinus1Width
        panelWidthMappings[PanelIndex(index: 5)] = panelPlus5Width
        panelWidthMappings[PanelIndex(index: 4)] = panelPlus4Width
        panelWidthMappings[PanelIndex(index: 3)] = panelPlus3Width
        panelWidthMappings[PanelIndex(index: 2)] = panelPlus2Width
        panelWidthMappings[PanelIndex(index: 1)] = panelPlus1Width
        
        panelMinus5MaxWidth.identifier = "Panel: \(-5) max width"
        panelMinus4MaxWidth.identifier = "Panel: \(-4) max width"
        panelMinus3MaxWidth.identifier = "Panel: \(-3) max width"
        panelMinus2MaxWidth.identifier = "Panel: \(-2) max width"
        panelMinus1MaxWidth.identifier = "Panel: \(-1) max width"
        panelPlus5MaxWidth.identifier = "Panel: \(5) max width"
        panelPlus4MaxWidth.identifier = "Panel: \(4) max width"
        panelPlus3MaxWidth.identifier = "Panel: \(3) max width"
        panelPlus2MaxWidth.identifier = "Panel: \(2) max width"
        panelPlus1MaxWidth.identifier = "Panel: \(1) max width"
        
        panelMinus5MinWidth.identifier = "Panel: \(-5) min width"
        panelMinus4MinWidth.identifier = "Panel: \(-4) min width"
        panelMinus3MinWidth.identifier = "Panel: \(-3) min width"
        panelMinus2MinWidth.identifier = "Panel: \(-2) min width"
        panelMinus1MinWidth.identifier = "Panel: \(-1) min width"
        panelPlus5MinWidth.identifier = "Panel: \(5) min width"
        panelPlus4MinWidth.identifier = "Panel: \(4) min width"
        panelPlus3MinWidth.identifier = "Panel: \(3) min width"
        panelPlus2MinWidth.identifier = "Panel: \(2) min width"
        panelPlus1MinWidth.identifier = "Panel: \(1) min width"
        
        panelMinus5Width.identifier = "Panel: \(-5) width"
        panelMinus4Width.identifier = "Panel: \(-4) width"
        panelMinus3Width.identifier = "Panel: \(-3) width"
        panelMinus2Width.identifier = "Panel: \(-2) width"
        panelMinus1Width.identifier = "Panel: \(-1) width"
        panelPlus5Width.identifier = "Panel: \(5) width"
        panelPlus4Width.identifier = "Panel: \(4) width"
        panelPlus3Width.identifier = "Panel: \(3) width"
        panelPlus2Width.identifier = "Panel: \(2) width"
        panelPlus1Width.identifier = "Panel: \(1) width"
        
    }
    
    /// some min and max constraints for the main panel prevents UINavigationBar from 
    /// complaining that there is something wrong with the autolayout (Unsatisfiable constraint error)
    open func configureConstraintsForMainPanel() {
        let onTheFlyIndex = PanelIndex(index: 0)
        if let centerPanel = panelMappings[onTheFlyIndex] {
            NSLayoutConstraint.activate([
                centerPanel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
                centerPanel.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
        }
    }
    
    /// adds the stackview to the view hierarchy
    private func configurePrimaryStackView() {
        switch configuration.orientation {
        case .horizontal:
            mainStackView.axis = .horizontal
        case .vertical:
            mainStackView.axis = .vertical
        }
        
        mainStackView.spacing = configuration.interPanelSpacing
        mainStackView.backgroundColor = .clear
    }
    
    // MARK: empty view
    func configure(emptyStateView: UIView) {
        if _emptyStateBackgroundView == nil {
            let emptyStateBackgroundView = UIView()
            emptyStateBackgroundView.backgroundColor = .systemBackground
            emptyStateBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(emptyStateBackgroundView)
            
            NSLayoutConstraint.activate([
                emptyStateBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
                emptyStateBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                emptyStateBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                emptyStateBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
            _emptyStateBackgroundView = emptyStateBackgroundView
        }
        
        if let alreadyConfiguredEmptyViewContainer = _emptyViewContainerStack {
            alreadyConfiguredEmptyViewContainer.subviews.forEach { $0.removeFromSuperview() }
        } else {
            let emptyViewContainer = UIStackView()
            emptyViewContainer.translatesAutoresizingMaskIntoConstraints = false
            _emptyStateBackgroundView!.addSubview(emptyViewContainer)
            
            var emptyStateViewConstraints = [NSLayoutConstraint]()
            emptyStateViewConstraints.append(emptyViewContainer.centerXAnchor.constraint(equalTo: _emptyStateBackgroundView!.centerXAnchor))
            
            if configuration.emptyViewVerticalAdjustment == 0.0 {
                emptyStateViewConstraints.append(emptyViewContainer.centerYAnchor.constraint(equalTo: _emptyStateBackgroundView!.centerYAnchor))
            } else {
                // clean the incorrect values
                let effectiveVerticalAdjustment: CGFloat
                if configuration.emptyViewVerticalAdjustment < -1.0 {
                    effectiveVerticalAdjustment = -1.0
                } else if configuration.emptyViewVerticalAdjustment > 1.0 {
                    effectiveVerticalAdjustment = 1.0
                } else {
                    effectiveVerticalAdjustment = configuration.emptyViewVerticalAdjustment
                }
                
                emptyStateViewConstraints.append(NSLayoutConstraint(item: emptyViewContainer, attribute: .centerY, relatedBy: .equal, toItem: _emptyStateBackgroundView, attribute: .centerY, multiplier: effectiveVerticalAdjustment, constant: 0))
            }
            NSLayoutConstraint.activate(emptyStateViewConstraints)
            
            _emptyViewContainerStack = emptyViewContainer
        }
        
        _emptyViewContainerStack!.addArrangedSubview(emptyStateView)
    }
    
    func removeEmptyStateView() {
        _emptyViewContainerStack = nil
        _emptyStateBackgroundView = nil
    }
    
    @discardableResult
    func add(childNavController: UINavigationController, on panel: PanelIndex) -> UIView {
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
            parentView = getPanel(for: panel)
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
            if let highlightColor = configuration.panelDividerHoverColor {
                UIView.animate(withDuration: configuration.panelTransitionDuration, animations: {
                    hoveredSeparator.backgroundColor = highlightColor
                })
            }
            if configuration.orientation == .horizontal {
                NSCursor.resizeLeftRight.set()
            } else {
                NSCursor.resizeUpDown.set()
            }
        case .ended, .cancelled:
            if configuration.panelDividerHoverColor != nil {
                UIView.animate(withDuration: configuration.panelTransitionDuration, animations: {
                    hoveredSeparator.backgroundColor = .clear
                })
            }
            NSCursor.arrow.set()
        default:
            if configuration.panelDividerHoverColor != nil {
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
        
        // we cannot continue if we cannot identify which panel and its associated divider is touched
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
                if configuration.orientation == .horizontal {
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
                    if configuration.orientation == .horizontal {
                        NSCursor.resizeRight.set()
                    } else {
                        NSCursor.resizeUp.set()
                    }
                    #endif
                    
                } else if proposedWidthOrHeight > maxWidthConstraint.constant {
                    finalPanelWidth = maxWidthConstraint.constant
                    #if targetEnvironment(macCatalyst)
                    if configuration.orientation == .horizontal {
                        NSCursor.resizeLeft.set()
                    } else {
                        NSCursor.resizeDown.set()
                    }
                    #endif
                } else {
                    // it is within the min and max
                    finalPanelWidth = proposedWidthOrHeight
                    #if targetEnvironment(macCatalyst)
                    if configuration.orientation == .horizontal {
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

