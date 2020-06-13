//
//  sliderWinesListReview.swift
//  Sommelier
//
//  Created by Damian on 03/11/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import UIKit
import Firebase

class sliderWinesListReview: UIView {
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var review: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    let db = Firestore.firestore()

    override func awakeFromNib() {
        self.profileImage.layer.cornerRadius = profileImage.frame.width/2
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
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.profileImage.image = UIImage(data: data)
            }
        }
    }
}
