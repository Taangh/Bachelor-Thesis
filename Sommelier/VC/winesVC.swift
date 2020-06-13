//
//  winesVC.swift
//  Sommelier
//
//  Created by Damian on 16/10/2018.
//  Copyright © 2018 Damian. All rights reserved.
//

import UIKit
import FoldingCell
import Firebase
//import FirebaseDatabase

class winesVC: UIViewController, UISearchBarDelegate, UIScrollViewDelegate, AddWineDelegte, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WineCellDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var winesTable: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var addWineView: UIView!
    @IBOutlet weak var addWineBtn: UIButton!
    @IBOutlet weak var addWineScrollView: UIScrollView!
    @IBOutlet weak var addWinePageControl: UIPageControl!
    @IBOutlet weak var addWineToDb: UIButton!
    @IBOutlet weak var sliderRating: UISlider!
    @IBOutlet weak var noteTextBox: UITextView!
    @IBOutlet weak var tasteSegmentedControl: UISegmentedControl!
    @IBOutlet weak var colorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var priceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ratingValue: UILabel!

    let db = Firestore.firestore()
    //var ref: DatabaseReference!
    var wines = [wine]()
    var opinions = [String:[opinion]]()
    var showedWines = [wine]()
    var slides:[sliderAddWine] = [sliderAddWine]()
    var wineID = ""
    var prefColor = ""
    var prefTaste = ""
    var userPoints = 0
    var prefPrice = 0
    let colorDict = ["White": 0, "Red": 1, "Rose": 2]
    let tasteDict = ["Sweet": 0, "Semi Sweet": 1, "Dry": 2]
    var lblImageToAdd: UIImage!
    var lblScan = false
    var lblImages = [String:UIImage]()
    var winePass: wine!
    var opinionsPass: [opinion]!
    
    enum Const {
        static let closeCellHeight: CGFloat = 135
        static let openCellHeight: CGFloat = 500
        static let rowsCount = 10
    }
    
    var cellHeights: [CGFloat] = []

    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadImages()
        //ref = Database.database().reference()
        importPreferences()
        searchBar.delegate = self
        searchView.isHidden = true
        addWineView.isHidden = true
        searchBar.isHidden = false
        searchView.layer.cornerRadius = 10
        reviewView.layer.cornerRadius = 10
        winesTable.backgroundColor = .clear
        winesTable.dataSource = self
        winesTable.delegate = self
        assignbackground()
        searchBarCustomize()
        tableSetUp()
        
        searchBar.showsBookmarkButton = true
        searchBar.setImage(UIImage(named: "cam"), for: .bookmark, state: .normal)
        addWineScrollView.delegate = self

        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        addWinePageControl.numberOfPages = slides.count
        addWinePageControl.currentPage = 0
        addWinePageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
        
        view.bringSubviewToFront(addWinePageControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(winesVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(winesVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //addWineScrollView.isHidden = true
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
       // performSegue(withIdentifier: "camera", sender: nil)
        self.lblScan = true
        self.openCamera()
    }
    
    func findMatchingLbl() {
        var smallerKey = ""
        var smallerPerc = 100.0
        for image in lblImages {
            let imgToCompare = self.lblImageToAdd.resized(withPercentage: 0.2)?.jpegData(compressionQuality: 0.0)
            let imgImg = UIImage(data: imgToCompare!)
            
            let test = compareImages(image1: image.value, image2: imgImg!)
            let width = Double(image.value.size.width)
            let height = Double(image.value.size.height)
            let res = test! * 100 / (width * height * 3.0) / 255.0
            if(smallerPerc>res) {
                smallerPerc = res
                smallerKey = image.key
            }
        }
        
        print(smallerKey)
        foundWine(id: smallerKey)
    }
    
    @objc func scrollViewTapped() {
        performSegue(withIdentifier: "winesToOpinions", sender:self)
    }
    
    func pixelValues(fromCGImage imageRef: CGImage?) -> [UInt8]?
    {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        
        if let imageRef = imageRef {
            width = imageRef.width
            height = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow
            let totalBytes = height * bytesPerRow
            let bitmapInfo = imageRef.bitmapInfo
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            var intensities = [UInt8](repeating: 0, count: totalBytes)
            
            let contextRef = CGContext(data: &intensities,
                                       width: width,
                                       height: height,
                                       bitsPerComponent: bitsPerComponent,
                                       bytesPerRow: bytesPerRow,
                                       space: colorSpace,
                                       bitmapInfo: bitmapInfo.rawValue)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
            
            pixelValues = intensities
        }
        
        return pixelValues
    }
    
    func compareImages(image1: UIImage, image2: UIImage) -> Double? {
        guard let data1 = pixelValues(fromCGImage: image1.cgImage),
            let data2 = pixelValues(fromCGImage: image2.cgImage),
            data1.count == data2.count else {
                return nil
        }
        
        let width = Double(image1.size.width)
        let height = Double(image1.size.height)
        
        return zip(data1, data2)
            .enumerated()
            .reduce(0.0) {
                $1.offset % 4 == 3 ? $0 : $0 + abs(Double($1.element.0) - Double($1.element.1))
        }
    }
    
    func importPreferences() {
        if((Auth.auth().currentUser) != nil) {
            let query = db.collection("users").document((Auth.auth().currentUser?.uid)!)
            
            query.addSnapshotListener { (document, error) in
                if let document = document, document.exists {
                    let dict = document.data()
                    self.prefColor = dict?["color"] as! String
                    self.prefTaste = dict?["taste"] as! String
                    self.prefPrice = dict?["price"] as! Int
                    self.userPoints = dict?["points"] as! Int
                    self.importFromDB(name: "", color: self.prefColor, taste: self.prefTaste, price: self.prefPrice)
                    if(dict?["color"] as! String != "") {
                    self.colorSegmentedControl.selectedSegmentIndex = self.colorDict[self.prefColor]!
                    self.tasteSegmentedControl.selectedSegmentIndex = self.tasteDict[self.prefTaste]!
                    self.priceSegmentedControl.selectedSegmentIndex = self.prefPrice-1
                    }
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            importFromDB(name: "", color: "", taste: "", price: 0)
        }
    }
    
    
    @IBAction func reviewSliderChange(_ sender: UISlider) {
        ratingValue.text = "\(Double(sliderRating.value).rounded(toPlaces: 1))"
    }
    
    @IBAction func addWineToDB(_ sender: Any) {
        addToDb()
        addWineView.isHidden = true
        addWineToDb.isHidden = true
        searchBar.isHidden = false
        winesTable.isHidden = false
        addWineBtn.isHidden = false
        self.view.endEditing(true)
    }
    
    @IBAction func clearFilters(_ sender: Any) {
        tasteSegmentedControl.selectedSegmentIndex = -1
        colorSegmentedControl.selectedSegmentIndex = -1
        priceSegmentedControl.selectedSegmentIndex = -1
        searchBar.text = ""
    }
    
    @IBAction func addReview(_ sender: Any) {
        reviewView.isHidden = false
        searchBar.isHidden = true
        winesTable.isHidden = true
        reviewTextView.becomeFirstResponder()
    }
    
    @IBAction func addReviewToDb(_ sender: Any) {
        addReview()
        reviewView.isHidden = true
        winesTable.isHidden = false
        searchBar.isHidden = false
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        winesTable.isHidden = true
        searchView.isHidden = false
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        winesTable.isHidden = false
        searchView.isHidden = true
        reviewView.isHidden = true
        addWineView.isHidden = true
        searchBar.isHidden = false
        addWineBtn.isHidden = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(reviewView.isHidden&&addWineView.isHidden) {
            self.view.endEditing(true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var color = ""
        var taste = ""
        var price = 0
        
        if(colorSegmentedControl.selectedSegmentIndex != -1)
        {
            color = colorSegmentedControl.titleForSegment(at: colorSegmentedControl.selectedSegmentIndex) ?? ""
        }
        if(tasteSegmentedControl.selectedSegmentIndex != -1)
        {
            taste = tasteSegmentedControl.titleForSegment(at: tasteSegmentedControl.selectedSegmentIndex) ?? ""
        }
        if(priceSegmentedControl.selectedSegmentIndex != -1)
        {
            let priceDolar = priceSegmentedControl.titleForSegment(at: priceSegmentedControl.selectedSegmentIndex)
            switch priceDolar {
            case "$":
                price = 1
            case "$$":
                price = 2
            case "$$$":
                price = 3
            default:
                price = 4
                
            }
        }
        
        showedWines = wines
        
        if(searchBar.text != "") {
            var tempArr = [wine]()
            for wine in showedWines where wine.name == searchBar.text {
                tempArr.append(wine)
            }
            showedWines = tempArr
        }
        
        if(color != "") {
            var tempArr = [wine]()
            for wine in showedWines where wine.color == color {
                tempArr.append(wine)
            }
            showedWines = tempArr
        }
        
        if(taste != "") {
            var tempArr = [wine]()
            for wine in showedWines where wine.taste == taste {
                tempArr.append(wine)
            }
            showedWines = tempArr
        }
        
        importFromDB(name: searchBar.text ?? "", color:  color, taste: taste, price: price)
        searchBar.resignFirstResponder()
    }
    
    private func importFromDB(name: String, color: String, taste: String, price: Int) {
        
        var query = db.collection("wines").limit(to: 100)

        if(color != "") {
            query = query.whereField("color", isEqualTo: color)
        }
        if(taste != "") {
            query = query.whereField("taste", isEqualTo: taste)
        }
        if(name != "") {
            query = query.whereField("name", isEqualTo: name.lowercased())
        }
        if(price != 0) {
            switch price {
            case 1:
                query = query.whereField("price", isGreaterThan: 1).whereField("price", isLessThan: 15)
            case 2:
                query = query.whereField("price", isGreaterThan: 14).whereField("price", isLessThan: 30)
            case 3:
                query = query.whereField("price", isGreaterThan: 29).whereField("price", isLessThan: 100)
            default:
                query = query.whereField("price", isGreaterThan: 99)
            }
        }

        query.addSnapshotListener { (querySnapshot, err) in
            if err == nil {
                self.wines = [wine]()
                for document in querySnapshot!.documents {
                    let wineData = document.data() as NSDictionary
                    let id = document.documentID
                    self.wines.append(wine(id: id, name: wineData["name"] as? String ?? "", price: wineData["price"] as? Float ?? 0, amount: wineData["amount"] as? Int ?? 0, color: wineData["color"] as? String ?? "", taste: wineData["taste"] as? String ?? "", country: wineData["country"] as? String ?? "", vintage: wineData["vintage"] as? Int ?? 0, vegetables: wineData["vegetables"] as? Bool ?? false, fruits: wineData["fruit"] as? Bool ?? false, cheese: wineData["cheese"] as? Bool ?? false, meat: wineData["meat"] as? Bool ?? false, fish: wineData["fish"] as? Bool ?? false, opinions: [opinion]()))
                }
                
                self.importOpinions()
                //self.winesTable.reloadData()
            } else {
                self.winesTable.reloadData()
            }
        }
        
    }
    
    func foundWine(id: String) {
        let query = db.collection("wines").document(id)
        query.getDocument { (document, error) in
            if let error = error {
                print("Err \(error.localizedDescription)")
            } else {
                self.wines = [wine]()
                let wineData = document!.data()!
                self.wines.append(wine(id: id, name: wineData["name"] as? String ?? "", price: wineData["price"] as? Float ?? 0, amount: wineData["amount"] as? Int ?? 0, color: wineData["color"] as? String ?? "", taste: wineData["taste"] as? String ?? "", country: wineData["country"] as? String ?? "", vintage: wineData["vintage"] as? Int ?? 0, vegetables: wineData["vegetables"] as? Bool ?? false, fruits: wineData["fruit"] as? Bool ?? false, cheese: wineData["cheese"] as? Bool ?? false, meat: wineData["meat"] as? Bool ?? false, fish: wineData["fish"] as? Bool ?? false, opinions: [opinion]()))
                self.winesTable.reloadData()
            }
        }
    }
    
    func importOpinions() {
        let query = db.collection("opinions")
        query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Err \(err.localizedDescription)")
            } else {
                self.opinions = [String:[opinion]]()
                for document in querySnapshot!.documents {
                    let opinionData = document.data() as NSDictionary
                    var opinionsArr = [opinion]()
                    let key = opinionData["wineID"] as? String ?? ""
                    opinionsArr = self.opinions[key] ?? [opinion]()
                    opinionsArr.append(opinion(id: document.documentID, rating: opinionData["rating"] as? Double ?? 0, userID: opinionData["userID"] as? String ?? "", wineID: opinionData["wineID"] as? String ?? "", review: opinionData["review"] as? String ?? "", note: opinionData["note"] as? String ?? ""))
                    self.opinions[key] = opinionsArr
                }
                
                let amount = self.wines.count-1
                if(amount >= 0) {
                for i in 0...self.wines.count-1 {
                    self.wines[i].opinions = self.opinions[self.wines[i].id]

                var rating = 0.0
                var avg = 0.0
                if(self.wines[i].opinions != nil) {
                    for opinion in self.wines[i].opinions {
                        rating += Double(opinion.rating).rounded(toPlaces: 1)
                    }
                    avg = Double(Float(rating)/Float(self.wines[i].opinions.count)).rounded(toPlaces: 1)
                } else {
                    avg = 0.0
                }
                
                self.wines[i].rating = avg

                }
                }
                
                self.wines.sort(by: {$0.rating > $1.rating})
                self.winesTable.reloadData()
            }
        }
    }
    
    
    func createSlides() -> [sliderAddWine] {
        
        let slide1:sliderAddWine = Bundle.main.loadNibNamed("sliderAddWine", owner: self, options: nil)?.first as! sliderAddWine
        slide1.secondView.isHidden = true
        slide1.thirdView.isHidden = true
        //slide1.ratingLbl.text = "4.7"
        
        let slide2:sliderAddWine = Bundle.main.loadNibNamed("sliderAddWine", owner: self, options: nil)?.first as! sliderAddWine
        //slide2.ratingLbl.text = "4.9"
        slide2.firstView.isHidden = true
        slide2.thirdView.isHidden = true
        
        let slide3:sliderAddWine = Bundle.main.loadNibNamed("sliderAddWine", owner: self, options: nil)?.first as! sliderAddWine
        slide3.firstView.isHidden = true
        slide3.secondView.isHidden = true
        slide3.delegate = self
        //slide3.ratingLbl.text = "3.1"
        
        return [slide1, slide2, slide3]
    }
    
    func setupSlideScrollView(slides : [sliderAddWine]) {
        //addWineScrollView.frame = CGRect(x: 0, y: 0, width: 343, height: 310)
        addWineScrollView.contentSize = CGSize(width: 343 * CGFloat(slides.count), height: 295)
        addWineScrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: 343 * CGFloat(i), y: 0, width: 343, height: 295)
            addWineScrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(addWineScrollView.contentOffset.x/343)
        addWinePageControl.currentPage = Int(pageIndex)
        if(Int(pageIndex)==2) {
            addWineToDb.isEnabled = true
            addWineToDb.layer.opacity = 1

        }
        
    }
    
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(addWinePageControl.currentPage) * addWineScrollView.frame.size.width
        addWineScrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    
    private func tableSetUp() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
        winesTable.estimatedRowHeight = Const.closeCellHeight
        winesTable.rowHeight = UITableView.automaticDimension
        if #available(iOS 10.0, *) {
            winesTable.refreshControl = UIRefreshControl()
            winesTable.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }
    
    @objc func refreshHandler() {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            if #available(iOS 10.0, *) {
                self?.winesTable.refreshControl?.endRefreshing()
            }
            self?.winesTable.reloadData()
        })
    }
    
    private func searchBarCustomize() {
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = #colorLiteral(red: 0.862745098, green: 0.8, blue: 0.8509803922, alpha: 1)
        searchBar?.tintColor = #colorLiteral(red: 0.7802448869, green: 0.7800709605, blue: 0.8006975055, alpha: 1)
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = #colorLiteral(red: 0.7802448869, green: 0.7800709605, blue: 0.8006975055, alpha: 1)
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = #colorLiteral(red: 0.7802448869, green: 0.7800709605, blue: 0.8006975055, alpha: 1)
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(UIImage(named: "ic_clear"), for: .normal)
        clearButton.tintColor = #colorLiteral(red: 0.7802448869, green: 0.7800709605, blue: 0.8006975055, alpha: 1)
    }
    
    private func assignbackground() {
        let background = UIImage(named: "bg1")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    @IBAction func addWine(_ sender: Any) {
        winesTable.isHidden = true
        addWineBtn.isHidden = true
        addWineToDb.isHidden = false
        searchBar.isHidden = true
        addWineView.isHidden = false
        addWineToDb.isEnabled = false
        addWineToDb.layer.opacity = 0.7
        
        self.view.endEditing(false)

    }
    
    func addToDb() {
        let name = slides[0].nameTxtField.text
        let amount = Double(slides[0].amountTxtField.text!)
        let price = Double(slides[0].priceTxtField.text!)
        let color = slides[1].colorSegmnet.titleForSegment(at: slides[1].colorSegmnet.selectedSegmentIndex)
        let taste = slides[1].tasteSegment.titleForSegment(at: slides[1].tasteSegment.selectedSegmentIndex)
        let cheese = slides[1].cheese
        let vegetable = slides[1].vegetable
        let fruit = slides[1].fruit
        let fish = slides[1].fish
        let meat = slides[1].meat
        let country = slides[2].countryTxtField.text
        let vintage = Double(slides[2].vintageTxtField.text!)
        
        let storage = Storage.storage(url:"gs://diploma-80825.appspot.com")
        let storageRef = storage.reference()
        
        var ref: DocumentReference? = nil
        ref = db.collection("wines").addDocument(data: [
            "name": name?.lowercased() ,
            "color": color,
            "taste": taste,
            "country": country,
            "vintage": vintage,
            "amount": amount,
            "price": price,
            "cheese": !cheese,
            "fish": !fish,
            "vegetable": !vegetable,
            "fruit": !fruit,
            "meat": !meat,



        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                let ref = "labels/\(ref!.documentID).jpg"
                let riversRef = storageRef.child(ref)
                let uploadTask = riversRef.putData((self.lblImageToAdd.resized(withPercentage: 0.2)?.jpegData(compressionQuality: 0.0)!)!, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    // Metadata contains file metadata such as size, content-type.
                    let size = metadata.size
                    // You can also access to download URL after upload.
                    riversRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                    }
                }
            }
        }

    }
    
    func downloadImages() {
        let query = db.collection("wines")
        let storage = Storage.storage(url:"gs://diploma-80825.appspot.com")
        query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                //self.wines = [wine]()
                print("Err \(err.localizedDescription)")
            } else {
                self.lblImages = [String:UIImage]()
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    let path = "labels/\(id).jpg"
                    let storageRef = storage.reference(withPath: path)
                    
                    storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            self.lblImages[id] = UIImage(data: data!)!
                            print("downloaded with \(path)")
                        }
                    }
                    
                }
            }
        }
    }
    
    func addReview() {
        let rating = Double(sliderRating.value).rounded(toPlaces: 1)

        var ref: DocumentReference? = nil
        ref = db.collection("opinions").addDocument(data: [
            "rating": rating,
            "review": reviewTextView.text,
            "userID": Auth.auth().currentUser?.uid,
            "wineID": wineID,
            "note": noteTextBox.text
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
            }
        }
        
        self.db.collection("users").document((Auth.auth().currentUser?.uid)!).updateData([
            "points": self.userPoints+1,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
            }
        }
    }
    
    @IBAction func cancelWineAdd(_ sender: UIButton) {
        winesTable.isHidden = false
        addWineBtn.isHidden = false
        searchBar.isHidden = false
        addWineView.isHidden = true
        self.view.endEditing(true)
    }
    
    @IBAction func cancelReviewAdd(_ sender: UIButton) {
        winesTable.isHidden = false
        reviewView.isHidden = true
        searchView.isHidden = true
        self.view.endEditing(true)
    }
    
    func scrollViewTap(wine: wine, opinions: [opinion]) {
        self.winePass = wine
        self.opinionsPass = opinions
        performSegue(withIdentifier: "winesToOpinions", sender: nil)
    }
    
    
    func didButtonTapped() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have perission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // imageViewPic.contentMode = .scaleToFill
            self.lblImageToAdd = pickedImage
            if(lblScan) {
                self.findMatchingLbl()
                self.lblScan = false
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "winesToOpinions" {
            if let viewController = segue.destination as? reviewsVC {
                viewController.opinions = self.opinionsPass
                viewController.wine = self.winePass
            }
        }
    }
}

//TableView Extension
extension winesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.wines.count
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as wineCell = cell else {
            return
        }
        
        if(self.wines.count != 0) {
        cell.updateCell(wine: wines[indexPath.row])
        cell.downloadImage(wineID: self.wines[indexPath.row].id)
        cell.delegate = self
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
        }
        //cell.number = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = winesTable.dequeueReusableCell(withIdentifier: "wineCell", for: indexPath) as! FoldingCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        return cell
    }
    
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.wines.count != 0) {
        self.wineID = wines[indexPath.row].id!
        let cell = winesTable.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = Const.openCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = Const.closeCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            self.winesTable.beginUpdates()
            self.winesTable.endUpdates()
        }, completion: nil)
    }
    }
    
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    
    func resizedTo1MB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > 1000 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = resizedImage.pngData()
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }


}
