//
//  reviewCell.swift
//  Sommelier
//
//  Created by Damian on 09/12/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import UIKit
import Firebase

class reviewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var color: UILabel!
    @IBOutlet weak var taste: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var review: UITextView!
    
    let db = Firestore.firestore()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.userPhoto.layer.cornerRadius = self.userPhoto.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updataCell(wine: wine, opinion: opinion) {
        self.name.text = wine.name.capitalized
        self.color.text = wine.color
        self.taste.text = wine.taste
        self.amount.text = "\(wine.amount!) ml"
        self.rating.text = "\(opinion.rating!)"
        self.review.text = opinion.review
        setUser(userID: opinion.userID)
        
    }
    
    func setUser(userID: String) {
        print(userID)
        let query = db.collection("users").document(userID)
        query.getDocument { (querySnapshot, err) in
            if let err = err {
                print("Err \(err.localizedDescription)")
            } else {
                let dict = querySnapshot!.data() as! NSDictionary
                self.userName.text = dict["name"] as? String ?? ""
                let imageUrl = dict["userPhoto"] as? String ?? ""
                if let url = URL(string: imageUrl) {
                    self.downloadImage(from: url)
                }
            }
        }
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.userPhoto.image = UIImage(data: data)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}
