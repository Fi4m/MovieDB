//
//  MoviePosterCVCell.swift
//  MovieDB
//
//  Created by Vedant Mahant on 09/12/17.
//  Copyright © 2017 Vedant. All rights reserved.
//

import UIKit

class MoviePosterCVCell: UICollectionViewCell {

    @IBOutlet weak var imgMoviePoster: UIImageView!
    var movieEntity: MovieEntity! {
        didSet {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
