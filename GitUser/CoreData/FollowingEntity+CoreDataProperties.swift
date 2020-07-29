//
//  FollowingEntity+CoreDataProperties.swift
//  GitUser
//
//  Created by Rey Sayas on 7/28/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//
//

import Foundation
import CoreData


extension FollowingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FollowingEntity> {
        return NSFetchRequest<FollowingEntity>(entityName: "FollowingEntity")
    }

    @NSManaged public var id: Double
    @NSManaged public var count: Double

}
