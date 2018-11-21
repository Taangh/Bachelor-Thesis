//
//  profileVC.swift
//  Sommelier
//
//  Created by Damian on 16/10/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import UIKit
import FacebookLogin
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class profileVC: UIViewController, FBSDKLoginButtonDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var profilePhotoBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var rankLbl: UILabel!
    @IBOutlet weak var preferencesColorLbl: UILabel!
    @IBOutlet weak var preferencesTasteLbl: UILabel!
    @IBOutlet weak var preferencesMoneyFirstLbl: UILabel!
    @IBOutlet weak var preferencesMoneySecondLbl: UILabel!
    @IBOutlet weak var preferencesMoneyThirdLbl: UILabel!
    @IBOutlet weak var preferencesMoneyFourthLbl: UILabel!

    @IBOutlet weak var reviewPager: UIPageControl!
    @IBOutlet weak var reviewScrollView: UIScrollView!
    @IBOutlet weak var loginBg: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profilePhoto: UIButton!
    @IBOutlet weak var photoBg: UIView!
    var loginButton = FBSDKLoginButton()
    var slides:[slideProfileReview] = []
    let db = Firestore.firestore()
    
    @IBAction func profilePhotoBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Do you want to log out?", preferredStyle: .actionSheet)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive, handler: { (action) -> Void in
            let manager = FBSDKLoginManager()
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

        //importPreferences()
        reviewScrollView.delegate = self
        reviewScrollView.layer.cornerRadius = 10
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        reviewPager.numberOfPages = slides.count
        reviewPager.currentPage = 0
        reviewPager.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)

        view.bringSubviewToFront(reviewPager)
        
            var frame = self.view.center
            frame.y = frame.y - loginButton.frame.height*2
            loginButton.center = frame
            loginButton.delegate = self
            view.addSubview(loginButton)
        
        if(FBSDKAccessToken.current()?.tokenString == nil) {
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
    
    func importPreferences() {
        var query = db.collection("users").document((Auth.auth().currentUser?.uid)!)
        
        query.getDocument { (document, error) in
            if let document = document, document.exists {
                let dict = document.data()
                self.preferencesColorLbl.text = dict?["color"] as! String
                self.preferencesTasteLbl.text = dict?["taste"] as! String
                let price = dict?["price"] as! Int
                
                switch price {
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
                
            } else {
                print("Document does not exist")
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
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        loginButton.isHidden = true
        self.loginBg.isHidden = true
        self.profileView.isHidden = false
        
        if(result.token != nil) {
            let credential = FacebookAuthProvider.credential(withAccessToken: result.token.tokenString)
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                    loginButton.isHidden = false
                    self.loginBg.isHidden = false
                    self.profileView.isHidden = true
                } else {
                    
                }
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
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
        
        let slide1:slideProfileReview = Bundle.main.loadNibNamed("slideProfileReview", owner: self, options: nil)?.first as! slideProfileReview
        slide1.ratingLbl.text = "4.7"
        
        let slide2:slideProfileReview = Bundle.main.loadNibNamed("slideProfileReview", owner: self, options: nil)?.first as! slideProfileReview
        slide2.ratingLbl.text = "4.9"
        
        let slide3:slideProfileReview = Bundle.main.loadNibNamed("slideProfileReview", owner: self, options: nil)?.first as! slideProfileReview
        slide3.ratingLbl.text = "3.1"
        
        return [slide1, slide2, slide3]
    }
    
    
    func setupSlideScrollView(slides : [slideProfileReview]) {
        reviewScrollView.frame = CGRect(x: 0, y: 0, width: 313, height: 170)
        reviewScrollView.contentSize = CGSize(width: 317 * CGFloat(slides.count), height: 170)
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

}
