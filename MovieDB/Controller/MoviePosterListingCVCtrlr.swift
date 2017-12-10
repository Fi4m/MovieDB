//
//  MoviePosterListingCVCtrlr.swift
//  MovieDB
//
//  Created by Vedant Mahant on 09/12/17.
//  Copyright © 2017 Vedant. All rights reserved.
//

import UIKit
import SWRevealViewController
import Kingfisher

// MARK: - Declaring Sorting Protocol
protocol RefreshMovieListingDelegate {
    func refreshMovieListing(withParameters params: [String:Any])
}

class MoviePosterListingCVCtrlr: UICollectionViewController {
    
    var listMovies: [MovieEntity]!
    
    //reactive variable for api calls
    var parameters: [String:Any]! {
        didSet {
            if moviePosterListingType == .discover {
                callListOfMovies()
            }
            else {
                callSearchResults()
            }
        }
    }
    var moviePosterListingType = Endpoint.discover {
        didSet {
            let indexPath = IndexPath(item: 0, section: 0)
            if collectionView?.cellForItem(at: indexPath) != nil {
                collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MovieDB"
        
        //register nib for reuse in collection view
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView")
        collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView?.backgroundColor = .white
        setupNavigationItem()
        parameters = [String:Any]()
    }
    
    /*
    Setup SWRevealViewController on right with bar button and gesture.
    Initialize searchBar on navigationItem
    */
    func setupNavigationItem() {
        let barBtnReveal = UIBarButtonItem(image: #imageLiteral(resourceName: "sort-descending"), style: .plain, target: self.revealViewController(), action: #selector(self.revealViewController().rightRevealToggle(_:)))
        navigationItem.rightBarButtonItem = barBtnReveal
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listMovies?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        guard cell.subviews.count != 0 else {
            return cell
        }
        let imgMoviePoster = UIImageView(frame: cell.bounds)
        imgMoviePoster.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.addSubview(imgMoviePoster)
        imgMoviePoster.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500/\(listMovies[indexPath.row].imgPosterURL)")!)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destination = MovieDetailsVC(listMovies[indexPath.row])
        destination.navigationItem.title = "Movie Details"
        navigationController?.pushViewController(destination, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView", for: indexPath)
        footerView.backgroundColor = .black
        footerView.frame.size.height = 124
        guard footerView.subviews.count == 0 else {
            
            //enable pagination when footer is called on the second time
            if moviePosterListingType == .discover {
                if let page = parameters["page"] as? Int {
                    parameters["page"] = page + 1
                }
                else {
                    parameters["page"] = 2
                }
            }
            else {
                parameters["page"] = parameters["page"] as! Int + 1
            }
            return footerView
        }
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.frame.origin = CGPoint(x: footerView.bounds.width/2 - activityIndicator.bounds.width/2, y: footerView.bounds.height/2 - activityIndicator.bounds.height/2)
        activityIndicator.startAnimating()
        footerView.addSubview(activityIndicator)
        return footerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
    
    //call discover endpoint
    func callListOfMovies() {
        WebService.shared.callAPI(endPoint: .discover, withMethod: .get, forParamters: parameters) { (serviceResponse) in
            self.populateArrayAndReloadData(serviceResponse["results"] as! [[String:Any]])
        }
    }
    
    func populateArrayAndReloadData(_ dictArray: [[String:Any]]) {
        if parameters["page"] == nil || parameters["page"] as! Int == 1 {
            self.listMovies = [MovieEntity]()
        }
        var indexPaths = [IndexPath]()
        for (index,eachMovie) in dictArray.enumerated() {
            self.listMovies.append(MovieEntity(eachMovie))
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        
        //performBatchUpdates was producing wierd animations
//        collectionView?.performBatchUpdates({
//            collectionView?.insertItems(at: indexPaths)
//        }, completion: nil)
        collectionView?.reloadData()
    }
}

extension MoviePosterListingCVCtrlr: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2, height: collectionView.bounds.width * 16 / 18)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Sorting Delegate
extension MoviePosterListingCVCtrlr: RefreshMovieListingDelegate {
    func refreshMovieListing(withParameters params: [String : Any]) {
        let indexPath = IndexPath(item: 0, section: 0)
        if collectionView?.cellForItem(at: indexPath) != nil {
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        parameters = params
    }
}

// MARK: - Search Query
extension MoviePosterListingCVCtrlr: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard !(searchController.searchBar.text!.isEmpty) else {
            moviePosterListingType = .discover
            parameters = [String:Any]()
            return
        }
        moviePosterListingType = .search
        parameters = ["query":searchController.searchBar.text!,
                      "page":1]
    }
    
    //call search endpoint
    func callSearchResults() {
        WebService.shared.callAPI(endPoint: .search, withMethod: .get, forParamters: parameters) { (serviceResponse) in
            self.populateArrayAndReloadData(serviceResponse["results"] as! [[String:Any]])
        }
    }
}
