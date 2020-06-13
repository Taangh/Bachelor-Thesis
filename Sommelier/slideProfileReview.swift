//
//  Slide.swift
//  Sommelier
//
//  Created by Damian on 02/11/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import UIKit
import Firebase

class slideProfileReview: UIView {
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var tasteLbl: UILabel!
    @IBOutlet weak var colorLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var reviewLbl: UILabel!
    let db = Firestore.firestore()
    
    func setWine(wineID: String) {
        let query = db.collection("wines").document(wineID)
        query.getDocument { (querySnapshot, err) in
            if let err = err {
                print("Err \(err.localizedDescription)")
            } else {
                let dict = querySnapshot!.data() as! NSDictionary
                self.tasteLbl.text = dict["taste"] as? String ?? ""
                self.nameLbl.text = (dict["name"] as? String ?? "").capitalized
                self.colorLbl.text = dict["color"] as? String ?? ""
            }
        }
    }

}
