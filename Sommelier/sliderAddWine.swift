//
//  sliderAddWine.swift
//  Sommelier
//
//  Created by Damian on 24/11/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import UIKit

protocol AddWineDelegte: class {
    func didButtonTapped()
}

class sliderAddWine: UIView {
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var cheeseBtn: UIButton!
    @IBOutlet weak var carrotBtn: UIButton!
    @IBOutlet weak var appleBtn: UIButton!
    @IBOutlet weak var fishBtn: UIButton!
    @IBOutlet weak var meatBtn: UIButton!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var amountTxtField: UITextField!
    @IBOutlet weak var priceTxtField: UITextField!
    @IBOutlet weak var colorSegmnet: UISegmentedControl!
    @IBOutlet weak var tasteSegment: UISegmentedControl!
    @IBOutlet weak var countryTxtField: UITextField!
    @IBOutlet weak var vintageTxtField: UITextField!
    
    var cheese = true
    var vegetable = true
    var fruit = true
    var fish = true
    var meat = true

    
    weak var delegate: AddWineDelegte?

    @IBAction func btn1(_ sender: UIButton) {
        delegate?.didButtonTapped()
    }
    
    @IBAction func cheeseBtn(_ sender: UIButton) {
        if(!cheese) {
            cheeseBtn.setImage(UIImage(named: "cheeseDisabled"), for: .normal)
            cheese = true
        } else {
            cheeseBtn.setImage(UIImage(named: "cheese"), for: .normal)
            cheese = false
        }
    }
    
    @IBAction func carrottBtn(_ sender: UIButton) {
        if(!vegetable) {
            carrotBtn.setImage(UIImage(named: "carrotDisabled"), for: .normal)
            vegetable = true
        } else {
            carrotBtn.setImage(UIImage(named: "carrot"), for: .normal)
            vegetable = false
        }
    }
    
    @IBAction func appleBtn(_ sender: UIButton) {
        if(!fruit) {
            appleBtn.setImage(UIImage(named: "appleDisabled"), for: .normal)
            fruit = true
        } else {
            appleBtn.setImage(UIImage(named: "apple"), for: .normal)
            fruit = false
        }
    }
    
    @IBAction func fishBtn(_ sender: UIButton) {
        if(!fish) {
            fishBtn.setImage(UIImage(named: "fishDisabled"), for: .normal)
            fish = true
        } else {
            fishBtn.setImage(UIImage(named: "fish"), for: .normal)
            fish = false
        }
    }
    
    @IBAction func meatBtn(_ sender: UIButton) {
        if(!meat) {
            meatBtn.setImage(UIImage(named: "meatDisabled"), for: .normal)
            meat = true
        } else {
            meatBtn.setImage(UIImage(named: "meat"), for: .normal)
            meat = false
        }
    }
    

    
}

