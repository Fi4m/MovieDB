//
//  MoviePosterListingCVCtrlr.swift
//  MovieDB
//
//  Created by Vedant Mahant on 09/12/17.
//  Copyright © 2017 Vedant. All rights reserved.
//

import UIKit
import SWRevealViewController

protocol RefreshMovieListingDelegate {
    func callListOfMovies(withParameters params: [String:Any?])
}

class MoviePosterListingCVCtrlr: UICollectionViewController {
    
    var listMovies = [MovieEntity]()
    var parameters = [String:Any]()
    var txtSearch: UITextField!
    var retainedTitleView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MovieDB"
        retainedTitleView = navigationItem.titleView
        navigationItem.hidesSearchBarWhenScrolling = true
//        navigationItem.searchController = UISearchController()
        // Register cell classes
        self.collectionView!.register(UINib(nibName: "MoviePosterCVCell", bundle: nil), forCellWithReuseIdentifier: "MoviePosterCVCell")

        // Do any additional setup after loading the view.
        setupNavigationItem()
        
        callListOfMovies(withParameters: parameters)
    }
    
    func setupNavigationItem() {
        let barBtnReveal = UIBarButtonItem(image: #imageLiteral(resourceName: "sort-descending"), style: .plain, target: self.revealViewController(), action: #selector(self.revealViewController().rightRevealToggle(_:)))
        navigationItem.rightBarButtonItem = barBtnReveal
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        txtSearch = UITextField(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        txtSearch.borderStyle = .roundedRect
        txtSearch.backgroundColor = .white
        txtSearch.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        txtSearch.placeholder = "Search..."
        setupSearchBar()
    }
    
    func setupSearchBar() {
        let barBtnSearch = UIBarButtonItem(image: #imageLiteral(resourceName: "search"), style: .plain, target: self, action: #selector(toggleTextField(_:)))
        navigationItem.rightBarButtonItems?.append(barBtnSearch)
    }
    
    @objc
    func toggleTextField(_ sender: UIBarButtonItem) {
        if sender.image == #imageLiteral(resourceName: "search") {
            navigationItem.titleView = txtSearch
            sender.image = #imageLiteral(resourceName: "cancel-music")
        }
        else {
            navigationItem.titleView = retainedTitleView
            sender.image = #imageLiteral(resourceName: "search")
            parameters["page"] = nil
            callListOfMovies(withParameters: parameters)
        }
    }
    
    @objc
    func textDidChange(_ sender: UITextField) {
        guard sender.text!.count > 0 else {
            callListOfMovies(withParameters: parameters)
            return
        }
        let params: [String:Any] = ["page":1,
                                  "query":sender.text!]
        WebService.shared.callAPI(endPoint: "/search/movie", withMethod: .get, forParamters: params) { (serviceResponse) in
            self.listMovies = [MovieEntity]()
            for eachMovie in serviceResponse["results"] as! [[String:Any]] {
                self.listMovies.append(MovieEntity(eachMovie))
            }
            self.collectionView?.reloadData()
        }
        
    }


    override
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listMovies.count
    }

    override
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCVCell", for: indexPath) as! MoviePosterCVCell
        cell.movieEntity = listMovies[indexPath.row]
        guard indexPath.row != listMovies.count - 1 else {
            if let page = parameters["page"] as? Int {
                parameters["page"] = page + 1
            }
            else {
                parameters["page"] = 2
            }
            callListOfMovies(withParameters: parameters)
            return cell
        }
        return cell
    }
    
    override
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destination = MovieDetailsVC(listMovies[indexPath.row])
        navigationController?.pushViewController(destination, animated: true)
    }
}


extension MoviePosterListingCVCtrlr: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2, height: collectionView.frame.width * 16 / 18)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension MoviePosterListingCVCtrlr: RefreshMovieListingDelegate {
    func callListOfMovies(withParameters params: [String:Any?]) {
        for eachKey in params.keys {
            parameters[eachKey] = params[eachKey] ?? nil
        }
        WebService.shared.callAPI(endPoint: "/discover/movie", withMethod: .get, forParamters: parameters) { (serviceResponse) in
            if self.parameters["page"] as? Int == nil {
                self.listMovies = [MovieEntity]()
            }
            for eachMovie in serviceResponse["results"] as! [[String:Any]] {
                self.listMovies.append(MovieEntity(eachMovie))
            }
            self.collectionView?.reloadData()
        }
    }
}
