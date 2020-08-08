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
    
    var users: [User]?
    
    var currentIdx:Int = 0;
    var minPageSize:Int = 100;
    
    private var isLoading: Bool = false;
    let debouncer = Debouncer(timeInterval: 0.3)

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NetworkStatus.sharedInstace.startNetworkReachabilityObserver()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Candies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        users = CoreDataService.sharedInstance.getAllUsers();
        
        if users?.count == 0 {
            loadMoreUser()
        } else {
            currentIdx = users!.count + randomPageSize()
            self.reloadTableViews()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        debouncer.handler = {
            // Send the debounced network request here
            self.users = CoreDataService.sharedInstance.searchUser(with: self.searchController.searchBar.text!);
            self.reloadTableViews()
        }
    }
    
    fileprivate func reloadTableViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    fileprivate func randomPageSize() -> Int{
        return Int.random(in: 0 ... minPageSize)
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
                    self.currentIdx = self.users!.count + self.randomPageSize()
                    self.reloadTableViews()
                    self.isLoading = false;
                }
            case .failure(let error):
                print(error.localizedDescription);
                DispatchQueue.main.async {
                    self.showAlert(message: error.localizedDescription, title: "Error")
                }
            }
        }
    }
    
    func showAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action) in
            self.loadMoreUser(idx: self.currentIdx)
        }))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me")
        
        
        let details = UserDetailViewController(nibName: "UserDetailViewController", bundle: nil)
        let user = users![indexPath.row];
        details.user = user
        details.doneHandler = {
            self.debouncer.renewInterval()
        }
        navigationController?.pushViewController(details, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.searchBar.text!.isEmpty ?  users!.count + 1 : users!.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }
       
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if users!.count > indexPath.row {
            let user = users![indexPath.row];
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell") as? UserTableViewCell
            cell?.setupUser(user, (indexPath.row % 4) == 3)
            return cell!
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
                self.loadMoreUser(idx: currentIdx)
            }
        }
    }
}

extension ViewController: UISearchResultsUpdating {
    
  func updateSearchResults(for searchController: UISearchController) {
//    let searchBar = searchController.searchBar
    debouncer.renewInterval()
  }
}

class Debouncer {
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    typealias Handler = () -> Void
    var handler: Handler?

    private let timeInterval: TimeInterval

    private var timer: Timer?
    func renewInterval() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self] timer in
            self?.handleTimer(timer)
        })
    }

    private func handleTimer(_ timer: Timer) {
        guard timer.isValid else {
            return
        }
        handler?()
    }

}


