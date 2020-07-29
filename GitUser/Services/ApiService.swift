//
//  ApiService.swift
//  GitUser
//
//  Created by Rey Sayas on 7/27/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

public enum ApiType:Int {
    case userList = 0
    case userDetail = 1
}

public enum APIServiceError: Error {
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case decodeError
}

public struct User: Codable {
    public let login: String?
    public let id: Int?
    public let node_id: String?
    public let avatar_url: String?
    public let type: String?
    public let site_admin: Bool?
    public let note: String?
//    public let followers: [User]?
//    public let followings: [User]?
    public let followers_url: String?
    public let following_url: String?
    
    private enum CodingKeys: String, CodingKey {
        case login = "login"
        case id = "id"
        case node_id = "node_id"
        case avatar_url = "avatar_url"
        case type = "type"
        case site_admin = "site_admin"
        case note = "note"
        case followers_url = "followers_url"
        case following_url = "following_url"
    }
}

public enum DispatchPriority {
    case high
    case low
}

public struct UserListResponse: Codable {
    public let data: [User]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // parse JSON result
        // [{..},{..}]
        let users = try container.decode([User].self)
        data = users
    }
}

class ApiService {
    
    public static let shared = ApiService()
    
    // https://api.github.com/users?since= -- for user list
    // https://api.github.com/users/[username] -- for user details
    let baseURL = URL(string: "https://api.github.com/");
    
    // semaphore of queueing all request
    let semaphore = DispatchSemaphore(value: 1)
    
    let jsonDecoder: JSONDecoder = {
       let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .useDefaultKeys
       return jsonDecoder
    }()
    
    
    public func getUserList(index: Int = 0, dispatchPriority: DispatchPriority, result: @escaping (Result<UserListResponse, APIServiceError>) -> Void) {
        let url = baseURL?.appendingPathComponent("users")
        let queryItems = [URLQueryItem(name: "since", value: String(index))]
        
        
        fetchResource(url: url!, queryItems: queryItems, dispatchQueue: getPriority(dispatchPriority: dispatchPriority)!, completion: result)
    }
    
    
    private func getPriority(dispatchPriority: DispatchPriority) -> DispatchQueue? {
        let priority: DispatchQueue?
        
        switch dispatchPriority {
        case .high:
            priority = DispatchQueue.global(qos: .userInitiated)
        default:
            priority = DispatchQueue.global(qos: .utility)
        }
        
        return priority
    }
    
    private func fetchResource<T: Decodable>(url: URL, queryItems:[URLQueryItem]?, dispatchQueue:DispatchQueue, completion: @escaping (Result<T, APIServiceError>) -> Void) {
        
        // User Semaphore to queue and dispatch all network request one at the time
        let semaphore = DispatchSemaphore(value: 1)
        
        // Begin dispatch
        dispatchQueue.async {
            // Begin and wait
            semaphore.wait()
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                completion(.failure(.invalidEndpoint))
                return
            }
            
            if queryItems != nil {
                urlComponents.queryItems = queryItems
            }
            
            guard let url = urlComponents.url else {
                completion(.failure(.invalidEndpoint))
                return
            }
            
            URLSession.shared.dataTask(with: url) { (result) in
               switch result {
                   case .success(let (response, data)):
                    
                       guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                           completion(.failure(.invalidResponse))
                           return
                       }
                       do {
                        let values = try JSONDecoder().decode(UserListResponse.self, from: data)
                        completion(.success(values as! T))
                        // Finished
                        semaphore.signal()
                       } catch {
                           completion(.failure(.decodeError))
                       }
               case .failure( _):
                       completion(.failure(.apiError))
                   }
            }.resume()
        }
    }
}


extension URLSession {
    func dataTask(with url:URL, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: url) { (data, response, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            
            result(.success((response, data)))
        }
    }
}
