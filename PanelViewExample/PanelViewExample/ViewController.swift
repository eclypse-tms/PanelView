//
//  ViewController.swift
//  PanelViewExample
//
//  Created by Nessa Kucuk, Turker on 7/12/24.
//

import UIKit
import PanelView

class ViewController: UIViewController {
    
    @IBOutlet private var buttonGroup: UIStackView!
    @IBOutlet private var leadingPlusButton: UIButton!
    @IBOutlet private var trailingPlusButton: UIButton!
    @IBOutlet private var leadingMinusButton: UIButton!
    @IBOutlet private var trailingMinusButton: UIButton!
    
    private var clickCount = 0
    
    private var panelView: PanelViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addPanelView()
        leadingPlusButton.setTitle("", for: .normal)
        trailingPlusButton.setTitle("", for: .normal)
        leadingMinusButton.setTitle("", for: .normal)
        trailingMinusButton.setTitle("", for: .normal)
    }

    private func addPanelView() {
        panelView = PanelViewController()
        var customConfig = PanelViewConfiguration()
        customConfig.emptyViewImage = UIImage(systemName: "macpro.gen3")
        customConfig.emptyViewImageDimensions = CGSize(width: 60, height: 60)
        let customLabel = UILabel()
        customLabel.text = "Bonanza"
        customLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        customConfig.emptyViewLabel = customLabel
        
        panelView.configuration = customConfig
        addFullScreen(childViewController: panelView)
    }
       
    /// adds a child view controller and makes it full screen
    public func addFullScreen(childViewController child: UIViewController) {
        guard child.parent == nil else {
            //if the child already has a parent, it won't add anything
            return
        }
        
        addChild(child)
        view.insertSubview(child.view, belowSubview: buttonGroup)
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: child.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: child.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: child.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: child.view.bottomAnchor)
        ])
        
        child.didMove(toParent: self)
    }
    
    @IBAction
    private func didClickOnAdd(_ sender: UIButton) {
        if clickCount == 0 {
            clickCount += 1
            let initial = UIViewController()
            initial.view.backgroundColor = .systemBackground
            
            let centerViewIndicator = UILabel()
            centerViewIndicator.translatesAutoresizingMaskIntoConstraints = false
            centerViewIndicator.text = "Main"
            centerViewIndicator.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            
            initial.view.addSubview(centerViewIndicator)
            NSLayoutConstraint.activate([
                centerViewIndicator.centerXAnchor.constraint(equalTo: initial.view.centerXAnchor),
                centerViewIndicator.centerYAnchor.constraint(equalTo: initial.view.centerYAnchor),
            ])
            
            panelView.show(viewController: initial, for: .centerPanel)
        } else {
            if sender.tag == -1 {
                // left side buttons are clicked
                clickCount += 1
                let leftSideVC = UIViewController()
                leftSideVC.view.backgroundColor = randomSystemColor()
                panelView.show(viewController: leftSideVC, for: .navigationPanel)
            }
        }
    }
    
    @IBAction
    private func didClickOnRemove(_ sender: UIButton) {
        
    }
    
    private func randomSystemColor() -> UIColor {
      let systemColors: [UIColor] = [
        .systemRed,
        .systemGreen,
        .systemBlue,
        .systemOrange,
        .systemYellow,
        .systemPink,
        .systemPurple,
        .systemGray,
        .systemBrown,
        .systemCyan,
        .systemIndigo,
        .systemMint,
        .systemTeal,
        .black,
        .white,
      ]
      
      let randomIndex = Int.random(in: 0..<systemColors.count)
      return systemColors[randomIndex]
    }
}

