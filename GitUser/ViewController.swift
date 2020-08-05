//
//  ViewController.swift
//  GitUser
//
//  Created by Rey Sayas on 7/27/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var users: [User]?
    
    var currentIdx:Int = 0;
    var minPageSize:Int = 30;
    
    private var isLoading: Bool = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Candies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        users = CoreDataService.sharedInstance.getAllUsers();
        
        if users?.count == 0 {
            loadMoreUser()
        } else {
            currentIdx = users!.count
            self.tableView.reloadData()
        }
    }

    func loadMoreUser(idx: Int = 0) {
        self.isLoading = true;
        ApiService.shared.getUserList(index: idx, dispatchPriority: .high) { (result) in
            switch result {
            case .success(let response):
                // Save returned data on Device
                CoreDataService.sharedInstance.insertUser(users: response.data, withProgress: { (counter, total) in
                    // Do something here
                    print("Counter: \(counter) / Total: \(total)")
                    
                }) {
                    // Do somethere here when data is finished saving
                    self.users = CoreDataService.sharedInstance.getAllUsers();
                    self.currentIdx = self.users!.count + 1
                    self.tableView.reloadData()
                    self.isLoading = false;
                }
            case .failure(let error):
                print(error.localizedDescription);
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me")
        
        
        let details = UserDetailViewController(nibName: "UserDetailViewController", bundle: nil)
        let user = users![indexPath.row];
        details.user = user
        navigationController?.pushViewController(details, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users!.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }
       
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserTableViewCell
        
        let user = users![indexPath.row];
        cell?.setupUser(user, (indexPath.row % 4) == 3)
        
        return cell!
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.size.height {
            if !self.isLoading {
                self.loadMoreUser(idx: currentIdx)
            }
        }
    }
}

extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
//    let searchBar = searchController.searchBar
    
    self.users = CoreDataService.sharedInstance.searchUser(with: searchController.searchBar.text!);
    self.tableView.reloadData()
    
  }
}


