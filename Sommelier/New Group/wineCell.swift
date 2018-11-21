
//
//  header.swift
//  Sommelier
//
//  Created by Damian on 16/10/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import UIKit
import FoldingCell
import Firebase

class wineCell: FoldingCell, UIScrollViewDelegate {
    
    @IBOutlet weak var nameClosed: UILabel!
    @IBOutlet weak var nameOpened: UILabel!
    @IBOutlet weak var ratingClosed: UILabel!
    @IBOutlet weak var ratingOpened: UILabel!
    @IBOutlet weak var priceClosed: UILabel!
    @IBOutlet weak var priceOpened: UILabel!
    @IBOutlet weak var amountClosed: UILabel!
    @IBOutlet weak var amountOpened: UILabel!
    @IBOutlet weak var colorClosed: UILabel!
    @IBOutlet weak var colorOpened: UILabel!
    @IBOutlet weak var tasteClosed: UILabel!
    @IBOutlet weak var tasteOpened: UILabel!
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var cheeseBtn: UIButton!
    @IBOutlet weak var vegetableBtn: UIButton!
    @IBOutlet weak var fruitBtn: UIButton!
    @IBOutlet weak var fishBtn: UIButton!
    @IBOutlet weak var meatBtn: UIButton!
    @IBOutlet weak var reviewScrollView: UIScrollView!
    @IBOutlet weak var reviewPager: UIPageControl!
    var slides:[sliderWinesListReview] = []
    let db = Firestore.firestore()
    var opinionsArr = [opinion]()
    //var ref: DatabaseReference!
        


    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        //profilePhoto.layer.cornerRadius = profilePhoto.bounds.width/2
        super.awakeFromNib()
        reviewScrollView.delegate = self
        reviewScrollView.layer.cornerRadius = 10

        
        //view.bringSubviewToFront(reviewPager)
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    func updateCell(wine: wine) {
        self.nameClosed.text = wine.name.capitalized
        self.nameOpened.text = wine.name.capitalized
        self.priceClosed.text = "\(wine.price ?? 0) zł"
        self.priceOpened.text = "\(wine.price ?? 0) zł"
        self.amountClosed.text = "\(wine.amount ?? 0) ml"
        self.amountOpened.text = "\(wine.amount ?? 0) ml"
        self.colorClosed.text = wine.color
        self.colorOpened.text = wine.color
        self.tasteClosed.text = wine.taste
        self.tasteOpened.text = wine.taste
        self.fishBtn.isEnabled = wine.fish
        self.vegetableBtn.isEnabled = wine.vegetables
        self.meatBtn.isEnabled = wine.meat
        self.fruitBtn.isEnabled = wine.fruits
        self.cheeseBtn.isEnabled = wine.cheese
        
        importPreferences(wineID: wine.id, wine: wine)
        
    }
    
    func createSlides(wine: wine) -> [sliderWinesListReview] {
        var amount = opinionsArr.count
        var slides = [sliderWinesListReview]()
        if(amount>3) {
            amount = 3
        }
        
        for _ in 0...amount {
            let slide:sliderWinesListReview = Bundle.main.loadNibNamed("sliderWinesListReview", owner: self, options: nil)?.first as! sliderWinesListReview
            //slide.ratingLbl.text = "4.7"
            slides.append(slide)
        }
        
        print("SLIDES \(slides.count)")
        return slides
    }
    
    
    func setupSlideScrollView(slides : [sliderWinesListReview]) {
        reviewScrollView.frame = CGRect(x: 0, y: 0, width: 315, height: 143)
        reviewScrollView.contentSize = CGSize(width: 315 * CGFloat(slides.count), height: 143)
        reviewScrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: 315 * CGFloat(i), y: 0, width: 315, height: 143)
            reviewScrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(reviewScrollView.contentOffset.x/315)
        reviewPager.currentPage = Int(pageIndex)
        
    }
    
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(reviewPager.currentPage) * reviewScrollView.frame.size.width
        reviewScrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func importPreferences(wineID: String, wine: wine) {
        
        let query = db.collection("opinions").limit(to: 3).whereField("wineID", isEqualTo: wineID)
        query.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Err \(err.localizedDescription)")
            } else {
                for document in querySnapshot!.documents {
                    let dict = document.data() as NSDictionary
                    self.opinionsArr.append(opinion(id: document.documentID, rating: dict["rating"] as? Float ?? 0, userID: dict["userID"] as? String ?? "", wineID: dict["wineID"] as? String ?? "", review: dict["review"] as? String ?? ""))
                }
                print(self.opinionsArr)
                self.slides = self.createSlides(wine: wine)
                self.setupSlideScrollView(slides: self.slides)
                
                self.reviewPager.numberOfPages = self.slides.count
                self.reviewPager.currentPage = 0
                self.reviewPager.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
        }
    }
}
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
