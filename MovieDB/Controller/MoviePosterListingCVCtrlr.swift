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
import MBProgressHUD

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
        
        setupCollectionView()
        setupNavigationItem()
        parameters = [String:Any]()
    }
    
    func setupCollectionView() {
        collectionView?.backgroundColor = .black
        collectionView?.register(UINib(nibName: "MoviePosterCVCell", bundle: nil), forCellWithReuseIdentifier: "MoviePosterCVCell")
        collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView")
        collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView?.backgroundColor = .white
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCVCell", for: indexPath) as! MoviePosterCVCell
        
        cell.movieEntity = listMovies[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destination = MovieDetailsVC(listMovies[indexPath.row])
        destination.navigationItem.title = "Movie Details"
        navigationController?.pushViewController(destination, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView", for: indexPath)
        footerView.frame.size.height = 124
        
        //only add activity indicator the first time footer view is called and enable pagination from the second time
        guard footerView.subviews.count == 0 else {
            //stop pagination of list of movies is empty
            guard listMovies.count > 0 else {
                return footerView
            }
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
        //add activity indicator for the first time
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = footerView.center
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
        let footerView = collectionView!.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: 0))
        // add no data found label else activity indicator for pagination
        if dictArray.count == 0 {
            if (footerView?.subviews.first as? UIActivityIndicatorView) != nil {
                footerView?.removeAllSubviews()
                let noDataLabel = UILabel()
                noDataLabel.text = "No Data Found!"
                noDataLabel.sizeToFit()
                noDataLabel.center = footerView!.center
                footerView!.addSubview(noDataLabel)
                return
            }
        }
        else {
            for eachMovie in dictArray {
                self.listMovies.append(MovieEntity(eachMovie))
            }
            if (footerView?.subviews.first as? UILabel) != nil {
                footerView?.removeAllSubviews()
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                activityIndicator.center = footerView!.center
                activityIndicator.startAnimating()
                footerView!.addSubview(activityIndicator)
            }
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
        return CGSize(width: collectionView.bounds.width / 2, height: collectionView.bounds.width/2 * (3/2))
        //poster images downloaded are majorly in the aspect ratio 3/2
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

extension UIView {
    func removeAllSubviews() {
        for eachSubview in subviews {
            eachSubview.removeFromSuperview()
        }
    }
}
