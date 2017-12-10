//
//  MovieEntity.swift
//  MovieDB
//
//  Created by Vedant Mahant on 09/12/17.
//  Copyright © 2017 Vedant. All rights reserved.
//

import Foundation

//no need of protocol as only one data object required for assessment
//protocol DataObjectsInitializer {
//    init(_ dict: [String:Any])
//}

struct MovieEntity {//: DataObjectsInitializer {
    
    let title: String
    let description: String
    let imgPosterURL: String
    let imgBackdrop: String
    let userRating: Double
    let releaseDate: Date?
    
    init(_ dict: [String:Any]) {
        title = dict["original_title"] as! String
        description = dict["overview"] as! String
        imgPosterURL = dict["poster_path"] as? String ?? ""
        imgBackdrop = dict["backdrop_path"] as? String ?? ""
        userRating = dict["vote_average"] as! Double
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        releaseDate = dateFormatter.date(from: dict["release_date"] as! String)
    }
    
}
