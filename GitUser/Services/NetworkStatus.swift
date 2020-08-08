//
//  NetworkStatus.swift
//  GitUser
//
//  Created by Ray Sayas on 8/8/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import Foundation
import Alamofire

class NetworkStatus {
    static let sharedInstace = NetworkStatus()
    
    let reachabilityManager = NetworkReachabilityManager(host: "www.apple.com")
    
    func startNetworkReachabilityObserver () {
        reachabilityManager?.startListening(onUpdatePerforming: { (status) in
            if status == .notReachable {
                print("Internet unavailable")
            } else if status == .reachable(.cellular) || status == .reachable(.ethernetOrWiFi) {
                print("Internet available")
            }
        })
    }
}
