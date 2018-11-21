//
//  opinion.swift
//  Sommelier
//
//  Created by Damian on 07/11/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import Foundation

class opinion {
    private(set) var id: String!
    private(set) var rating: Float!
    private(set) var review: String!
    private(set) var userID: String!
    private(set) var wineID: String!
    
    init(id: String, rating: Float, userID: String, wineID: String, review: String) {
        self.id = id
        self.rating = rating
        self.userID = userID
        self.wineID = wineID
        self.review = review
    }
}
