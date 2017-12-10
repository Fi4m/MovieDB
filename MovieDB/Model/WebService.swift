//
//  WebService.swift
//  MovieDB
//
//  Created by Vedant Mahant on 09/12/17.
//  Copyright © 2017 Vedant. All rights reserved.
//

import UIKit
import SystemConfiguration
import MBProgressHUD

typealias CompletionHandler = (_ serviceResponse: [String:Any]) -> Void

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum Endpoint: String {
    case discover = "/discover/movie"
    case search = "/search/movie"
}

class WebService {
    
    //singleton for webservice calls
    static let shared = WebService()
    
    //base URL for MovieDB
    private let baseURL = "https://api.themoviedb.org/3"
    private let session = URLSession(configuration: .default)
    
    //apiKey required for MovieDB data access
    private let apiKey = "08d02e50f177c47452bade3210abd446"
    
    //activity indicator for service calls and block UI for user
    fileprivate var progressHUD: MBProgressHUD!
    
    func callAPI(endPoint api: Endpoint, withMethod method: HTTPMethod, forParamters parameters: [String:Any], actionWithResponseData completionHandler: @escaping CompletionHandler) {
        
        guard checkForNetworkConnectivity() else {
            MovieDBAlertController.shared.presentAlertController(title: "Connection Problem", message: "Please check your internet connection !", completionHandler: nil)
            return
        }
        var request: URLRequest!
        if method == .post {
            showHUD()
            request = URLRequest(url: URL(string: "\(baseURL)\(api.rawValue)?api_key=\(apiKey)")!)
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }
        else {
            // check for pagination so that the UI does not get blocked
            if parameters["page"] != nil {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            else {
                showHUD()
            }
            var urlString = "\(baseURL)\(api.rawValue)?api_key=\(apiKey)"
            for eachKey in parameters.keys {
                urlString.append("&\(eachKey)=\(parameters[eachKey]!)")
            }
            request = URLRequest(url: URL(string: urlString.replacingOccurrences(of: " ", with: "%20"))!)
            
        }
        request.httpMethod = method.rawValue
        
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                self.progressHUD.hide(animated: true)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    MovieDBAlertController.shared.presentAlertController(title: "MovieDB", message: error!.localizedDescription, completionHandler: nil)
                    return
                }
                do {
                    
                    let responseData = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
                    print(responseData)
                    print((response as! HTTPURLResponse).allHeaderFields.keys)
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        completionHandler(responseData)
                    }
                    else {
                        MovieDBAlertController.shared.presentAlertController(title: "MovieDB", message: responseData["status_message"] as! String, completionHandler: nil)
                    }
                    
                }
                catch {
                    MovieDBAlertController.shared.presentAlertController(title: "MovieDB", message: error.localizedDescription, completionHandler: nil)
                }
            }
        }
        dataTask.resume()
    }
}
extension WebService {
    
    // possible states for internet access
    private enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    private var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
    // check for internet access
    fileprivate func checkForNetworkConnectivity() -> Bool {
        guard self.currentReachabilityStatus != .notReachable else {
            return false
        }
        return true
    }
    
    fileprivate func showHUD() {
        progressHUD = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!.rootViewController!.view, animated: true)
    }
}

//MARK: singleton for error displaying through alerts
class MovieDBAlertController: UIAlertController {
    
    static let shared = MovieDBAlertController(title: "ALIST", message: nil, preferredStyle: .alert)
    var actionAfterDismiss: (()->Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            guard self.actionAfterDismiss != nil else {
                return
            }
            self.actionAfterDismiss()
        }
        addAction(okAction)
    }
    
    func presentAlertController(title: String = "ALIST", message: String, completionHandler: (()->Void)?) {
        self.title = title
        self.message = message
        actionAfterDismiss = completionHandler
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
    }
    
}
