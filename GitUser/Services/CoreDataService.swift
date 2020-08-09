//
//  CoreDataService.swift
//  GitUser
//
//  Created by Rey Sayas on 7/28/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataService {
    static let sharedInstance = CoreDataService()
    
    fileprivate var manageContext:NSManagedObjectContext?
    
    func getUser(user:User) -> User? {
        let contex = getManageContext()
        let userEntity: UserEntity!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: contex)
        
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "id == %i", user.id!)
        
        do {
            let result = try contex.fetch(fetchRequest) as! [UserEntity]
            
            if result.count == 0 {
                return nil
            }
            
            userEntity = result.first!
            
            let _user = User(
                login: userEntity.login,
                id: Int(exactly: NSNumber(value: userEntity.id)),
                node_id: userEntity.node_id,
                avatar_url: userEntity.avatar_url,
                type: userEntity.type,
                site_admin: userEntity.site_admin,
                note: userEntity.note,
                followers_url: userEntity.followers_url,
                following_url: userEntity.following_url,
                name: userEntity.name,
                company: userEntity.company,
                location: userEntity.location,
                blog: userEntity.blog,
                bio: userEntity.bio,
                followersCount: Int(exactly: NSNumber(value: userEntity.followersCount)),
                followingCount: Int(exactly: NSNumber(value: userEntity.followingCount)),
                avatarImage: userEntity.avatarImage
            )
            
            return _user
        } catch {
            return nil
        }
    }
    
    func deleteAllUsers(_ complete: @escaping(() -> ())) {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = manageContext?.persistentStoreCoordinator
        
        privateContext.perform {
            let contex = self.getManageContext()
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: contex)
            fetchRequest.entity = entity
            
            do {
                let result = try contex.fetch(fetchRequest) as! [UserEntity]
                
                for user in result {
                    contex.delete(user)
                }
                
                do {
                    try contex.save()
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        complete()
                    }
                } catch {
                    fatalError("Failure to save child context: \(error)")
                }
            } catch {
                fatalError("Failure to fetch the user")
            }
        }
    }
    
    public func updateUserDetails(user:User, complete: @escaping(() -> ())) {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = manageContext?.persistentStoreCoordinator
        privateContext.perform {
            let contex = self.getManageContext()
            let userEntity: UserEntity?
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: contex)
            
            fetchRequest.entity = entity
            fetchRequest.predicate = NSPredicate(format: "id == %i", user.id!)
            
            do {
                let result = try contex.fetch(fetchRequest) as! [UserEntity]
                
                if result.count == 0 {
//                    return false
                }
                
                userEntity = result.first
                
                userEntity?.avatarImage = user.avatarImage
                userEntity?.name = user.name
                userEntity?.company = user.company
                userEntity?.location = user.location
                userEntity?.blog = user.blog
                userEntity?.bio = user.bio
                userEntity?.note = user.note
                userEntity?.followersCount = Int32(exactly: NSNumber(value: user.followersCount ?? 0))!
                userEntity?.followingCount = Int32(exactly: NSNumber(value: user.followingCount ?? 0))!
                
                do {
                    try contex.save()
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        complete()
                    }
                } catch {
                    fatalError("Failure to save child context: \(error)")
                }
                
            } catch {
                fatalError("Failure to fetch the user")
            }
        }
    }
    
    func updateUser(user:User) -> Bool{
        let contex = getManageContext()
        let userEntity: UserEntity?
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: contex)
        
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "id == %i", user.id!)
        
        do {
            let result = try contex.fetch(fetchRequest) as! [UserEntity]
            
            if result.count == 0 {
                return false
            }
            
            userEntity = result.first
            
            userEntity?.avatarImage = user.avatarImage
            userEntity?.name = user.name
            userEntity?.company = user.company
            userEntity?.location = user.location
            userEntity?.blog = user.blog
            userEntity?.bio = user.bio
            userEntity?.note = user.note
            userEntity?.followersCount = Int32(exactly: NSNumber(value: user.followersCount ?? 0))!
            userEntity?.followingCount = Int32(exactly: NSNumber(value: user.followingCount ?? 0))!
            
            do {
                try contex.save()
                return true
            } catch {
                fatalError("Failure to save child context: \(error)")
            }
            
        } catch {
            fatalError("Failure to fetch the user")
        }
        
        return false
    }
    
    func insertUser(users:[User], withProgress: @escaping((_ counter:Int, _ total:Int) -> ()), complete: @escaping(() -> ())) {
        
        let context = getManageContext()
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = context
        
        var count = 0
        childContext.perform {
            for user in users {
                if !self.entityIsExisting(id: user.id!) {
                    let userEntity = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: childContext) as? UserEntity
                    
                    // set values
                    userEntity?.id = Int32(exactly: NSNumber(value: user.id!))!
                    userEntity?.login = user.login ?? ""
                    userEntity?.node_id = user.node_id ?? ""
                    userEntity?.note = user.note ?? ""
                    userEntity?.site_admin = user.site_admin ?? false
                    userEntity?.type = user.type ?? ""
                    userEntity?.avatar_url = user.avatar_url ?? ""
                    userEntity?.name = user.name ?? ""
                    userEntity?.company = user.name ?? ""
                    userEntity?.location = user.location ?? ""
                    userEntity?.blog = user.blog ?? ""
                    userEntity?.bio = user.bio ?? ""
                    userEntity?.followersCount = Int32(exactly: NSNumber(value: user.followersCount ?? 0))!
                    userEntity?.followingCount = Int32(exactly: NSNumber(value: user.followingCount ?? 0))!
                    
                    do {
                        try childContext.save()
                    } catch {
                        fatalError("Failure to save child context: \(error)")
                    }
                } else {
                    // do somethere here when it is already in the database
                }
                count = count + 1
                withProgress(count, users.count)
            }
            
            // Finally save all the child context data to main context
            do {
                try context.save()
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    complete()
                }
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    func searchUser(with keyword:String) -> [User]? {
        let manageContext = getManageContext()
        let userFetch = getUserFetchRequest()
        
        // sort the result by id
        userFetch.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        if keyword.count > 1 {
            userFetch.predicate = NSPredicate(format: "login contains[cd] %@ OR note contains[cd] %@", keyword, keyword)
        }
        
        var users = [User]()
        
        do {
            let fetchUsers = try manageContext.fetch(userFetch) as? [UserEntity]
            
            if fetchUsers?.count == 0  {
                return [User]()
            }
            
            for user in fetchUsers! {
                let user = User(
                    login: user.login,
                    id: Int(exactly: NSNumber(value: user.id)),
                    node_id: user.node_id,
                    avatar_url: user.avatar_url,
                    type: user.type,
                    site_admin: user.site_admin,
                    note: user.note,
                    followers_url: user.followers_url,
                    following_url: user.following_url,
                    name: user.name,
                    company: user.company,
                    location: user.location,
                    blog: user.blog,
                    bio: user.bio,
                    followersCount: Int(exactly: NSNumber(value: user.followersCount)),
                    followingCount: Int(exactly: NSNumber(value: user.followingCount)),
                    avatarImage: user.avatarImage
                )
                
                users.append(user)
            }
            
            return users
        } catch {
            fatalError("Failed to fetch git users: \(error)")
        }
    }
    
    fileprivate func getUserFetchRequest() -> NSFetchRequest<NSFetchRequestResult>{
        return NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
    }
    
    func getAllUsers() -> [User]? {
        let manageContext = getManageContext()
        
        let userFetch = getUserFetchRequest()
//        
        var users = [User]()
        
        // sort the result by id
        userFetch.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        do {
            let fetchUsers = try manageContext.fetch(userFetch) as? [UserEntity]
            
            if fetchUsers?.count == 0  {
                return [User]()
            }
            
            
            for user in fetchUsers! {
                let _user = User(
                    login: user.login,
                    id: Int(exactly: NSNumber(value: user.id)),
                    node_id: user.node_id,
                    avatar_url: user.avatar_url,
                    type: user.type,
                    site_admin: user.site_admin,
                    note: user.note,
                    followers_url: user.followers_url,
                    following_url: user.following_url,
                    name: user.name,
                    company: user.company,
                    location: user.location,
                    blog: user.blog,
                    bio: user.bio,
                    followersCount: Int(exactly: NSNumber(value: user.followersCount)),
                    followingCount: Int(exactly: NSNumber(value: user.followingCount)),
                    avatarImage: user.avatarImage
                )
                
                users.append(_user)
            }
            
            return users
        } catch {
            fatalError("Failed to fetch git users: \(error)")
            return []
        }
    }
    
    func entityIsExisting(id:Int) -> Bool {
        let context = getManageContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: context)
        
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "id == %i", id)
        
        do {
            let result = try context.fetch(fetchRequest) as! [UserEntity]
            
            if (result.count) > 0 {
                return true
            }
        } catch {
            
        }
        
        return false
    }
    
    fileprivate func getManageContext() -> NSManagedObjectContext{
        
        if manageContext != nil {
            return manageContext!
        }
        
        manageContext = persistentContainer.viewContext
        return manageContext!
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GitUser")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
