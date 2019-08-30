//
//  ViewController.swift
//  Engineer
//
//  Created by Abhishek Dave on 30/08/19.
//  Copyright © 2019 Apple Developer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    var algoliaDataContainer: Algolia = Algolia()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //add rechability watch
        NetworkLayer.shared.handleRechability(reachable: {
            print("Network Reachable")
        }) {
            OperationQueue.main.addOperation {
                let alert = UIAlertController(title: "EngineerAI", message: "Internet connection is not available", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        //tableview loadMore and refresh handlers
        self.tableview.cr.addHeadRefresh {
            OperationQueue.main.addOperation {
                self.tableview.cr.resetNoMore()
            }
            self.loadPosts(pageNumber: 0)
        }
        self.tableview.cr.addFootRefresh {
            self.loadPosts(pageNumber: self.algoliaDataContainer.page+1)
        }
        
        //fertch initial data for screen
        self.tableview.cr.beginHeaderRefresh()
    }
    
    
    
}

//MARK: UITableViewDataSource + UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.algoliaDataContainer.hits.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostCell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        cell.post = self.algoliaDataContainer.hits[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PostCell else {
            return
        }
        cell.toggleCellSelection()
    }
}

//MARK:- PostCellDelegate
extension ViewController: PostCellDelegate {
    func postTableViewCell(cell: PostCell, didUpdatedSelectionFor post: Post) {
        self.updateSelectionCounter()
    }
    func updateSelectionCounter(){
        let selectedPosts = self.algoliaDataContainer.hits.allSelectedValues.count
        self.title = selectedPosts > 0 ? "Selected Post(s) \(selectedPosts)" : ""
    }
}


//MARK:- View level data operations
extension ViewController {
    func loadPosts(pageNumber: Int){
        
        NetworkLayer.shared.loadPosts(pageNumber: pageNumber) { (result) in
            OperationQueue.main.addOperation {
                self.tableview.cr.endHeaderRefresh()
                self.tableview.cr.endLoadingMore()
            }
            
            switch result {
            case .success(let algolia):
                self.handleNetworkLayerData(algolia: algolia, pastPageNumber: pageNumber)
                
            case .failure(let networkLayerError):
                self.handleNetworkLayerError(error: networkLayerError)
            }
        }
    }
    
    func handleNetworkLayerData(algolia: Algolia, pastPageNumber pageNumber: Int){
        if pageNumber == 0 {
            self.algoliaDataContainer = algolia
        }else{
            self.algoliaDataContainer.page = pageNumber
            self.algoliaDataContainer.hits.append(contentsOf: algolia.hits)
        }
        
        print("self.data.nbPages := \(self.algoliaDataContainer.nbPages)")
        print("self.data.page := \(self.algoliaDataContainer.page)")
        if self.algoliaDataContainer.nbPages <= self.algoliaDataContainer.page {
            OperationQueue.main.addOperation {
                self.tableview.cr.noticeNoMoreData()
            }
        }
        
        OperationQueue.main.addOperation {
            OperationQueue.main.addOperation {
                self.updateSelectionCounter()
            }
            self.tableview.reloadData()
        }
    }
    
    func handleNetworkLayerError(error: NetworkLayer.Errors){
        var message : String = ""
        
        switch error {
        case .internetNotAvailable:
            message = "Internet connection is not available"
            
        case .jsonDecode(let error):
            message = "Data is not in correct format, JSON format is expected" + "\n\nDetails :" + error.localizedDescription
            
        case .noData:
            message = "Data not received from server"
            
        case .other(let error):
            message = "Something went wrong, please try again" + "\n\nDetails :" + error.localizedDescription
        }
        
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "EngineerAI", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}




