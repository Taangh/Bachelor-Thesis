//
//  ViewController.swift
//  Sommelier
//
//  Created by Damian on 16/10/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import UIKit
import Parchment
import FoldingCell

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vine = storyboard.instantiateViewController(withIdentifier: "winesVC") as! winesVC
        let profile = storyboard.instantiateViewController(withIdentifier: "profileVC")
        
        let pagingViewController = FixedPagingViewController(viewControllers: [
            vine,
            profile
            ])

        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.textColor = #colorLiteral(red: 0.1803921569, green: 0.1529411765, blue: 0.1725490196, alpha: 1)
        pagingViewController.selectedTextColor = #colorLiteral(red: 0.3769004941, green: 0.001023530494, blue: 0.2608191371, alpha: 1)
        pagingViewController.indicatorColor = #colorLiteral(red: 0.3769004941, green: 0.001023530494, blue: 0.2608191371, alpha: 1)
        pagingViewController.didMove(toParent: self)
        let indicators = PagingIndicatorOptions.visible(height: 4, zIndex: Int.max, spacing: UIEdgeInsets.zero, insets: UIEdgeInsets.zero)
        pagingViewController.indicatorOptions = indicators
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addReview))
        
    }
    
    @objc func addReview() {
        
    }



}

