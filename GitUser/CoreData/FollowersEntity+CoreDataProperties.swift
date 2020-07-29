//
//  FollowersEntity+CoreDataProperties.swift
//  GitUser
//
//  Created by Rey Sayas on 7/28/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//
//

import Foundation
import CoreData


extension FollowersEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FollowersEntity> {
        return NSFetchRequest<FollowersEntity>(entityName: "FollowersEntity")
    }

    @NSManaged public var id: Double
    @NSManaged public var count: Double

}
