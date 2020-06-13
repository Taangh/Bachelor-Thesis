//
//  profileVC.swift
//  Sommelier
//
//  Created by Damian on 16/10/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class profileVC: UIViewController, LoginButtonDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var profilePhotoBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var rankLbl: UILabel!
    @IBOutlet weak var preferencesColorLbl: UILabel!
    @IBOutlet weak var preferencesTasteLbl: UILabel!
    @IBOutlet weak var preferencesMoneyFirstLbl: UILabel!
    @IBOutlet weak var preferencesMoneySecondLbl: UILabel!
    @IBOutlet weak var preferencesMoneyThirdLbl: UILabel!
    @IBOutlet weak var preferencesMoneyFourthLbl: UILabel!
    @IBOutlet weak var editProfileView: UIView!
    @IBOutlet weak var prefView: UIView!
    @IBOutlet weak var colorSegment: UISegmentedControl!
    @IBOutlet weak var tasteSegment: UISegmentedControl!
    @IBOutlet weak var priceSegment: UISegmentedControl!
    @IBOutlet weak var reviewPager: UIPageControl!
    @IBOutlet weak var reviewScrollView: UIScrollView!
    @IBOutlet weak var loginBg: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profilePhoto: UIButton!
    @IBOutlet weak var photoBg: UIView!
    @IBOutlet weak var noOpinionView: UIView!
    var prefPrice = 0
    var opinions = [opinion]()
    var loginButton = FBLoginButton()
    var slides:[slideProfileReview] = []
    let db = Firestore.firestore()
    
    let colorDict = ["White": 0, "Red": 1, "Rose": 2]
    let tasteDict = ["Sweet": 0, "Semi Sweet": 1, "Dry": 2]
    
    @IBAction func profilePhotoBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Do you want to log out?", preferredStyle: .actionSheet)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive, handler: { (action) -> Void in
            let manager = LoginManager()
            manager.logOut()
            try! Auth.auth().signOut()
            self.loginBg.isHidden = false
            self.profileView.isHidden = true
            self.loginButton.isHidden = false
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(logOutAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        importOpinions()
        importPreferences()

        reviewScrollView.delegate = self
        reviewScrollView.layer.cornerRadius = 10
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        reviewScrollView.addGestureRecognizer(scrollViewTap)

        
            var frame = self.view.center
            frame.y = frame.y - loginButton.frame.height*2
            loginButton.center = frame
            loginButton.delegate = self
            view.addSubview(loginButton)
        
        if(AccessToken.current?.tokenString == nil) {
            loginBg.isHidden = false
            profileView.isHidden = true
            loginButton.isHidden = false

        } else {
            loginBg.isHidden = true
            profileView.isHidden = false
            loginButton.isHidden = true
            nameLbl.text = Auth.auth().currentUser?.displayName
            let imageUrl = (Auth.auth().currentUser?.photoURL?.absoluteString)! + "?height=500"
            print(imageUrl)
            if let url = URL(string: imageUrl) {
                downloadImage(from: url)
            }
            
        }
        
        profilePhoto.layer.cornerRadius = profilePhoto.bounds.width/2
        photoBg.layer.cornerRadius = photoBg.bounds.width/2

        profilePhoto.clipsToBounds = true
        profileView.backgroundColor = .clear
        assignbackground()
        
    }
    
    func addUserToDb() {
        db.collection("users").document((Auth.auth().currentUser?.uid)!).getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    print("Exists")
                } else {
                    print("Not exist")
                    self.db.collection("users").document((Auth.auth().currentUser?.uid)!).setData([
                        "color": "",
                        "taste": "",
                        "name": Auth.auth().currentUser?.displayName!,
                        "points": 0,
                        "price": 0,
                        "userPhoto": Auth.auth().currentUser?.photoURL?.absoluteString
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                        }
                    }

                }
            }
            
        }
    }
    
    func importPreferences() {
        if((Auth.auth().currentUser) != nil) {
        let query = db.collection("users").document((Auth.auth().currentUser?.uid)!)
        
        query.addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                let dict = document.data()
                if(dict?["color"] as! String != "") {
                    self.preferencesColorLbl.text = dict?["color"] as! String
                    self.preferencesTasteLbl.text = dict?["taste"] as! String
                } else {
                    self.preferencesColorLbl.text = "-"
                    self.preferencesTasteLbl.text = "-"

                }
                self.prefPrice = dict?["price"] as! Int
                switch self.prefPrice {
                    case 1:
                        self.preferencesMoneyFirstLbl.textColor = #colorLiteral(red: 0.3294117647, green: 0.2823529412, blue: 0.3137254902, alpha: 1)
                        self.preferencesMoneySecondLbl.textColor = #colorLiteral(red: 0.5529411765, green: 0.4784313725, blue: 0.5294117647, alpha: 1)
                        self.preferencesMoneyThirdLbl.textColor = #colorLiteral(red: 0.5529411765, green: 0.4784313725, blue: 0.5294117647, alpha: 1)
                        self.preferencesMoneyFourthLbl.textColor = #colorLiteral(red: 0.5529411765, green: 0.4784313725, blue: 0.5294117647, alpha: 1)
                    case 2:
                        self.preferencesMoneyFirstLbl.textColor = #colorLiteral(red: 0.3294117647, green: 0.2823529412, blue: 0.3137254902, alpha: 1)
                        self.preferencesMoneySecondLbl.textColor = #colorLiteral(red: 0.3294117647, green: 0.2823529412, blue: 0.3137254902, alpha: 1)
                        self.preferencesMoneyThirdLbl.textColor = #colorLiteral(red: 0.5529411765, green: 0.4784313725, blue: 0.5294117647, alpha: 1)
                        self.preferencesMoneyFourthLbl.textColor = #colorLiteral(red: 0.5529411765, green: 0.4784313725, blue: 0.5294117647, alpha: 1)
                    case 3:
                        self.preferencesMoneyFirstLbl.textColor = #colorLiteral(red: 0.3294117647, green: 0.2823529412, blue: 0.3137254902, alpha: 1)
                        self.preferencesMoneySecondLbl.textColor = #colorLiteral(red: 0.3294117647, green: 0.2823529412, blue: 0.3137254902, alpha: 1)
                        self.preferencesMoneyThirdLbl.textColor = #colorLiteral(red: 0.3294117647, green: 0.2823529412, blue: 0.3137254902, alpha: 1)
                        self.preferencesMoneyFourthLbl.textColor = #colorLiteral(red: 0.5529411765, green: 0.4784313725, blue: 0.5294117647, alpha: 1)
                    case 4:
                        self.preferencesMoneyFirstLbl.textColor = #colorLiteral(red: 0.3294117647, green: 0.2823529412, blue: 0.3137254902, alpha: 1)
                        self.preferencesMoneySecondLbl.textColor = #colorLiteral(red: 0.3294117647, green: 0.2823529412, blue: 0.3137254902, alpha: 1)
                        self.preferencesMoneyThirdLbl.textColor = #colorLiteral(red: 0.3294117647, green: 0.2823529412, blue: 0.3137254902, alpha: 1)
                        self.preferencesMoneyFourthLbl.textColor = #colorLiteral(red: 0.3294117647, green: 0.2823529412, blue: 0.3137254902, alpha: 1)
                    default:
                        print("oj")
                }
                
                let points = dict?["points"] as! Int
                if(points < 11) {
                    self.rankLbl.text = "Beginner Sommelier | \(points)"
                } else if(points < 26) {
                    self.rankLbl.text = "Sommelier | \(points)"
                } else if(points < 51) {
                    self.rankLbl.text = "Advanced Sommelier | \(points)"
                } else {
                    self.rankLbl.text = "Master of Wine | \(points)"
                }
                
            } else {
                print("Document does not exist")
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
                self.profilePhoto.setBackgroundImage(UIImage(data: data), for: .normal)
            }
        }
    }
    
    func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
        loginButton.isHidden = true
        self.loginBg.isHidden = true
        self.profileView.isHidden = false
        
        if(result != nil) {
            let credential = FacebookAuthProvider.credential(withAccessToken: result.token!.tokenString)
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                    loginButton.isHidden = false
                    self.loginBg.isHidden = false
                    self.profileView.isHidden = true
                } else {
                    self.importOpinions()
                    loginButton.isHidden = true
                    self.nameLbl.text = Auth.auth().currentUser?.displayName
                    let imageUrl = (Auth.auth().currentUser?.photoURL?.absoluteString)! + "?height=500"
                    self.addUserToDb()
                    print(imageUrl)
                    if let url = URL(string: imageUrl) {
                        self.downloadImage(from: url)
                    }
                }
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton!) {
        
        try! Auth.auth().signOut()
    }
    
    func assignbackground(){
        let background = UIImage(named: "bg2")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    func createSlides() -> [slideProfileReview] {
        var amount = opinions.count
        var slides = [slideProfileReview]()
        if(amount>3) {
            amount = 3
        }
        
        for i in 0...(amount-1) {
            let slide:slideProfileReview = Bundle.main.loadNibNamed("slideProfileReview", owner: self, options: nil)?.first as! slideProfileReview
            let rating = Double(opinions[i].rating).rounded(toPlaces: 1)
            
            slide.ratingLbl.text = "\(rating)"
            slide.reviewLbl.text = opinions[i].review
            slide.setWine(wineID: opinions[i].wineID)
            slides.append(slide)
        }
        
        return slides
        
    }
    
    
    func setupSlideScrollView(slides : [slideProfileReview]) {
      //  reviewScrollView.frame = CGRect(x: 0, y: 0, width: 313, height: 170)
        reviewScrollView.contentSize = CGSize(width: 313 * CGFloat(slides.count), height: 170)
        reviewScrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: 313 * CGFloat(i), y: 0, width: 313, height: 170)
            reviewScrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(reviewScrollView.contentOffset.x/313)
        reviewPager.currentPage = Int(pageIndex)
    
    }
    
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(reviewPager.currentPage) * reviewScrollView.frame.size.width
        reviewScrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    @IBAction func editPref(_ sender: UIButton) {
        prefView.isHidden = true
        editProfileView.isHidden = false
        
        if(preferencesColorLbl.text != "-") {
            colorSegment.selectedSegmentIndex = colorDict[preferencesColorLbl.text!]!
            tasteSegment.selectedSegmentIndex = tasteDict[preferencesTasteLbl.text!]!
            priceSegment.selectedSegmentIndex = self.prefPrice-1
        }
    }
    
    @IBAction func cancelEditPref(_ sender: UIButton) {
        prefView.isHidden = false
        editProfileView.isHidden = true
    }
    
    @IBAction func savePreferences(_ sender: UIButton) {
        prefView.isHidden = false
        editProfileView.isHidden = true
        var priceValue = 0
        let priceDolar = priceSegment.titleForSegment(at: priceSegment.selectedSegmentIndex)
        switch priceDolar {
        case "$":
            priceValue = 1
        case "$$":
            priceValue = 2
        case "$$$":
            priceValue = 3
        default:
            priceValue = 4
            
        }
        
        db.collection("users").document((Auth.auth().currentUser?.uid)!).updateData([
            "color": colorSegment.titleForSegment(at: colorSegment.selectedSegmentIndex)!,
            "taste": tasteSegment.titleForSegment(at: tasteSegment.selectedSegmentIndex)!,
            "price": priceValue
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func importOpinions() {
        let query = db.collection("opinions").whereField("userID", isEqualTo: Auth.auth().currentUser?.uid ?? "")
        query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Err \(err.localizedDescription)")
            } else {
                self.opinions = [opinion]()
                for document in querySnapshot!.documents {
                    let opinionData = document.data() as NSDictionary
                    self.opinions.append(opinion(id: document.documentID, rating: opinionData["rating"] as? Double ?? 0, userID: opinionData["userID"] as? String ?? "", wineID: opinionData["wineID"] as? String ?? "", review: opinionData["review"] as? String ?? "", note: opinionData["note"] as? String ?? ""))
                }
                
                if(self.opinions.count != 0) {
                    self.noOpinionView.isHidden = true
                self.slides = self.createSlides()
                self.setupSlideScrollView(slides: self.slides)
                
                self.reviewPager.numberOfPages = self.slides.count
                self.reviewPager.currentPage = 0
                self.reviewPager.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
                
                self.view.bringSubviewToFront(self.reviewPager)
                } else {
                    self.noOpinionView.isHidden = false
                }
            }
        }
    }
    
    @objc func scrollViewTapped() {
        performSegue(withIdentifier: "profileToOpinions", sender:self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileToOpinions" {
            if let viewController = segue.destination as? opinionsVC {
                    viewController.opinions = opinions
                }
            }
    }
}
