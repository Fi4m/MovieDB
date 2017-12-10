//
//  SortTypeSelectionTVCtrlr.swift
//  MovieDB
//
//  Created by Vedant Mahant on 09/12/17.
//  Copyright © 2017 Vedant. All rights reserved.
//

import UIKit

class SortTypeSelectionTVCtrlr: UIViewController {
    
    var tableView: UITableView!
    
    //Sorting options provided by MovieDB
    private let sortingOptions = ["popularity.desc",
                                  "popularity.asc",
                                  "release_date.desc",
                                  "release_date.asc",
                                  "revenue.desc",
                                  "revenue.asc",
                                  "primary_release_date.desc",
                                  "primary_release_date.asc",
                                  "original_title.desc",
                                  "original_title.asc",
                                  "vote_average.desc",
                                  "vote_average.asc",
                                  "vote_count.desc",
                                  "vote_count.asc"]
    
    //sorting delegate
    var refreshMovieListingDelegate: RefreshMovieListingDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSortingOptionsTableView()
        //popularity.desc is the default sorting method so displaying selected from default
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
    }
    
    func setupSortingOptionsTableView() {
        //260 is the default value of viewController revealed in SWRevealViewController, hence the width 260
        tableView = UITableView(frame: CGRect(x: view.bounds.width - 260, y: 0, width: 260, height: view.bounds.height), style: .plain)
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Sort by..."
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sortingOptions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = sortingOptions[indexPath.row].replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".", with: " ").capitalized
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.revealViewController().revealToggle(animated: true)
        //sorting delegate called
        refreshMovieListingDelegate?.refreshMovieListing(withParameters: ["sort_by":sortingOptions[indexPath.row]])
    }
}
