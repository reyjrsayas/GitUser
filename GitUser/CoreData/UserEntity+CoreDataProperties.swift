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
    @NSManaged public var id: Double
    @NSManaged public var node_id: String?
    @NSManaged public var type: String?
    @NSManaged public var site_admin: Bool
    @NSManaged public var followers_url: String?
    @NSManaged public var following_url: String?
    @NSManaged public var note: String?
    @NSManaged public var avatar_url: String?

}
