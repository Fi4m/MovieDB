//
//  MovieDetailsVC.swift
//  MovieDB
//
//  Created by Vedant Mahant on 09/12/17.
//  Copyright © 2017 Vedant. All rights reserved.
//

import UIKit
import HCSStarRatingView

class MovieDetailsVC: UIViewController {
    
    let movieEntity: MovieEntity
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgMoviePoster: UIImageView!
    @IBOutlet weak var lblMovieTitle: UILabel!
    @IBOutlet weak var lblMovieDescription: UILabel!
    @IBOutlet weak var viewMovieRating: HCSStarRatingView!
    
    init(_ movie: MovieEntity) {
        movieEntity = movie
        super.init(nibName: "MovieDetailsVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imgBackground.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500/\(movieEntity.imgPosterURL)")!)
        imgMoviePoster.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500/\(movieEntity.imgBackdrop)")!, placeholder: #imageLiteral(resourceName: "NoImageFound"), options: nil, progressBlock: nil, completionHandler: nil)
        
        let attributedTitle = NSMutableAttributedString(string: movieEntity.title, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20)])
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        if let date = movieEntity.releaseDate  {
            attributedTitle.append(NSAttributedString(string: "\n\(dateFormatter.string(from: date))", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        }
        lblMovieTitle.attributedText = attributedTitle
        
        // display overview if present otherwise display placeholder
        lblMovieDescription.text = movieEntity.description.isEmpty ? "No overview found." : movieEntity.description
        
        //view movie rating
        viewMovieRating.value = CGFloat(movieEntity.userRating)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}
