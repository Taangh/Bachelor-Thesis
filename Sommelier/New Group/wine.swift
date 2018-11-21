//
//  vine.swift
//  Sommelier
//
//  Created by Damian on 21/10/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import Foundation

class wine {
    private(set) var id: String!
    private(set) var name: String!
    private(set) var price: Float!
    private(set) var amount: Int!
    private(set) var color: String!
    private(set) var taste: String!
    private(set) var vegetables: Bool!
    private(set) var fruits: Bool!
    private(set) var cheese: Bool!
    private(set) var meat: Bool!
    private(set) var fish: Bool!

    init(id: String, name: String, price: Float, amount: Int, color: String, taste: String, vegetables: Bool, fruits: Bool, cheese: Bool, meat: Bool, fish: Bool) {
        self.id = id
        self.name = name
        self.price = price
        self.amount = amount
        self.color = color
        self.taste = taste
        self.vegetables = vegetables
        self.fruits = fruits
        self.cheese = cheese
        self.meat = meat
        self.fish = fish
    }
}
