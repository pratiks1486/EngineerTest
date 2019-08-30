//
//  NetworkLayer.swift
//  Engineer
//
//  Created by Abhishek Dave on 30/08/19.
//  Copyright © 2019 Apple Developer. All rights reserved.
//

import Foundation



class NetworkLayer {
    enum Errors: Swift.Error {
        case internetNotAvailable
        case jsonDecode(error: Swift.Error)
        case noData
        case other(error: Swift.Error)
    }
    
    static var shared: NetworkLayer = NetworkLayer()
    let reachability = Reachability()
    
    
    deinit {
        reachability?.stopNotifier()
    }
}


//MARK: Handle Rechability
extension NetworkLayer {
    func handleRechability(reachable: @escaping ()->(),
                           unreachable: @escaping ()->()
        ){
        
        reachability?.whenReachable = { reachability in
            reachable()
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability?.whenUnreachable = { _ in
            print("Not reachable")
            unreachable()
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}


//MARK: Load Posts data
extension NetworkLayer {
    func loadPosts(pageNumber: Int,
                   completion: @escaping (Result<Algolia, Errors>) -> Void
        ) {
        
        guard self.reachability?.connection != .none else {
            completion(.failure(Errors.internetNotAvailable))
            return
        }
        
        
        let urlString : String = "https://hn.algolia.com/api/v1/search_by_date?tags=story&page=\(pageNumber)"
        let url = URL(string: urlString)!
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else {
                completion(.failure(Errors.other(error: error!)))
                return
            }
            
            guard let data = data else {
                completion(.failure(Errors.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                let algoliaData = try decoder.decode(Algolia.self, from: data)
                
                completion(.success(algoliaData))
                return
            } catch {
                completion(.failure(Errors.jsonDecode(error: error)))
                return
            }
            
            }.resume()
    }
}
