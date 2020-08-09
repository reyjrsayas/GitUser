//
//  ViewController.swift
//  GitUser
//
//  Created by Rey Sayas on 7/27/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    func startNetworkReachabilityObserver() {
        reachabilityManager?.startListening(onUpdatePerforming: { status in

            switch status {
                            case .notReachable:
                                print("The network is not reachable")
                            case .unknown :
                                print("It is unknown whether the network is reachable")
                            case .reachable(.ethernetOrWiFi):
                                print("The network is reachable over the WiFi connection")
                            case .reachable(.cellular):
                                print("The network is reachable over the cellular connection")
                      }
        })
    }
}

class ViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var cells: [DynamicTVCRow]? = []
    
    var currentIdx:Int = 0;
    var minPageSize:Int = 100;
    
    private var isLoading: Bool = false;
    let debouncer = Debouncer(timeInterval: 0.3)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registetCellNibs()
        self.initSearchController()
        self.initDebouncerHandler()
        self.initDataDisplay()
    }
    
    fileprivate func initDataDisplay() {
        self.buildTableCell(users: CoreDataService.sharedInstance.getAllUsers())
        
        if cells?.count == 0 {
            loadMoreUser()
        } else {
            self.isLoading = true;
            currentIdx = cells!.count + randomPageSize()
            self.reloadTableViews()
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
                    self.buildTableCell(users: CoreDataService.sharedInstance.getAllUsers()!)
                    self.currentIdx = self.cells!.count + self.randomPageSize()
                    self.reloadTableViews()
                    self.isLoading = false;
                }
            case .failure(let error):
//                print(error.errorDescription);
                DispatchQueue.main.async {
                    self.showAlert(message: error.errorDescription!, title: "Error")
                }
            }
        }
    }
    
    func showAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
//        alert.addAction(UIAlertAction(title: "Try again later", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action) in
            self.loadMoreUser(idx: self.currentIdx)
        }))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showUserDetails(user:User) {
        let details = UserDetailViewController(nibName: "UserDetailViewController", bundle: nil)
        details.user = user
        details.doneHandler = { isDone in
            if isDone {
                self.debouncer.renewInterval()
            }
        }
        navigationController?.pushViewController(details, animated: true)
    }
    
    fileprivate func initDebouncerHandler() {
        debouncer.handler = {
            // Send the debounced network request here
            self.buildTableCell(users: CoreDataService.sharedInstance.searchUser(with: self.searchController.searchBar.text!)!)
            self.reloadTableViews()
        }
    }
    
    fileprivate func initSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Candies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    fileprivate func reloadTableViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.isLoading = false
        }
    }
    
    fileprivate func randomPageSize() -> Int{
        return Int.random(in: 0 ... minPageSize)
    }
}

// TableView Datasource & Delegate
extension ViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = cells![indexPath.row]
        cell.selectRow()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.searchBar.text!.isEmpty ?  cells!.count + 1 : cells!.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }
       
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cells!.count > indexPath.row {
            let cell = cells![indexPath.row].getCellFor(tableView, indexPath: indexPath);
            return cell
        } else {
            let loadingCell = LoadingTableViewCell.instanceFromNib()
            return loadingCell
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.size.height {
            if !self.isLoading {
                if !searchController.searchBar.text!.isEmpty { return }
                self.loadMoreUser(idx: currentIdx)
            }
        }
    }
}

// UISeachController delegate
extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    if searchController.searchBar.text!.isEmpty { return }
    debouncer.renewInterval()
  }
}

extension ViewController {
    fileprivate func registetCellNibs() {
        self.tableView.register(UINib(nibName: "UserNormalCell", bundle: nil), forCellReuseIdentifier: String(describing: UserNormalCell.self))
        self.tableView.register(UINib(nibName: "UserNoteCell", bundle: nil), forCellReuseIdentifier: String(describing: UserNoteCell.self))
        self.tableView.register(UINib(nibName: "UserInvertAvatarCell", bundle: nil), forCellReuseIdentifier: String(describing: UserInvertAvatarCell.self))
        self.tableView.register(UINib(nibName: "UserInvertAvatarAndNoteCell", bundle: nil), forCellReuseIdentifier: String(describing: UserInvertAvatarAndNoteCell.self))
    }
    
    fileprivate func buildTableCell(users: [User]?) {
        self.cells = []
        for (index, user) in users!.enumerated() {
            
            // if user if 4th in the list invert image
            if (index % 4) == 3 {
                if user.note != nil {
                    if user.note!.isEmpty {
                        let cell = UserInvertAvatarCellWrapper(user: user) { (user) in
                            self.showUserDetails(user: user)
                        }
                        self.cells?.append(cell)
                    } else {
                        let cell = UserInverAvatarAndNoteCellWrapper(user: user) { (user) in
                            self.showUserDetails(user: user)
                        }
                        self.cells?.append(cell)
                    }
                } else {
                    let cell = UserInvertAvatarCellWrapper(user: user) { (user) in
                        self.showUserDetails(user: user)
                    }
                    self.cells?.append(cell)
                }
                
            } else {
                if user.note != nil {
                    if user.note!.isEmpty {
                        let cell = UserNormalCellWrapper(user: user) { (user) in
                            self.showUserDetails(user: user)
                        }
                        self.cells?.append(cell)
                    } else {
                        let cell = UserNoteCellWrapper(user: user) { (user) in
                            self.showUserDetails(user: user)
                        }
                        self.cells?.append(cell)
                    }
                } else {
                    let cell = UserNormalCellWrapper(user: user) { (user) in
                        self.showUserDetails(user: user)
                    }
                    self.cells?.append(cell)
                }
            }
        }
    }
}


