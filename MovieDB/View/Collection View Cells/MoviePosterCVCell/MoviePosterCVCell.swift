//
//  MoviePosterCVCell.swift
//  MovieDB
//
//  Created by Vedant Mahant on 09/12/17.
//  Copyright © 2017 Vedant. All rights reserved.
//

import UIKit
import Kingfisher

class MoviePosterCVCell: UICollectionViewCell {

    @IBOutlet weak var imgMoviePoster: UIImageView!
    var movieEntity: MovieEntity! {
        didSet {
            if let imageURL = movieEntity.imgPosterURL {
                imgMoviePoster.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500/\(imageURL)")!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
