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
    private(set) var rating: Double!
    private(set) var review: String!
    private(set) var userID: String!
    private(set) var wineID: String!
    private(set) var note: String!
    
    init(id: String, rating: Double, userID: String, wineID: String, review: String, note: String) {
        self.id = id
        self.rating = rating
        self.userID = userID
        self.wineID = wineID
        self.review = review
        self.note = note
    }
}
