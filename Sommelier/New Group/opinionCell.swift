//
//  opinionCell.swift
//  Sommelier
//
//  Created by Damian on 05/12/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import UIKit
import Firebase

class opinionCell: UITableViewCell {
    
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var review: UITextView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var taste: UILabel!
    @IBOutlet weak var color: UILabel!
    
    let db = Firestore.firestore()


    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func updateCell() {
        //self.profileImage 
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setWine(wineID: String) {
        let query = db.collection("wines").document(wineID)
        query.getDocument { (querySnapshot, err) in
            if let err = err {
                print("Err \(err.localizedDescription)")
            } else {
                let dict = querySnapshot!.data() as! NSDictionary
                self.taste.text = dict["taste"] as? String ?? ""
                self.name.text = (dict["name"] as? String ?? "").capitalized
                self.color.text = dict["color"] as? String ?? ""
            }
        }
    }

}
