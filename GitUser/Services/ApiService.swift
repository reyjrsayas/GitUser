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
    case invalidResponse(message:String)
    case noData
    case decodeError
    
    var errorDescription:String? {
        switch self {
        case let .invalidResponse(message: message):
            return message
        default:
            break
        }
        
        return "There is an error occur"
    }
}

public struct User: Codable {
    public let login: String?
    public let id: Int?
    public let node_id: String?
    public let avatar_url: String?
    public let type: String?
    public let site_admin: Bool?
    public var note: String?
    public let followers_url: String?
    public let following_url: String?
    public let name: String?
    public let company: String?
    public let location: String?
    public let blog: String?
    public let bio:String?
    public let followersCount: Int?
    public let followingCount: Int?
    public var avatarImage:Data?
    
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
        case name = "name"
        case company = "company"
        case location = "location"
        case blog = "blog"
        case bio = "bio"
        case avatarImage = "avatarImage"
        case followersCount = "followersCount"
        case followingCount = "followingCount"
    }
}

public enum DispatchPriority {
    case high
    case low
}

public struct UserDetailsResponse: Codable {
    public let data: User
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let user = try container.decode(User.self)
        data = user
    }
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
    
    public func getUserDetails(user:User, dispatchPriority: DispatchPriority, result: @escaping (Result<UserDetailsResponse, APIServiceError>) -> Void) {
        let url = baseURL?.appendingPathComponent("users").appendingPathComponent(user.login!)
        
        fetchDetailsResource(url: url!, queryItems: nil, dispatchQueue: getPriority(dispatchPriority: dispatchPriority)!, completion: result)
    }
    
    public func downloadImage(url:String, dispatch:DispatchPriority, result: @escaping (Result<UIImage, APIServiceError>) -> Void) {
        let _url = URL(string: url)
        
        fetchImage(url: _url!, dispatch: dispatch, dispatchQueue: getPriority(dispatchPriority: dispatch)!, completion: result)
    }
    
    private func fetchImage(url: URL, dispatch:DispatchPriority, dispatchQueue: DispatchQueue, completion: @escaping (Result<UIImage, APIServiceError>) -> Void) {
        // User Semaphore to queue and dispatch all network request one at the time
        let semaphore = DispatchSemaphore(value: 1)
        
        // Begin dispatch
        dispatchQueue.async {
            // Begin and wait
            semaphore.wait()
            
            URLSession.shared.dataTask(with: url) { (result) in
               switch result {
                   case .success(let (response, data)):
                    
                       guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                           completion(.failure(.invalidEndpoint))
                            semaphore.signal()
                           return
                       }
                       
                       let values = UIImage(data: data)
                       completion(.success(values!))
                       // Finished
                       semaphore.signal()
               case .failure( _):
                       completion(.failure(.apiError))
                       semaphore.signal()
                   }
            }.resume()
        }
    }
    
    
    private func getPriority(dispatchPriority: DispatchPriority) -> DispatchQueue? {
        let priority: DispatchQueue?
        
        switch dispatchPriority {
        case .high:
            priority = DispatchQueue.global(qos: .userInitiated)
        default:
            priority = DispatchQueue.global(qos: .userInitiated)
        }
        
        return priority
    }
    
    private func fetchDetailsResource<T: Decodable>(url: URL, queryItems:[URLQueryItem]?, dispatchQueue:DispatchQueue, completion: @escaping (Result<T, APIServiceError>) -> Void) {
        
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
                           let values = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                           
                        completion(.failure(.invalidResponse(message: values!["message"] as! String)))
                            semaphore.signal()
                           return
                       }
                       do {
                        let values = try JSONDecoder().decode(UserDetailsResponse.self, from: data)
                        completion(.success(values as! T))
                        // Finished
                        semaphore.signal()
                       } catch {
                           completion(.failure(.decodeError))
                            semaphore.signal()
                       }
               case .failure( _):
                       completion(.failure(.apiError))
                       semaphore.signal()
                   }
            }.resume()
        }
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
                            let values = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            
                            completion(.failure(.invalidResponse(message: values!["message"] as! String)))
                            semaphore.signal()
                           return
                       }
                       do {
                        let values = try JSONDecoder().decode(UserListResponse.self, from: data)
                        completion(.success(values as! T))
                        // Finished
                        semaphore.signal()
                       } catch {
                           completion(.failure(.decodeError))
                            semaphore.signal()
                       }
               case .failure( _):
                       completion(.failure(.apiError))
                       semaphore.signal()
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
