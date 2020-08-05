//
//  UserEntity+CoreDataProperties.swift
//  GitUser
//
//  Created by Rey Sayas on 7/28/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var login: String?
    @NSManaged public var id: Int32
    @NSManaged public var node_id: String?
    @NSManaged public var type: String?
    @NSManaged public var site_admin: Bool
    @NSManaged public var followers_url: String?
    @NSManaged public var following_url: String?
    @NSManaged public var note: String?
    @NSManaged public var avatar_url: String?
    @NSManaged public var name: String?
    @NSManaged public var company: String?
    @NSManaged public var location: String?
    @NSManaged public var blog: String?
    @NSManaged public var bio: String?
    @NSManaged public var followingCount: Int32
    @NSManaged public var followersCount: Int32
    @NSManaged public var avatarImage: Data?

}
