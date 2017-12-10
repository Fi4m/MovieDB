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
    @IBOutlet weak var lblMovieTitle: UILabel!
    var movieEntity: MovieEntity! {
        didSet {
            self.lblMovieTitle.text = self.movieEntity.title
            imgMoviePoster.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500/\(movieEntity.imgPosterURL)")!, placeholder: #imageLiteral(resourceName: "NoImageAvailable"), options: nil, progressBlock: nil) { (image, _, _, _) in
                guard image != nil else {
                    self.lblMovieTitle.isHidden = false
                    return
                }
                self.lblMovieTitle.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
