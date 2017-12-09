//
//  SortTypeSelectionTVCtrlr.swift
//  MovieDB
//
//  Created by Vedant Mahant on 09/12/17.
//  Copyright © 2017 Vedant. All rights reserved.
//

import UIKit

class SortTypeSelectionTVCtrlr: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    private let dict = ["popularity.asc",
                        "popularity.desc",
                        "release_date.asc",
                        "release_date.desc",
                        "revenue.asc",
                        "revenue.desc",
                        "primary_release_date.asc",
                        "primary_release_date.desc",
                        "original_title.asc",
                        "original_title.desc",
                        "vote_average.asc",
                        "vote_average.desc",
                        "vote_count.asc",
                        "vote_count.desc"]
    var refreshMovieListingDelegate: RefreshMovieListingDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: CGRect(x: view.frame.width - 260, y: 0, width: 260, height: view.frame.height), style: .plain)
        tableView.autoresizingMask = [.flexibleLeftMargin,.flexibleHeight]
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SortTypeSelectionTVCtrlr: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dict.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = dict[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.revealViewController().revealToggle(animated: true)
        refreshMovieListingDelegate?.callListOfMovies(withParameters: ["sort_by":dict[indexPath.row],
                                                                       "page":nil])
    }
}
