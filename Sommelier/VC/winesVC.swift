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
import FirebaseDatabase

class winesVC: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var winesTable: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var reviewTextView: UITextView!
    
    @IBOutlet weak var tasteSegmentedControl: UISegmentedControl!
    @IBOutlet weak var colorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var priceSegmentedControl: UISegmentedControl!

    let db = Firestore.firestore()
    var ref: DatabaseReference!
    var wines = [wine]()
    var showedWines = [wine]()
    
    enum Const {
        static let closeCellHeight: CGFloat = 135
        static let openCellHeight: CGFloat = 410
        static let rowsCount = 10
    }
    
    var cellHeights: [CGFloat] = []

    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        importFromDB(name: "",color: "",taste: "",price: "")

        searchBar.delegate = self
        searchView.isHidden = true
        searchView.layer.cornerRadius = 10
        reviewView.layer.cornerRadius = 10
        winesTable.backgroundColor = .clear
        winesTable.dataSource = self
        winesTable.delegate = self
        assignbackground()
        searchBarCustomize()
        tableSetUp()
        
        NotificationCenter.default.addObserver(self, selector: #selector(winesVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(winesVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func clearFilters(_ sender: Any) {
        tasteSegmentedControl.selectedSegmentIndex = -1
        colorSegmentedControl.selectedSegmentIndex = -1
        priceSegmentedControl.selectedSegmentIndex = -1
        searchBar.text = ""
    }
    
    @IBAction func addReview(_ sender: Any) {
        reviewView.isHidden = false
        winesTable.isHidden = true
        reviewTextView.becomeFirstResponder()
    }
    
    @IBAction func addReviewToDb(_ sender: Any) {
        reviewView.isHidden = true
        winesTable.isHidden = false
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(reviewView.isHidden) {
            self.view.endEditing(true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var color = ""
        var taste = ""
        var price = ""
        
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
            price = priceSegmentedControl.titleForSegment(at: priceSegmentedControl.selectedSegmentIndex) ?? ""
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
    
    private func importFromDB(name: String, color: String, taste: String, price: String) {

        ref = Database.database().reference()
        
        let winesRef = ref.child("wines")
        winesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let val = snapshot.value as? NSDictionary {
                for i in val {
                    let wineData = i.value as! NSDictionary
                    let id = i.key as! String
                    self.wines.append(wine(id: id, name: wineData["name"] as? String ?? "", price: wineData["price"] as? Float ?? 0, amount: wineData["amount"] as? Int ?? 0, color: wineData["color"] as? String ?? "", taste: wineData["taste"] as? String ?? "", vegetables: wineData["vegetables"] as? Bool ?? false, fruits: wineData["fruit"] as? Bool ?? false, cheese: wineData["cheese"] as? Bool ?? false, meat: wineData["meat"] as? Bool ?? false, fish: wineData["fish"] as? Bool ?? false))
                }
            }
            
            self.showedWines = self.wines
            self.winesTable.reloadData()
        })
            
        { (error) in
            print(error.localizedDescription)
        }

//        var query = db.collection("wines").limit(to: 100)
//
//        if(color != "") {
//            query = query.whereField("color", isEqualTo: color)
//        }
//        if(taste != "") {
//            query = query.whereField("taste", isEqualTo: taste)
//        }
//        if(name != "") {
//            query = query.whereField("name", isEqualTo: name.lowercased())
//        }
//        if(price != "") {
//            //query = query.whereField("color", isEqualTo: color)
//        }
//
//        query.getDocuments { (querySnapshot, err) in
//            if let err = err {
//                print("Err \(err.localizedDescription)")
//            } else {
//                self.wines = [wine]()
//                for document in querySnapshot!.documents {
//                    let wineData = document.data() as NSDictionary
//                    let id = document.documentID
//                    self.wines.append(wine(id: id, name: wineData["name"] as? String ?? "", price: wineData["price"] as? Float ?? 0, amount: wineData["amount"] as? Int ?? 0, color: wineData["color"] as? String ?? "", taste: wineData["taste"] as? String ?? "", vegetables: wineData["vegetables"] as? Bool ?? false, fruits: wineData["fruit"] as? Bool ?? false, cheese: wineData["cheese"] as? Bool ?? false, meat: wineData["meat"] as? Bool ?? false, fish: wineData["fish"] as? Bool ?? false))
//
//                    let storage = Storage.storage(url:"gs://diploma-80825.appspot.com")
//                    let storageRef = storage.reference()
//                    let ref = storageRef.child(wineData["label"] as! String)
//
//                    ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
//                        if let error = error {
//                            print("Error: \(error.localizedDescription)")
//                        } else {
//                            let image = UIImage(data: data!)
//                        }
//                    }
//                }
//
//                self.winesTable.reloadData()
//            }
//        }
    }
    
    func importOpinions() {
        
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
    
}

extension winesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.wines.count
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as wineCell = cell else {
            return
        }

        cell.updateCell(wine: wines[indexPath.row])
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
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
