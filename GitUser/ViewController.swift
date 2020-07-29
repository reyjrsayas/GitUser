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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Candies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        users = CoreDataService.sharedInstance.getAllUsers();
        
        if users?.count == 0 {
            ApiService.shared.getUserList(dispatchPriority: .high) { (result) in
                switch result {
                case .success(let response):
                    // Save returned data on Device
                    CoreDataService.sharedInstance.insertUser(users: response.data, withProgress: { (counter, total) in
                        // Do something here
                        print("Counter: \(counter) / Total: \(total)")
                    }) {
                        // Do somethere here when data is finished saving
                        print("Saving users finished")
                        print("=====================")
                        self.users = CoreDataService.sharedInstance.getAllUsers();
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription);
                }
            }
        } else {
            self.tableView.reloadData()
        }
    }

    func loadAllUsers() {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me")
        
        
        let details = UserDetailViewController(nibName: "UserDetailViewController", bundle: nil)
        navigationController?.pushViewController(details, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users!.count
       }
       
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let user = users![indexPath.row];
    cell.textLabel?.text = user.login
       return cell
   }
}

extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
//    let searchBar = searchController.searchBar
    
    self.users = CoreDataService.sharedInstance.searchUser(with: searchController.searchBar.text!);
    self.tableView.reloadData()
    
  }
}


