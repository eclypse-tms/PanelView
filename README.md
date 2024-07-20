<p align="center">
  <img width="150" height="150" src="./assets/panelview_app_icon.svg">
</p>

<p align="center">
    <img src="https://img.shields.io/badge/UIKit-darkslategray?logo=uikit" alt="UIKit">
    <img src="https://img.shields.io/badge/SwiftUI-darkslategray?logo=swift" alt="SwiftUI">
	<img src="https://img.shields.io/badge/iOS-15+-blue" alt="SwiftUI">
	<img src="https://img.shields.io/badge/macOS-12+-blue" alt="SwiftUI">
</p>

# PanelView
A superpowered SplitView that gives the controls back to the developer.

<p align="center">
  <img src="./assets/hero_image.jpg" width="842.66" height="512">
	<br/>
	Made with PanelView
</p>
<br/>

## Installation (iOS, macCatalyst)
### Swift Package Manager

Add PanelView to your project via Swift Package Manager.

`https://github.com/eclypse-tms/PanelView`

### Manually

Drop the [source files](https://github.com/eclypse-tms/PanelView/Sources) into your project.
<br/>

## Why PanelView?
1. Apple's UISplitViewController works and behaves in unexpected ways. Developer has to come up with too many work-arounds to get UISplitViewController to work as desired. PanelView gives control back to the developer.
1. UISplitViewController only lets you run in 2 or 3 column mode. PanelView has no limitations on how many columns you can have.
1. You can place the columns (panels) to left or to the right of your main view in any combination.
1. You can stack views top-to-bottom instead of side-by-side. This is in fact why we call our library PanelView.
1. You can embed a PanelView in another PanelView to have complex, mosaique like layout.
1. In compact screen size environments instead of collapsing down to one column like UISplitViewController forces you, you can stack your panels on top of each other instead.
1. You have fine grain controls on how and when to display panels.
<br/>

<p align="center">
  <img src="./assets/panelview_with_6_panels.png" width="535" height="399">
	<br/>
	PanelView that is split 6 way
</p>

## Usage
```
import PanelView

let panelView = PanelView()
// then add this PanelView to your view hierarchy in anyway you see fit

// let's say you have 3 panels you want to display
// from left to right: navigation, main screen and inspector panel 
// set the size constraints for the navigation panel
panelView.minimumWidth(320, for: .navigation)
panelView.maximumWidth(768, for: .navigation)
panelView.preferredWidthFraction(0.3, for: .navigation)

// set the size constraints for the inspector panel
panelView.minimumWidth(200, for: .inspector)
panelView.maximumWidth(575, for: .inspector)
panelView.preferredWidthFraction(0.25, for: .inspector)

let vc1 = ViewController1() 
let vc2 = ViewController2()
let vc3 = ViewController3()

panelView.show(vc1, for: .navigation)
panelView.show(vc2, for: .center)
panelView.show(vc3, for. .inspector)

```

## Additional Configuration
PanelView offers additional configuration 
```
/// Provides configuration possibilities for PanelView
public struct PanelViewConfiguration {
    /// runs the PanelView in horizontal or vertical mode.
    ///
    /// Once the orientation is determined, it cannot be changed later on.
    public var orientation: PanelOrientation
    
    /// the view to display when there are no panels visible.
    public var emptyStateView: UIView?
        
    /// when this value is not nil, the view resizers will be highlighted when
    /// a pointer hovers over them. when this value is nil, no highlighting will
    /// occur.
    ///
    /// only applicable to macCatalyst
    public var viewResizerHoverColor: UIColor?
    
    /// the this color is only visible in between the panels - when there are
    /// multiple panels open.
    public var panelSeparatorColor: UIColor
    
    /// The space in the between the panels.
    public var interPanelSpacing: CGFloat
    
    /// Number of panels on each side that are created and added to the view hiearchy.
    /// The default value is 4. This means 4 panels on each side of the main panel
    /// for a total of 9 panels are added to the view hierarchy. Priming panels
    /// before hand helps with animations and transitions to work correctly. If you know
    /// that you will need more than 9 panels adjust this number accordingly otherwise
    /// leave it as-is.
    public var numberOfPanelsToPrime: Int
    
    /// the animation duration when inserting and removing panels from the view
    public var panelTransitionDuration: Double
    
    /// determines whether the panels heights or widths can be changed in the UI
    public var allowsUIPanelSizeAdjustment: Bool
}
```
