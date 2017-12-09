//
//  MoviePosterListingCVCtrlr.swift
//  MovieDB
//
//  Created by Vedant Mahant on 09/12/17.
//  Copyright © 2017 Vedant. All rights reserved.
//

import UIKit

class MoviePosterListingCVCtrlr: UICollectionViewController {
    
    var listMovies = [MovieEntity]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        self.collectionView!.register(UINib(nibName: "MoviePosterCVCell", bundle: nil), forCellWithReuseIdentifier: "MoviePosterCVCell")

        // Do any additional setup after loading the view.
        callListOfMovies()
    }
    
    func callListOfMovies() {
        WebService.shared.callAPI(endPoint: "/discover/movie", withMethod: .get, forParamters: nil) { (serviceResponse, error) in
            guard error == nil else {
                return
            }
            for eachMovie in serviceResponse!["results"] as! [[String:Any]] {
                self.listMovies.append(MovieEntity(eachMovie))
            }
            self.collectionView?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return listMovies.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCVCell", for: indexPath) as! MoviePosterCVCell
        
        // Configure the cell
        cell.movieEntity = listMovies[indexPath.row]
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
