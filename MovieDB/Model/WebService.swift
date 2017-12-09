//
//  WebService.swift
//  MovieDB
//
//  Created by Vedant Mahant on 09/12/17.
//  Copyright © 2017 Vedant. All rights reserved.
//

import Foundation

typealias CompletionHandler = (_ serviceResponse: [String:Any]?,_ error: Error?) -> Void

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

class WebService {
    
    static let shared = WebService()
    private let baseURL = "https://api.themoviedb.org/3"
    private let session = URLSession(configuration: .default)
    private let apiKey = "08d02e50f177c47452bade3210abd446"
    
    func callAPI(endPoint apiExtension: String, withMethod method: HTTPMethod, forParamters parameters: [String:Any]?, actionWithResponseData completionHandler: @escaping CompletionHandler) {
        var request: URLRequest!
        if method == .post {
            request = URLRequest(url: URL(string: "\(baseURL)\(apiExtension)?api_key=\(apiKey)")!)
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameters!, options: .prettyPrinted)
        }
        else {
            if let params = parameters {
                var urlString = "\(baseURL)\(apiExtension)?api_key=\(apiKey)"
                for eachKey in params.keys {
                    urlString.append("&\(eachKey)=\(params[eachKey] as! String)")
                }
                request = URLRequest(url: URL(string: urlString)!)
            }
            else {
                request = URLRequest(url: URL(string: "\(baseURL)\(apiExtension)?api_key=\(apiKey)")!)
            }
            
        }
        request.httpMethod = method.rawValue
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    return completionHandler(nil, error)
                }
                do {
                    let responseData = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
                    completionHandler(responseData, nil)
                }
                catch {
                    return completionHandler(nil, error)
                }
            }
        }
        dataTask.resume()
    }
}
